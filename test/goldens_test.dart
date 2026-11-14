// SPDX-License-Identifier: AGPL-3.0-only

// Golden files of the screens of lot 2a (Today, Task, Homes) at 360 px, in
// English and French, at text scale 1 and 2, drawn with the app's own fonts
// (docs/adr/0011-design-from-the-web-app.md). The web application has no dark
// theme, so neither has the app. Regenerate after a deliberate change of look:
//   flutter test --update-goldens test/goldens_test.dart
// and review every changed image in the pull request.

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:housecairn_mobile/data/repository.dart';
import 'package:housecairn_mobile/ui/task_screen.dart';
import 'package:housecairn_mobile/ui/today.dart';
import 'package:material_ui/material_ui.dart';

import 'support/app.dart';
import 'support/fixture.dart';
import 'support/goldens.dart';

late TwoHomes homes;
late String bins;

/// The two homes of the fixture, a task of the main home done once (history
/// and a preview of its next dates), and the main home as the current one.
Future<void> seed(Repository repository) async {
  homes = await TwoHomes.create(repository);
  final id = bins = await repository.createTask(
    homes.main,
    TaskInput(
      title: 'Put the bins out',
      dueOn: repository.today().addDays(-7),
      repeatMode: 'after_last',
      repeatUnit: 'week',
    ),
  );
  final open = await repository.openOccurrencesOf(id);
  await repository.complete(open.first.id);
}

void main() {
  setUpAll(() async {
    useTolerantGoldens();
    await loadAppFonts();
  });

  const labels = {
    'en': (more: 'More', homes: 'Homes'),
    'fr': (more: 'Plus', homes: 'Logements'),
  };

  for (final MapEntry(key: locale, value: l) in labels.entries) {
    for (final scale in [1.0, 2.0]) {
      final name = '${locale}_x${scale.toInt()}';

      testWidgets('Today, $name', (tester) async {
        await onPhone(tester, textScale: scale);
        final state = await pumpApp(tester, locale: locale, seed: seed);
        // One home: All homes would list rows of equal dates in an order
        // that is not fixed.
        await state.choose(homes.main);
        await tester.pumpAndSettle();
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/today_$name.png'),
        );
      });

      testWidgets('Task, $name', (tester) async {
        await onPhone(tester, textScale: scale);
        await pumpApp(tester, locale: locale, seed: seed);
        // Opened as Today opens it (the row may be below the fold at x2).
        unawaited(
          Navigator.of(tester.element(find.byType(TodayScreen))).push(
            MaterialPageRoute<void>(
              builder: (_) => TaskScreen(homeId: homes.main, taskId: bins),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/task_$name.png'),
        );
      });

      testWidgets('Homes, $name', (tester) async {
        await onPhone(tester, textScale: scale);
        await pumpApp(tester, locale: locale, seed: seed);
        await tester.tap(destination(l.more));
        await tester.pumpAndSettle();
        await tester.tap(find.text(l.homes));
        await tester.pumpAndSettle();
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/homes_$name.png'),
        );
      });
    }
  }
}
