// SPDX-License-Identifier: AGPL-3.0-only

import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:housecairn_mobile/data/repository.dart';
import 'package:housecairn_mobile/ui/project_screens.dart';
import 'package:housecairn_mobile/ui/state.dart';
import 'package:housecairn_mobile/ui/stock_format.dart';
import 'package:material_ui/material_ui.dart';

import 'support/app.dart';
import 'support/fakes.dart';
import 'support/lot2b.dart';
import 'support/lot3b.dart';

/// The amount fields write and read money in the language of the phone, and
/// store what they stored before (docs/protocol.md, 2.2: two decimals).
void main() {
  group('the text of an amount', () {
    final value = Decimal.parse('1200');

    test('is written with the separators of the language', () {
      expect(moneyFieldText('fr', value), '1\u202f200,00');
      expect(moneyFieldText('en', value), '1,200.00');
      expect(moneyFieldText('fr', Decimal.parse('300')), '300,00');
      expect(moneyFieldText('en', Decimal.parse('0.5')), '0.50');
      expect(moneyFieldText('fr', Decimal.parse('1200.01')), '1\u202f200,01');
    });

    test('is read with a comma or a point in French, spaces ignored', () {
      for (final typed in [
        '1 200,50',
        '1\u00a0200,50',
        '1\u202f200,50',
        '1200,50',
        '1200.50',
        ' 1200.5 0',
      ]) {
        expect(amountInput('fr', typed), startsWith('1200.5'), reason: typed);
      }
      expect(amountInput('fr', '1 200,50'), '1200.50');
      expect(amountInput('fr', '1200.50'), '1200.50');
    });

    test('is read as English writes it: a comma only groups', () {
      expect(amountInput('en', '1,200.50'), '1200.50');
      expect(amountInput('en', '1200.50'), '1200.50');
      expect(amountInput('en', '1 200.50'), '1200.50');
      // Not a grouping: left for the validator, as a decimal comma.
      expect(amountInput('en', '12,5'), '12.5');
    });

    test('what a field shows is what it reads back', () {
      for (final locale in ['fr', 'en']) {
        for (final text in ['0', '300', '1200.01', '9999999999.99']) {
          final shown = moneyFieldText(locale, Decimal.parse(text));
          expect(
            Decimal.parse(amountInput(locale, shown)),
            Decimal.parse(text),
            reason: '$locale $text',
          );
        }
      }
    });
  });

  for (final locale in ['fr', 'en']) {
    String t(String en, String fr) => locale == 'en' ? en : fr;
    final shown = locale == 'fr' ? '300,00' : '300.00';
    final quoteShown = locale == 'fr' ? '1\u202f200,01' : '1,200.01';

    Future<(Lot3b, AppState)> start(WidgetTester tester) async {
      await onPhone(tester);
      late Lot3b data;
      final state = await pumpApp(
        tester,
        locale: locale,
        seed: (r) async => data = await Lot3b.seed(r),
        notifier: FakeNotifier(),
      );
      await state.choose(data.main);
      await tester.pumpAndSettle();
      return (data, state);
    }

    String fieldText(WidgetTester tester, String key) =>
        tester.widget<TextFormField>(find.byKey(Key(key))).controller!.text;

    Future<void> save(WidgetTester tester) async {
      await tester.tap(find.text(t('Save', 'Enregistrer')));
      await tester.pumpAndSettle();
    }

    testWidgets('a budget line shows its amounts in the language, $locale', (
      tester,
    ) async {
      final (data, _) = await start(tester);
      await openScreen(
        tester,
        LineFormScreen(
          homeId: data.main,
          projectId: data.project,
          lineId: data.line,
        ),
      );
      expect(fieldText(tester, 'line-planned'), shown);
      expect(
        fieldText(tester, 'line-paid'),
        locale == 'fr' ? '120,00' : '120.00',
      );
    });

    testWidgets('a quote shows its amount in the language, $locale', (
      tester,
    ) async {
      final (data, _) = await start(tester);
      await openScreen(
        tester,
        QuoteFormScreen(
          homeId: data.main,
          projectId: data.project,
          quoteId: data.quote,
        ),
      );
      expect(fieldText(tester, 'quote-amount'), quoteShown);
    });

    testWidgets('the envelope shows its amount in the language, $locale', (
      tester,
    ) async {
      final (data, _) = await start(tester);
      await openScreen(tester, EnvelopeFormScreen(homeId: data.main));
      expect(
        fieldText(tester, 'envelope-amount'),
        locale == 'fr' ? '5\u202f000,00' : '5,000.00',
      );
    });

    for (final (typed, stored) in [
      ('1 200,50', '1200.50'),
      ('1200.50', '1200.50'),
      ('1\u00a0200,5', '1200.50'),
      if (locale == 'en') ('1,200.50', '1200.50'),
    ]) {
      testWidgets('"$typed" is saved as $stored, $locale', (tester) async {
        final (data, state) = await start(tester);
        await openScreen(
          tester,
          LineFormScreen(
            homeId: data.main,
            projectId: data.project,
            lineId: data.line,
          ),
        );
        await tester.enterText(find.byKey(const Key('line-planned')), typed);
        await save(tester);
        final line = await state.repository.budgetLine(data.line);
        expect(line!.planned, stored);
        expect(line.paid, '120.00');
      });
    }

    testWidgets('an amount that is not one is refused, $locale', (
      tester,
    ) async {
      final (data, state) = await start(tester);
      await openScreen(
        tester,
        LineFormScreen(
          homeId: data.main,
          projectId: data.project,
          lineId: data.line,
        ),
      );
      for (final typed in ['abc', '12.345', '1.2.3', '-5', '1,2,3']) {
        await tester.enterText(find.byKey(const Key('line-planned')), typed);
        await save(tester);
        expect(
          find.text(
            t(
              'Give an amount of money, such as 1250.50.',
              'Indiquez un montant, par exemple 1250,50.',
            ),
          ),
          findsOneWidget,
          reason: typed,
        );
        expect(
          (await state.repository.budgetLine(data.line))!.planned,
          '300.00',
        );
      }
    });

    testWidgets('a quote saved untouched keeps its amount, $locale', (
      tester,
    ) async {
      final (data, state) = await start(tester);
      await openScreen(
        tester,
        QuoteFormScreen(
          homeId: data.main,
          projectId: data.project,
          quoteId: data.quote,
        ),
      );
      await save(tester);
      expect((await state.repository.quote(data.quote))!.amount, '1200.01');
    });
  }
}
