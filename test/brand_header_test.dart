// SPDX-License-Identifier: AGPL-3.0-only

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:housecairn_mobile/design/brand.dart';
import 'package:housecairn_mobile/design/icons.dart';
import 'package:housecairn_mobile/design/tokens.dart';
import 'package:material_ui/material_ui.dart';

import 'support/app.dart';
import 'support/fixture.dart';

/// The brand and the help button in the bar of the five section roots, as the
/// web shows them on a phone (`shell/brand.html`, `shell/help_link.html`,
/// release v0.4.0): the cairn at `layout.logo-icon` and the name HouseCairn,
/// on the roots only, and the help link to the page of the documentation.
void main() {
  const roots = [
    ('en', 'Today', 'screens/today/'),
    ('en', 'Rooms', 'screens/rooms/'),
    ('en', 'Projects', 'screens/projects/'),
    ('en', 'Budget', 'screens/budget/'),
    ('en', 'More', 'screens/more/'),
  ];

  for (final (locale, label, page) in roots) {
    testWidgets('the bar of $label has the brand and the help button', (
      tester,
    ) async {
      final opened = <Uri>[];
      await onPhone(tester, width: 390);
      await pumpApp(
        tester,
        locale: locale,
        openUrl: (uri) async {
          opened.add(uri);
          return true;
        },
      );
      if (label != 'Today') {
        await tester.tap(destination(label));
        await tester.pumpAndSettle();
      }
      final bar = find.byType(AppBar);
      // The icon is the cairn of the web at the token layout.logo-icon.
      final icon = find.descendant(
        of: bar,
        matching: find.byKey(const Key('brand-icon')),
      );
      expect(icon, findsOneWidget);
      expect(tester.getSize(icon), const Size.square(HcLayout.logoIcon));
      expect(
        find.descendant(of: bar, matching: find.text('HouseCairn')),
        findsOneWidget,
      );
      // Read as one image named HouseCairn.
      expect(tester.getSemantics(find.byType(HcBrand)).label, 'HouseCairn');
      // The bar keeps its height: the brand takes the place the bar had.
      expect(tester.getSize(bar).height, HcComponent.appbarMinHeight);
      // The brand is at the left, the help at the right of the bar.
      expect(tester.getTopLeft(icon).dx, lessThan(24));
      final help = find.byKey(const Key('help-button'));
      expect(help, findsOneWidget);
      expect(tester.getTopRight(help).dx, greaterThan(390 - 24));
      expect(hcIcon(HcIcons.help), findsOneWidget);
      // The page title stays under the bar, as the h1 of the web.
      expect(find.byKey(const Key('page-title')), findsOneWidget);
      await tester.tap(help);
      await tester.pumpAndSettle();
      expect(opened, [Uri.parse('https://docs.housecairn.app/$page')]);
    });
  }

  testWidgets('the help opens the French page of the documentation in French', (
    tester,
  ) async {
    final opened = <Uri>[];
    await onPhone(tester, width: 390);
    await pumpApp(
      tester,
      locale: 'fr',
      openUrl: (uri) async {
        opened.add(uri);
        return true;
      },
    );
    await tester.tap(find.byKey(const Key('help-button')));
    await tester.pumpAndSettle();
    expect(opened, [
      Uri.parse('https://docs.housecairn.app/fr/screens/today/'),
    ]);
    expect(find.byTooltip('Aide sur cette page'), findsOneWidget);
  });

  testWidgets('a page below a root has no brand, as the web on a phone', (
    tester,
  ) async {
    await onPhone(tester, width: 390);
    await pumpApp(tester);
    await tester.tap(destination('More'));
    await tester.pumpAndSettle();
    await scrollMoreTo(tester, find.byKey(const Key('more-about')));
    await tester.tap(find.byKey(const Key('more-about')));
    await tester.pumpAndSettle();
    expect(find.byType(HcBrand), findsNothing);
    // It has no action of its own: the help button of its page (lot D8b).
    expect(find.byKey(const Key('help-button')), findsOneWidget);
  });

  testWidgets('on an iPhone the brand stays in the bar when the page scrolls', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    await onPhone(tester, width: 390, height: 500);
    await pumpApp(tester);
    await tester.tap(destination('More'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(Scrollable).last, const Offset(0, -400));
    await tester.pumpAndSettle();
    expect(find.byType(HcBrand), findsOneWidget);
    // The title is not copied into the bar: the brand keeps the place.
    expect(
      find.descendant(of: find.byType(AppBar), matching: find.text('More')),
      findsNothing,
    );
  });

  for (final (locale, width, scale) in [
    ('en', 320.0, 1.0),
    ('fr', 320.0, 2.0),
    ('en', 360.0, 1.5),
  ]) {
    testWidgets(
      'with two homes the page fits ${width.round()} px, text x$scale '
      '($locale)',
      (tester) async {
        await onPhone(tester, width: width, textScale: scale);
        await pumpApp(
          tester,
          locale: locale,
          seed: (repository) async => TwoHomes.create(repository),
        );
        expect(find.byKey(const Key('home-selector')), findsOneWidget);
        // No overflow was reported, and every part of the bar is on screen.
        expect(tester.takeException(), isNull);
        for (final key in ['brand-icon', 'help-button']) {
          final box = tester.getRect(find.byKey(Key(key)));
          expect(box.left, greaterThanOrEqualTo(0), reason: key);
          expect(box.right, lessThanOrEqualTo(width), reason: key);
        }
        // The selector is under the title, not in the bar (lot D8b), and fits
        // the width of the page.
        final selector = tester.getRect(find.byKey(const Key('home-selector')));
        expect(selector.right, lessThanOrEqualTo(width));
        // The name goes before it is cut: whole or not shown, the cairn stays.
        final name = find.byKey(const Key('brand-name'));
        if (name.evaluate().isNotEmpty) {
          expect(
            tester.renderObject<RenderParagraph>(name).didExceedMaxLines,
            isFalse,
          );
        }
        final brand = tester.getRect(find.byType(HcBrand));
        final help = tester.getRect(find.byKey(const Key('help-button')));
        expect(brand.right, lessThanOrEqualTo(help.left));
      },
    );
  }
}
