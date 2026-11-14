// SPDX-License-Identifier: AGPL-3.0-only

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/app_localizations.dart';
import 'sections.dart';

/// The five sections of the design guide of Housecairn, in this order, in a
/// bar at the bottom: Today, Rooms, Projects, Budget, More
/// (web repository, docs/developer/design-guide.md, "Five sections").
enum Section { today, rooms, projects, budget, more }

/// The app shell: one navigator per section, so that each section keeps its
/// own screens when another one is opened, and the bottom bar.
class Shell extends StatefulWidget {
  const Shell({super.key});

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  Section _current = Section.today;
  final _navigators = {
    for (final section in Section.values) section: GlobalKey<NavigatorState>(),
  };

  void _select(int index) {
    final section = Section.values[index];
    if (section == _current) {
      // A second tap on the current section goes back to its root.
      _navigators[section]!.currentState?.popUntil((route) => route.isFirst);
    } else {
      setState(() => _current = section);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final navigator = _navigators[_current]!.currentState;
        if (navigator != null && navigator.canPop()) {
          navigator.pop();
        } else if (_current != Section.today) {
          setState(() => _current = Section.today);
        } else {
          await SystemNavigator.pop();
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: _current.index,
          children: [
            for (final section in Section.values)
              Navigator(
                key: _navigators[section],
                onGenerateRoute: (settings) => MaterialPageRoute<void>(
                  settings: settings,
                  builder: (context) => sectionRoot(section),
                ),
              ),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _current.index,
          onDestinationSelected: _select,
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.today_outlined),
              selectedIcon: const Icon(Icons.today),
              label: l10n.navToday,
            ),
            NavigationDestination(
              icon: const Icon(Icons.meeting_room_outlined),
              selectedIcon: const Icon(Icons.meeting_room),
              label: l10n.navRooms,
            ),
            NavigationDestination(
              icon: const Icon(Icons.construction_outlined),
              selectedIcon: const Icon(Icons.construction),
              label: l10n.navProjects,
            ),
            NavigationDestination(
              icon: const Icon(Icons.account_balance_wallet_outlined),
              selectedIcon: const Icon(Icons.account_balance_wallet),
              label: l10n.navBudget,
            ),
            NavigationDestination(
              icon: const Icon(Icons.more_horiz),
              label: l10n.navMore,
            ),
          ],
        ),
      ),
    );
  }
}
