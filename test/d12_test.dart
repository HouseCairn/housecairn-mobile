// SPDX-License-Identifier: AGPL-3.0-only

// Budget, projects, templates, More, the first start and About as the web
// draws them (design lot D12): one group of tests per gap closed.

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:housecairn_mobile/data/repository.dart';
import 'package:housecairn_mobile/design/brand.dart';
import 'package:housecairn_mobile/design/icons.dart';
import 'package:housecairn_mobile/design/theme.dart';
import 'package:housecairn_mobile/design/tokens.dart';
import 'package:housecairn_mobile/design/widgets.dart';
import 'package:housecairn_mobile/sync/server_transport.dart';
import 'package:housecairn_mobile/ui/state.dart';
import 'package:housecairn_mobile/ui/templates_screen.dart';
import 'package:housecairn_mobile/version.dart';
import 'package:material_ui/material_ui.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'support/app.dart';
import 'support/fixture.dart';
import 'support/goldens.dart';
import 'support/lot2b.dart';
import 'support/lot3b.dart';
import 'support/screens_2b.dart';

/// The title of the page, its `h1`.
String pageTitle(WidgetTester tester) =>
    tester.widget<HcLargeTitle>(find.byType(HcLargeTitle)).title;

/// Makes [homeId] a home of a server where the account only reads.
Future<void> readOnly(Repository r, String homeId) =>
    r.serverState.writeServerState(
      ServerSyncState(
        homes: [
          ServerHome(
            id: homeId,
            name: 'Flat',
            role: 'read_only',
            members: const [],
          ),
        ],
      ).encode(),
    );

Future<Lot3b> startLot3b(
  WidgetTester tester, {
  String locale = 'en',
  double width = 390,
  Future<void> Function(Repository, Lot3b)? more,
  UrlOpener? openUrl,
}) async {
  await onPhone(tester, width: width, height: 844);
  late Lot3b data;
  final state = await pumpApp(
    tester,
    locale: locale,
    openUrl: openUrl,
    seed: (r) async {
      data = await Lot3b.seed(r);
      await more?.call(r, data);
    },
  );
  await state.choose(data.main);
  await tester.pumpAndSettle();
  return data;
}

void main() {
  // Manrope, as the phone draws it: the test font is much wider.
  setUpAll(loadAppFonts);

  setUp(() {
    PackageInfo.setMockInitialValues(
      appName: 'Housecairn',
      packageName: 'app.example',
      version: '0.5.0',
      buildNumber: '1',
      buildSignature: '',
    );
  });

  group('N7: each tab of Budget has the title and the note of the web', () {
    for (final locale in ['en', 'fr']) {
      testWidgets(locale, (tester) async {
        await startLot3b(tester, locale: locale);
        final l = labels[locale]!;
        final year = DateTime.now().year;
        final expected = locale == 'en'
            ? [
                ('Budget', null),
                (
                  'Budget by room',
                  'Projects counted in $year, shared evenly between their '
                      'rooms, and the upkeep of $year.',
                ),
                (
                  'Budget by project',
                  'Each project is counted in one year, the year it starts. '
                      'An abandoned project plans nothing any more: what was '
                      'paid on it shows as spent without a plan.',
                ),
                (
                  'Budget of the upkeep',
                  'The tasks that are in no project, with the occurrences of '
                      '$year: those done, the one open, and those the '
                      'repetition will still bring before the end of the '
                      'year. An open task with no date counts in the current '
                      'year. A task of a project counts in its project.',
                ),
              ]
            : [
                ('Budget', null),
                (
                  'Budget par pièce',
                  'Projets comptés en $year, répartis également entre leurs '
                      'pièces, et entretien de $year.',
                ),
                ('Budget par projet', null),
                ("Budget de l'entretien", null),
              ];
        for (final (tab, (title, note)) in expected.indexed) {
          await budgetTab(tester, l, tab);
          expect(pageTitle(tester), title);
          if (note == null) continue;
          // Under the year (or the tabs), above the first card, as the web.
          final noteBox = tester.getRect(find.text(note));
          final firstCard = find.byType(HcCardList);
          if (firstCard.evaluate().isNotEmpty) {
            expect(
              noteBox.bottom,
              lessThanOrEqualTo(tester.getRect(firstCard.first).top),
            );
          }
        }
      });
    }
  });

  group('N18: the envelope card has its heading in small capitals', () {
    testWidgets('Budget', (tester) async {
      await startLot3b(tester);
      await openSection(tester, 'Budget');
      final heading = tester.widget(find.byKey(const Key('envelope-heading')));
      expect(heading, isA<HcSectionHeading>());
      expect(
        find.descendant(
          of: find.byType(HcCard),
          matching: find.byKey(const Key('envelope-heading')),
        ),
        findsOneWidget,
      );
      expect(find.text('ENVELOPE ${DateTime.now().year}'), findsOneWidget);
    });

    testWidgets('Projects', (tester) async {
      await startLot3b(tester);
      await openSection(tester, 'Projects');
      expect(
        tester.widget(find.byKey(const Key('projects-envelope-heading'))),
        isA<HcSectionHeading>(),
      );
      expect(
        find.text('BUDGET ENVELOPE ${DateTime.now().year}'),
        findsOneWidget,
      );
    });
  });

  testWidgets('N19: the projects are in groups by status, with a heading', (
    tester,
  ) async {
    await startLot3b(
      tester,
      more: (r, data) => r.createProject(
        data.main,
        const ProjectInput(title: 'New windows', status: 'planned'),
      ),
    );
    await openSection(tester, 'Projects');
    final going = find.byKey(const Key('projects-group-in_progress'));
    final planned = find.byKey(const Key('projects-group-planned'));
    expect(tester.widget<HcSectionHeading>(going).text, 'In progress');
    expect(tester.widget<HcSectionHeading>(planned).text, 'Planned');
    // In the order of the web, each project under its own heading.
    final repaint = tester.getRect(find.text('Repaint the kitchen'));
    final windows = tester.getRect(find.text('New windows'));
    expect(tester.getRect(going).bottom, lessThan(repaint.top));
    expect(repaint.bottom, lessThan(tester.getRect(planned).top));
    expect(tester.getRect(planned).bottom, lessThan(windows.top));
  });

  group(
    'N20: a template says its interval as the web and links its source',
    () {
      for (final (locale, interval) in [
        ('en', 'every month · '),
        ('fr', 'tous les mois · '),
      ]) {
        testWidgets(locale, (tester) async {
          final opened = <Uri>[];
          await onPhone(tester, width: 390, height: 844);
          await pumpApp(
            tester,
            locale: locale,
            openUrl: (address) async {
              opened.add(address);
              return true;
            },
          );
          await openScreen(tester, const TemplatesScreen());
          final row = find.byKey(const Key('template-smoke-alarm-test'));
          expect(
            find.descendant(of: row, matching: find.text(interval)),
            findsOneWidget,
          );
          final source = find.byKey(
            const Key('template-source-smoke-alarm-test'),
          );
          expect(
            find.descendant(of: source, matching: find.text('source')),
            findsOneWidget,
          );
          await tester.tap(source);
          await tester.pumpAndSettle();
          expect(opened, [
            Uri.parse(
              'https://www.nfpa.org/education-and-research/home-fire-safety/'
              'smoke-alarms/installing-and-maintaining-smoke-alarms',
            ),
          ]);
          // The link opens the source and leaves the box as it was.
          expect(
            tester
                .widget<CheckboxListTile>(
                  find.byKey(const Key('template-smoke-alarm-test')),
                )
                .value,
            isFalse,
          );
        });
      }
    },
  );

  group('N27: the button of the reports line of Today', () {
    for (final locale in ['en', 'fr']) {
      testWidgets('is small, on one line beside the count at 390 ($locale)', (
        tester,
      ) async {
        await onPhone(tester, width: 390, height: 844);
        await pumpApp(
          tester,
          locale: locale,
          seed: (r) async {
            final home = await r.createHome(name: 'Main home');
            await r.createReport(home, title: 'The tap drips');
          },
        );
        final see = find.byKey(const Key('today-reports-see'));
        final label = find.descendant(of: see, matching: find.byType(Text));
        final count = find.byKey(const Key('today-reports-count'));
        // `.button-small`: 14 px, one line; the count on one line too.
        final style = DefaultTextStyle.of(tester.element(label)).style;
        expect(style.fontSize, HcText.buttonSmall.fontSize);
        expect(
          tester.getSize(label).height,
          lessThan(2 * HcFont.sizeSm * HcComponent.buttonLineHeight),
        );
        expect(
          tester.getSize(count).height,
          lessThan(2 * HcFont.sizeBase * HcFont.lineHeight),
        );
        // A target of 48 still.
        expect(
          tester.getSize(see).height,
          greaterThanOrEqualTo(HcLayout.touchTargetLg),
        );
      });
    }
  });

  group('More', () {
    testWidgets('N28: Reports has the flag, Contractors the hard hat', (
      tester,
    ) async {
      await startLot3b(tester);
      await openSection(tester, 'More');
      expect(
        find.descendant(
          of: find.byKey(const Key('more-reports')),
          matching: hcIcon(HcIcons.flag),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('more-contractors')),
          matching: hcIcon(HcIcons.hardhat),
        ),
        findsOneWidget,
      );
      // The shapes of the web, the curves of S included, draw.
      expect(tester.takeException(), isNull);
    });

    for (final (locale, words) in [('en', 'Reports'), ('fr', 'Signalements')]) {
      testWidgets('M3: Reports says how many wait ($locale)', (tester) async {
        await startLot3b(tester, locale: locale);
        await openSection(tester, labels[locale]!.more);
        expect(find.text('$words (1)'), findsOneWidget);
      });
    }

    testWidgets('M3: no count when no report waits', (tester) async {
      await onPhone(tester, width: 390, height: 844);
      await pumpApp(tester);
      await openSection(tester, 'More');
      expect(
        find.descendant(
          of: find.byKey(const Key('more-reports')),
          matching: find.text('Reports'),
        ),
        findsOneWidget,
      );
    });

    testWidgets(
      'M3: a read-only member of a server home sees no count, as on the web',
      (tester) async {
        await startLot3b(tester, more: (r, data) => readOnly(r, data.main));
        // The reader holds their own report; the web counts none for them
        // (`waiting_for`), on Today as in More.
        expect(find.byKey(const Key('today-reports')), findsNothing);
        await openSection(tester, 'More');
        expect(
          find.descendant(
            of: find.byKey(const Key('more-reports')),
            matching: find.text('Reports'),
          ),
          findsOneWidget,
        );
      },
    );
  });

  testWidgets('M3: reportsWaiting counts for a writer, not for a reader', (
    tester,
  ) async {
    final r = await openRepository();
    addTearDown(r.db.close);
    final home = await r.createHome(name: 'Main home');
    await r.createReport(home, title: 'The tap drips');
    expect(await r.reportsWaiting(home), 1);
    await readOnly(r, home);
    expect(await r.reportsWaiting(home), 0);
  });

  testWidgets('N29: Details of the year is a folded section of the forms', (
    tester,
  ) async {
    await startLot3b(tester);
    await openSection(tester, 'Budget');
    final details = find.byKey(const Key('envelope-details'));
    expect(tester.widget(details), isA<HcFoldSection>());
    final paid = find.descendant(of: details, matching: find.text('Paid'));
    expect(paid, findsNothing);
    await tester.tap(find.text('Details of the year'));
    await tester.pumpAndSettle();
    expect(paid, findsOneWidget);
  });

  group('the first start', () {
    testWidgets('T11, D1: the logo, then the title, centred', (tester) async {
      await onPhone(tester, width: 390, height: 844);
      await pumpApp(tester, firstStart: true);
      final brand = find.byType(HcBrand);
      expect(brand, findsOneWidget);
      final title = find.byKey(const Key('ways-title'));
      expect(tester.getRect(brand).bottom, lessThan(tester.getRect(title).top));
      expect(tester.getCenter(brand).dx, closeTo(195, 1));
      expect(tester.widget<Text>(title).textAlign, TextAlign.center);
    });

    testWidgets('D2: a way coming later is muted, its mark too', (
      tester,
    ) async {
      await onPhone(tester, width: 390, height: 844);
      await pumpApp(tester, firstStart: true);
      final family = find.byKey(const Key('way-relay'));
      final title = find.descendant(
        of: family,
        matching: find.text('Family sync'),
      );
      expect(tester.widget<Text>(title).style!.color, HcColors.textMuted);
      expect(
        find.descendant(
          of: family,
          matching: find.byKey(const Key('way-indicator-off')),
        ),
        findsOneWidget,
      );
      // The way that can be chosen keeps the colour of the text.
      final alone = find.descendant(
        of: find.byKey(const Key('way-alone')),
        matching: find.text('Alone on this phone'),
      );
      expect(tester.widget<Text>(alone).style!.color, HcColors.text);
    });
  });

  group('About, the tile of Android at 320 with text at twice the size', () {
    for (final (locale, label, soon, more) in [
      ('en', 'Android', 'Coming soon', 'More'),
      ('fr', 'Android', 'Bientôt', 'Plus'),
    ]) {
      testWidgets('keeps its word whole, the pill under it ($locale)', (
        tester,
      ) async {
        await onPhone(tester, width: 320, height: 844, textScale: 2);
        late Lot3b data;
        final state = await pumpApp(
          tester,
          locale: locale,
          seed: (r) async => data = await Lot3b.seed(r),
        );
        await state.choose(data.main);
        await tester.pumpAndSettle();
        await openSection(tester, more);
        final row = find.byKey(const Key('more-about'));
        await tester.scrollUntilVisible(row, 100);
        await tester.ensureVisible(row);
        await tester.pumpAndSettle();
        await tester.tap(row);
        await tester.pumpAndSettle();
        final tile = find.byKey(const Key('about-link-android'));
        await tester.scrollUntilVisible(
          tile,
          100,
          scrollable: find.byType(Scrollable).last,
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        final word = find.descendant(of: tile, matching: find.text(label));
        // One line: the height of the word is the height it has unbound.
        final paragraph = tester.renderObject<RenderParagraph>(word);
        expect(
          paragraph.size.height,
          paragraph.getMinIntrinsicHeight(double.infinity),
          reason: 'the word is cut',
        );
        final pill = find.descendant(of: tile, matching: find.text(soon));
        expect(
          tester.getRect(pill).top,
          greaterThanOrEqualTo(tester.getRect(word).bottom),
          reason: 'the pill is under the label',
        );
        expect(tester.getRect(tile).height, lessThan(160));
        expect(tester.getRect(pill).right, lessThanOrEqualTo(320));
      });
    }
  });

  group('N23: About is the card of the web', () {
    Future<List<Uri>> toAbout(WidgetTester tester) async {
      final opened = <Uri>[];
      await onPhone(tester, width: 390, height: 844);
      await pumpApp(
        tester,
        openUrl: (address) async {
          opened.add(address);
          return true;
        },
      );
      await openSection(tester, 'More');
      await tester.scrollUntilVisible(hcIcon(HcIcons.info), 100);
      await tester.tap(hcIcon(HcIcons.info));
      await tester.pumpAndSettle();
      return opened;
    }

    testWidgets('one title, the logo, the version, no filled button', (
      tester,
    ) async {
      await toAbout(tester);
      expect(find.byType(HcLargeTitle), findsOneWidget);
      expect(find.text('Housecairn'), findsNothing);
      final card = find.byKey(const Key('about-card'));
      for (final key in ['about-logo', 'about-version', 'about-source']) {
        expect(
          find.descendant(of: card, matching: find.byKey(Key(key))),
          findsOneWidget,
          reason: key,
        );
      }
      expect(find.text('HOUSECAIRN'), findsOneWidget);
      expect(find.byType(FilledButton), findsNothing);
      expect(find.text('Open source licences'), findsOneWidget);
    });

    testWidgets('the links of the web open, Android is coming soon', (
      tester,
    ) async {
      final opened = await toAbout(tester);
      expect(heading('Links'), findsOneWidget);
      for (final (key, address) in [
        ('about-source', 'https://$sourceAddress'),
        ('about-link-site', 'https://housecairn.app'),
        ('about-link-docs', 'https://docs.housecairn.app'),
        ('about-link-app', 'https://github.com/HouseCairn/housecairn'),
        (
          'about-link-addon',
          'https://github.com/HouseCairn/home-assistant-addons',
        ),
        (
          'about-link-integration',
          'https://github.com/HouseCairn/home-assistant-housecairn',
        ),
        ('about-link-mobile', 'https://$sourceAddress'),
      ]) {
        opened.clear();
        await tester.ensureVisible(find.byKey(Key(key)));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(Key(key)));
        await tester.pumpAndSettle();
        expect(opened, [Uri.parse(address)], reason: key);
      }
      final android = find.byKey(const Key('about-link-android'));
      expect(
        find.descendant(of: android, matching: find.text('Coming soon')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: android, matching: find.byType(InkWell)),
        findsNothing,
      );
    });
  });
}
