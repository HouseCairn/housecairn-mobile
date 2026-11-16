// SPDX-License-Identifier: AGPL-3.0-only

import 'package:material_ui/material_ui.dart';

import '../design/icons.dart';
import '../design/tokens.dart';
import '../design/widgets.dart';
import '../l10n/app_localizations.dart';
import 'about.dart';
import 'budget_screens.dart';
import 'contractor_screens.dart';
import 'homes_screen.dart';
import 'project_screens.dart';
import 'report_screens.dart';
import 'reminders_row.dart';
import 'rooms.dart';
import 'shell.dart';
import 'state.dart';
import 'today.dart';
import 'ways.dart';
import 'help_button.dart';

/// The root screen of a section.
Widget sectionRoot(Section section) => switch (section) {
  Section.today => const TodayScreen(),
  Section.rooms => const RoomsScreen(),
  Section.projects => const ProjectsScreen(),
  Section.budget => const BudgetScreen(),
  Section.more => const MoreScreen(),
};

/// More, in the groups of the web and in their order (design/patterns.md of
/// the web, More): Home, Me, Help, then the group of the app, last. An entry
/// has its icon and the subtitle of the web (`core/more.py`); an entry the
/// app does not have yet is left out, never moved to another group.
class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    void open(Widget screen) => Navigator.of(context).push(hcRoute(screen));
    return HcScaffold(
      title: l10n.navMore,
      brand: true,
      actions: const [HelpButton(page: HelpPages.more)],
      body: HcScreenList(
        children: [
          HcSectionHeading(l10n.moreHomeGroup),
          HcCardList(
            children: [
              if (AppScope.of(context).current case final home?)
                HcRow(
                  key: const Key('more-reports'),
                  leading: const HcIcon(
                    HcIcons.reports,
                    color: HcColors.primary,
                  ),
                  title: l10n.reports,
                  text: l10n.moreReportsText,
                  onTap: () => open(ReportsScreen(homeId: home.id)),
                ),
              HcRow(
                key: const Key('more-contractors'),
                leading: const HcIcon(
                  HcIcons.contractors,
                  color: HcColors.primary,
                ),
                title: l10n.contractors,
                text: l10n.moreContractorsText,
                onTap: () => open(const ContractorsScreen()),
              ),
              HcRow(
                key: const Key('more-homes'),
                leading: const HcIcon(HcIcons.homes, color: HcColors.primary),
                title: l10n.homes,
                text: l10n.moreHomesText,
                onTap: () => open(const HomesScreen()),
              ),
            ],
          ),
          HcSectionHeading(l10n.moreMeGroup),
          HcCardList(
            children: [
              HcRow(
                key: const Key('more-notifications'),
                leading: const HcIcon(
                  HcIcons.reminders,
                  color: HcColors.primary,
                ),
                title: l10n.notifications,
                text: l10n.moreNotificationsText,
                onTap: () => open(const NotificationsScreen()),
              ),
            ],
          ),
          HcSectionHeading(l10n.moreHelpGroup),
          HcCardList(
            children: [
              HcRow(
                key: const Key('more-about'),
                leading: const HcIcon(HcIcons.info, color: HcColors.primary),
                title: l10n.about,
                onTap: () => open(const AboutScreen()),
              ),
            ],
          ),
          HcSectionHeading(l10n.waysGroup),
          const WaysRows(),
        ],
      ),
    );
  }
}
