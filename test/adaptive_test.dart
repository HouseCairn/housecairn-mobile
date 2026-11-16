// SPDX-License-Identifier: AGPL-3.0-only

// The controls that follow the platform (design lot D5; `design/patterns.md`
// of the web, "Platform adaptations", rows 1 to 4): on an iPhone the wheel of
// iOS for a list and a date, the alert of iOS and its switch; on Android the
// menu, the calendar, the dialog and the switch of Material, as before. The
// colours and the font stay those of Housecairn on both. Each test runs on
// both platforms, set by `debugDefaultTargetPlatformOverride`; the golden
// files of iOS are in English and French:
//   flutter test --update-goldens test/adaptive_test.dart

import 'dart:async';

import 'package:cupertino_ui/cupertino_ui.dart'
    show
        CupertinoActionSheet,
        CupertinoAlertDialog,
        CupertinoDatePicker,
        CupertinoPicker,
        CupertinoSwitch,
        CupertinoTheme;
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:housecairn_mobile/data/repository.dart';
import 'package:housecairn_mobile/design/adaptive.dart';
import 'package:housecairn_mobile/design/theme.dart';
import 'package:housecairn_mobile/design/tokens.dart';
import 'package:housecairn_mobile/l10n/app_localizations.dart';
import 'package:housecairn_mobile/ui/parts.dart';
import 'package:housecairn_mobile/ui/task_screen.dart';
import 'package:housecairn_mobile/ui/today.dart';
import 'package:material_ui/material_ui.dart';

import 'support/app.dart';
import 'support/fixture.dart';
import 'support/goldens.dart';
import 'support/lot2b.dart' show stateOf;

late TwoHomes homes;
late String bins;

/// The homes of the fixture and a task that repeats, due a week ago.
Future<void> seed(Repository repository) async {
  homes = await TwoHomes.create(repository);
  bins = await repository.createTask(
    homes.main,
    TaskInput(
      title: 'Put the bins out',
      dueOn: repository.today().addDays(-7),
      repeatMode: 'after_last',
      repeatUnit: 'week',
    ),
  );
}

/// Runs [body] with the platform set to [platform], and puts it back after,
/// even when [body] fails (the test framework checks it is unset).
Future<void> onPlatform(
  TargetPlatform platform,
  Future<void> Function() body,
) async {
  debugDefaultTargetPlatformOverride = platform;
  try {
    await body();
  } finally {
    debugDefaultTargetPlatformOverride = null;
  }
}

/// Opens the form of the task of [seed], as Edit the task opens it.
Future<void> openTask(WidgetTester tester, {String locale = 'en'}) async {
  await pumpApp(tester, locale: locale, seed: seed);
  unawaited(
    Navigator.of(tester.element(find.byType(TodayScreen))).push(
      MaterialPageRoute<void>(
        builder: (_) => TaskFormScreen(homeId: homes.main, taskId: bins),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// Opens the page of the task of [seed] (lot D2), as Today opens it.
Future<void> openTaskPage(WidgetTester tester, {String locale = 'en'}) async {
  await pumpApp(tester, locale: locale, seed: seed);
  unawaited(
    Navigator.of(tester.element(find.byType(TodayScreen))).push(
      MaterialPageRoute<void>(
        builder: (_) => TaskScreen(homeId: homes.main, taskId: bins),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// A screen with [child] in the theme and the languages of the app, for the
/// controls alone.
Widget harness(Widget child) => MaterialApp(
  theme: housecairnTheme(),
  locale: const Locale('en'),
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: const [
    AppLocalizations.delegate,
    ...GlobalMaterialLocalizations.delegates,
  ],
  home: Scaffold(body: Center(child: child)),
);

/// The field of key [key] (Repeat, Due date of the task form).
Finder field(String key) => find.byKey(Key(key));

/// Scrolls [target] into view, then taps it.
Future<void> tapField(WidgetTester tester, Finder target) async {
  await tester.ensureVisible(target);
  await tester.pumpAndSettle();
  await tester.tap(target);
}

void main() {
  const platforms = {
    'Android': TargetPlatform.android,
    'iOS': TargetPlatform.iOS,
  };

  for (final MapEntry(key: name, value: platform) in platforms.entries) {
    final ios = platform == TargetPlatform.iOS;

    group(name, () {
      testWidgets('a list opens the ${ios ? 'wheel of iOS' : 'menu'}', (
        tester,
      ) async {
        await onPlatform(platform, () async {
          await onPhone(tester);
          await openTask(tester);
          expect(
            find.byType(DropdownButtonFormField<String>),
            ios ? findsNothing : findsWidgets,
          );
          await tapField(tester, field('task-repeat'));
          await tester.pumpAndSettle();
          expect(
            find.byKey(const Key('hc-select-wheel')),
            ios ? findsOneWidget : findsNothing,
          );
          expect(
            find.byType(CupertinoPicker),
            ios ? findsOneWidget : findsNothing,
          );
          if (ios) {
            // Once, Fixed date, After the last time: two lines up is Once.
            await tester.drag(
              find.byType(CupertinoPicker),
              const Offset(0, 80),
            );
            await tester.pumpAndSettle();
            await tester.tap(find.byKey(const Key('hc-sheet-done')));
          } else {
            await tester.tap(find.text('Once').last);
          }
          await tester.pumpAndSettle();
          expect(find.byType(CupertinoPicker), findsNothing);
          expect(
            find.descendant(
              of: field('task-repeat'),
              matching: find.text('Once'),
            ),
            findsWidgets,
          );
        });
      });

      if (ios) {
        testWidgets('Cancel on the wheel keeps the choice', (tester) async {
          await onPlatform(platform, () async {
            await onPhone(tester);
            await openTask(tester);
            final before = find.descendant(
              of: field('task-repeat'),
              matching: find.byType(Text),
            );
            final text = tester.widget<Text>(before.first).data;
            await tapField(tester, field('task-repeat'));
            await tester.pumpAndSettle();
            await tester.drag(
              find.byType(CupertinoPicker),
              const Offset(0, 80),
            );
            await tester.pumpAndSettle();
            await tester.tap(find.byKey(const Key('hc-sheet-cancel')));
            await tester.pumpAndSettle();
            expect(tester.widget<Text>(before.first).data, text);
          });
        });
      }

      testWidgets(
        'a date is a field that opens the ${ios ? 'date wheel of iOS' : 'calendar'}',
        (tester) async {
          await onPlatform(platform, () async {
            await onPhone(tester);
            await openTask(tester);
            final due = field('task-due');
            final shown = find.descendant(
              of: find.descendant(
                of: due,
                matching: find.byType(InputDecorator),
              ),
              matching: find.byType(Text),
            );
            final formatted = tester.widget<Text>(shown.first).data!;
            expect(formatted, isNot('No date'));
            await tapField(
              tester,
              find.descendant(of: due, matching: find.text(formatted)),
            );
            await tester.pumpAndSettle();
            expect(
              find.byType(CupertinoDatePicker),
              ios ? findsOneWidget : findsNothing,
            );
            expect(
              find.byType(DatePickerDialog),
              ios ? findsNothing : findsOneWidget,
            );
            if (ios) {
              await tester.tap(find.byKey(const Key('hc-sheet-done')));
            } else {
              await tester.tap(find.text('OK'));
            }
            await tester.pumpAndSettle();
            expect(
              find.descendant(of: due, matching: find.text(formatted)),
              findsOneWidget,
              reason: 'the date shown is kept',
            );
            // The button in the field removes the date.
            await tapField(tester, find.byKey(const Key('hc-date-clear')));
            await tester.pumpAndSettle();
            expect(
              find.descendant(of: due, matching: find.text('No date')),
              findsOneWidget,
            );
            expect(find.byKey(const Key('hc-date-clear')), findsNothing);
          });
        },
      );

      testWidgets(
        'Postpone on the page of a task opens the ${ios ? 'date wheel of iOS' : 'calendar'}',
        (tester) async {
          await onPlatform(platform, () async {
            await onPhone(tester);
            await openTaskPage(tester);
            await tapField(tester, find.byKey(const Key('task-postpone')));
            await tester.pumpAndSettle();
            expect(
              find.byType(CupertinoDatePicker),
              ios ? findsOneWidget : findsNothing,
            );
            expect(
              find.byType(DatePickerDialog),
              ios ? findsNothing : findsOneWidget,
            );
            await tester.tap(
              ios ? find.byKey(const Key('hc-sheet-done')) : find.text('OK'),
            );
            await tester.pumpAndSettle();
            final repository = stateOf(tester).repository;
            final open = (await repository.openOccurrencesOf(bins)).single;
            expect(open.status, 'postponed');
            expect(
              open.dueOn,
              repository.today().addDays(1).iso,
              reason: 'tomorrow by default',
            );
          });
        },
      );

      testWidgets('a confirmation is the ${ios ? 'alert of iOS' : 'dialog'}', (
        tester,
      ) async {
        await onPlatform(platform, () async {
          late BuildContext context;
          await tester.pumpWidget(
            harness(
              Builder(
                builder: (c) {
                  context = c;
                  return const SizedBox.shrink();
                },
              ),
            ),
          );
          final answer = confirmDelete(
            context,
            title: 'Delete?',
            body: 'Gone.',
          );
          await tester.pumpAndSettle();
          expect(
            find.byType(CupertinoAlertDialog),
            ios ? findsOneWidget : findsNothing,
          );
          expect(find.byType(AlertDialog), ios ? findsNothing : findsOneWidget);
          final delete = find.text('Delete');
          final style = tester.widget<Text>(delete).style;
          if (ios) {
            expect(style?.color, HcColors.danger);
            expect(style?.fontFamily, HcFont.family);
            final cancel = tester.widget<Text>(find.text('Cancel')).style;
            expect(cancel?.fontWeight, HcFont.bold, reason: 'Cancel in bold');
            expect(cancel?.color, HcColors.primary);
          }
          await tester.tap(delete);
          await tester.pumpAndSettle();
          expect(await answer, isTrue);
        });
      });

      testWidgets(
        'a choice of actions is the ${ios ? 'action sheet' : 'simple dialog'}',
        (tester) async {
          await onPlatform(platform, () async {
            late BuildContext context;
            await tester.pumpWidget(
              harness(
                Builder(
                  builder: (c) {
                    context = c;
                    return const SizedBox.shrink();
                  },
                ),
              ),
            );
            final answer = showHcChoices<int>(
              context,
              title: 'Attach',
              choices: const [(Key('one'), 1, 'One'), (Key('two'), 2, 'Two')],
            );
            await tester.pumpAndSettle();
            expect(
              find.byType(CupertinoActionSheet),
              ios ? findsOneWidget : findsNothing,
            );
            expect(
              find.byType(SimpleDialog),
              ios ? findsNothing : findsOneWidget,
            );
            await tester.tap(find.byKey(const Key('two')));
            await tester.pumpAndSettle();
            expect(await answer, 2);
          });
        },
      );

      testWidgets(
        'the switch is the ${ios ? 'switch of iOS' : 'switch of Material'}',
        (tester) async {
          await onPlatform(platform, () async {
            var on = false;
            await tester.pumpWidget(
              harness(
                StatefulBuilder(
                  builder: (context, setState) => HcSwitch(
                    value: on,
                    onChanged: (v) => setState(() => on = v),
                  ),
                ),
              ),
            );
            expect(
              find.byType(CupertinoSwitch),
              ios ? findsOneWidget : findsNothing,
            );
            await tester.tap(find.byType(HcSwitch));
            await tester.pumpAndSettle();
            expect(on, isTrue);
            if (ios) {
              expect(
                tester
                    .widget<CupertinoSwitch>(find.byType(CupertinoSwitch))
                    .activeTrackColor,
                HcColors.primary,
              );
            }
          });
        },
      );
    });
  }

  testWidgets(
    'the widgets of iOS read the colours and the font of Housecairn',
    (tester) async {
      await onPlatform(TargetPlatform.iOS, () async {
        late BuildContext context;
        await tester.pumpWidget(
          harness(
            Builder(
              builder: (c) {
                context = c;
                return const SizedBox.shrink();
              },
            ),
          ),
        );
        final theme = CupertinoTheme.of(context);
        expect(theme.primaryColor, HcColors.primary);
        for (final style in [
          theme.textTheme.textStyle,
          theme.textTheme.actionTextStyle,
          theme.textTheme.pickerTextStyle,
          theme.textTheme.dateTimePickerTextStyle,
        ]) {
          expect(style.fontFamily, HcFont.family);
        }
      });
    },
  );

  group('golden files of iOS', () {
    setUpAll(() async {
      useTolerantGoldens();
      await loadAppFonts();
    });

    for (final locale in ['en', 'fr']) {
      Future<void> golden(WidgetTester tester, String name) => expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/ios_${name}_$locale.png'),
      );

      testWidgets('task form, $locale', (tester) async {
        await onPlatform(TargetPlatform.iOS, () async {
          await onPhone(tester);
          await openTask(tester, locale: locale);
          await golden(tester, 'task_form');
        });
      });

      testWidgets('list wheel, $locale', (tester) async {
        await onPlatform(TargetPlatform.iOS, () async {
          await onPhone(tester);
          await openTask(tester, locale: locale);
          await tapField(tester, field('task-repeat'));
          await tester.pumpAndSettle();
          await golden(tester, 'select_sheet');
        });
      });

      testWidgets('date wheel, $locale', (tester) async {
        await onPlatform(TargetPlatform.iOS, () async {
          await onPhone(tester);
          await openTask(tester, locale: locale);
          await tapField(
            tester,
            find.descendant(
              of: field('task-due'),
              matching: find.byType(InputDecorator),
            ),
          );
          await tester.pumpAndSettle();
          await golden(tester, 'date_sheet');
        });
      });

      testWidgets('alert, $locale', (tester) async {
        await onPlatform(TargetPlatform.iOS, () async {
          await onPhone(tester);
          await openTask(tester, locale: locale);
          final context = tester.element(find.byType(TaskFormScreen));
          final l10n = AppLocalizations.of(context);
          unawaited(
            confirmDelete(
              context,
              title: l10n.deleteRoom,
              body: l10n.deleteRoomBody,
            ),
          );
          await tester.pumpAndSettle();
          await golden(tester, 'alert');
        });
      });
    }
  });
}
