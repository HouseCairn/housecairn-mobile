// SPDX-License-Identifier: AGPL-3.0-only

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:housecairn_mobile/data/repository.dart';
import 'package:housecairn_mobile/design/tokens.dart';
import 'package:material_ui/material_ui.dart';

import 'support/app.dart';
import 'support/fixture.dart';
import 'support/goldens.dart';

/// Today and the header, as design/patterns.md of the web draws them (lot
/// D8b): the open reports line of Today, the selector of the home under the
/// `h1`, the back button of iOS with the title of the previous page, and the
/// help button on a page that has no other action.
void main() {
  // Manrope, as the phone draws it: the test font is much wider.
  setUpAll(() async {
    useTolerantGoldens();
    await loadAppFonts();
  });

  /// One home with one open report.
  Future<void> startWithReport(WidgetTester tester) async {
    await onPhone(tester, width: 390, height: 844);
    await pumpApp(
      tester,
      seed: (r) async {
        final home = await r.createHome(name: 'Main home');
        await r.createReport(home, title: 'The tap drips');
      },
    );
  }

  group('the open reports line of Today', () {
    testWidgets('is sage-soft, with the button at the right on its line', (
      tester,
    ) async {
      await startWithReport(tester);
      final banner = find.byKey(const Key('today-reports'));
      expect(banner, findsOneWidget);
      final line = find.descendant(
        of: banner,
        matching: find.byType(DecoratedBox),
      );
      final decoration =
          tester.widget<DecoratedBox>(line.first).decoration as BoxDecoration;
      // `.undo-banner`: sage-soft, a border, the radius `md`.
      expect(decoration.color, HcColors.sageSoft);
      expect(decoration.border, Border.all(color: HcColors.border));
      expect(decoration.borderRadius, BorderRadius.circular(HcRadius.md));
      final box = tester.getRect(line.first);
      final count = tester.getRect(
        find.byKey(const Key('today-reports-count')),
      );
      final see = tester.getRect(find.byKey(const Key('today-reports-see')));
      // The count at the left, the button at the right, on the same line.
      expect(count.right, lessThanOrEqualTo(see.left));
      expect(see.center.dy, closeTo(count.center.dy, 1.5));
      // 16 px (space-4) between the line's edge and the button.
      expect(box.right - see.right, closeTo(HcSpace.s4 + 1, 1.5));
      expect(count.left - box.left, closeTo(HcSpace.s4 + 1, 1.5));
      // The line is one row tall: the button, 8 px (space-2) above and under.
      expect(box.height, lessThan(see.height + 2 * HcSpace.s2 + 4));
      // "Report a problem" follows it, under the line.
      final add = tester.getRect(find.byKey(const Key('today-report-add')));
      expect(add.top, greaterThanOrEqualTo(box.bottom));
    });
  });

  group('the selector of the home', () {
    Future<void> startWithTwoHomes(WidgetTester tester) async {
      await onPhone(tester, width: 390, height: 844);
      await pumpApp(tester, seed: (r) async => TwoHomes.create(r));
    }

    for (final label in ['Today', 'Rooms', 'Projects', 'Budget']) {
      testWidgets('is under the h1 of $label, not in the bar', (tester) async {
        await startWithTwoHomes(tester);
        await tester.tap(destination(label));
        await tester.pumpAndSettle();
        final selector = find.byKey(const Key('home-selector'));
        expect(selector, findsOneWidget);
        expect(
          find.descendant(of: find.byType(AppBar), matching: selector),
          findsNothing,
        );
        final title = tester.getRect(find.byKey(const Key('page-title')));
        final line = tester.getRect(selector);
        expect(line.top, greaterThanOrEqualTo(title.bottom));
        // At the left, in line with the title.
        expect(line.left, closeTo(title.left, HcSpace.s1 + 1));
        // The bar keeps the whole brand, name included, and the help button.
        expect(find.byKey(const Key('brand-name')), findsOneWidget);
        expect(find.byKey(const Key('help-button')), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('is not on a page that is not a root', (tester) async {
      await startWithTwoHomes(tester);
      await tester.tap(destination('More'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('more-contractors')));
      await tester.pumpAndSettle();
      expect(find.text('Contractors'), findsWidgets);
      expect(find.byKey(const Key('home-selector')), findsNothing);
    });

    testWidgets('is not shown with one home', (tester) async {
      await startWithReport(tester);
      expect(find.byKey(const Key('home-selector')), findsNothing);
    });
  });

  group('the back button of iOS', () {
    void ios() {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
    }

    testWidgets('names the previous page and goes back', (tester) async {
      ios();
      await onPhone(tester, width: 390, height: 844);
      await pumpApp(tester);
      await tester.tap(destination('More'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('more-contractors')));
      await tester.pumpAndSettle();
      final title = find.byKey(const Key('ios-back-title'));
      expect(title, findsOneWidget);
      expect(tester.widget<Text>(title).data, 'More');
      // Whole, not cut with an ellipsis.
      expect(
        tester.renderObject<RenderParagraph>(title).didExceedMaxLines,
        isFalse,
      );
      expect(tester.getRect(title).width, greaterThan(HcSpace.s6));
      // A target of 48, whole in the bar.
      final back = tester.getRect(find.byKey(const Key('ios-back')));
      expect(back.height, greaterThanOrEqualTo(HcLayout.touchTargetLg));
      expect(back.left, greaterThanOrEqualTo(0));
      await tester.tap(find.byKey(const Key('ios-back')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('ios-back')), findsNothing);
      expect(find.byKey(const Key('more-contractors')), findsOneWidget);
    });

    testWidgets('names the page of the section it comes from, in French', (
      tester,
    ) async {
      ios();
      await onPhone(tester, width: 390, height: 844);
      await pumpApp(tester, locale: 'fr');
      await tester.tap(destination('Plus'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('more-homes')));
      await tester.pumpAndSettle();
      expect(
        tester.widget<Text>(find.byKey(const Key('ios-back-title'))).data,
        'Plus',
      );
    });

    testWidgets('keeps a long title in its two fifths of the bar', (
      tester,
    ) async {
      ios();
      await onPhone(tester, width: 320, height: 640, textScale: 2);
      await pumpApp(tester, seed: (r) async => TwoHomes.create(r));
      await tester.tap(destination('More'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const Key('more-contractors')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('more-contractors')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Main plumber'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<Text>(find.byKey(const Key('ios-back-title'))).data,
        'Contractors',
      );
      expect(tester.takeException(), isNull);
      final back = tester.getRect(find.byKey(const Key('ios-back')));
      expect(back.width, lessThanOrEqualTo(320 * 2 / 5 + 0.5));
    });

    testWidgets('a form opened as a sheet keeps its Cancel', (tester) async {
      ios();
      await onPhone(tester, width: 390, height: 844);
      await pumpApp(tester);
      await tester.tap(find.byKey(const Key('today-report-add')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('sheet-cancel')), findsOneWidget);
      expect(find.byKey(const Key('ios-back')), findsNothing);
    });
  });

  testWidgets('on Android the back button is the system one', (tester) async {
    await onPhone(tester, width: 390, height: 844);
    await pumpApp(tester);
    await tester.tap(destination('More'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('more-contractors')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('ios-back')), findsNothing);
    await back(tester);
    expect(find.byKey(const Key('more-contractors')), findsOneWidget);
  });

  group('the help button on a page with no other action', () {
    Future<void> openFromMore(WidgetTester tester, String key) async {
      await tester.tap(destination('More'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(Key(key)));
      await tester.pumpAndSettle();
    }

    final pages = [
      ('more-contractors', 'screens/contractors/'),
      ('more-homes', 'screens/homes/'),
      ('more-reports', 'screens/reports/'),
      ('more-notifications', 'screens/notifications/'),
      ('more-about', 'screens/about/'),
    ];
    for (final (key, page) in pages) {
      testWidgets('$key opens $page', (tester) async {
        await onPhone(tester, width: 390, height: 844);
        final opened = <Uri>[];
        await pumpApp(
          tester,
          openUrl: (uri) async {
            opened.add(uri);
            return true;
          },
        );
        await openFromMore(tester, key);
        final help = find.descendant(
          of: find.byType(AppBar),
          matching: find.byKey(const Key('help-button')),
        );
        expect(help, findsOneWidget);
        await tester.tap(help);
        await tester.pump();
        expect(opened, [Uri.parse('https://docs.housecairn.app/$page')]);
      });
    }

    testWidgets('a page with Edit in its bar has no help', (tester) async {
      await onPhone(tester, width: 390, height: 844);
      await pumpApp(tester, seed: (r) async => TwoHomes.create(r));
      await tester.tap(destination('Rooms'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Main kitchen'));
      await tester.pumpAndSettle();
      expect(find.text('Edit'), findsOneWidget);
      expect(find.byKey(const Key('help-button')), findsNothing);
    });
  });

  // Today with an open report, 360 px: the banner at both text sizes.
  for (final locale in ['en', 'fr']) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('golden: Today with an open report, $locale x$scale', (
        tester,
      ) async {
        await onPhone(tester, textScale: scale);
        await pumpApp(
          tester,
          locale: locale,
          seed: (r) async {
            final home = await r.createHome(name: 'Main home');
            await r.createReport(home, title: 'The tap drips');
          },
        );
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile(
            'goldens/today_reports_${locale}_x${scale.toInt()}.png',
          ),
        );
      });
    }
  }
}
