// SPDX-License-Identifier: AGPL-3.0-only

import 'package:material_ui/material_ui.dart';

import '../l10n/app_localizations.dart';
import 'state.dart';

/// Value of [HomeSelector] for All homes.
const allHomesChoice = '*';

/// The home selector of the app bar, shown from two active homes on
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
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 160),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.home_outlined),
              const SizedBox(width: 4),
              Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
              const Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
      ),
    );
  }
}
