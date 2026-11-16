// SPDX-License-Identifier: AGPL-3.0-only

// The forms as the web has them (design lot D11): the order of the fields, the
// help of the web under them, the title of the home, one style of Delete,
// folded sections (the rooms, duration and season of a project; the
// materials of a task). Nine of the tests (room order, name from type, item
// room help, home title, report Photo label, folded project section, season
// help, one Delete, task materials saved) were each run with the change they
// are named for undone, and failed.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:housecairn_mobile/data/repository.dart';
import 'package:housecairn_mobile/design/tokens.dart';
import 'package:housecairn_mobile/design/widgets.dart';
import 'package:housecairn_mobile/ui/homes_screen.dart';
import 'package:housecairn_mobile/ui/item_screens.dart';
import 'package:housecairn_mobile/ui/project_screens.dart';
import 'package:housecairn_mobile/ui/report_screens.dart';
import 'package:housecairn_mobile/ui/rooms.dart';
import 'package:housecairn_mobile/ui/task_form_screen.dart';
import 'package:material_ui/material_ui.dart';

import 'support/app.dart';
import 'support/arb.dart';
import 'support/lot2b.dart';
import 'support/lot3a.dart';
import 'support/lot3b.dart';

double top(WidgetTester tester, Finder finder) =>
    tester.getTopLeft(finder.first).dy;

/// Scrolls the list of the screen until [finder] shows, then a little more, so
/// that the bar at the bottom does not cover it.
Future<void> see(WidgetTester tester, Finder finder) async {
  final list = find
      .byWidgetPredicate(
        (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
      )
      .hitTestable()
      .last;
  await tester.scrollUntilVisible(finder, 200, scrollable: list);
  await tester.drag(list, const Offset(0, -150));
  await tester.pumpAndSettle();
}

/// Picks [text] in the list of the field of key [key] (Android: the menu).
Future<void> choose(WidgetTester tester, String key, String text) async {
  await see(tester, find.byKey(Key(key)));
  await tester.tap(find.byKey(Key(key)));
  await tester.pumpAndSettle();
  await tester.tap(find.text(text).last);
  await tester.pumpAndSettle();
}

void main() {
  for (final locale in ['en', 'fr']) {
    final m = arbMessages(locale);

    group(locale, () {
      testWidgets('a room: Type, Name, Notes, with the help of the web, and '
          'the type fills the name in', (tester) async {
        await onPhone(tester);
        late Lot2b data;
        await pumpApp(
          tester,
          locale: locale,
          seed: (r) async => data = await Lot2b.seed(r),
        );
        await openScreen(tester, RoomFormScreen(homeId: data.homes.main));
        final kind = top(tester, find.byKey(const Key('room-kind')));
        final name = top(tester, find.byKey(const Key('room-name')));
        expect(kind, lessThan(name));
        expect(find.text(m['roomKindHelp']!), findsOneWidget);
        expect(find.text(m['roomNameHelp']!), findsOneWidget);
        expect(
          top(tester, find.text(m['roomNameHelp']!)),
          greaterThan(top(tester, find.text(m['roomKindHelp']!))),
        );
      });

      testWidgets('a room: choosing the type fills the name in, a typed name '
          'stays', (tester) async {
        await onPhone(tester);
        late Lot2b data;
        await pumpApp(
          tester,
          locale: locale,
          seed: (r) async => data = await Lot2b.seed(r),
        );
        await openScreen(tester, RoomFormScreen(homeId: data.homes.main));
        final nameField = find.byKey(const Key('room-name'));
        expect(tester.widget<TextFormField>(nameField).controller!.text, '');
        final kitchen = locale == 'fr' ? 'Cuisine' : 'Kitchen';
        final bedroom = locale == 'fr' ? 'Chambre' : 'Bedroom';
        await choose(tester, 'room-kind', kitchen);
        expect(
          tester.widget<TextFormField>(nameField).controller!.text,
          kitchen,
        );
        // Still the label of the previous type: it follows the new type.
        await choose(tester, 'room-kind', bedroom);
        expect(
          tester.widget<TextFormField>(nameField).controller!.text,
          bedroom,
        );
        // A name that was typed stays.
        await tester.enterText(nameField, 'Guest room');
        await choose(tester, 'room-kind', kitchen);
        expect(
          tester.widget<TextFormField>(nameField).controller!.text,
          'Guest room',
        );
      });

      testWidgets('an item: the room comes first, with its help', (
        tester,
      ) async {
        await onPhone(tester);
        late Lot2b data;
        await pumpApp(
          tester,
          locale: locale,
          seed: (r) async => data = await Lot2b.seed(r),
        );
        await openScreen(
          tester,
          ItemFormScreen(
            homeId: data.homes.main,
            roomId: data.cellar,
            chooseRoom: true,
          ),
        );
        expect(
          top(tester, find.byKey(const Key('item-room'))),
          lessThan(top(tester, find.byKey(const Key('item-name')))),
        );
        expect(find.text(m['itemRoomHelp']!), findsOneWidget);
      });

      testWidgets('the home: the title of its form, Archive above Delete, '
          'Delete filled in the danger colour, the help of the web', (
        tester,
      ) async {
        await onPhone(tester);
        late Lot2b data;
        await pumpApp(
          tester,
          locale: locale,
          seed: (r) async => data = await Lot2b.seed(r),
        );
        await openScreen(tester, HomeScreen(homeId: data.homes.main));
        expect(find.text(m['editHome']!), findsOneWidget);
        await see(tester, find.text(m['homeCurrencyHelp']!));
        expect(find.text(m['homeCurrencyHelp']!), findsOneWidget);
        await see(tester, find.text(m['homeHemisphereHelp']!));
        expect(find.text(m['homeHemisphereHelp']!), findsOneWidget);
        final archive = find.byKey(const Key('home-archive'));
        final delete = find.byKey(const Key('home-delete'));
        await see(tester, delete);
        expect(find.text(m['homeArchive']!), findsOneWidget);
        expect(find.text(m['homeDelete']!), findsOneWidget);
        // One under the other, the width of the column.
        expect(top(tester, archive), lessThan(top(tester, delete)));
        expect(
          tester.getSize(archive).width,
          tester.getSize(find.byKey(const Key('home-delete'))).width,
        );
        final button = tester.widget<FilledButton>(
          find.descendant(of: delete, matching: find.byType(FilledButton)),
        );
        expect(button.style?.backgroundColor?.resolve({}), HcColors.danger);
      });

      testWidgets('the report: the label Photo and the help of the web, with '
          'formats and size', (tester) async {
        await onPhone(tester);
        late Lot2b data;
        await pumpApp(
          tester,
          locale: locale,
          seed: (r) async => data = await Lot2b.seed(r),
          photoSource: cameraWith(),
        );
        await openScreen(tester, ReportFormScreen(homeId: data.homes.main));
        expect(
          find.descendant(
            of: find.byType(HcField),
            matching: find.text(m['photo']!),
          ),
          findsOneWidget,
        );
        final size = locale == 'fr' ? '20 Mo' : '20 MB';
        expect(
          find.text(m['reportPhotoHelpSize']!.replaceAll('{max}', size)),
          findsOneWidget,
        );
      });

      testWidgets('the project: rooms, duration and season are in a folded '
          'section, closed on a new project, and they are saved', (
        tester,
      ) async {
        await onPhone(tester);
        late Lot3b data;
        final state = await pumpApp(
          tester,
          locale: locale,
          seed: (r) async => data = await Lot3b.seed(r),
        );
        await openScreen(tester, ProjectFormScreen(homeId: data.main));
        final section = find.byKey(const Key('project-section-rooms'));
        expect(section, findsOneWidget);
        expect(find.text(m['projectSectionRooms']!), findsOneWidget);
        // Closed: no chip, no duration, no season.
        expect(find.byKey(const Key('project-duration')), findsNothing);
        expect(find.byType(FilterChip), findsNothing);
        await tester.enterText(
          find.byKey(const Key('project-title')),
          'Repaint',
        );
        await see(tester, find.text(m['projectSectionRooms']!));
        await tester.tap(find.text(m['projectSectionRooms']!));
        await tester.pumpAndSettle();
        expect(find.byType(FilterChip), findsWidgets);
        await tester.enterText(find.byKey(const Key('project-duration')), '3');
        await choose(
          tester,
          'project-season',
          locale == 'fr' ? 'Printemps' : 'Spring',
        );
        await tester.tap(find.text(m['save']!));
        await tester.pumpAndSettle();
        final saved =
            (await state.repository.db
                    .select(state.repository.db.projects)
                    .get())
                .firstWhere((p) => p.title == 'Repaint');
        // Three days of elapsed time, in minutes; the unit starts at days.
        expect(saved.estimatedMinutes, 3 * 24 * 60);
        expect(saved.season, 'spring');
      });

      for (final south in [false, true]) {
        testWidgets('the project: the help of the season names the hemisphere '
            'in lower case, as the web does (${south ? 'south' : 'north'})', (
          tester,
        ) async {
          await onPhone(tester);
          late Lot3b data;
          await pumpApp(
            tester,
            locale: locale,
            seed: (r) async {
              data = await Lot3b.seed(r);
              if (south) await r.updateHome(data.main, hemisphere: 'south');
            },
          );
          await openScreen(tester, ProjectFormScreen(homeId: data.main));
          await see(tester, find.text(m['projectSectionRooms']!));
          await tester.tap(find.text(m['projectSectionRooms']!));
          await tester.pumpAndSettle();
          // The words of the web, written out: not read back from the file
          // of messages that the app itself is built from.
          final hemisphere = {
            ('en', false): 'northern',
            ('en', true): 'southern',
            ('fr', false): 'nord',
            ('fr', true): 'sud',
          }[(locale, south)]!;
          final help = locale == 'fr'
              ? 'La saison suit l\'hémisphère du logement ($hemisphere) : '
                    'modifiez-le dans les réglages du logement.'
              : 'The season follows the hemisphere of the home ($hemisphere): '
                    'change it in the settings of the home.';
          await see(tester, find.text(help));
          expect(find.text(help), findsOneWidget);
        });
      }

      testWidgets('a project keeps its duration and its season when it is '
          'saved', (tester) async {
        await onPhone(tester);
        late Lot3b data;
        final state = await pumpApp(
          tester,
          locale: locale,
          seed: (r) async {
            data = await Lot3b.seed(r);
            final p = (await r.project(data.project))!;
            await r.updateProject(
              data.project,
              ProjectInput(
                title: p.title,
                goal: p.goal,
                status: p.status,
                priority: p.priority,
                estimatedMinutes: 90,
                season: 'winter',
              ),
            );
          },
        );
        await openScreen(
          tester,
          ProjectFormScreen(homeId: data.main, projectId: data.project),
        );
        expect(
          tester
              .widget<TextFormField>(find.byKey(const Key('project-duration')))
              .controller!
              .text,
          '90',
          reason: 'the duration of the project is read, not wiped',
        );
        await tester.tap(find.text(m['save']!));
        await tester.pumpAndSettle();
        final saved = (await state.repository.project(data.project))!;
        expect(saved.estimatedMinutes, 90);
        expect(saved.season, 'winter');
      });
    });
  }

  testWidgets('every Delete is the one filled danger button', (tester) async {
    final offences = <String>[];
    for (final file in Directory('lib/ui').listSync().whereType<File>()) {
      final source = file.readAsStringSync();
      // An outlined button drawn in the danger colour.
      for (final match in RegExp(
        r'OutlinedButton[^;]{0,200}HcColors\.danger',
        dotAll: true,
      ).allMatches(source)) {
        offences.add('${file.path}: ${match.start}');
      }
      // A button of key `…-delete` that is not the one component.
      for (final match in RegExp(
        r"(\w+)\(\s*key: (?:const )?Key\('[a-z]+-delete'\)",
      ).allMatches(source)) {
        if (match.group(1) != 'HcDeleteButton') {
          offences.add('${file.path}: ${match.group(0)}');
        }
      }
    }
    expect(offences, isEmpty);
  });

  testWidgets('the materials of a task: a folded section of the form, lines '
      'saved with the task', (tester) async {
    await onPhone(tester);
    late Lot3a data;
    final state = await pumpApp(
      tester,
      seed: (r) async => data = await Lot3a.seed(r),
    );
    // A new task: the section is closed, then opened, a line chosen.
    await openScreen(tester, TaskFormScreen(homeId: data.main));
    final section = find.byKey(const Key('task-section-materials'));
    expect(section, findsOneWidget);
    expect(find.byKey(const Key('task-material-article-0')), findsNothing);
    await tester.enterText(find.byKey(const Key('task-title')), 'Paint walls');
    await unfoldTaskSection(tester, 'task-section-materials');
    await seeInTaskForm(
      tester,
      find.byKey(const Key('task-material-article-0')),
    );
    await choose(tester, 'task-material-article-0', 'White paint');
    await tester.enterText(
      find.byKey(const Key('task-material-quantity-0')),
      '2,5',
    );
    await tester.tap(find.byKey(const Key('task-material-add')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('task-material-article-1')), findsOneWidget);
    await saveTask(tester);
    final created =
        (await state.repository.db.select(state.repository.db.tasks).get())
            .firstWhere((t) => t.title == 'Paint walls');
    final lines = await state.repository.materialsOf(created.id);
    expect([for (final l in lines) l.article.name], ['White paint']);
    expect(lines.single.quantity.toString(), '2.5');
  });

  testWidgets('a task that lists materials opens the section on them, and '
      'removing a line removes it from the task', (tester) async {
    await onPhone(tester);
    late Lot3a data;
    final state = await pumpApp(
      tester,
      seed: (r) async => data = await Lot3a.seed(r),
    );
    await openScreen(
      tester,
      TaskFormScreen(homeId: data.main, taskId: data.service),
    );
    await seeInTaskForm(
      tester,
      find.byKey(const Key('task-material-article-0')),
    );
    expect(find.text('Main filter'), findsWidgets);
    await seeInTaskForm(
      tester,
      find.byKey(const Key('task-material-remove-0')),
    );
    await tester.tap(find.byKey(const Key('task-material-remove-0')));
    await tester.pumpAndSettle();
    await saveTask(tester);
    expect(await state.repository.materialsOf(data.service), isEmpty);
  });
}
