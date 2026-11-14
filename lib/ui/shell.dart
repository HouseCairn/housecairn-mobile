// SPDX-License-Identifier: AGPL-3.0-only

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../design/icons.dart';
import '../design/tokens.dart';
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
        // The bar of the web (`.nav`): white, a line above, the five
        // sections with the icons of the web, the current one in bold.
        bottomNavigationBar: DecoratedBox(
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: HcColors.border)),
          ),
          // The labels of the bar keep their size whatever the text size of
          // the phone, as the tab bar of iOS does: five labels must stay side
          // by side on 360 px (docs/adr/0011).
          child: MediaQuery.withNoTextScaling(
            child: NavigationBar(
              selectedIndex: _current.index,
              onDestinationSelected: _select,
              destinations: [
                for (final (icon, label) in [
                  (HcIcons.today, l10n.navToday),
                  (HcIcons.rooms, l10n.navRooms),
                  (HcIcons.projects, l10n.navProjects),
                  (HcIcons.budget, l10n.navBudget),
                  (HcIcons.more, l10n.navMore),
                ])
                  NavigationDestination(icon: HcIcon(icon), label: label),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
