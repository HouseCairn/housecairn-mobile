// SPDX-License-Identifier: AGPL-3.0-only

import 'package:material_ui/material_ui.dart';

import '../design/adaptive.dart';
import '../design/icons.dart';
import '../design/tokens.dart';
import '../design/widgets.dart';
import 'help_button.dart';
import '../l10n/app_localizations.dart';
import 'state.dart';

/// Reminders on or off (docs/spec.md, "Reminders"). The permission to show
/// notifications is asked here, when the person turns reminders on; if they
/// refuse, reminders stay off and the screen says why. Nothing is sent from
/// the phone: the notifications are local alarms.
class RemindersRow extends StatelessWidget {
  const RemindersRow({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = AppScope.of(context);
    return HcRow(
      leading: const HcIcon(HcIcons.reminders, color: HcColors.primary),
      title: l10n.reminders,
      text: l10n.remindersExplain,
      trailing: Semantics(
        label: l10n.reminders,
        child: HcSwitch(
          key: const Key('reminders-switch'),
          value: state.remindersOn,
          onChanged: (on) async {
            final messenger = ScaffoldMessenger.of(context);
            if (!await state.setReminders(on)) {
              messenger
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(content: Text(l10n.remindersDenied)));
            }
          },
        ),
      ),
    );
  }
}

/// Notifications, the entry of Me in More (web: Notifications, "where and
/// when your reminders go"): the switch of the reminders and what they do.
/// It is a screen of its own, as on the web, so that More holds only links.
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return HcScaffold(
      title: l10n.notifications,
      actions: const [HelpButton(page: HelpPages.notifications)],
      body: HcScreenList(
        children: [
          const SizedBox(height: HcSpace.s2),
          HcCardList(children: const [RemindersRow()]),
        ],
      ),
    );
  }
}
