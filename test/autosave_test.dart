// SPDX-License-Identifier: AGPL-3.0-only

// The sheets of a room, an article and a task saved as they are changed
// (web ADR 0082): nothing is written while the typing goes on, the change is
// written once the typing pauses, "Saved" is shown, and a refusal of the
// repository is shown while what was typed stays in the field.

import 'package:flutter_test/flutter_test.dart';
import 'package:housecairn_mobile/data/repository.dart';
import 'package:housecairn_mobile/ui/autosave.dart';
import 'package:housecairn_mobile/ui/rooms.dart';
import 'package:housecairn_mobile/ui/state.dart';
import 'package:housecairn_mobile/ui/stock_screens.dart';
import 'package:housecairn_mobile/ui/task_form_screen.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:material_ui/material_ui.dart';

import 'screens_2b_test.dart' show type;
import 'support/app.dart';
import 'support/fakes.dart';
import 'support/lot2b.dart';

/// One sheet under test: how to create the row, open its sheet, and read back
/// the field that is typed in, and how to delete the row.
class _Sheet {
  const _Sheet({
    required this.name,
    required this.field,
    required this.create,
    required this.open,
    required this.read,
    required this.remove,
  });

  final String name;
  final String field;
  final Future<String> Function(Repository r, String home) create;
  final Widget Function(String home, String id) open;
  final Future<String?> Function(Repository r, String id) read;
  final Future<void> Function(Repository r, String id) remove;
}

final _sheets = [
  _Sheet(
    name: 'room',
    field: 'room-name',
    create: (r, home) =>
        r.createRoom(home, name: 'Pantry', kind: 'other', position: 9),
    open: (home, id) => RoomFormScreen(homeId: home, roomId: id),
    read: (r, id) async => (await r.room(id))?.name,
    remove: (r, id) => r.deleteRoom(id),
  ),
  _Sheet(
    name: 'article',
    field: 'article-name',
    create: (r, home) => r.addArticle(home, const ArticleInput(name: 'Filter')),
    open: (home, id) => ArticleFormScreen(homeId: home, articleId: id),
    read: (r, id) async => (await r.article(id))?.name,
    remove: (r, id) => r.deleteArticle(id),
  ),
  _Sheet(
    name: 'task',
    field: 'task-title',
    create: (r, home) => r.createTask(home, const TaskInput(title: 'Sweep')),
    open: (home, id) => TaskFormScreen(homeId: home, taskId: id),
    read: (r, id) async => (await r.task(id))?.title,
    remove: (r, id) => r.deleteTask(id),
  ),
];

void main() {
  setUpAll(initializeDateFormatting);

  for (final locale in ['en', 'fr']) {
    String t(String en, String fr) => locale == 'en' ? en : fr;

    Future<(AppState, String home)> start(WidgetTester tester) async {
      await onPhone(tester);
      late Lot2b data;
      final state = await pumpApp(
        tester,
        locale: locale,
        seed: (r) async => data = await Lot2b.seed(r),
        notifier: FakeNotifier(),
      );
      await state.choose(data.homes.main);
      await tester.pumpAndSettle();
      return (state, data.homes.main);
    }

    for (final sheet in _sheets) {
      testWidgets('the sheet of a ${sheet.name} saves itself after a pause '
          'of typing, $locale', (tester) async {
        final (state, home) = await start(tester);
        final id = await sheet.create(state.repository, home);
        final before = await sheet.read(state.repository, id);
        await openScreen(tester, sheet.open(home, id));
        expect(find.byKey(const Key('autosave-status')), findsNothing);
        final semantics = tester.ensureSemantics();
        await type(tester, sheet.field, 'Changed');
        // Nothing is written while the typing goes on.
        await tester.pump(const Duration(milliseconds: 400));
        expect(await sheet.read(state.repository, id), before);
        expect(find.byKey(const Key('autosave-status')), findsNothing);
        await tester.pump(autosavePause);
        await tester.pumpAndSettle();
        expect(await sheet.read(state.repository, id), 'Changed');
        expect(find.byKey(const Key('autosave-status')), findsOneWidget);
        expect(find.text(t('Saved', 'Enregistré')), findsOneWidget);
        expect(
          tester.takeAnnouncements().map((a) => a.message),
          contains(t('Saved', 'Enregistré')),
        );
        // A further change hides "Saved" until it is saved in its turn.
        await type(tester, sheet.field, 'Changed again');
        await tester.pump();
        expect(find.byKey(const Key('autosave-status')), findsNothing);
        await tester.pump(autosavePause);
        await tester.pumpAndSettle();
        expect(await sheet.read(state.repository, id), 'Changed again');
        expect(find.byKey(const Key('autosave-status')), findsOneWidget);
        semantics.dispose();
      });

      testWidgets('the sheet of a ${sheet.name} keeps what was typed when the '
          'repository refuses it, $locale', (tester) async {
        final (state, home) = await start(tester);
        final id = await sheet.create(state.repository, home);
        await openScreen(tester, sheet.open(home, id));
        // The row is deleted meanwhile (by another device, after a sync): the
        // repository refuses the write.
        await sheet.remove(state.repository, id);
        await type(tester, sheet.field, 'Typed too late');
        await tester.pump(autosavePause);
        await tester.pumpAndSettle();
        expect(
          find.text(t('This no longer exists.', "Cela n'existe plus.")),
          findsOneWidget,
        );
        // What was typed is still in the field, and nothing is said saved.
        expect(
          tester
              .widget<EditableText>(
                find.descendant(
                  of: find.byKey(Key(sheet.field)),
                  matching: find.byType(EditableText),
                ),
              )
              .controller
              .text,
          'Typed too late',
        );
        expect(find.byKey(const Key('autosave-status')), findsNothing);
        expect(await sheet.read(state.repository, id), isNull);
      });
    }
  }
}
