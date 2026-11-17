// SPDX-License-Identifier: AGPL-3.0-only

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/document_source.dart';
import '../core/notifier.dart';
import '../core/photo_source.dart';
import '../core/store.dart';
import '../data/database.dart';
import '../data/repository.dart';
import '../domain/day.dart';
import '../domain/photos.dart';
import '../domain/reminders.dart';
import '../domain/templates.dart';
import '../l10n/app_localizations.dart';
import '../sync/engine.dart';
import '../sync/files.dart';
import '../sync/mode.dart';
import '../sync/server_address.dart';
import '../sync/server_connection.dart';
import '../sync/server_http.dart';
import '../sync/server_http_io.dart';
import '../sync/server_sign_in.dart';
import '../sync/server_transport.dart';
import '../sync/transport.dart';

/// Re-encodes a photo off the main isolate (a photo of 12 megapixels takes a
/// second or two); tests give [processPhoto] itself.
typedef PhotoProcessor = Future<ProcessedPhoto> Function(Uint8List bytes);

Future<ProcessedPhoto> processInIsolate(Uint8List bytes) =>
    compute(processPhoto, bytes);

/// The thumbnail of a photo fetched from the server, made in an isolate.
Future<Uint8List?> thumbnailInIsolate(Uint8List bytes) =>
    compute(makeThumbnail, bytes);

/// Opens an address in the app of the phone that handles it (a web page in
/// the browser, `tel:` in the dialler, `mailto:` in the mail app); `false`
/// when none does. Nothing is fetched by Housecairn itself.
typedef UrlOpener = Future<bool> Function(Uri address);

Future<bool> openInSystem(Uri address) async {
  try {
    return await launchUrl(address, mode: LaunchMode.externalApplication);
  } on PlatformException {
    return false;
  }
}

/// Gives a file of the phone to another app that opens it (a PDF viewer, the
/// Files app, Photos), through the share sheet of the system: the only way
/// both systems open a file of an app's own directory. [origin] is where the
/// sheet points from on a tablet. `false` when nothing took it.
typedef FileOpener = Future<bool> Function(
  String path, {
  required String name,
  required String type,
  Rect? origin,
});

Future<bool> shareWithSystem(
  String path, {
  required String name,
  required String type,
  Rect? origin,
}) async {
  try {
    final result = await SharePlus.instance.share(
      ShareParams(
        files: [XFile(path, name: name, mimeType: type)],
        fileNameOverrides: [name],
        sharePositionOrigin: origin,
      ),
    );
    return result.status != ShareResultStatus.unavailable;
  } on PlatformException {
    return false;
  }
}

/// Reads the library of task templates shipped with the app.
Future<TemplateLibrary> loadBundledTemplates() async =>
    parseTemplates(await rootBundle.loadString('assets/task_templates.yaml'));

/// The homes of the phone as the screens see them: every home, the active
/// ones, the current one, and whether Today shows all of them
/// (docs/spec.md, "Homes"). Screens read it through [AppScope] and write
/// through [repository], then call [refresh].
///
/// It also holds what the screens of lot 2b use from the phone: where a photo
/// comes from, the local notifications, the task templates.
class AppState extends ChangeNotifier {
  AppState(
    this.repository, {
    this.photoSource,
    this.documentSource,
    this.notifier,
    this.photoProcessor = processInIsolate,
    this.thumbnailer = thumbnailInIsolate,
    this.loadTemplates = loadBundledTemplates,
    this.openUrl = openInSystem,
    this.openFile = shareWithSystem,
    this.store,
    this.serverHttp = IoServerHttp.new,
    this.signInCallbacks,
    this.syncDelay = const Duration(seconds: 2),
  });

  final Repository repository;

  /// The camera and the gallery; `null` where there are none (tests).
  final PhotoSource? photoSource;

  /// The Files app (iOS) or the document picker (Android), for the file of a
  /// quote; `null` where there are none (tests).
  final DocumentSource? documentSource;

  /// The local notifications; `null` where there are none (tests).
  final Notifier? notifier;
  final PhotoProcessor photoProcessor;

  /// Makes the thumbnail of a photo fetched from the server.
  final Thumbnailer thumbnailer;
  final Future<TemplateLibrary> Function() loadTemplates;
  final UrlOpener openUrl;

  /// Opens a file attached to a task in another app (lot 4d).
  final FileOpener openFile;

  /// The secrets at rest (the Keychain or the Android Keystore): the access
  /// to a server in the third way; `null` where there is none (tests that
  /// never connect).
  final Store? store;

  /// The connection to the address typed, in the third way.
  final ServerHttp Function(ServerAddress address) serverHttp;

  /// The redirects of the browser back to the app; the app's
  /// [SignInCallbacks] when `null`.
  final Stream<Uri>? signInCallbacks;

  /// Whether the data was read once; until then the app shows nothing.
  bool loaded = false;

  /// The way the phone is used (docs/adr/0010): alone when none is stored.
  SyncMode syncMode = SyncMode.alone;

  /// The first start: no way chosen and no home, so the app asks how it is
  /// to be used before it makes the first home. A phone with homes and no
  /// way (a build of lot 2) is alone and never asked.
  bool firstStart = false;

  List<HomeRow> homes = const [];
  HomeRow? current;
  bool todayAllHomes = false;

  /// Whether the person turned reminders on, and the phone still allows them.
  bool remindersOn = false;

  /// The words of the notifications, set by the app once the language is
  /// known and again when it changes.
  AppLocalizations? l10n;

  /// Grows on every change, so that a screen knows its data is stale.
  int revision = 0;

  List<HomeRow> get activeHomes =>
      homes.where((h) => h.archivedAt == null).toList();

  /// The selector is shown from two active homes on (`homes/current.py:31-32`).
  bool get showsSelector => activeHomes.length >= 2;

  /// Reads the homes again. With no way chosen and no home it is the first
  /// start: [firstStart] is set and nothing is made until [startAlone]; with
  /// a way chosen and no home, the first home is made. Reminders are planned
  /// again from the data as it is now.
  Future<void> refresh({String? firstHomeName}) async {
    final stored = await repository.storedSyncMode();
    final empty = (await repository.homes()).isEmpty;
    firstStart = stored == null && empty;
    if (firstHomeName != null && stored != null && empty) {
      await repository.createHome(name: firstHomeName);
    }
    syncMode = stored ?? SyncMode.alone;
    serverAddressShown = syncMode == SyncMode.server
        ? (await serverAddress())?.display
        : null;
    loaded = true;
    homes = await repository.homes();
    current = await repository.currentHome();
    todayAllHomes = await repository.todayShowsAllHomes();
    serverSync.refused = await repository.refusedChanges();
    _watchLocalWrites();
    remindersOn = await _remindersStillAllowed();
    revision++;
    notifyListeners();
    await reschedule();
  }

  /// The first start, "Alone on this phone": stores the way, then makes the
  /// first home, named [firstHomeName].
  Future<void> startAlone(String firstHomeName) async {
    await repository.setSyncMode(SyncMode.alone);
    await refresh(firstHomeName: firstHomeName);
  }

  // ---------- the third way: a Housecairn server (lot 4b) ----------

  Store get _store =>
      store ?? (throw StateError('No secure store on this build.'));

  ServerTransport _transport(ServerAddress address, {Store? store}) =>
      ServerTransport(
        address: address,
        http: serverHttp(address),
        store: store ?? _store,
        state: repository.serverState,
        device: repository.deviceB64,
        schemaVersion: repository.schemaVersion,
        seenStore: repository.serverSeen,
      );

  /// Signs in to [address] in the system browser (OAuth 2 with PKCE); the
  /// access is then in [store], nothing of the homes was sent or received.
  Future<void> signInToServer(ServerAddress address) => ServerConnector(
    http: serverHttp,
    store: _store,
    openBrowser: openUrl,
    deviceName: l10n?.serverDeviceName ?? 'Housecairn',
    callbacks: signInCallbacks,
  ).signIn(address);

  /// The homes the access chosen in the browser covers, and their members.
  Future<List<ServerHome>> serverHomesOffered(ServerAddress address) async {
    final transport = _transport(address);
    await transport.capabilities();
    return transport.homes();
  }

  /// Forgets an access signed in but not confirmed: revoked on the server
  /// when it answers, deleted from [store] whatever happens.
  Future<void> forgetServer(ServerAddress address) =>
      _transport(address).disconnect();

  /// The confirmation of the third way at the first start: the phone has no
  /// home, so it keeps the server's (docs/adr/0010, "Moving from one way to
  /// another"): the way and the address are stored, then the first sync
  /// brings the homes of the access.
  Future<void> startServer(ServerAddress address) async {
    await repository.setServerAddress(address.display);
    await repository.setSyncMode(SyncMode.server);
    await syncWithServer(throwing: true);
  }

  /// The address of the server in use, in the third way.
  Future<ServerAddress?> serverAddress() async =>
      ServerAddress.stored(await repository.serverAddress());

  /// The address of the server in use as Settings shows it; `null` outside
  /// the third way.
  String? serverAddressShown;

  /// A new sign-in to the server in use, not confirmed yet: its credential
  /// is in memory only ([HeldCredentialStore]), the secure store still holds
  /// the access the server stopped.
  HeldCredentialStore? _signInHeld;

  /// After the server revoked or expired the access
  /// ([ServerStop.disconnected]): a new sign-in to [address] in the browser,
  /// then the homes the new access covers, read only. Nothing is written to
  /// the secure store nor to the phone's record of the server until
  /// [confirmSignInAgain]; on any failure the new access is dropped
  /// ([dropSignInAgain]) and the error goes to the caller.
  Future<List<ServerHome>> signInAgain(ServerAddress address) async {
    await dropSignInAgain();
    final held = HeldCredentialStore(_store);
    _signInHeld = held;
    try {
      await ServerConnector(
        http: serverHttp,
        store: held,
        openBrowser: openUrl,
        deviceName: l10n?.serverDeviceName ?? 'Housecairn',
        callbacks: signInCallbacks,
      ).signIn(address);
      final transport = _transport(address, store: held);
      await transport.capabilities();
      return await transport.homes(keep: false);
    } on Object {
      await dropSignInAgain();
      rethrow;
    }
  }

  /// Connect, after [signInAgain]: the new access goes to the secure store,
  /// the old one is revoked on the server at best (it may only have
  /// expired, and would stay known to the server), and the phone syncs at
  /// once from where it was. The homes the new access no longer covers
  /// leave the phone at that sync, as any home gone; the confirmation named
  /// them.
  Future<void> confirmSignInAgain() async {
    final credential = _signInHeld?.credential;
    if (credential == null) {
      // Connect again after a sync that failed: the new access is stored
      // already, only the sync is tried again.
      await syncWithServer(throwing: true);
      if (serverSync.stopped case final reason?) throw ServerStopped(reason);
      return;
    }
    _signInHeld = null;
    final address = await serverAddress();
    final old = await ServerCredential.read(_store);
    await credential.write(_store);
    if (address != null && old != null && old.refresh != credential.refresh) {
      await _revokeAtBest(address, old);
    }
    serverSync.stopped = null;
    await syncWithServer(throwing: true);
  }

  /// Back, Cancel or a failure after [signInAgain]: the new access is
  /// forgotten at once and revoked on the server at best; the secure store
  /// and the phone's record of the server stay as they were.
  Future<void> dropSignInAgain() async {
    final held = _signInHeld;
    _signInHeld = null;
    final credential = held?.credential;
    if (held == null || credential == null) return;
    final address = await serverAddress();
    if (address != null) await _revokeAtBest(address, credential);
  }

  /// Revokes [credential] on [address] when the server answers; never
  /// throws, and leaves the secure store and the record of the server alone.
  Future<void> _revokeAtBest(
    ServerAddress address,
    ServerCredential credential,
  ) async {
    final alone = HeldCredentialStore(_store);
    try {
      await credential.write(alone);
      await _transport(address, store: alone).disconnect(keepState: true);
    } on Object {
      // At best: the access can still be revoked on the server's page.
    }
  }

  /// What the screens show of the sync with the server (lot 4b).
  final serverSync = ServerSyncStatus();

  Future<SyncReport?>? _syncing;
  bool _syncAgain = false;
  Timer? _syncSoon;
  StreamSubscription<void>? _localWrites;

  /// Syncs with the server: at the opening, when the app comes back to the
  /// front, and [syncDelay] after the last change made on the phone (lot 4b,
  /// ADR 0010, "the phone syncs at the opening and in the background").
  /// One round at a time: asked while one runs, another follows it. An
  /// error is kept in [serverSync] for the screens; with [throwing], the
  /// caller gets it too (the confirmation of the third way).
  Future<SyncReport?> syncWithServer({bool throwing = false}) async {
    if (_syncing case final running?) {
      _syncAgain = true;
      return running;
    }
    final done = Completer<SyncReport?>();
    _syncing = done.future;
    SyncReport? report;
    try {
      do {
        _syncAgain = false;
        report = await _syncRound();
      } while (_syncAgain);
      done.complete(report);
      return report;
    } on Object {
      done.complete(null);
      if (throwing) rethrow;
      return null;
    } finally {
      _syncing = null;
      await refresh();
    }
  }

  /// One round of sync with the server; nothing outside the third way, and
  /// nothing while the server stopped the access ([ServerStop.disconnected]),
  /// not even from "Sync now": only a new sign-in, confirmed, lets the
  /// phone send again ([confirmSignInAgain]).
  Future<SyncReport?> _syncRound() async {
    if (serverSync.stopped == ServerStop.disconnected) return null;
    if (syncMode != SyncMode.server &&
        await repository.storedSyncMode() != SyncMode.server) {
      return null;
    }
    final address = await serverAddress();
    if (address == null) return null;
    final status = serverSync;
    status.running = true;
    notifyListeners();
    try {
      final transport = _transport(address);
      final report = await SyncEngine(
        repository,
        transport,
        thumbnailer: thumbnailer,
      ).sync();
      await _restoreDropped(transport);
      status
        ..lastSync = repository.clock.now()
        ..stopped = null
        ..unreachable = false
        ..failed = false
        ..notices = [
          ...status.notices,
          for (final n in report.notices)
            if (ServerSyncStatus.shown.contains(n.kind)) n,
        ];
      return report;
    } on ServerStopped catch (e) {
      status.stopped = e.reason;
      rethrow;
    } on ServerHttpException {
      status.unreachable = true;
      rethrow;
    } on ServerBusy {
      status.unreachable = true;
      rethrow;
    } on Object {
      status.failed = true;
      rethrow;
    } finally {
      status.running = false;
    }
  }

  /// How long after the last change of the phone it syncs.
  final Duration syncDelay;

  /// Syncs [syncDelay] after now, unless another change comes first; not
  /// while the server stopped this phone (a sign-in, an update or another
  /// address is needed: [syncWithServer] from the screens still tries, but
  /// for a stopped access, which waits for a new sign-in).
  void syncSoon() {
    if (syncMode != SyncMode.server || serverSync.stoppedForGood) return;
    _syncSoon?.cancel();
    _syncSoon = Timer(syncDelay, syncWithServer);
  }

  /// The app comes back to the front: a sync, at once.
  Future<void> resumed() async {
    if (syncMode != SyncMode.server || serverSync.stoppedForGood) return;
    _syncSoon?.cancel();
    await syncWithServer();
  }

  /// The opening of the app: the homes, the reminder tapped, then a sync in
  /// the third way.
  Future<void> open({String? firstHomeName}) async {
    await refresh(firstHomeName: firstHomeName);
    await openLaunchReminder();
    if (syncMode == SyncMode.server) await syncWithServer();
  }

  void _watchLocalWrites() {
    if (syncMode == SyncMode.server) {
      _localWrites ??= repository.localWrites.listen((_) => syncSoon());
    } else {
      _localWrites?.cancel();
      _localWrites = null;
      _syncSoon?.cancel();
    }
  }

  @override
  void dispose() {
    _syncSoon?.cancel();
    _localWrites?.cancel();
    super.dispose();
  }

  /// Sends the refused change [id] again, with a sync at once.
  Future<void> sendAgain(int id) async {
    await repository.sendAgain(id);
    await syncWithServer();
  }

  /// "Try again" for the files the server did not take: every one that is
  /// not done is tried at once, with no wait, the refused ones too.
  Future<void> retryFiles() async {
    await repository.retryFiles();
    await syncWithServer();
  }

  /// Drops the refused change [id]: it is no longer sent, and a sync at once
  /// puts the server's value back on the phone (maintainer's decision,
  /// 2026-11-16); out of reach, it comes with the next sync.
  Future<void> dropRefused(int id) async {
    await repository.dropRefused(id);
    await syncWithServer();
  }

  /// The rows of the changes dropped, read again from the server's snapshot
  /// of their home and put back as it holds them.
  Future<List<SyncNotice>> _restoreDropped(ServerTransport transport) async {
    final notices = <SyncNotice>[];
    for (final MapEntry(key: home, value: rows)
        in (await repository.serverRereads()).entries) {
      final found = await transport.serverRows(home, rows);
      notices.addAll(
        await repository.restoreServerRows(
          home,
          rows,
          operations: found?.operations,
          present: found?.present ?? const {},
        ),
      );
    }
    return notices;
  }

  /// The notices of the past syncs were read.
  void dismissNotices() {
    serverSync.notices = const [];
    notifyListeners();
  }

  /// The move alone → server is open only to a phone with no home
  /// (docs/plan.md, lot 4b): keeping this phone's homes on a server is lot
  /// 4c, and the phone never merges nor drops them on its own.
  bool get canMoveToServer => homes.isEmpty;

  /// The changes of this phone not yet sent to the server, oldest first.
  Future<List<SyncOperation>> unsentChanges() async => [
    for (final o in await repository.outgoing()) o.operation,
  ];

  /// The move server → alone (docs/adr/0010, "Moving from one way to
  /// another"): the changes not sent are sent first; when the server cannot
  /// be reached, nothing changes and they are given back, unless
  /// [keepUnsent] says the person confirmed leaving with them on this phone
  /// only. Then the access is revoked and deleted from [store], the marks
  /// and the transport's state go, and the homes stay as they were at the
  /// last sync, no longer synced.
  Future<List<SyncOperation>> leaveServer({bool keepUnsent = false}) async {
    // Never two rounds at once: the one running ends first.
    _syncSoon?.cancel();
    await _syncing;
    final address = await serverAddress();
    // The access stopped by the server sends nothing more: the changes not
    // sent are named, as with no network.
    final stopped = serverSync.stopped == ServerStop.disconnected;
    if (stopped && !keepUnsent && (await unsentChanges()).isNotEmpty) {
      return unsentChanges();
    }
    if (!stopped && address != null && (await unsentChanges()).isNotEmpty) {
      try {
        await SyncEngine(repository, _transport(address)).sync();
      } on ServerHttpException {
        if (!keepUnsent) return unsentChanges();
      } on ServerBusy {
        if (!keepUnsent) return unsentChanges();
      } on ServerStopped {
        if (!keepUnsent) return unsentChanges();
      }
    }
    if (address != null) await _transport(address).disconnect();
    final left = await repository.outgoing();
    if (left.isNotEmpty) await repository.acknowledge(left.last.seq);
    await repository.forgetServerSeen();
    await repository.forgetFileSync();
    // The changes the server refused stay in the homes of this phone, as
    // they were made; they are no longer to be sent anywhere.
    await repository.forgetRefused();
    serverSync.reset();
    await repository.setServerAddress(null);
    await repository.setSyncMode(SyncMode.alone);
    await refresh();
    return const [];
  }

  Future<void> choose(String homeId) async {
    await repository.chooseHome(homeId);
    await refresh();
  }

  Future<void> showAllHomes() async {
    await repository.showAllHomesOnToday();
    await refresh();
  }

  // ---------- reminders ----------

  /// Reminders are on when the person turned them on and the system still
  /// allows notifications; when it was revoked since, they go back off.
  Future<bool> _remindersStillAllowed() async {
    if (!await repository.remindersEnabled()) return false;
    final n = notifier;
    if (n == null) return true;
    if (await n.permitted()) return true;
    await repository.setRemindersEnabled(false);
    return false;
  }

  /// Turns reminders on or off. The permission is asked here, at the moment
  /// the person asks for reminders and not before; `false` when they refuse,
  /// and reminders stay off.
  Future<bool> setReminders(bool on) async {
    final n = notifier;
    if (on) {
      if (n == null || !await n.requestPermission()) return false;
    }
    await repository.setRemindersEnabled(on);
    remindersOn = on;
    if (!on) await n?.cancelAll();
    notifyListeners();
    await reschedule();
    return true;
  }

  bool _planning = false;
  bool _again = false;

  /// Plans the reminders from the data and schedules them, replacing the
  /// pending ones: at every start and after every change, so that a task
  /// done, postponed, changed or deleted is reminded as it now is.
  Future<void> reschedule() async {
    final n = notifier;
    final words = l10n;
    if (!remindersOn || n == null || words == null) return;
    if (_planning) {
      _again = true;
      return;
    }
    _planning = true;
    try {
      do {
        _again = false;
        final active = await repository.activeHomes();
        final plan = planReminders(
          sources: await repository.reminderSources(),
          now: repository.clock.now().toLocal(),
          namesHomes: active.length >= 2,
          texts: ReminderWords(words),
        );
        await n.cancelAll();
        for (final reminder in plan.all) {
          await n.schedule(
            id: reminder.id,
            title: reminder.title,
            body: reminder.body,
            at: reminder.at,
            channel: words.remindersChannel,
            payload: reminder.payload,
          );
        }
      } while (_again);
    } finally {
      _planning = false;
    }
  }

  /// Opens the home of a reminder the person tapped: it becomes the current
  /// one (docs/spec.md, "Reminders").
  Future<void> openReminder(String payload) async {
    final homeId = payload.split('/').first;
    if (activeHomes.any((h) => h.id == homeId)) await choose(homeId);
  }

  bool _launchChecked = false;

  /// Handles the tap that started the app when a notification was tapped
  /// while the app was not running: the same as a tap while it runs. Once per
  /// start; call it when the homes are read.
  Future<void> openLaunchReminder() async {
    if (_launchChecked) return;
    _launchChecked = true;
    final payload = await notifier?.launchPayload();
    if (payload != null) await openReminder(payload);
  }
}

/// The sync with the server as the screens show it (lot 4b): running, when
/// it last went through, why the server stopped the phone, the notices to
/// read, and the changes the server refused.
class ServerSyncStatus {
  /// The notices of a sync shown to the person: an undo taken back, a row
  /// dropped after a restart from the snapshot.
  static const shown = {
    SyncNoticeKind.undoReverted,
    SyncNoticeKind.droppedAfterRestart,
    SyncNoticeKind.viewChanged,
  };

  bool running = false;
  DateTime? lastSync;

  /// Why the server stopped this phone at the last round; `null` when it
  /// went through.
  ServerStop? stopped;

  /// The last round found no server, or a server too busy to answer: the
  /// phone tries again by itself.
  bool unreachable = false;

  /// The last round failed for another reason.
  bool failed = false;

  List<SyncNotice> notices = const [];
  List<RefusedChange> refused = const [];

  /// The server stopped the phone until the person acts (sign in again,
  /// update the app or the server, use https): the phone does not try by
  /// itself until then, nor at the next opening of the app.
  bool get stoppedForGood => stopped != null;

  void reset() {
    running = false;
    lastSync = null;
    stopped = null;
    unreachable = false;
    failed = false;
    notices = const [];
    refused = const [];
  }
}

/// The words of the notifications, from the ARB files.
class ReminderWords implements ReminderTexts {
  ReminderWords(this.l10n);

  final AppLocalizations l10n;

  @override
  String title(String task, String? homeName) =>
      homeName == null ? task : l10n.reminderTitleHome(homeName, task);

  @override
  String due(Day dueOn) => l10n.dueOn(
    DateFormat.yMMMd(l10n.localeName)
        .format(DateTime(dueOn.year, dueOn.month, dueOn.day)),
  );

  @override
  String summaryTitle(int count) => l10n.reminderSummaryTitle(count);

  @override
  String summaryLine(String? homeName, int count) => homeName == null
      ? l10n.reminderSummaryLine(count)
      : l10n.reminderSummaryLineHome(homeName, count);
}

/// Gives [AppState] to the screens below it.
class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child})
    : super(notifier: state);

  static AppState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;
}
