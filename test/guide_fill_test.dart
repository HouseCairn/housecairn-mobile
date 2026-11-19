// SPDX-License-Identifier: AGPL-3.0-only

// Fill in for me of the guide (web ADR 0084, lot A3), form by form: on the
// example home, the form opened by the step shows the values of the file,
// the room and the item of a task and the place of a report included, as the
// web's `get_initial` does, and nothing is written before its button; the
// same form of a real home, given the same values, shows none of them
// (`fillsHere`). And Mark as done is on the four steps that leave no trace,
// and on no other.

import 'dart:io';

import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:housecairn_mobile/data/repository.dart';
import 'package:housecairn_mobile/design/widgets.dart';
import 'package:housecairn_mobile/domain/guide.dart';
import 'package:housecairn_mobile/ui/guide_screens.dart';
import 'package:housecairn_mobile/ui/item_screens.dart';
import 'package:housecairn_mobile/ui/project_screens.dart';
import 'package:housecairn_mobile/ui/report_screens.dart';
import 'package:housecairn_mobile/ui/stock_format.dart';
import 'package:housecairn_mobile/ui/task_form_screen.dart';
import 'package:housecairn_mobile/ui/templates_screen.dart';
import 'package:material_ui/material_ui.dart';

import 'support/app.dart';

final guide = parseGuide(File('design/guide.json').readAsStringSync());

/// Every row of every table, to see that nothing was written.
Future<String> dump(Repository r) async {
  final tables = await r.db
      .customSelect(
        "SELECT name FROM sqlite_master WHERE type = 'table' "
        "AND name NOT LIKE 'sqlite_%' ORDER BY name",
      )
      .get();
  final out = StringBuffer();
  for (final t in tables) {
    final name = t.read<String>('name');
    final rows = await r.db.customSelect('SELECT * FROM "$name"').get();
    out.writeln('$name ${[for (final row in rows) '${row.data}']..sort()}');
  }
  return out.toString();
}

Future<void> push(WidgetTester tester, Widget form) async {
  tester.state<NavigatorState>(find.byType(Navigator).last).push(hcRoute(form));
  await tester.pumpAndSettle();
  // Long enough for any save that would follow a change.
  await tester.pump(const Duration(seconds: 3));
  await tester.pumpAndSettle();
}

/// Whether a field shows [text]: the field of key [key], or any field.
bool showsText(WidgetTester tester, String? key, String text) {
  final fields = key == null
      ? find.byType(EditableText)
      : find.descendant(
          of: find.byKey(Key(key)),
          matching: find.byType(EditableText),
        );
  return fields
      .evaluate()
      .map((e) => (e.widget as EditableText).controller.text)
      .contains(text);
}

/// The value chosen in the list of key [key], `null` when there is no list.
Object? chosen(WidgetTester tester, String key) {
  final list = find.byKey(Key(key));
  if (list.evaluate().isEmpty) return null;
  return (tester.widget(list) as dynamic).value;
}

/// What the form of a step must show on the example home and not on a real
/// one: texts in fields, and choices of lists, by the key of the row of the
/// file (`room.kitchen`) of the home the form belongs to.
class Shown {
  const Shown({this.texts = const {}, this.choices = const {}});

  /// Text of a field, by key of the field (`null`: any field).
  final Map<String?, String> texts;

  /// Key of a list → key of the row of the file it must have chosen.
  final Map<String, String> choices;
}

/// One form of the guide.
class Case {
  const Case({
    required this.step,
    required this.upTo,
    required this.shown,
    required this.real,
    this.extra,
  });

  final String step;

  /// The scenarios made in the example home before the step (`fillExample`).
  final int upTo;

  /// Rows added to the example home after them.
  final Future<void> Function(Repository r, String home)? extra;

  /// The same form on [home], a real home with the rows of [ids] (key of the
  /// file → id), taking [fill].
  final Future<Widget> Function(
    Repository r,
    String home,
    Map<String, String> ids,
    GuideFill fill,
  )
  real;

  final Shown shown;
}

/// The rows of the file a real home gets, so that the values of the file
/// would have somewhere to go: two rooms (the bathroom first, so that a room
/// chosen by default is not the kitchen), the machine in the kitchen.
Future<Map<String, String>> realRows(Repository r, String home) async {
  final bathroom = await r.createRoom(home, name: 'Bathroom', kind: 'bathroom');
  final kitchen = await r.createRoom(
    home,
    name: 'Kitchen',
    kind: 'kitchen',
    position: 1,
  );
  final machine = await r.addItem(
    kitchen,
    const ItemInput(name: 'Espresso machine'),
  );
  return {
    'room.bathroom': bathroom,
    'room.kitchen': kitchen,
    'item.machine': machine,
  };
}

/// [fill] with its references made those of the real home.
GuideFill onReal(GuideFill fill, Map<String, String> ids) => {
  ...fill,
  if (fill.containsKey('room')) 'room': ids['room.kitchen'],
  if (fill.containsKey('item')) 'item': ids['item.machine'],
};

Future<void> bathroomProject(Repository r, String home) async {
  final project = await r.createProject(
    home,
    const ProjectInput(title: 'Redo the bathroom'),
  );
  await r.createLine(
    project,
    const LineInput(label: 'Plumber (shower)', planned: '3000'),
  );
}

final cases = <Case>[
  Case(
    step: 'rooms-equipment.3',
    upTo: 2,
    extra: (r, home) async {
      await r.createRoom(home, name: 'Bathroom', kind: 'bathroom');
      await r.createRoom(home, name: 'Kitchen', kind: 'kitchen', position: 1);
    },
    shown: const Shown(
      texts: {'item-name': 'Espresso machine'},
      choices: {'item-room': 'room.kitchen'},
    ),
    real: (r, home, ids, fill) async =>
        ItemFormScreen(homeId: home, chooseRoom: true, fill: onReal(fill, ids)),
  ),
  Case(
    step: 'rooms-equipment.4',
    upTo: 3,
    shown: const Shown(texts: {null: 'Brewmark'}),
    real: (r, home, ids, fill) async => ItemFormScreen(
      homeId: home,
      roomId: ids['room.kitchen'],
      itemId: ids['item.machine'],
      fill: fill,
    ),
  ),
  Case(
    step: 'recurring-task.1',
    upTo: 3,
    shown: const Shown(
      texts: {'task-title': 'Descaling'},
      choices: {'task-room': 'room.kitchen', 'task-item': 'item.machine'},
    ),
    real: (r, home, ids, fill) async =>
        TaskFormScreen(homeId: home, fill: onReal(fill, ids)),
  ),
  Case(
    step: 'recurring-task.2',
    upTo: 3,
    extra: (r, home) async {
      final ids = await r.exampleRowIds(guide, home, language: 'en');
      await r.createTask(
        home,
        TaskInput(
          title: 'Descaling',
          roomId: ids['room.kitchen'],
          itemId: ids['item.machine'],
        ),
      );
    },
    shown: const Shown(texts: {'task-interval': '3'}),
    real: (r, home, ids, fill) async {
      final task = await r.createTask(
        home,
        TaskInput(title: 'Descaling', itemId: ids['item.machine']),
      );
      return TaskFormScreen(homeId: home, taskId: task, fill: fill);
    },
  ),
  Case(
    step: 'report-problem.1',
    upTo: 4,
    shown: const Shown(
      texts: {'report-title': 'The kitchen tap drips'},
      choices: {'report-room': 'room:room.kitchen'},
    ),
    real: (r, home, ids, fill) async =>
        ReportFormScreen(homeId: home, fill: onReal(fill, ids)),
  ),
  Case(
    step: 'project-budget.1',
    upTo: 5,
    shown: const Shown(texts: {'project-title': 'Redo the bathroom'}),
    real: (r, home, ids, fill) async =>
        ProjectFormScreen(homeId: home, fill: fill),
  ),
  Case(
    step: 'project-budget.2',
    upTo: 5,
    extra: (r, home) => r
        .createProject(home, const ProjectInput(title: 'Redo the bathroom'))
        .then((_) {}),
    shown: const Shown(texts: {'line-label': 'Plumber (shower)'}),
    real: (r, home, ids, fill) async {
      final project = await r.createProject(
        home,
        const ProjectInput(title: 'Redo the bathroom'),
      );
      return LineFormScreen(homeId: home, projectId: project, fill: fill);
    },
  ),
  Case(
    step: 'project-budget.3',
    upTo: 5,
    extra: bathroomProject,
    shown: Shown(
      texts: {'quote-amount': moneyFieldText('en', Decimal.parse('3400'))},
    ),
    real: (r, home, ids, fill) async {
      final project = await r.createProject(
        home,
        const ProjectInput(title: 'Redo the bathroom'),
      );
      return QuoteFormScreen(homeId: home, projectId: project, fill: fill);
    },
  ),
  Case(
    step: 'project-budget.4',
    upTo: 5,
    extra: (r, home) async {
      await bathroomProject(r, home);
      await r.createContractor(home, name: 'Linden Plumbing');
    },
    shown: Shown(
      texts: {'quote-amount': moneyFieldText('en', Decimal.parse('2850'))},
    ),
    real: (r, home, ids, fill) async {
      final project = await r.createProject(
        home,
        const ProjectInput(title: 'Redo the bathroom'),
      );
      await r.createContractor(home, name: 'Linden Plumbing');
      return QuoteFormScreen(homeId: home, projectId: project, fill: fill);
    },
  ),
  Case(
    step: 'project-budget.6',
    upTo: 5,
    shown: Shown(
      texts: {'envelope-amount': moneyFieldText('en', Decimal.parse('6000'))},
    ),
    real: (r, home, ids, fill) async =>
        EnvelopeFormScreen(homeId: home, fill: fill),
  ),
];

void main() {
  for (final c in cases) {
    group('Fill in for me, step ${c.step}', () {
      late String example;
      late String real;

      Future<(Repository, Map<String, String>, GuideFill, Widget)> start(
        WidgetTester tester,
      ) async {
        // A tall screen, so that every field of a long form is built.
        await onPhone(tester, height: 4000);
        final state = await pumpApp(
          tester,
          seed: (r) async {
            real = await r.createHome(name: 'Main house');
            example = await r.createExampleHome(guide, language: 'en');
            await r.fillExample(guide, example, upTo: c.upTo, language: 'en');
            await c.extra?.call(r, example);
          },
        );
        final r = state.repository;
        final links = await stepLinks(r, guide, state.exampleHome, 'en');
        final form = links[c.step]!.fill!();
        final ids = await r.exampleRowIds(guide, example, language: 'en');
        return (r, ids, (form as dynamic).fill as GuideFill, form);
      }

      testWidgets('the example home shows the values, writes nothing', (
        tester,
      ) async {
        final (r, ids, fill, form) = await start(tester);
        expect(fill, isNotEmpty);
        final before = await dump(r);
        await push(tester, form);
        expect(find.byKey(const Key('example-banner')), findsOneWidget);
        for (final MapEntry(:key, :value) in c.shown.texts.entries) {
          expect(showsText(tester, key, value), isTrue, reason: '$key');
        }
        for (final MapEntry(:key, :value) in c.shown.choices.entries) {
          final row = value.startsWith('room:')
              ? 'room:${ids[value.substring(5)]}'
              : ids[value];
          expect(row, isNotNull, reason: value);
          expect(chosen(tester, key), row, reason: key);
        }
        expect(await dump(r), before, reason: 'nothing saved before Save');
      });

      testWidgets('a real home ignores the same values', (tester) async {
        final (r, _, fill, _) = await start(tester);
        final ids = await realRows(r, real);
        final form = await c.real(r, real, ids, fill);
        final before = await dump(r);
        await push(tester, form);
        expect(find.byKey(const Key('example-banner')), findsNothing);
        for (final MapEntry(:key, :value) in c.shown.texts.entries) {
          expect(showsText(tester, key, value), isFalse, reason: '$key');
        }
        for (final MapEntry(:key, :value) in c.shown.choices.entries) {
          final row = value.startsWith('room:')
              ? 'room:${ids[value.substring(5)]}'
              : ids[value];
          expect(chosen(tester, key), isNot(row), reason: key);
        }
        expect(await dump(r), before);
      });
    });
  }

  testWidgets('5.4: the contractor already known is chosen, not added', (
    tester,
  ) async {
    await onPhone(tester);
    late String example;
    late String linden;
    final state = await pumpApp(
      tester,
      seed: (r) async {
        await r.createHome(name: 'Main house');
        example = await r.createExampleHome(guide, language: 'en');
        await r.fillExample(guide, example, upTo: 5, language: 'en');
        await bathroomProject(r, example);
        linden = await r.createContractor(example, name: 'Linden Plumbing');
      },
    );
    final r = state.repository;
    final links = await stepLinks(r, guide, state.exampleHome, 'en');
    await push(tester, links['project-budget.4']!.fill!());
    expect(chosen(tester, 'quote-contractor'), linden);
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    final contractors = await r.contractors(example);
    expect([for (final c in contractors) c.id], [linden]);
  });

  testWidgets('Add from template, from a room of the example home, adds '
      'there, under its banner', (tester) async {
    await onPhone(tester, height: 4000);
    late String example;
    late String kitchen;
    final state = await pumpApp(
      tester,
      seed: (r) async {
        await r.createHome(name: 'Main house');
        example = await r.createExampleHome(guide, language: 'en');
        kitchen = await r.createRoom(example, name: 'Kitchen', kind: 'kitchen');
      },
    );
    await push(tester, TemplatesScreen(homeId: example, roomId: kitchen));
    expect(find.byKey(const Key('example-banner')), findsOneWidget);
    final template = find.byKey(const Key('template-smoke-alarm-test'));
    final list = find.byType(Scrollable).last;
    await tester.scrollUntilVisible(template, 500, scrollable: list);
    await tester.tap(template);
    await tester.pumpAndSettle();
    final room = find.byKey(const Key('templates-room'));
    await tester.scrollUntilVisible(room, 500, scrollable: list);
    expect(chosen(tester, 'templates-room'), kitchen);
    final add = find.byKey(const Key('templates-add'));
    await tester.scrollUntilVisible(add, 500, scrollable: list);
    await tester.tap(add);
    await tester.pumpAndSettle();
    // One task, in the kitchen of the example home, and none anywhere else.
    final added = await state.repository.tasksOf(roomId: kitchen);
    expect([for (final e in added) e.task.homeId], [example]);
    final all = await state.repository.db
        .customSelect('SELECT COUNT(*) AS n FROM tasks')
        .getSingle();
    expect(all.read<int>('n'), 1);
  });

  group('Mark as done', () {
    const manual = {
      'create-home.2',
      'create-home.3',
      'recurring-task.4',
      'report-problem.2',
    };

    test('the file has four steps that leave no trace', () {
      expect({
        for (final s in guide.steps)
          if (s.manual) s.id,
      }, manual);
    });

    testWidgets('on those four steps only', (tester) async {
      await onPhone(tester);
      await pumpApp(
        tester,
        seed: (r) async {
          await r.createHome(name: 'Main house');
          await r.createExampleHome(guide, language: 'en');
        },
      );
      await tester.tap(destination('More'));
      await tester.pumpAndSettle();
      final entry = find.byKey(const Key('more-guide'));
      await tester.scrollUntilVisible(
        entry,
        200,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.tap(entry);
      await tester.pumpAndSettle();
      final seen = <String>{};
      for (final scenario in guide.scenarios) {
        final row = find.byKey(Key('guide-scenario-${scenario.id}'));
        await tester.scrollUntilVisible(
          row,
          200,
          scrollable: find.byType(Scrollable).last,
        );
        await tester.tap(row);
        await tester.pumpAndSettle();
        for (final step in scenario.steps) {
          final card = find.byKey(Key('guide-step-${step.id}'));
          await tester.scrollUntilVisible(
            card,
            200,
            scrollable: find.byType(Scrollable).last,
          );
          final tick = find.byKey(Key('guide-tick-${step.id}'));
          if (tick.evaluate().isNotEmpty) seen.add(step.id);
        }
        await back(tester);
      }
      expect(seen, manual);
    });
  });
}
