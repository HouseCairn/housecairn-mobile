// SPDX-License-Identifier: AGPL-3.0-only

import 'package:material_ui/material_ui.dart';

import '../design/icons.dart';
import '../design/theme.dart';
import '../design/tokens.dart';
import '../l10n/app_localizations.dart';
import 'state.dart';

/// Value of [HomeSelector] for All homes.
const allHomesChoice = '*';

/// The home selector, a compact line under the `h1` of a section root
/// (design/patterns.md of the web, "Header"), shown from two active homes on
/// (docs/spec.md, "Homes"). On Today ([withAllHomes]) it also offers All
/// homes. Choosing a home makes it the current one, kept on the phone.
class HomeSelector extends StatelessWidget {
  const HomeSelector({super.key, this.withAllHomes = false});

  final bool withAllHomes;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    if (!state.showsSelector) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    final all = withAllHomes && state.todayAllHomes;
    final label = all ? l10n.allHomes : state.current?.name ?? '';
    return PopupMenuButton<String>(
      key: const Key('home-selector'),
      tooltip: l10n.homeSelectorTooltip,
      onSelected: (choice) => choice == allHomesChoice
          ? state.showAllHomes()
          : state.choose(choice),
      itemBuilder: (context) => [
        if (withAllHomes)
          CheckedPopupMenuItem(
            value: allHomesChoice,
            checked: all,
            child: Text(l10n.allHomes),
          ),
        for (final home in state.activeHomes)
          CheckedPopupMenuItem(
            value: home.id,
            checked: !all && home.id == state.current?.id,
            child: Text(home.name),
          ),
      ],
      // The selector of the web (`.home-switcher-toggle`): the name in
      // bold, a chevron, on its own line at the left, under the title.
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: HcLayout.touchTargetLg),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: HcSpace.s1),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const HcIcon(HcIcons.home, color: HcColors.primary),
                const SizedBox(width: HcSpace.s1),
                Flexible(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: HcText.rowTitle.copyWith(fontWeight: HcFont.bold),
                  ),
                ),
                const SizedBox(width: HcSpace.s1),
                const RotatedBox(
                  quarterTurns: 1,
                  child: HcIcon(
                    HcIcons.chevron,
                    size: HcComponent.chevronSize,
                    color: HcColors.text,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
