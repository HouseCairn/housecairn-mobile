// SPDX-License-Identifier: AGPL-3.0-only

import 'day.dart';

/// Reminders, planned by the phone from its own data and scheduled as local
/// notifications (docs/spec.md, "Reminders"). Nothing leaves the phone.
///
/// The rules are those of the web, carried over (`notifications/models.py:70-91`,
/// `notifications/reminders.py:56`, `:178-236`): the first reminder goes out
/// [defaultDaysBefore] days before the due date at [defaultSendHour]:00, and
/// follow-ups come every [followUpDays] days by priority while the occurrence
/// stays open. Postponing moves the due date, so the reminders start again
/// from the new date; done and skipped close the occurrence, so they stop.
/// The plan is made again at every start and after every change, which is how
/// both come about.

/// Days before the due date of the first reminder (`Preference.days_before`).
const defaultDaysBefore = 1;

/// Hour of the day of the reminders (`Preference.send_at`, 08:00).
const defaultSendHour = 8;

/// Days between two follow-ups, by priority (`FOLLOW_UP_DAYS`).
const followUpDays = {'high': 1, 'normal': 3, 'low': 7};

/// The most notifications pending at once. iOS keeps 64 per app; the phone
/// schedules the nearest 60 with the daily summary among them, and the rest
/// is in the summary.
const maxPending = 60;

/// How far ahead follow-ups are planned; they are planned again at every
/// start.
const planHorizonDays = 60;

/// An open occurrence with a due date, as the planner reads it.
class ReminderSource {
  const ReminderSource({
    required this.occurrenceId,
    required this.taskId,
    required this.taskTitle,
    required this.homeId,
    required this.homeName,
    required this.dueOn,
    required this.priority,
  });

  final String occurrenceId;
  final String taskId;
  final String taskTitle;
  final String homeId;
  final String homeName;
  final Day dueOn;
  final String priority;
}

/// The words of the notifications, from the ARB files.
abstract interface class ReminderTexts {
  /// Title of a reminder: the task, and its home when [homeName] is given
  /// ("Second home: change the smoke alarm battery").
  String title(String task, String? homeName);

  /// Body of a reminder: the due date.
  String due(Day dueOn);

  /// Title of the daily summary of the [count] tasks that have no reminder of
  /// their own.
  String summaryTitle(int count);

  /// One line of the summary: [count] tasks of a home (the home is named only
  /// with two active homes or more).
  String summaryLine(String? homeName, int count);
}

/// One notification to schedule.
class PlannedReminder {
  const PlannedReminder({
    required this.id,
    required this.at,
    required this.title,
    required this.body,
    required this.payload,
  });

  final int id;

  /// The instant, in the time zone of the phone.
  final DateTime at;
  final String title;
  final String body;

  /// `<home id>` and `<task id>`, to open the right home (docs/spec.md).
  final String payload;
}

/// What to schedule: the reminders, and the daily summary of the tasks that
/// do not have one.
class ReminderPlan {
  const ReminderPlan(this.reminders, this.summary);

  final List<PlannedReminder> reminders;
  final PlannedReminder? summary;

  /// Everything to schedule: [maxPending] at most.
  List<PlannedReminder> get all => [...reminders, ?summary];
}

DateTime _at(Day day, int hour) => DateTime(day.year, day.month, day.day, hour);

/// The reminders of [sources] from [now] on, at most [maxPending]
/// notifications, the daily summary included.
///
/// [namesHomes] is true with two active homes or more: every title names its
/// home, and the summary groups by home. With one active home none does.
ReminderPlan planReminders({
  required List<ReminderSource> sources,
  required DateTime now,
  required bool namesHomes,
  required ReminderTexts texts,
  int daysBefore = defaultDaysBefore,
  int sendHour = defaultSendHour,
}) {
  // Every instant of every occurrence, with the round of the follow-up it is.
  final candidates = <({ReminderSource source, int round, DateTime at})>[];
  final horizon = DateTime(now.year, now.month, now.day + planHorizonDays);
  for (final source in sources) {
    final step = followUpDays[source.priority] ?? followUpDays['normal']!;
    var round = 0;
    for (var k = 0; ; k++) {
      final at = _at(source.dueOn.addDays(-daysBefore + k * step), sendHour);
      if (at.isAfter(horizon)) break;
      if (at.isAfter(now)) {
        candidates.add((source: source, round: round++, at: at));
      }
    }
  }
  // The next reminder of every task first, then the second of each, and so
  // on: a task with many follow-ups never crowds out another.
  candidates.sort((a, b) {
    final byRound = a.round.compareTo(b.round);
    if (byRound != 0) return byRound;
    final byTime = a.at.compareTo(b.at);
    if (byTime != 0) return byTime;
    return a.source.occurrenceId.compareTo(b.source.occurrenceId);
  });
  final firsts = candidates.where((c) => c.round == 0).length;
  // The summary takes a place of the sixty when some task has none.
  final room = firsts > maxPending ? maxPending - 1 : maxPending;
  final chosen = candidates.take(room).toList()
    ..sort((a, b) {
      final byTime = a.at.compareTo(b.at);
      return byTime != 0
          ? byTime
          : a.source.occurrenceId.compareTo(b.source.occurrenceId);
    });
  var id = 2;
  final reminders = [
    for (final c in chosen)
      PlannedReminder(
        id: id++,
        at: c.at,
        title: texts.title(
          c.source.taskTitle,
          namesHomes ? c.source.homeName : null,
        ),
        body: texts.due(c.source.dueOn),
        payload: '${c.source.homeId}/${c.source.taskId}',
      ),
  ];
  final covered = {for (final c in chosen) c.source.occurrenceId};
  final left = [
    for (final c in candidates)
      if (c.round == 0 && !covered.contains(c.source.occurrenceId)) c.source,
  ];
  if (left.isEmpty) return ReminderPlan(reminders, null);
  // Grouped by home, the homes by name; the summary goes out at the next
  // hour of reminders.
  final byHome = <String, List<ReminderSource>>{};
  for (final source in left) {
    (byHome[source.homeName + source.homeId] ??= []).add(source);
  }
  final lines = !namesHomes
      ? [texts.summaryLine(null, left.length)]
      : [
          for (final key in byHome.keys.toList()..sort())
            texts.summaryLine(byHome[key]!.first.homeName, byHome[key]!.length),
        ];
  final today = Day(now.year, now.month, now.day);
  final first = DateTime(now.year, now.month, now.day, sendHour).isAfter(now)
      ? today
      : today.addDays(1);
  return ReminderPlan(
    reminders,
    PlannedReminder(
      id: 1,
      at: _at(first, sendHour),
      title: texts.summaryTitle(left.length),
      body: lines.join('\n'),
      payload: '',
    ),
  );
}
