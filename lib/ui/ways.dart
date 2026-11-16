// SPDX-License-Identifier: AGPL-3.0-only

import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../design/adaptive.dart';
import '../design/theme.dart';
import '../design/tokens.dart';
import '../design/widgets.dart';
import '../l10n/app_localizations.dart';
import '../sync/mode.dart';
import '../sync/operation.dart';
import '../sync/server_transport.dart';
import '../sync/transport.dart';
import 'server_screens.dart';
import 'server_sync.dart';
import 'state.dart';

/// The words of one way to use the app (docs/adr/0010), from the ARB files.
({String title, String text}) wayWords(AppLocalizations l10n, SyncMode way) =>
    switch (way) {
      SyncMode.alone => (title: l10n.wayAloneTitle, text: l10n.wayAloneText),
      SyncMode.relay => (title: l10n.wayFamilyTitle, text: l10n.wayFamilyText),
      SyncMode.server => (title: l10n.wayServerTitle, text: l10n.wayServerText),
    };

/// The first-start screen: the three ways to use the app as three choices of
/// equal weight, "Alone on this phone" selected and the only one active
/// (docs/adr/0010, "What the screen says"). Choosing it stores the way and
/// makes the first home.
class WaysScreen extends StatefulWidget {
  const WaysScreen({super.key});

  @override
  State<WaysScreen> createState() => _WaysScreenState();
}

class _WaysScreenState extends State<WaysScreen> {
  /// Set while the first home is being made: Continue does nothing more
  /// until then, so that two quick taps make one home.
  bool _starting = false;

  /// The way selected; Alone until another available one is tapped.
  SyncMode _selected = SyncMode.alone;

  Future<void> _continue(AppState state, String firstHomeName) async {
    if (_starting) return;
    if (_selected == SyncMode.server) {
      // The address, the sign-in and the confirmation (lot 4b): nothing is
      // stored before the confirmation.
      await Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const ServerAddressScreen()),
      );
      return;
    }
    setState(() => _starting = true);
    try {
      await state.startAlone(firstHomeName);
    } finally {
      if (mounted) setState(() => _starting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = AppScope.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  HcSpace.s4,
                  HcSpace.s6,
                  HcSpace.s4,
                  HcSpace.s2,
                ),
                children: [
                  Semantics(
                    header: true,
                    child: Text(l10n.waysTitle, style: HcText.pageTitle),
                  ),
                  const SizedBox(height: HcSpace.s4),
                  for (final way in SyncMode.values) ...[
                    WayCard(
                      key: Key('way-${way.name}'),
                      way: way,
                      selected: way == _selected,
                      onTap: wayAvailable(way)
                          ? () => setState(() => _selected = way)
                          : null,
                    ),
                    const SizedBox(height: HcSpace.s3),
                  ],
                ],
              ),
            ),
            // Always in reach, whatever the text size: outside the list.
            Padding(
              padding: const EdgeInsets.all(HcSpace.s4),
              child: FilledButton(
                key: const Key('ways-continue'),
                onPressed: _starting
                    ? null
                    : () => _continue(state, l10n.firstHomeName),
                child: Text(l10n.waysContinue),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One way as a choice (a radio of a group): a card, selected with the
/// border of the primary colour. A way that is not available has no action,
/// says "Coming later", and opens nothing.
class WayCard extends StatelessWidget {
  const WayCard({
    super.key,
    required this.way,
    required this.selected,
    required this.onTap,
  });

  final SyncMode way;
  final bool selected;

  /// `null`: the way is not available.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final words = wayWords(l10n, way);
    final enabled = onTap != null;
    return Semantics(
      container: true,
      inMutuallyExclusiveGroup: true,
      checked: selected,
      enabled: enabled,
      child: MergeSemantics(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: enabled ? HcColors.surface : HcColors.background,
            border: Border.all(
              color: selected ? HcColors.primary : HcColors.border,
              width: selected
                  ? HcComponent.borderWidth * 2
                  : HcComponent.borderWidth,
            ),
            borderRadius: BorderRadius.circular(HcRadius.lg),
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(HcRadius.lg),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: HcLayout.touchTargetLg,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(HcSpace.s4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Indicator(selected: selected),
                      const SizedBox(width: HcSpace.s3),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(words.title, style: HcText.cardTitle),
                            const SizedBox(height: HcSpace.s1),
                            Text(words.text, style: HcText.body),
                            if (!enabled) ...[
                              const SizedBox(height: HcSpace.s2),
                              HcPill(
                                l10n.wayComingLater,
                                tone: HcPillTone.ghost,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The round mark of a radio: a ring, with a dot when selected.
class _Indicator extends StatelessWidget {
  const _Indicator({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Padding(
      padding: const EdgeInsets.only(top: HcSpace.s1),
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? HcColors.primary : HcColors.borderStrong,
            width: HcComponent.borderWidth * 2,
          ),
        ),
        child: SizedBox(
          width: HcSpace.s5,
          height: HcSpace.s5,
          child: selected
              ? const Padding(
                  padding: EdgeInsets.all(HcSpace.s1),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: HcColors.primary,
                    ),
                  ),
                )
              : null,
        ),
      ),
    ),
  );
}

/// The rows of More that show the way in use, the way that is coming later
/// disabled with "Coming later" (docs/plan.md, lot 2c), and the moves of
/// lot 4b: server → alone, and alone → server for a phone with no home
/// (with homes, a message that lot 4c brings it, and nothing changes).
class WaysRows extends StatelessWidget {
  const WaysRows({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = AppScope.of(context);
    final inUse = state.syncMode;
    final rows = HcCardList(
      children: [
        // The state of the sync, "Sync now" and the changes refused, in
        // the third way (lot 4b).
        if (inUse == SyncMode.server)
          HcRow(
            key: const Key('way-row-sync'),
            title: l10n.syncTitle,
            text: syncProblem(l10n, state.serverSync),
            pills: [
              if (state.serverSync.refused.isNotEmpty)
                HcPill(
                  l10n.syncRefusedCount(state.serverSync.refused.length),
                  tone: HcPillTone.warning,
                ),
            ],
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const ServerSyncScreen()),
            ),
          ),
        for (final way in SyncMode.values)
          Semantics(
            key: Key('way-row-${way.name}'),
            enabled: way == inUse || wayAvailable(way),
            child: HcRow(
              title: wayWords(l10n, way).title,
              text: wayWords(l10n, way).text,
              pills: [
                if (way == inUse)
                  HcPill(l10n.wayInUse, tone: HcPillTone.success)
                else if (!wayAvailable(way))
                  HcPill(l10n.wayComingLater, tone: HcPillTone.ghost),
              ],
              onTap: way != inUse && wayAvailable(way)
                  ? () => _move(context, state, way)
                  : null,
            ),
          ),
      ],
    );
    if (inUse != SyncMode.server) return rows;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const ServerSettingsRows(),
        const SizedBox(height: HcSpace.s3),
        rows,
      ],
    );
  }

  static Future<void> _move(
    BuildContext context,
    AppState state,
    SyncMode to,
  ) async {
    if (to == SyncMode.server) {
      if (!state.canMoveToServer) {
        final l10n = AppLocalizations.of(context);
        await _tell(context, l10n.wayServerTitle, l10n.wayMoveToServerLater);
        return;
      }
      await Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const ServerAddressScreen()),
      );
      return;
    }
    if (state.syncMode == SyncMode.server && to == SyncMode.alone) {
      final l10n = AppLocalizations.of(context);
      await leaveServer(
        context,
        state,
        title: l10n.wayLeaveServerTitle,
        action: l10n.wayLeaveServerConfirm,
      );
    }
  }

  /// A message with OK: the alert of iOS on an iPhone, the dialog of
  /// Material on Android (ADR 0011).
  static Future<void> _tell(BuildContext context, String title, String text) =>
      showHcDialog<void>(
        context,
        (context) => HcDialog(
          key: const Key('way-message'),
          title: title,
          content: Text(text),
          actions: [
            HcDialogAction(
              key: const Key('way-message-ok'),
              label: MaterialLocalizations.of(context).okButtonLabel,
              kind: HcDialogKind.cancel,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );

  /// A confirmation of [lines] with Cancel and [action] (ADR 0011).
  static Future<bool> _confirm(
    BuildContext context, {
    required Key key,
    required String title,
    required List<String> lines,
    required String action,
  }) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showHcDialog<bool>(
      context,
      (context) => HcDialog(
        key: key,
        scrollable: true,
        title: title,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final line in lines)
              Padding(
                padding: const EdgeInsets.only(bottom: HcSpace.s2),
                child: Text(line),
              ),
          ],
        ),
        actions: [
          HcDialogAction(
            key: const Key('way-cancel'),
            label: l10n.cancel,
            kind: HcDialogKind.cancel,
            onPressed: () => Navigator.of(context).pop(false),
          ),
          HcDialogAction(
            key: const Key('way-confirm'),
            label: action,
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
    return ok ?? false;
  }

  /// Server → alone, from the row of the first way or from Disconnect in
  /// Settings: a confirmation titled [title] that counts the changes not
  /// sent, with the button [action]; if the server cannot be reached, a
  /// second one that names them. The access is revoked and deleted, the
  /// homes stay, and the phone is back to the choice of the ways, alone.
  static Future<void> leaveServer(
    BuildContext context,
    AppState state, {
    required String title,
    required String action,
  }) async {
    final l10n = AppLocalizations.of(context);
    final unsent = await state.unsentChanges();
    if (!context.mounted) return;
    final go = await _confirm(
      context,
      key: const Key('way-leave-server'),
      title: title,
      lines: [
        l10n.wayLeaveServerText,
        if (unsent.isNotEmpty) l10n.wayLeaveServerUnsent(unsent.length),
      ],
      action: action,
    );
    if (!go) return;
    final left = await state.leaveServer();
    if (left.isEmpty || !context.mounted) return;
    final names = unsentNames(left);
    final drop = await _confirm(
      context,
      key: const Key('way-leave-server-unsent'),
      title: title,
      lines: [
        l10n.wayLeaveServerUnreachable,
        for (final name in names.named) '• $name',
        if (names.others > 0) l10n.wayLeaveServerOther(names.others),
      ],
      action: l10n.wayLeaveServerDrop,
    );
    if (drop) await state.leaveServer(keepUnsent: true);
  }
}

/// Settings in the third way (docs/adr/0010, "What the screen says"): the
/// address of the server in use, read only, with the sentence of the
/// confirmation next to it for as long as the phone is connected; "Sign in
/// again" when the server revoked or expired the access; and Disconnect,
/// which revokes the access, deletes it from the phone and goes back to the
/// first way with the homes kept (the move server → alone).
class ServerSettingsRows extends StatefulWidget {
  const ServerSettingsRows({super.key});

  @override
  State<ServerSettingsRows> createState() => _ServerSettingsRowsState();
}

class _ServerSettingsRowsState extends State<ServerSettingsRows> {
  /// Set while a sign-in or a disconnection runs: a second tap does nothing.
  bool _busy = false;

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _disconnect(AppState state) {
    final l10n = AppLocalizations.of(context);
    return WaysRows.leaveServer(
      context,
      state,
      title: l10n.settingsServerDisconnectTitle,
      action: l10n.settingsServerDisconnect,
    );
  }

  /// A new sign-in to the same server in the browser, then the
  /// confirmation, which names the homes that would leave the phone. The
  /// new access stays in memory until Connect; leaving the confirmation in
  /// any other way (Cancel, the system back, the back gesture) drops it.
  Future<void> _signInAgain(AppState state) async {
    final l10n = AppLocalizations.of(context);
    final navigator = Navigator.of(context);
    final address = await state.serverAddress();
    if (address == null) return;
    try {
      final homes = await state.signInAgain(address);
      if (!mounted) {
        unawaited(state.dropSignInAgain());
        return;
      }
      await navigator.push(
        MaterialPageRoute<void>(
          builder: (_) => ServerConfirmScreen(
            address: address,
            homes: homes,
            reconnect: true,
          ),
        ),
      );
      // Connect took the new access already; otherwise it is dropped.
      unawaited(state.dropSignInAgain());
    } on Object catch (e) {
      if (!mounted) return;
      await WaysRows._tell(
        context,
        l10n.settingsServerSignInAgain,
        serverProblem(l10n, e),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = AppScope.of(context);
    return HcCardList(
      children: [
        HcRow(
          key: const Key('settings-server-address'),
          title: l10n.settingsServerAddress,
          text: state.serverAddressShown ?? '',
          moreText: l10n.serverSeesEverything,
        ),
        if (state.serverSync.stopped == ServerStop.disconnected)
          HcRow(
            key: const Key('settings-server-sign-in-again'),
            title: l10n.settingsServerSignInAgain,
            text: l10n.serverDisconnected,
            onTap: _busy ? null : () => _run(() => _signInAgain(state)),
          ),
        HcRow(
          key: const Key('settings-server-disconnect'),
          title: l10n.settingsServerDisconnect,
          text: l10n.settingsServerDisconnectText,
          onTap: _busy ? null : () => _run(() => _disconnect(state)),
        ),
      ],
    );
  }
}

/// The names of the rows that [operations] change (their `name` or `title`
/// as the phone sends it), each once, and how many change a row without a
/// name in them.
({List<String> named, int others}) unsentNames(List<SyncOperation> operations) {
  final named = <String>{};
  final others = <String>{};
  for (final op in operations) {
    final fields = (op[Op.fields] as Map?) ?? const {};
    final name = fields['name'] ?? fields['title'];
    if (name is String && name.isNotEmpty) {
      named.add(name);
    } else {
      others.add('${op[Op.type]}:${op[Op.id]}');
    }
  }
  return (named: named.toList(), others: others.length);
}
