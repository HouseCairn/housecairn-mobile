// SPDX-License-Identifier: AGPL-3.0-only

import 'package:material_ui/material_ui.dart';

import '../design/tokens.dart';
import '../l10n/app_localizations.dart';
import 'about.dart';
import 'home_selector.dart';
import 'homes_screen.dart';
import 'shell.dart';
import 'today.dart';

/// The root screen of a section.
Widget sectionRoot(Section section) => switch (section) {
  Section.today => const TodayScreen(),
  Section.rooms => EmptySection(title: (l10n) => l10n.navRooms),
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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(HcSpace.s6),
          child: Text(
            l10n.emptySection,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge
                ?.copyWith(color: HcColors.textMuted),
          ),
        ),
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
      body: ListView(
        children: [
          _GroupHeading(l10n.moreHouseholdGroup),
          ListTile(
            leading: const Icon(Icons.home_work_outlined),
            title: Text(l10n.homes),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => const HomesScreen(),
              ),
            ),
          ),
          _GroupHeading(l10n.moreHelpGroup),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(l10n.about),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => const AboutScreen(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupHeading extends StatelessWidget {
  const _GroupHeading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        HcSpace.s4,
        HcSpace.s4,
        HcSpace.s4,
        HcSpace.s2,
      ),
      child: Semantics(
        header: true,
        child: Text(
          text,
          style: Theme.of(context).textTheme.titleSmall
              ?.copyWith(color: HcColors.textMuted),
        ),
      ),
    );
  }
}
