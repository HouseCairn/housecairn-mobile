// SPDX-License-Identifier: AGPL-3.0-only

import 'package:material_ui/material_ui.dart';

import '../data/repository.dart';
import '../design/adaptive.dart';
import '../domain/day.dart';
import '../l10n/app_localizations.dart';
import 'messages.dart';
import 'state.dart';
import 'stock_screens.dart';

/// What can be done to an open occurrence, from Today and from the task
/// (`tasks/services.py`): done in one tap with an undo bar, skipped,
/// postponed; the refusals are said, the data is read again.

Future<void> _run(
  BuildContext context,
  AppState state,
  Future<void> Function() action,
) async {
  try {
    await action();
  } on Refused catch (refused) {
    if (context.mounted) showRefusal(context, refused);
  }
  await state.refresh();
}

/// The bar that says what was done and takes it back.
void offerUndo(BuildContext context, String message, String occurrenceId) {
  final l10n = AppLocalizations.of(context);
  final state = AppScope.of(context);
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        action: SnackBarAction(
          label: l10n.undo,
          // The screen that offered it may be gone when it is pressed: only the
          // state, captured now, is used.
          onPressed: () =>
              _run(context, state, () => state.repository.undo(occurrenceId)),
        ),
      ),
    );
}

/// Done, today; the stock the task takes is said when it is short.
Future<void> markDone(
  BuildContext context,
  String occurrenceId,
  String title,
) async {
  final l10n = AppLocalizations.of(context);
  final state = AppScope.of(context);
  final repository = state.repository;
  final locale = Localizations.localeOf(context).toLanguageTag();
  Closing? closed;
  await _run(context, state, () async {
    closed = await repository.complete(occurrenceId);
  });
  if (closed != null && context.mounted) {
    final short = closed!.short;
    offerUndo(
      context,
      [
        l10n.doneMessage(title),
        if (short.isNotEmpty) shortageMessage(l10n, locale, short),
      ].join(' '),
      occurrenceId,
    );
  }
}

/// Skipped this time.
Future<void> markSkipped(
  BuildContext context,
  String occurrenceId,
  String title,
) async {
  final l10n = AppLocalizations.of(context);
  final state = AppScope.of(context);
  final repository = state.repository;
  var closed = false;
  await _run(context, state, () async {
    await repository.skip(occurrenceId);
    closed = true;
  });
  if (closed && context.mounted) {
    offerUndo(context, l10n.skippedMessage(title), occurrenceId);
  }
}

/// Postponed to a day the person chooses, tomorrow at the earliest.
Future<void> postponeOccurrence(
  BuildContext context,
  String occurrenceId,
) async {
  final state = AppScope.of(context);
  final repository = state.repository;
  final today = repository.today();
  final picked = await hcPickDate(
    context,
    initial: asDateTime(today.addDays(1)),
    first: asDateTime(today),
    last: asDateTime(today.addYears(dateSpanYears)),
  );
  if (picked == null || !context.mounted) return;
  await _run(
    context,
    state,
    () => repository.postpone(occurrenceId, Day.of(picked)),
  );
}

/// Takes back a done or a skip.
Future<void> undoOccurrence(BuildContext context, String occurrenceId) {
  final state = AppScope.of(context);
  return _run(context, state, () => state.repository.undo(occurrenceId));
}
