// SPDX-License-Identifier: AGPL-3.0-only

// The report a task was made from, and its photo, on the page of the task and
// in the lists (`tasks/task_detail.html`, `tasks/_occurrence_row.html`,
// `mark_photo_reports` and `reports_of_task` of `reports/services.py`).

import 'dart:io';
import 'dart:math';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:housecairn_mobile/core/clock.dart';
import 'package:housecairn_mobile/data/database.dart';
import 'package:housecairn_mobile/data/repository.dart';
import 'package:housecairn_mobile/l10n/app_localizations_en.dart';
import 'package:housecairn_mobile/l10n/app_localizations_fr.dart';
import 'package:housecairn_mobile/ui/photos.dart';
import 'package:housecairn_mobile/ui/report_screens.dart';
import 'package:housecairn_mobile/ui/task_list_screen.dart';
import 'package:housecairn_mobile/ui/task_screen.dart';
import 'package:material_ui/material_ui.dart';

import 'support/app.dart';
import 'support/fixture.dart';
import 'support/lot2b.dart';
import 'support/report_origin.dart';

/// Counts the statements that read the table of the reports.
class _ReportQueries extends QueryInterceptor {
  int count = 0;

  @override
  Future<List<Map<String, Object?>>> runSelect(
    QueryExecutor executor,
    String statement,
    List<Object?> args,
  ) {
    if (statement.contains('FROM "reports"') ||
        statement.contains('FROM reports')) {
      count++;
    }
    return executor.runSelect(statement, args);
  }
}

void main() {
  final en = AppLocalizationsEn();
  final fr = AppLocalizationsFr();

  Future<ReportOrigin> openTask(
    WidgetTester tester,
    String Function(ReportOrigin) task, {
    String locale = 'en',
    double width = 360,
    double textScale = 1,
    Future<void> Function(Repository, ReportOrigin)? alter,
  }) async {
    await onPhone(tester, width: width, height: 1600, textScale: textScale);
    late ReportOrigin data;
    await pumpApp(
      tester,
      locale: locale,
      seed: (r) async {
        data = await ReportOrigin.seed(r);
        await alter?.call(r, data);
      },
    );
    await openScreen(tester, TaskScreen(homeId: data.home, taskId: task(data)));
    return data;
  }

  group('the page of a task', () {
    testWidgets('shows the report it was made from, then its photo, under '
        'the head and before When', (tester) async {
      final d = await openTask(tester, (d) => d.withPhoto);
      expect(find.text(en.taskReportedProblem.toUpperCase()), findsOneWidget);
      final card = find.byKey(Key('task-report-${d.reportWithPhoto}'));
      expect(card, findsOneWidget);
      expect(
        find.descendant(of: card, matching: find.textContaining('Reported on')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: card,
          matching: find.byKey(Key('task-report-link-${d.reportWithPhoto}')),
        ),
        findsOneWidget,
      );
      expect(find.byKey(Key('report-photo-${d.reportWithPhoto}')), findsOne);
      final heading = tester.getTopLeft(
        find.text(en.taskReportedProblem.toUpperCase()),
      );
      expect(
        heading.dy,
        greaterThan(
          tester.getBottomLeft(find.byKey(const Key('task-edit'))).dy,
        ),
      );
      expect(
        heading.dy,
        lessThan(tester.getTopLeft(find.text(en.taskWhen.toUpperCase())).dy),
      );
    });

    testWidgets('says the date in French as the web does', (tester) async {
      await openTask(tester, (d) => d.withPhoto, locale: 'fr');
      expect(find.text(fr.taskReportedProblem.toUpperCase()), findsOneWidget);
      expect(find.textContaining('Signalé le'), findsOneWidget);
    });

    testWidgets('a photo not on the phone yet is the tile of lot 4c', (
      tester,
    ) async {
      final d = await openTask(tester, (d) => d.photoMissing);
      expect(
        find.byKey(Key('report-photo-missing-${d.reportMissing}')),
        findsOneWidget,
      );
      expect(find.byKey(Key('report-photo-${d.reportMissing}')), findsNothing);
      expect(find.text(en.photoNotHere), findsOneWidget);
    });

    testWidgets('the photo opens full width', (tester) async {
      final d = await openTask(tester, (d) => d.withPhoto);
      // A picture is not decoded in a widget test, so it has no size to hit:
      // its tap is called.
      tester
          .widget<InkWell>(
            find.byKey(Key('report-photo-open-${d.reportWithPhoto}')),
          )
          .onTap!();
      await tester.pumpAndSettle();
      expect(find.byType(ReportPhotoScreen), findsOneWidget);
      expect(find.byKey(const Key('report-photo-full')), findsOneWidget);
    });

    testWidgets('a photo not there opens on the message that it is not', (
      tester,
    ) async {
      final d = await openTask(tester, (d) => d.photoMissing);
      await tester.tap(find.byKey(Key('report-photo-open-${d.reportMissing}')));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('report-photo-full-missing')),
        findsOneWidget,
      );
    });

    testWidgets('the title of the report opens the report', (tester) async {
      final d = await openTask(tester, (d) => d.withPhoto);
      await tester.tap(
        find.byKey(Key('task-report-link-${d.reportWithPhoto}')),
      );
      await tester.pumpAndSettle();
      expect(find.byType(ReportScreen), findsOneWidget);
      expect(find.byKey(const Key('report-status')), findsOneWidget);
    });

    testWidgets('a report without a photo shows no photo', (tester) async {
      final d = await openTask(tester, (d) => d.noPhoto);
      expect(find.byKey(Key('task-report-${d.reportNoPhoto}')), findsOne);
      expect(find.byType(ReportPhoto), findsNothing);
    });

    testWidgets('a photo empty in the database shows neither the photo nor '
        'the tile', (tester) async {
      final d = await openTask(
        tester,
        (d) => d.withPhoto,
        alter: (r, d) => r.db.customStatement(
          "UPDATE reports SET photo = '' WHERE id = ?",
          [uuidBytes(d.reportWithPhoto)],
        ),
      );
      expect(find.byKey(Key('task-report-${d.reportWithPhoto}')), findsOne);
      expect(find.byType(ReportPhoto), findsNothing);
      expect(find.byKey(const Key('report-photo-missing')), findsNothing);
    });

    testWidgets('in an archived home the section still shows', (tester) async {
      final d = await openTask(
        tester,
        (d) => d.withPhoto,
        alter: (r, d) async {
          await r.createHome(name: 'Other');
          await r.archiveHome(d.home);
        },
      );
      expect(find.text(en.taskReportedProblem.toUpperCase()), findsOne);
      expect(find.byKey(Key('task-report-${d.reportWithPhoto}')), findsOne);
      expect(find.byType(ReportPhoto), findsOne);
    });

    testWidgets('a deleted report does not show, nor the heading', (
      tester,
    ) async {
      final d = await openTask(tester, (d) => d.deleted);
      expect(find.byKey(Key('task-report-${d.reportDeleted}')), findsNothing);
      expect(find.text(en.taskReportedProblem.toUpperCase()), findsNothing);
    });

    testWidgets('a task made from nothing has no such section', (tester) async {
      await openTask(tester, (d) => d.plain);
      expect(find.text(en.taskReportedProblem.toUpperCase()), findsNothing);
    });

    testWidgets('a report closed since still shows, as on the web', (
      tester,
    ) async {
      final d = await openTask(tester, (d) => d.closed);
      expect(find.byKey(Key('task-report-${d.reportClosed}')), findsOne);
      expect(find.byKey(Key('report-photo-${d.reportClosed}')), findsOne);
    });

    testWidgets('several reports: the latest first', (tester) async {
      final d = await openTask(tester, (d) => d.twoReports);
      final newer = tester.getTopLeft(
        find.byKey(Key('task-report-${d.reportNewer}')),
      );
      final older = tester.getTopLeft(
        find.byKey(Key('task-report-${d.reportOlder}')),
      );
      expect(newer.dy, lessThan(older.dy));
    });

    for (final locale in ['en', 'fr']) {
      testWidgets('at 320 px and text twice as large: no overflow ($locale)', (
        tester,
      ) async {
        await openTask(
          tester,
          (d) => d.withPhoto,
          locale: locale,
          width: 320,
          textScale: 2,
        );
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('the lists', () {
    late Repository r;
    late ReportOrigin d;

    setUp(() async {
      r = await openRepository();
      addTearDown(r.db.close);
      d = await ReportOrigin.seed(r);
    });

    Future<Set<String>> flagged(Future<List<TodayEntry>> rows) async => {
      for (final e in await rows)
        if (e.hasReportPhoto) e.task.id,
    };

    test('Today flags the tasks made from a report with a photo', () async {
      expect(await flagged(r.todayEntries(homeId: d.home)), {
        d.withPhoto,
        d.photoMissing,
        d.closed,
        d.twoReports,
      });
    });

    test('All flags the same tasks', () async {
      final page = await r.openTasks(d.home);
      expect(
        {
          for (final e in page.rows)
            if (e.hasReportPhoto) e.task.id,
        },
        {d.withPhoto, d.photoMissing, d.closed, d.twoReports},
      );
    });

    test('a search keeps the flag', () async {
      final page = await r.openTasks(d.home, query: 'leak');
      expect(page.rows.single.hasReportPhoto, isTrue);
    });

    test('a report of another home does not flag the task', () async {
      final other = await r.createHome(name: 'Other');
      await r.db.customStatement(
        'UPDATE reports SET home_id = ? WHERE id = ?',
        [uuidBytes(other), uuidBytes(d.reportWithPhoto)],
      );
      expect(await r.tasksWithReportPhoto([d.withPhoto]), isEmpty);
      expect(await r.reportsOfTask(d.withPhoto), isEmpty);
    });

    test('a photo empty in the database is no photo', () async {
      await r.db.customStatement("UPDATE reports SET photo = '' WHERE id = ?", [
        uuidBytes(d.reportWithPhoto),
      ]);
      expect(await r.tasksWithReportPhoto([d.withPhoto]), isEmpty);
    });

    testWidgets('one query on the reports for a whole page, not one a row', (
      tester,
    ) async {
      final counter = _ReportQueries();
      final db = AppDatabase(NativeDatabase.memory().interceptWith(counter));
      addTearDown(db.close);
      final repo = Repository(
        db,
        clock: FixedClock(testNow),
        files: Directory.systemTemp.createTempSync('housecairn-files-'),
        random: Random(1),
      );
      await tester.runAsync(() async {
        await repo.open();
        await ReportOrigin.seed(repo);
        final home = (await repo.activeHomes()).single.id;
        counter.count = 0;
        await repo.todayEntries(homeId: home);
        expect(counter.count, 1, reason: 'Today');
        counter.count = 0;
        await repo.openTasks(home);
        expect(counter.count, 1, reason: 'All');
        counter.count = 0;
        await repo.seasonEntries(homeId: home);
        expect(counter.count, lessThanOrEqualTo(1), reason: 'In season');
      });
    });
  });

  group('the rows', () {
    Future<ReportOrigin> openList(
      WidgetTester tester,
      Widget Function(ReportOrigin) screen, {
      String locale = 'en',
      double width = 360,
      double textScale = 1,
    }) async {
      await onPhone(tester, width: width, height: 1800, textScale: textScale);
      late ReportOrigin data;
      await pumpApp(
        tester,
        locale: locale,
        seed: (r) async => data = await ReportOrigin.seed(r),
      );
      await openScreen(tester, screen(data));
      return data;
    }

    Future<String> occurrenceOf(WidgetTester tester, String task) async {
      final repo = stateOf(tester).repository;
      return (await tester.runAsync<List<OccurrenceRow>>(
        () => repo.openOccurrencesOf(task),
      ))!.first.id;
    }

    testWidgets('All: the pill Photo on the rows that have one', (
      tester,
    ) async {
      final d = await openList(tester, (d) => TaskListScreen(homeId: d.home));
      final withPhoto = await occurrenceOf(tester, d.withPhoto);
      final without = await occurrenceOf(tester, d.noPhoto);
      final plain = await occurrenceOf(tester, d.plain);
      expect(find.byKey(Key('today-photo-$withPhoto')), findsOneWidget);
      expect(find.byKey(Key('today-photo-$without')), findsNothing);
      expect(find.byKey(Key('today-photo-$plain')), findsNothing);
      expect(
        find.descendant(
          of: find.byKey(Key('today-$withPhoto')),
          matching: find.text(en.reportPhotoPill),
        ),
        findsOneWidget,
      );
    });

    testWidgets('Today: the pill Photo too, after the date', (tester) async {
      await onPhone(tester, height: 1800);
      late ReportOrigin d;
      await pumpApp(tester, seed: (r) async => d = await ReportOrigin.seed(r));
      final withPhoto = await occurrenceOf(tester, d.withPhoto);
      final deleted = await occurrenceOf(tester, d.deleted);
      expect(find.byKey(Key('today-photo-$withPhoto')), findsOneWidget);
      expect(find.byKey(Key('today-photo-$deleted')), findsNothing);
    });

    for (final locale in ['en', 'fr']) {
      testWidgets('at 320 px and text twice as large: no overflow ($locale)', (
        tester,
      ) async {
        await openList(
          tester,
          (d) => TaskListScreen(homeId: d.home),
          locale: locale,
          width: 320,
          textScale: 2,
        );
        expect(tester.takeException(), isNull);
      });
    }
  });
}
