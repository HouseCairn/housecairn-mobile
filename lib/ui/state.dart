// SPDX-License-Identifier: AGPL-3.0-only

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/notifier.dart';
import '../core/photo_source.dart';
import '../data/database.dart';
import '../data/repository.dart';
import '../domain/day.dart';
import '../domain/photos.dart';
import '../domain/reminders.dart';
import '../domain/templates.dart';
import '../l10n/app_localizations.dart';

/// Re-encodes a photo off the main isolate (a photo of 12 megapixels takes a
/// second or two); tests give [processPhoto] itself.
typedef PhotoProcessor = Future<ProcessedPhoto> Function(Uint8List bytes);

Future<ProcessedPhoto> processInIsolate(Uint8List bytes) =>
    compute(processPhoto, bytes);

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
    this.notifier,
    this.photoProcessor = processInIsolate,
    this.loadTemplates = loadBundledTemplates,
    this.openUrl = openInSystem,
  });

  final Repository repository;

  /// The camera and the gallery; `null` where there are none (tests).
  final PhotoSource? photoSource;

  /// The local notifications; `null` where there are none (tests).
  final Notifier? notifier;
  final PhotoProcessor photoProcessor;
  final Future<TemplateLibrary> Function() loadTemplates;
  final UrlOpener openUrl;

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

  /// Reads the homes again, and makes the first home at the first start.
  /// Reminders are planned again from the data as it is now.
  Future<void> refresh({String? firstHomeName}) async {
    if (firstHomeName != null && (await repository.homes()).isEmpty) {
      await repository.createHome(name: firstHomeName);
    }
    homes = await repository.homes();
    current = await repository.currentHome();
    todayAllHomes = await repository.todayShowsAllHomes();
    remindersOn = await _remindersStillAllowed();
    revision++;
    notifyListeners();
    await reschedule();
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
