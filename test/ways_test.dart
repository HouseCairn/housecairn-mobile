// SPDX-License-Identifier: AGPL-3.0-only

// Lot 2c: the first start, with the three ways to use the app
// (docs/adr/0010-three-ways-to-use-the-app.md), the way stored in
// `local_settings`, Settings, the texts, and the interface of the transport.

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:housecairn_mobile/app.dart';
import 'package:housecairn_mobile/data/repository.dart';
import 'package:housecairn_mobile/domain/photos.dart';
import 'package:housecairn_mobile/domain/templates.dart';
import 'package:housecairn_mobile/sync/mode.dart';
import 'package:housecairn_mobile/ui/state.dart';
import 'package:housecairn_mobile/ui/ways.dart';
import 'package:material_ui/material_ui.dart';

import 'support/app.dart';
import 'support/arb.dart';
import 'support/fake_transport.dart';
import 'support/fixture.dart';

const _words = {
  'en': (
    title: 'How do you want to use Housecairn?',
    alone: 'Alone on this phone',
    family: 'Family sync',
    server: 'My Housecairn server',
    later: 'Coming later',
    inUse: 'In use',
    go: 'Continue',
    more: 'More',
    firstHome: 'My home',
  ),
  'fr': (
    title: 'Comment voulez-vous utiliser Housecairn ?',
    alone: 'Seul sur ce téléphone',
    family: 'Synchronisation en famille',
    server: 'Mon serveur Housecairn',
    later: 'Prévu plus tard',
    inUse: 'Utilisé',
    go: 'Continuer',
    more: 'Plus',
    firstHome: 'Ma maison',
  ),
};

/// A repository that counts how many times the way is stored, that is how
/// many times the first start ran.
class _CountingRepository extends Repository {
  _CountingRepository(Repository base)
    : super(base.db, clock: base.clock, files: base.files);

  int stores = 0;

  @override
  Future<void> setSyncMode(SyncMode mode) {
    stores++;
    return super.setSyncMode(mode);
  }
}

/// The app started again on the data of [state]: a new [AppState] on the same
/// repository, as the app is on its next launch.
Future<AppState> restart(
  WidgetTester tester,
  AppState state,
  String locale,
) async {
  final next = AppState(state.repository);
  await tester.pumpWidget(const SizedBox());
  await tester.pumpWidget(HousecairnApp(state: next, locale: Locale(locale)));
  await tester.pumpAndSettle();
  return next;
}

Future<void> openMore(WidgetTester tester, String more) async {
  await tester.tap(destination(more));
  await tester.pumpAndSettle();
}

void main() {
  for (final MapEntry(key: locale, value: w) in _words.entries) {
    group('first start ($locale)', () {
      testWidgets('shows the three ways, Alone selected, the others disabled', (
        tester,
      ) async {
        // Tall, so that the three cards are built together.
        await onPhone(tester, height: 1600);
        final state = await pumpApp(tester, locale: locale, firstStart: true);
        expect(state.firstStart, isTrue);
        expect(find.text(w.title), findsOneWidget);
        for (final title in [w.alone, w.family, w.server]) {
          expect(find.text(title), findsOneWidget);
        }
        expect(find.byType(NavigationBar), findsNothing);
        expect(
          state.homes,
          isEmpty,
          reason: 'nothing is made before the choice',
        );
        expect(await state.repository.storedSyncMode(), isNull);
        final cards = tester.widgetList<WayCard>(find.byType(WayCard)).toList();
        expect(cards.map((c) => c.way), SyncMode.values);
        expect(cards.map((c) => c.selected), [true, false, false]);
        expect(cards.map((c) => c.onTap != null), [true, false, false]);
        expect(find.text(w.later), findsNWidgets(2));
      });

      testWidgets('a tap on a way that is coming later opens nothing', (
        tester,
      ) async {
        // Tall, so that the three cards are built together.
        await onPhone(tester, height: 1600);
        final state = await pumpApp(tester, locale: locale, firstStart: true);
        for (final way in ['relay', 'server']) {
          await tester.ensureVisible(find.byKey(Key('way-$way')));
          await tester.pumpAndSettle();
          await tester.tap(find.byKey(Key('way-$way')));
          await tester.pumpAndSettle();
          expect(find.text(w.title), findsOneWidget);
          expect(find.byType(WaysScreen), findsOneWidget);
        }
        expect(find.byType(Dialog), findsNothing);
        expect(find.byType(AlertDialog), findsNothing);
        expect(find.byType(NavigationBar), findsNothing);
        expect(await state.repository.storedSyncMode(), isNull);
        expect(state.homes, isEmpty);
        expect(state.firstStart, isTrue);
      });

      testWidgets('choosing Alone stores the way and makes the first home', (
        tester,
      ) async {
        await onPhone(tester);
        final state = await pumpApp(tester, locale: locale, firstStart: true);
        await tester.tap(find.text(w.go));
        await tester.pumpAndSettle();
        expect(await state.repository.storedSyncMode(), SyncMode.alone);
        expect(state.homes.single.name, w.firstHome);
        expect(state.firstStart, isFalse);
        expect(find.byType(NavigationBar), findsOneWidget);
        expect(find.text(w.title), findsNothing);
      });

      testWidgets('after a restart the app opens on the home, no screen', (
        tester,
      ) async {
        await onPhone(tester);
        final state = await pumpApp(tester, locale: locale, firstStart: true);
        await tester.tap(find.text(w.go));
        await tester.pumpAndSettle();
        final next = await restart(tester, state, locale);
        expect(next.firstStart, isFalse);
        expect(next.homes.single.name, w.firstHome);
        expect(next.homes, hasLength(1), reason: 'no second home');
        expect(find.byType(NavigationBar), findsOneWidget);
        expect(find.text(w.title), findsNothing);
      });

      testWidgets('an install of a build of lot 2 opens on its homes', (
        tester,
      ) async {
        await onPhone(tester);
        final state = await pumpApp(
          tester,
          locale: locale,
          firstStart: true,
          seed: (r) async {
            await r.createHome(name: 'Cottage');
          },
        );
        expect(await state.repository.storedSyncMode(), isNull);
        expect(state.firstStart, isFalse);
        expect(state.syncMode, SyncMode.alone);
        expect(find.text(w.title), findsNothing);
        expect(find.byType(NavigationBar), findsOneWidget);
        expect(state.homes.single.name, 'Cottage');
        // Settings shows it as Alone, in use.
        await openMore(tester, w.more);
        await tester.scrollUntilVisible(
          find.byKey(const Key('way-row-alone')),
          100,
        );
        final alone = find.byKey(const Key('way-row-alone'));
        expect(
          find.descendant(of: alone, matching: find.text(w.inUse)),
          findsOneWidget,
        );
      });

      for (final forged in [SyncMode.relay, SyncMode.server]) {
        testWidgets(
          'a forged sync_mode ${forged.name} with no home asks the first start',
          (tester) async {
            await onPhone(tester, height: 1600);
            final state = await pumpApp(
              tester,
              locale: locale,
              firstStart: true,
              seed: (r) => r.setSyncMode(forged),
            );
            expect(await state.repository.storedSyncMode(), isNull);
            expect(state.firstStart, isTrue);
            expect(state.syncMode, SyncMode.alone);
            expect(state.homes, isEmpty);
            expect(find.text(w.title), findsOneWidget);
            expect(find.byType(NavigationBar), findsNothing);
          },
        );

        testWidgets(
          'a forged sync_mode ${forged.name} with homes is read as Alone',
          (tester) async {
            await onPhone(tester);
            final state = await pumpApp(
              tester,
              locale: locale,
              firstStart: true,
              seed: (r) async {
                await r.createHome(name: 'Cottage');
                await r.setSyncMode(forged);
              },
            );
            expect(await state.repository.storedSyncMode(), isNull);
            expect(state.syncMode, SyncMode.alone);
            expect(state.firstStart, isFalse);
            expect(state.homes.single.name, 'Cottage');
            expect(find.text(w.title), findsNothing);
            expect(find.byType(NavigationBar), findsOneWidget);
            // Settings: only Alone is in use.
            await openMore(tester, w.more);
            await tester.scrollUntilVisible(
              find.byKey(const Key('way-row-server')),
              100,
            );
            Finder pill(String way, String text) => find.descendant(
              of: find.byKey(Key('way-row-$way')),
              matching: find.text(text),
            );
            expect(pill('alone', w.inUse), findsOneWidget);
            expect(pill('relay', w.inUse), findsNothing);
            expect(pill('server', w.inUse), findsNothing);
            expect(pill('relay', w.later), findsOneWidget);
            expect(pill('server', w.later), findsOneWidget);
          },
        );
      }

      testWidgets('two quick taps on Continue make one home', (tester) async {
        await onPhone(tester);
        final base = await openRepository();
        addTearDown(base.db.close);
        final repository = _CountingRepository(base);
        await repository.open();
        final state = AppState(
          repository,
          photoProcessor: (bytes) async => processPhoto(bytes),
          loadTemplates: () async => parseTemplates(
            File('assets/task_templates.yaml').readAsStringSync(),
          ),
        );
        await tester.pumpWidget(
          HousecairnApp(state: state, locale: Locale(locale)),
        );
        await tester.pumpAndSettle();
        expect(state.firstStart, isTrue);
        // No frame between the taps: the second one lands on the button as
        // it was drawn, so only the handler can refuse it.
        await tester.tap(find.byKey(const Key('ways-continue')));
        await tester.tap(find.byKey(const Key('ways-continue')));
        await tester.pumpAndSettle();
        expect(repository.stores, 1, reason: 'the first start ran once');
        expect(state.homes, hasLength(1));
        expect(state.homes.single.name, w.firstHome);
        expect(await state.repository.homes(), hasLength(1));
        expect(await state.repository.storedSyncMode(), SyncMode.alone);
      });

      testWidgets('More shows the way in use and the two others disabled', (
        tester,
      ) async {
        await onPhone(tester);
        await pumpApp(tester, locale: locale);
        await openMore(tester, w.more);
        await tester.scrollUntilVisible(
          find.byKey(const Key('way-row-server')),
          100,
        );
        Finder pill(String way, String text) => find.descendant(
          of: find.byKey(Key('way-row-$way')),
          matching: find.text(text),
        );
        expect(pill('alone', w.inUse), findsOneWidget);
        expect(pill('relay', w.later), findsOneWidget);
        expect(pill('server', w.later), findsOneWidget);
        // Nothing opens: no row of the group is tappable.
        await tester.ensureVisible(find.byKey(const Key('way-row-server')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('way-row-server')));
        await tester.pumpAndSettle();
        expect(find.byType(Dialog), findsNothing);
        expect(find.text(w.server), findsOneWidget);
      });

      for (final scale in [1.0, 2.0]) {
        testWidgets('fits 360 px at text scale $scale, nothing overflows', (
          tester,
        ) async {
          await onPhone(tester, textScale: scale);
          await pumpApp(tester, locale: locale, firstStart: true);
          expect(tester.takeException(), isNull);
          await tester.scrollUntilVisible(
            find.byKey(const Key('way-server')),
            100,
          );
          expect(tester.takeException(), isNull);
          // The button stays reachable and leads on.
          await tester.tap(find.byKey(const Key('ways-continue')));
          await tester.pumpAndSettle();
          expect(find.byType(NavigationBar), findsOneWidget);
        });
      }

      testWidgets('meets the guidelines of tap target, label and contrast', (
        tester,
      ) async {
        final semantics = tester.ensureSemantics();
        await onPhone(tester);
        await pumpApp(tester, locale: locale, firstStart: true);
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        await expectLater(tester, meetsGuideline(textContrastGuideline));
        semantics.dispose();
      });
    });
  }

  group('sync_mode in local_settings', () {
    test(
      'absent means alone, and only alone, relay and server exist',
      () async {
        final repository = await openRepository();
        addTearDown(repository.db.close);
        expect(await repository.storedSyncMode(), isNull);
        expect(await repository.syncMode(), SyncMode.alone);
        expect(SyncMode.values.map((m) => m.stored), [
          'alone',
          'relay',
          'server',
        ]);
        // A way that is not available reads as none, whatever is written.
        for (final mode in SyncMode.values) {
          await repository.setSyncMode(mode);
          expect(
            await repository.storedSyncMode(),
            wayAvailable(mode) ? mode : isNull,
          );
        }
        expect(SyncMode.values.where(wayAvailable), [SyncMode.alone]);
        expect(SyncMode.parse('mesh'), isNull, reason: 'unknown value');
      },
    );

    test('it is a row of local_settings, kept in the database file', () async {
      final dir = Directory.systemTemp.createTempSync('housecairn-mode-');
      addTearDown(() => dir.deleteSync(recursive: true));
      final file = File('${dir.path}/app.db');
      final first = await openRepository(file: file);
      await first.setSyncMode(SyncMode.alone);
      final rows = await first.db
          .customSelect(
            "SELECT value FROM local_settings WHERE key = 'sync_mode'",
          )
          .get();
      expect(rows.single.data['value'], 'alone');
      await first.db.close();
      final second = await openRepository(file: file);
      addTearDown(second.db.close);
      expect(await second.storedSyncMode(), SyncMode.alone);
    });
  });

  group('texts of the three ways', () {
    final keys = [
      'waysTitle',
      'waysContinue',
      'waysGroup',
      'wayAloneTitle',
      'wayAloneText',
      'wayFamilyTitle',
      'wayFamilyText',
      'wayServerTitle',
      'wayServerText',
      'wayComingLater',
      'wayInUse',
    ];

    for (final locale in ['en', 'fr']) {
      final messages = arbMessages(locale);

      test('every key is in the ARB file ($locale)', () {
        for (final key in keys) {
          expect(messages[key], isNotNull, reason: key);
          expect(messages[key]!.trim(), isNotEmpty, reason: key);
        }
      });

      test('no text of the ways carries a price ($locale)', () {
        for (final key in keys) {
          expect(
            RegExp(r'[€$£¥]|\d').hasMatch(messages[key]!),
            isFalse,
            reason: key,
          );
        }
      });
    }

    test('the server text says what it stores, reads and unlocks (en)', () {
      final text = arbMessages('en')['wayServerText']!;
      expect(text, contains('Your server stores your homes and can read them'));
      expect(text, contains('Everything of this phone is kept on the server'));
      expect(text, contains('a one-time purchase unlocks it'));
    });

    test('the server text says what it stores, reads and unlocks (fr)', () {
      final text = arbMessages('fr')['wayServerText']!;
      expect(text, contains('enregistre vos logements et peut les lire'));
      expect(
        text,
        contains(
          'Tout ce qui est sur ce téléphone est conservé sur le serveur',
        ),
      );
      expect(text, contains('un achat unique le débloque'));
    });

    test('the family text says the relay cannot read (en, fr)', () {
      expect(arbMessages('en')['wayFamilyText'], contains('cannot read it'));
      expect(
        arbMessages('fr')['wayFamilyText'],
        contains('ne peut pas le lire'),
      );
    });
  });

  group('SyncTransport', () {
    const members = [
      'capabilities',
      'push',
      'pull',
      'putFile',
      'getFile',
      'deleteFile',
      'homesGone',
    ];

    test('has the members of ADR 0010 and nothing else', () {
      final source = File('lib/sync/transport.dart').readAsStringSync();
      final body = RegExp(
        r'abstract interface class SyncTransport \{(.*?)\n\}',
        dotAll: true,
      ).firstMatch(source)!.group(1)!;
      final declared = RegExp(
        r'^  Future<[^\n]*?>\s+(\w+)\(',
        multiLine: true,
      ).allMatches(body).map((m) => m.group(1)).toList();
      expect(declared, members);
    });

    test(
      'a fake follows the interface: push, pull, files, homes gone',
      () async {
        final transport = FakeSyncTransport(gone: ['h1']);
        expect((await transport.capabilities()).version, 'fake');
        await transport.push([
          {'t': 'task', 'id': 'a'},
          {'t': 'task', 'id': 'b'},
        ]);
        final all = await transport.pull();
        expect(all.operations, hasLength(2));
        expect(all.position, 2);
        expect((await transport.pull(after: all.position)).operations, isEmpty);
        expect((await transport.pull(after: 1)).operations.single['id'], 'b');
        await transport.putFile('f', Uint8List.fromList([1, 2]));
        expect(await transport.getFile('f'), [1, 2]);
        await transport.deleteFile('f');
        expect(transport.files, isEmpty);
        expect(await transport.homesGone(), ['h1']);
      },
    );

    test('only the server transport of lot 4b implements it in lib/', () {
      final implementers = [
        for (final file
            in Directory('lib')
                .listSync(recursive: true)
                .whereType<File>()
                .where((f) => f.path.endsWith('.dart')))
          if (RegExp(r'\b(implements|extends|with)\s+[^{;]*\bSyncTransport\b')
              .hasMatch(file.readAsStringSync()))
            file.path,
      ];
      // The relay's transport comes with lots 5 and 6.
      expect(implementers, ['lib/sync/server_transport.dart']);
    });
  });

  group('no network code in lib/', () {
    final sources = {
      for (final file
          in Directory('lib')
              .listSync(recursive: true)
              .whereType<File>()
              .where((f) => f.path.endsWith('.dart')))
        file.path: file.readAsStringSync(),
    };
    final imports = <String, Set<String>>{
      for (final MapEntry(:key, :value) in sources.entries)
        key: {
          for (final m in RegExp(
            r'''^\s*(?:import|export)\s+['"]([^'"]+)['"]''',
            multiLine: true,
          ).allMatches(value))
            m.group(1)!,
        },
    };

    test('the imports of lib/ are listed', () {
      expect(imports, isNotEmpty);
    });

    test('no package that talks to a network is imported', () {
      final network = RegExp(
        r'^package:(http|dio|http2|web_socket|web_socket_channel|grpc|'
        r'cronet_http|cupertino_http|socket_io_client|stomp_dart_client|'
        r'chopper|retrofit|firebase_\w+|sentry\w*)(/|$)',
      );
      final found = [
        for (final MapEntry(:key, :value) in imports.entries)
          for (final import in value)
            if (network.hasMatch(import)) '$key: $import',
      ];
      expect(found, isEmpty);
    });

    test('dart:io stays where the files are, and only the server transport '
        'opens a connection', () {
      final io = [
        for (final MapEntry(:key, :value) in imports.entries)
          if (value.contains('dart:io')) key,
      ]..sort();
      expect(io, [
        'lib/core/photo_source.dart',
        'lib/data/repository.dart',
        'lib/main.dart',
        // The third way (lot 4b): requests to the address typed, nothing
        // else (test/server_transport_test.dart).
        'lib/sync/server_http_io.dart',
      ]);
      final sockets = RegExp(
        r'\b(Socket|RawSocket|SecureSocket|ServerSocket|HttpClient|'
        r'HttpServer|WebSocket|RawDatagramSocket)\b',
      );
      final found = [
        for (final MapEntry(:key, :value) in sources.entries)
          if (key != 'lib/sync/server_http_io.dart' &&
              sockets.hasMatch(
                value
                    .split('\n')
                    .where((l) => !l.trimLeft().startsWith('//'))
                    .join('\n'),
              ))
            key,
      ];
      expect(found, isEmpty);
    });

    test('the pubspec adds no package for this lot', () {
      final pubspec = File('pubspec.yaml').readAsStringSync();
      final dependencies = RegExp(
        r'^dependencies:\n((?:  .*\n|\n)*)',
        multiLine: true,
      ).firstMatch(pubspec)!.group(1)!;
      final names = RegExp(
        r'^  (\w+):',
        multiLine: true,
      ).allMatches(dependencies).map((m) => m.group(1)).toList();
      expect(names, isNot(contains('http')));
      expect(names, isNot(contains('dio')));
    });
  });
}
