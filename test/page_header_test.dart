// SPDX-License-Identifier: AGPL-3.0-only

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:housecairn_mobile/design/widgets.dart';
import 'package:housecairn_mobile/ui/report_screens.dart';
import 'package:housecairn_mobile/ui/task_screen.dart';
import 'package:material_ui/material_ui.dart';

import 'support/app.dart';

/// The header of a screen and More (design/patterns.md of the web, "Header"
/// and "More"; lots D4 and D6).
void main() {
  Future<void> openMore(WidgetTester tester, String label) async {
    await tester.tap(destination(label));
    await tester.pumpAndSettle();
  }

  testWidgets('the title is the h1 of the content and wraps, never cut', (
    tester,
  ) async {
    await onPhone(tester, textScale: 2);
    final state = await pumpApp(tester, locale: 'fr');
    final home = state.current!;
    final navigator = tester.state<NavigatorState>(find.byType(Navigator).last);
    navigator.push(hcRoute(ReportFormScreen(homeId: home.id)));
    await tester.pumpAndSettle();
    final title = find.widgetWithText(HcLargeTitle, 'Signaler un problème');
    expect(title, findsOneWidget);
    // Not in the bar: the bar has the back button and the action only.
    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.text('Signaler un problème'),
      ),
      findsNothing,
    );
    final paragraph = tester.renderObject<RenderParagraph>(
      find.descendant(of: title, matching: find.byType(RichText)),
    );
    expect(paragraph.didExceedMaxLines, isFalse);
    // The action of the bar is the web's label, word for word.
    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.text('Envoyer le signalement'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('on iOS a form opens as a sheet, Cancel on the left', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    await onPhone(tester);
    final state = await pumpApp(tester);
    final route = hcRoute(ReportFormScreen(homeId: state.current!.id));
    expect((route as PageRoute<void>).fullscreenDialog, isTrue);
    tester.state<NavigatorState>(find.byType(Navigator).last).push(route);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('sheet-cancel')), findsOneWidget);
    await tester.tap(find.byKey(const Key('sheet-cancel')));
    await tester.pumpAndSettle();
    expect(find.byType(ReportFormScreen), findsNothing);
    debugDefaultTargetPlatformOverride = null;
  });

  test(
    'on iOS the page of a task is a page, its form and a new one sheets',
    () {
      // The page of a task is to read (lot D2); Edit the task and a new task
      // open the form, a sheet on iOS (lot D4).
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      bool sheet(Route<Object?> route) =>
          (route as PageRoute<Object?>).fullscreenDialog;
      expect(
        sheet(hcRoute(const TaskScreen(homeId: 'h', taskId: 't'))),
        isFalse,
      );
      expect(sheet(hcRoute(const TaskScreen(homeId: 'h'))), isTrue);
      expect(
        sheet(hcRouteOf<bool>(const TaskFormScreen(homeId: 'h', taskId: 't'))),
        isTrue,
      );
      debugDefaultTargetPlatformOverride = null;
    },
  );

  testWidgets('on Android a form stays a page, its back button is Cancel', (
    tester,
  ) async {
    await onPhone(tester);
    final state = await pumpApp(tester);
    final route = hcRoute(ReportFormScreen(homeId: state.current!.id));
    expect((route as PageRoute<void>).fullscreenDialog, isFalse);
  });

  for (final (locale, more, groups, home) in [
    (
      'en',
      'More',
      ['Home', 'Me', 'Help', 'How you use Housecairn'],
      ['Reports', 'Contractors', 'QR labels', 'My homes'],
    ),
    (
      'fr',
      'Plus',
      ['Logement', 'Moi', 'Aide', 'Utilisation de Housecairn'],
      ['Signalements', 'Intervenants', 'Étiquettes QR', 'Mes logements'],
    ),
  ]) {
    testWidgets('More has the groups of the web, in its order ($locale)', (
      tester,
    ) async {
      await onPhone(tester, height: 1600);
      await pumpApp(tester, locale: locale);
      await openMore(tester, more);
      final headings = tester
          .widgetList<HcSectionHeading>(find.byType(HcSectionHeading))
          .map((h) => h.text)
          .toList();
      expect(headings, groups);
      final rows = tester
          .widgetList<HcRow>(find.byType(HcRow))
          .map((r) => r.title)
          .take(home.length)
          .toList();
      expect(rows, home);
      // Every entry of Home and Me has its subtitle, as on the web.
      for (final key in [
        'more-reports',
        'more-contractors',
        'more-homes',
        'more-notifications',
      ]) {
        final row = tester.widget<HcRow>(find.byKey(Key(key)));
        expect(row.text, isNotNull, reason: key);
      }
      // An action of a list is not an entry of More.
      expect(
        find.text(
          locale == 'en' ? 'Add from a template' : 'Ajouter depuis un modèle',
        ),
        findsNothing,
      );
    });
  }
}
