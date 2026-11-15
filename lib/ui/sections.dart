// SPDX-License-Identifier: AGPL-3.0-only

import 'package:material_ui/material_ui.dart';

import '../design/icons.dart';
import '../design/tokens.dart';
import '../design/widgets.dart';
import '../l10n/app_localizations.dart';
import 'about.dart';
import 'contractor_screens.dart';
import 'home_selector.dart';
import 'homes_screen.dart';
import 'reminders_row.dart';
import 'rooms.dart';
import 'shell.dart';
import 'templates_screen.dart';
import 'today.dart';

/// The root screen of a section.
Widget sectionRoot(Section section) => switch (section) {
  Section.today => const TodayScreen(),
  Section.rooms => const RoomsScreen(),
  Section.projects => EmptySection(title: (l10n) => l10n.navProjects),
  Section.budget => EmptySection(title: (l10n) => l10n.navBudget),
  Section.more => const MoreScreen(),
};

/// A section with no content yet: its title, the home selector, and one line
/// that says so. The screens of lot 2b and later replace these.
class EmptySection extends StatelessWidget {
  const EmptySection({super.key, required this.title});

  final String Function(AppLocalizations l10n) title;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(title(l10n)), actions: const [HomeSelector()]),
      body: HcScreenList(
        children: [
          const SizedBox(height: HcSpace.s4),
          HcEmpty(l10n.emptySection),
        ],
      ),
    );
  }
}

/// More: everything that is not in the four other sections, by groups: the
/// household (Homes) and Help (About).
class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.navMore)),
      body: HcScreenList(
        children: [
          HcSectionHeading(l10n.moreHouseholdGroup),
          HcCardList(
            children: [
              HcRow(
                leading: const HcIcon(HcIcons.homes, color: HcColors.primary),
                title: l10n.homes,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => const HomesScreen(),
                  ),
                ),
              ),
              HcRow(
                leading: const HcIcon(
                  HcIcons.contractors,
                  color: HcColors.primary,
                ),
                title: l10n.contractors,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => const ContractorsScreen(),
                  ),
                ),
              ),
              HcRow(
                leading: const HcIcon(
                  HcIcons.templates,
                  color: HcColors.primary,
                ),
                title: l10n.addFromTemplate,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => const TemplatesScreen(),
                  ),
                ),
              ),
              const RemindersRow(),
            ],
          ),
          HcSectionHeading(l10n.moreHelpGroup),
          HcCardList(
            children: [
              HcRow(
                leading: const HcIcon(HcIcons.info, color: HcColors.primary),
                title: l10n.about,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => const AboutScreen(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
