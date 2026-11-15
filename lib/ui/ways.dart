// SPDX-License-Identifier: AGPL-3.0-only

import 'package:material_ui/material_ui.dart';

import '../design/theme.dart';
import '../design/tokens.dart';
import '../design/widgets.dart';
import '../l10n/app_localizations.dart';
import '../sync/mode.dart';
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

  Future<void> _continue(AppState state, String firstHomeName) async {
    if (_starting) return;
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
                      selected: way == SyncMode.alone,
                      onTap: wayAvailable(way) ? () {} : null,
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

/// The rows of More that show the way in use, and the two others disabled
/// with "Coming later" (docs/plan.md, lot 2c).
class WaysRows extends StatelessWidget {
  const WaysRows({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final inUse = AppScope.of(context).syncMode;
    return HcCardList(
      children: [
        for (final way in SyncMode.values)
          Semantics(
            key: Key('way-row-${way.name}'),
            enabled: way == inUse,
            child: HcRow(
              title: wayWords(l10n, way).title,
              text: wayWords(l10n, way).text,
              pills: [
                if (way == inUse)
                  HcPill(l10n.wayInUse, tone: HcPillTone.success)
                else
                  HcPill(l10n.wayComingLater, tone: HcPillTone.ghost),
              ],
            ),
          ),
      ],
    );
  }
}
