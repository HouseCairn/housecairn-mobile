// SPDX-License-Identifier: AGPL-3.0-only

import 'package:material_ui/material_ui.dart';

import '../design/icons.dart';
import '../design/tokens.dart';
import '../l10n/app_localizations.dart';
import 'state.dart';

/// The documentation site, the one the web's help link points to
/// (`HOUSECAIRN_DOCS_URL`, `core/help.py`).
const docsAddress = 'https://docs.housecairn.app';

/// The pages of the documentation site of the five sections, as in the web's
/// `HELP_PAGES` (`core/help.py`, v0.4.0).
abstract final class HelpPages {
  static const today = 'screens/today/';
  static const rooms = 'screens/rooms/';
  static const projects = 'screens/projects/';
  static const budget = 'screens/budget/';
  static const more = 'screens/more/';
  static const tasks = 'screens/tasks/';
  static const task = 'screens/task/';
  static const templates = 'screens/task-templates/';
  static const room = 'screens/room/';
  static const item = 'screens/item/';
  static const stockItem = 'screens/stock-item/';
  static const project = 'screens/project/';
  static const contractors = 'screens/contractors/';
  static const contractor = 'screens/contractor/';
  static const reports = 'screens/reports/';
  static const report = 'screens/report/';
  static const homes = 'screens/homes/';
  static const notifications = 'screens/notifications/';
  static const about = 'screens/about/';
}

/// The actions of a bar: [actions], or the help button of [page] when a
/// page has no action of its own (the web shows the "?" on every page,
/// design/patterns.md, "Header").
List<Widget> actionsOrHelp(List<Widget> actions, String page) =>
    actions.isEmpty ? [HelpButton(page: page)] : actions;

/// The address of [page] in the language of the app: the site publishes
/// English at its root and French under `fr/` (`DOCS_LANGUAGES`).
Uri helpAddress(String page, String languageCode) =>
    Uri.parse('$docsAddress/${languageCode == 'fr' ? 'fr/' : ''}$page');

/// The help button of the bar (`shell/help_link.html`): the circled question
/// mark, which opens the page of the documentation that describes the screen
/// in the browser of the phone, as the web link does. The app has no help
/// screen of its own.
class HelpButton extends StatelessWidget {
  const HelpButton({super.key, required this.page});

  final String page;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = AppScope.of(context);
    final language = Localizations.localeOf(context).languageCode;
    return IconButton(
      key: const Key('help-button'),
      tooltip: l10n.helpTooltip,
      constraints: const BoxConstraints.tightFor(
        width: HcLayout.touchTargetLg,
        height: HcLayout.touchTargetLg,
      ),
      icon: const HcIcon(HcIcons.help, color: HcColors.primary),
      onPressed: () => state.openUrl(helpAddress(page, language)),
    );
  }
}
