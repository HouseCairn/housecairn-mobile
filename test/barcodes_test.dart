// SPDX-License-Identifier: AGPL-3.0-only

// The barcode of an item or a stock item (docs/adr/0015-barcode-lookup.md,
// web ADR 0083): the check of a code as the web checks it, what an open
// database answers and what the form takes of it, the lookup of the phone
// alone against a fake of the open databases (no test reaches a real host),
// the lookup through a server, the field in the sync, the migration to
// schema 12, the search, and the screens: the question of the first scan,
// the refusal, the switch in Settings, the values used in the empty fields
// only, and the photo kept without metadata with its credit.

import 'dart:convert';
import 'dart:typed_data';

import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:housecairn_mobile/core/open_facts.dart';
import 'package:housecairn_mobile/data/database.dart';
import 'package:housecairn_mobile/data/repository.dart';
import 'package:housecairn_mobile/domain/barcode_lookup.dart';
import 'package:housecairn_mobile/domain/gtin.dart';
import 'package:housecairn_mobile/domain/photos.dart';
import 'package:housecairn_mobile/domain/scanned_code.dart';
import 'package:housecairn_mobile/l10n/app_localizations_en.dart';
import 'package:housecairn_mobile/sync/mode.dart';
import 'package:housecairn_mobile/sync/operation.dart';
import 'package:housecairn_mobile/sync/server_address.dart';
import 'package:housecairn_mobile/sync/server_http.dart';
import 'package:housecairn_mobile/sync/server_sign_in.dart';
import 'package:housecairn_mobile/sync/server_transport.dart';
import 'package:housecairn_mobile/ui/barcode_field.dart';
import 'package:housecairn_mobile/ui/item_screens.dart';
import 'package:housecairn_mobile/ui/photos.dart' show PhotoScreen;
import 'package:housecairn_mobile/ui/state.dart';
import 'package:housecairn_mobile/ui/stock_screens.dart';
import 'package:material_ui/material_ui.dart';

import 'drift/housecairn/generated/schema.dart';
import 'labels_test.dart' show FakeCodeCamera;
import 'support/app.dart';
import 'support/fakes.dart';
import 'support/fixture.dart';
import 'support/lot2b.dart';
import 'support/server_fake.dart' show MemoryStore;

/// A neutral product of the fake open databases.
const _ean = '4006381333931';

/// What the read API of a source answers for [_ean].
Uint8List _productJson({
  String name = 'Smoke alarm battery',
  String brands = 'Acme, Acme Home',
  String categories = 'Household, Batteries',
  String image =
      'https://images.openproductsfacts.org/images/products/400/front.jpg',
}) => utf8.encode(
  jsonEncode({
    'code': _ean,
    'status': 1,
    'product': {
      'product_name': name,
      'brands': brands,
      'categories': categories,
      'image_front_url': image,
      'creator': 'a-contributor',
    },
  }),
);

/// The open databases, scripted: every URL asked is kept; [answers] by host
/// (`null`: not found, a 404), photos by URL; [offline] answers nothing.
class FakeOpenFacts implements OpenFactsHttp {
  FakeOpenFacts({this.answers = const {}, this.photos = const {}});

  final Map<String, Uint8List?> answers;
  final Map<String, Uint8List> photos;
  bool offline = false;
  final asked = <Uri>[];

  @override
  Future<Uint8List> get(
    Uri url, {
    required String accept,
    required int maxBytes,
  }) async {
    asked.add(url);
    if (offline) throw const OpenFactsUnreachable('offline');
    if (lookupImageHosts.contains(url.host)) {
      final photo = photos[url.toString()];
      if (photo == null) throw const OpenFactsUnreachable('status');
      return photo;
    }
    if (!answers.containsKey(url.host)) {
      throw const OpenFactsUnreachable('offline');
    }
    final body = answers[url.host];
    if (body == null) throw const OpenFactsUnreachable('status');
    return body;
  }
}

FakeOpenFacts foundOpenFacts({Uint8List? photo}) => FakeOpenFacts(
  answers: {
    'world.openproductsfacts.org': _productJson(),
    'world.openfoodfacts.org': null,
  },
  photos: {
    'https://images.openproductsfacts.org/images/products/400/front.jpg':
        photo ?? jpegWithGps(orientation: 1),
  },
);

/// The barcode lookup of a server, scripted: [state] of the answer, or a
/// refusal [status] with [code].
class _BarcodeServer implements ServerHttp {
  _BarcodeServer({this.state = 'done', this.status = 200, this.code});

  String state;
  final int status;
  final String? code;
  int polls = 0;
  int runningFor = 0;
  final requests = <(String, Uri)>[];
  bool offline = false;

  @override
  Future<ServerReply> send(
    String method,
    Uri url, {
    Map<String, String> headers = const {},
    Uint8List? body,
  }) async {
    if (offline) {
      throw const ServerHttpException(ServerHttpFailure.unreachable);
    }
    requests.add((method, url));
    if (status != 200) {
      return ServerReply(status, utf8.encode(jsonEncode({'code': code})));
    }
    if (url.path.endsWith('/photo/')) {
      return ServerReply(200, jpegWithGps(orientation: 1));
    }
    if (method == 'GET') polls++;
    final now = polls < runningFor ? 'running' : state;
    return ServerReply(
      200,
      utf8.encode(
        jsonEncode({
          'code': _ean,
          'state': now,
          'source': 'openproductsfacts',
          'source_label': 'Open Products Facts',
          'name': 'Smoke alarm battery',
          'brand': 'Acme',
          'model': '',
          'category': 'Batteries',
          'product_url': 'https://world.openproductsfacts.org/product/$_ean',
          'author': 'a-contributor',
          'license': 'CC BY-SA 3.0',
          'license_url': 'https://creativecommons.org/licenses/by-sa/3.0/',
          'has_photo': now == 'done',
          'online_enabled': true,
        }),
      ),
    );
  }
}

void main() {
  group('a code, as the web checks it (barcodes/gtin.py)', () {
    test('valid codes of every length', () {
      for (final code in [
        '4006381333931', // EAN-13
        '96385074', // EAN-8
        '036000291452', // UPC-A
        '10012345678902', // GTIN-14
      ]) {
        expect(isValidGtin(code), isTrue, reason: code);
      }
    });

    test('a wrong check digit, a wrong length, a letter are refused', () {
      for (final code in [
        '4006381333932',
        '400638133393',
        '40063813339311',
        '9638507',
        '40063813339a1',
        '٤٠٠٦٣٨١٣٣٣٩٣١', // Arabic-Indic digits: not ASCII
        '',
      ]) {
        expect(isValidGtin(code), isFalse, reason: code);
      }
    });

    test('spaces and dashes are taken out', () {
      expect(cleanGtin(' 4 006381-333931 '), _ean);
      expect(cleanEan('4006381 333931'), _ean);
      expect(cleanEan(''), '');
      expect(
        () => cleanEan('4006381333932'),
        throwsA(
          isA<Refused>().having((r) => r.reason, 'reason', Refusal.eanInvalid),
        ),
      );
    });

    test('a UPC-A and its EAN-13 are the same product', () {
      expect(asGtin14('036000291452'), '00036000291452');
      expect(gtinVariants('036000291452'), {
        '036000291452',
        '0036000291452',
        '00036000291452',
      });
      expect(gtinVariants('96385074'), contains('0000096385074'));
      expect(asPublishedGtin('00036000291452'), '0036000291452');
      expect(asPublishedGtin('00000096385074'), '96385074');
      expect(gtinMatches('0036000291452', '036000291452'), isTrue);
      expect(gtinMatches('6381', _ean), isTrue);
      expect(gtinMatches('boiler', _ean), isFalse);
      expect(gtinMatches('4006381333931', ''), isFalse);
    });
  });

  group('what an open database answers', () {
    final source = lookupSources.first;

    test('the name, the first brand, the last category, the photo', () {
      final answer = parseOpenFacts(source, _ean, _productJson())!;
      expect(answer.state, LookupState.done);
      expect(answer.name, 'Smoke alarm battery');
      expect(answer.brand, 'Acme');
      expect(answer.category, 'Batteries');
      expect(answer.author, 'a-contributor');
      expect(answer.sourceLabel, 'Open Products Facts');
      expect(
        answer.productUrl,
        'https://world.openproductsfacts.org/product/$_ean',
      );
      expect(answer.license, 'CC BY-SA 3.0');
      expect(answer.imageUrl, startsWith('https://images.'));
    });

    test('a photo of another host or in http is not kept', () {
      for (final image in [
        'http://images.openproductsfacts.org/a.jpg',
        'https://example.com/a.jpg',
        'https://images.openproductsfacts.org.example.com/a.jpg',
      ]) {
        final answer = parseOpenFacts(
          source,
          _ean,
          _productJson(image: image),
        )!;
        expect(answer.imageUrl, isEmpty, reason: image);
      }
    });

    test('status 0, no product, nothing useful, not JSON: not found', () {
      expect(
        parseOpenFacts(source, _ean, utf8.encode('{"status": 0}')),
        isNull,
      );
      expect(
        parseOpenFacts(source, _ean, utf8.encode('{"status": 1}')),
        isNull,
      );
      expect(
        parseOpenFacts(
          source,
          _ean,
          _productJson(name: '', brands: '', image: ''),
        ),
        isNull,
      );
      expect(parseOpenFacts(source, _ean, utf8.encode('<html>')), isNull);
    });

    test('the form of an item and of a stock item (fill_values)', () {
      final answer = parseOpenFacts(source, _ean, _productJson())!;
      expect(fillValues(answer, LookupTarget.item), {
        'name': 'Smoke alarm battery',
        'brand': 'Acme',
        'notes': 'Batteries',
      });
      expect(fillValues(answer, LookupTarget.article), {
        'name': 'Acme Smoke alarm battery',
        'notes': 'Batteries',
      });
    });
  });

  group('the lookup of the phone alone', () {
    test(
      'only the code goes, to the read API, in the order of the web',
      () async {
        final http = FakeOpenFacts(
          answers: {
            'world.openproductsfacts.org': null,
            'world.openfoodfacts.org': _productJson(image: ''),
          },
        );
        final answer = await lookUpAlone(http, _ean);
        expect(answer.state, LookupState.done);
        expect(answer.sourceLabel, 'Open Food Facts');
        expect(http.asked, [
          Uri.parse(
            'https://world.openproductsfacts.org/api/v2/product/$_ean.json'
            '?fields=code%2Cproduct_name%2Cbrands%2Ccategories%2C'
            'image_front_url%2Cimage_url%2Ccreator',
          ),
          Uri.parse(
            'https://world.openfoodfacts.org/api/v2/product/$_ean.json'
            '?fields=code%2Cproduct_name%2Cbrands%2Ccategories%2C'
            'image_front_url%2Cimage_url%2Ccreator',
          ),
        ]);
      },
    );

    test('the photo is read from the source, nowhere else', () async {
      final http = foundOpenFacts();
      final answer = await lookUpAlone(http, _ean);
      expect(answer.photo, isNotNull);
      expect(http.asked.map((u) => u.host), [
        'world.openproductsfacts.org',
        'images.openproductsfacts.org',
      ]);
    });

    test('known by none: not found; read by none: offline', () async {
      final none = FakeOpenFacts(
        answers: {
          'world.openproductsfacts.org': null,
          'world.openfoodfacts.org': null,
        },
      );
      expect((await lookUpAlone(none, _ean)).state, LookupState.notFound);
      final offline = FakeOpenFacts()..offline = true;
      expect((await lookUpAlone(offline, _ean)).state, LookupState.offline);
    });

    test('an invalid code asks nobody', () async {
      final http = foundOpenFacts();
      expect(
        (await lookUpAlone(http, '4006381333932')).state,
        LookupState.failed,
      );
      expect(http.asked, isEmpty);
    });
  });

  group('the lookup through a server (web barcodes/api.py)', () {
    const home = '0b6f2f0e-6c5a-4d33-9a7e-0d6b8f5c1a01';
    final address = ServerAddress.parse('https://hc.example.com').$1!;

    Future<ServerTransport> transportOn(ServerHttp http) async {
      final store = MemoryStore();
      await ServerCredential(
        access: 'hca_one',
        refresh: 'hcr_one',
        token: address.resolve('/o/token/'),
        revoke: address.resolve('/o/revoke_token/'),
      ).write(store);
      return ServerTransport(
        address: address,
        http: http,
        store: store,
        state: _NoState(),
        device: 'AAECAwQFBgcICQoLDA0ODw',
        schemaVersion: 12,
      );
    }

    test('posts the code to the address typed, then reads its photo', () async {
      final server = _BarcodeServer();
      final transport = await transportOn(server);
      final answer = await transport.barcodeLookup(home, _ean);
      expect(answer.state, LookupState.done);
      expect(answer.hasPhoto, isTrue);
      expect(await transport.barcodePhoto(home, _ean), isNotNull);
      expect(server.requests, [
        (
          'POST',
          Uri.parse(
            'https://hc.example.com/api/v1/homes/$home/barcodes/lookup/',
          ),
        ),
        (
          'GET',
          Uri.parse(
            'https://hc.example.com/api/v1/homes/$home/barcodes/$_ean/photo/',
          ),
        ),
      ]);
    });

    test(
      'a server that does not open its lookup to the app (web v0.5.1)',
      () async {
        final transport = await transportOn(
          _BarcodeServer(status: 403, code: 'connection_outside_sync'),
        );
        expect(
          (await transport.barcodeLookup(home, _ean)).state,
          LookupState.unavailable,
        );
      },
    );

    test('too many codes, no connection, the lookup off', () async {
      expect(
        (await (await transportOn(
          _BarcodeServer(status: 429),
        )).barcodeLookup(home, _ean)).state,
        LookupState.limited,
      );
      expect(
        (await (await transportOn(
          _BarcodeServer()..offline = true,
        )).barcodeLookup(home, _ean)).state,
        LookupState.offline,
      );
      expect(
        (await (await transportOn(
          _BarcodeServer(state: 'off'),
        )).barcodeLookup(home, _ean)).state,
        LookupState.off,
      );
    });
  });

  group('the code and the credit in the sync', () {
    test(
      'the credit of a photo is an object on the wire, text on the phone',
      () {
        const credit = '{"source":"Open Food Facts","license":"CC BY-SA 3.0"}';
        final sent = ServerTransport.wire({
          Op.type: 'rooms.photo',
          Op.home: 'h',
          Op.id: 'p',
          Op.kind: Op.put,
          Op.clock: '0193a1b2c3d40001',
          Op.device: 'd',
          Op.schema: 12,
          Op.fields: {'attribution': credit, 'caption': ''},
        }).single;
        expect((sent[Op.fields]! as Map)['attribution'], {
          'source': 'Open Food Facts',
          'license': 'CC BY-SA 3.0',
        });
        final kept = ServerTransport.kept({
          Op.type: 'stock.article',
          Op.fields: {
            'ean': _ean,
            'label_attribution': {'source': 'Open Food Facts'},
          },
        });
        expect(
          (kept[Op.fields]! as Map)['label_attribution'],
          '{"source":"Open Food Facts"}',
        );
        expect((kept[Op.fields]! as Map)['ean'], _ean);
      },
    );
  });

  group('schema 12', () {
    test('a schema 11 file keeps its rows, and the codes kept in extra move to '
        'their columns', () async {
      final verifier = SchemaVerifier(GeneratedHelper());
      final schema = await verifier.schemaAt(11);
      final raw = schema.rawDatabase;
      Uint8List id(int n) => Uint8List.fromList(List.filled(16, n));
      raw.execute(
        'INSERT INTO homes (id, created_at, updated_at, name, currency, '
        'hemisphere, is_example) VALUES (?, 1, 1, ?, ?, ?, 0)',
        [id(1), 'Main home', 'EUR', 'north'],
      );
      raw.execute(
        'INSERT INTO rooms (id, created_at, updated_at, home_id, name) '
        'VALUES (?, 1, 1, ?, ?)',
        [id(2), id(1), 'Kitchen'],
      );
      raw.execute(
        'INSERT INTO items (id, created_at, updated_at, home_id, room_id, '
        'name) VALUES (?, 1, 1, ?, ?, ?)',
        [id(3), id(1), id(2), 'Boiler'],
      );
      raw.execute(
        'INSERT INTO items (id, created_at, updated_at, home_id, room_id, '
        'name) VALUES (?, 1, 1, ?, ?, ?)',
        [id(6), id(1), id(2), 'Fridge'],
      );
      raw.execute(
        'INSERT INTO articles (id, created_at, updated_at, home_id, name) '
        'VALUES (?, 1, 1, ?, ?)',
        [id(4), id(1), 'Filter'],
      );
      raw.execute(
        'INSERT INTO photos (id, created_at, updated_at, home_id, item_id) '
        'VALUES (?, 1, 1, ?, ?)',
        [id(5), id(1), id(3)],
      );
      for (final (entity, row, json) in [
        ('rooms.item', id(3), {'ean': _ean, 'other': 1}),
        (
          'stock.article',
          id(4),
          {
            'ean': '96385074',
            'label_attribution': {'source': 'Open Food Facts'},
          },
        ),
        (
          'rooms.photo',
          id(5),
          {
            'attribution': {'source': 'Open Products Facts', 'author': 'x'},
          },
        ),
      ]) {
        raw.execute(
          'INSERT INTO extra (entity, row_id, home_id, json) '
          'VALUES (?, ?, ?, ?)',
          [entity, row, id(1), jsonEncode(json)],
        );
      }
      final db = AppDatabase(schema.newConnection());
      await verifier.migrateAndValidate(db, 13);
      Future<List<Map<String, Object?>>> rows(String sql) async => [
        for (final r in await db.customSelect(sql).get()) r.data,
      ];
      expect(await rows('SELECT name, ean FROM items ORDER BY name'), [
        {'name': 'Boiler', 'ean': _ean},
        {'name': 'Fridge', 'ean': ''},
      ]);
      expect(await rows('SELECT ean, label_attribution FROM articles'), [
        {
          'ean': '96385074',
          'label_attribution': '{"source":"Open Food Facts"}',
        },
      ]);
      expect(await rows('SELECT attribution FROM photos'), [
        {'attribution': '{"source":"Open Products Facts","author":"x"}'},
      ]);
      // What the phone still does not know stays in `extra`.
      expect(await rows('SELECT entity, json FROM extra'), [
        {'entity': 'rooms.item', 'json': '{"other":1}'},
      ]);
      expect(await db.integrityCheck(), 'ok');
      await db.close();
    });
  });

  group('the repository', () {
    test('the code is stored cleaned, found by the search, refused when '
        'wrong', () async {
      final r = await openRepository();
      addTearDown(r.db.close);
      final data = await Lot2b.seed(r);
      final room = (await r.rooms(data.homes.main)).first.id;
      final item = await r.addItem(
        room,
        const ItemInput(name: 'Smoke alarm', ean: '0 36000-291452'),
      );
      expect((await r.item(item))!.ean, '036000291452');
      final found = await r.itemList(data.homes.main, query: '0036000291452');
      expect(found.map((e) => e.item.id), [item]);
      expect(
        (await r.itemList(
          data.homes.main,
          query: '291452',
        )).map((e) => e.item.id),
        [item],
      );
      await expectLater(
        r.addItem(room, const ItemInput(name: 'X', ean: '036000291453')),
        throwsA(isA<Refused>()),
      );
      final article = await r.addArticle(
        data.homes.main,
        const ArticleInput(name: 'Battery', ean: _ean),
      );
      expect(
        (await r.articles(
          data.homes.main,
          query: _ean,
        )).map((e) => e.article.id),
        [article],
      );
      expect(
        (await r.articles(
          data.homes.main,
          query: '0$_ean',
        )).map((e) => e.article.id),
        [article],
      );
    });

    test(
      'a found label is set only when there is none, with its credit',
      () async {
        final r = await openRepository();
        addTearDown(r.db.close);
        final data = await Lot2b.seed(r);
        final article = await r.addArticle(
          data.homes.main,
          const ArticleInput(name: 'Battery', ean: _ean),
        );
        final photo = processPhoto(jpegWithGps(orientation: 1));
        const credit = {
          'source': 'Open Products Facts',
          'source_url': 'https://world.openproductsfacts.org/product/$_ean',
          'license': 'CC BY-SA 3.0',
          'license_url': 'https://creativecommons.org/licenses/by-sa/3.0/',
          'author': 'a-contributor',
        };
        expect(await r.setFoundLabel(article, photo, credit), isTrue);
        final row = (await r.article(article))!;
        expect(row.label, isNotNull);
        expect(readAttribution(row.labelAttribution), credit);
        expect(await r.setFoundLabel(article, photo, credit), isFalse);
      },
    );
  });

  group('the screens', () {
    final l10n = AppLocalizationsEn();

    Future<(AppState, Lot2b)> openItemForm(
      WidgetTester tester, {
      required FakeOpenFacts http,
      bool? allowed,
      String code = _ean,
    }) async {
      await onPhone(tester, height: 1600);
      late Lot2b data;
      final state = await pumpApp(
        tester,
        seed: (r) async {
          data = await Lot2b.seed(r);
          if (allowed != null) await r.setBarcodeLookupAllowed(allowed);
        },
        codeCamera: () =>
            FakeCodeCamera(code: ScannedCode(CodeFormat.ean13, code)),
        openFactsHttp: () => http,
      );
      await openScreen(
        tester,
        ItemFormScreen(homeId: data.homes.main, roomId: data.kitchen),
      );
      return (state, data);
    }

    Future<void> scan(WidgetTester tester) async {
      await tester.ensureVisible(find.byKey(const Key('ean-scan')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('ean-scan')));
      await tester.pumpAndSettle();
    }

    testWidgets('the first scan asks first; allowed, the values fill the empty '
        'fields only, and the photo is kept without metadata, with its '
        'credit', (tester) async {
      final http = foundOpenFacts();
      final (state, data) = await openItemForm(tester, http: http);
      await tester.enterText(find.byKey(const Key('item-name')), 'My alarm');
      await scan(tester);
      // Nothing left the phone before the answer.
      expect(find.byType(BarcodeConsentScreen), findsOneWidget);
      expect(http.asked, isEmpty);
      expect(find.text(l10n.barcodeConsentWhat), findsOneWidget);
      await tester.tap(find.byKey(const Key('barcode-consent-allow')));
      await tester.pumpAndSettle();
      expect(state.barcodeLookupAllowed, isTrue);
      expect(http.asked.first.host, 'world.openproductsfacts.org');
      expect(http.asked.first.path, '/api/v2/product/$_ean.json');
      expect(find.byKey(const Key('ean-answer-done')), findsOneWidget);
      expect(find.byKey(const Key('photo-credit')), findsOneWidget);
      await tester.ensureVisible(find.byKey(const Key('ean-use')));
      await tester.tap(find.byKey(const Key('ean-use')));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.save));
      await tester.pumpAndSettle();
      final r = state.repository;
      final item = (await r.itemsOf(data.kitchen))
          .firstWhere((i) => i.ean == _ean);
      expect(item.name, 'My alarm');
      expect(item.brand, 'Acme');
      expect(item.notes, 'Batteries');
      final photos = await r.photosOf(itemId: item.id);
      expect(photos, hasLength(1));
      expect(readAttribution(photos.single.attribution), {
        'source': 'Open Products Facts',
        'source_url': 'https://world.openproductsfacts.org/product/$_ean',
        'license': 'CC BY-SA 3.0',
        'license_url': 'https://creativecommons.org/licenses/by-sa/3.0/',
        'author': 'a-contributor',
      });
      final stored = r.photoFile(photos.single).readAsBytesSync();
      expect(jpegMetadata(stored), isEmpty);
      // The page of the photo shows its credit under it (CC BY-SA 3.0).
      await openScreen(
        tester,
        PhotoScreen(photoId: photos.single.id, writable: true),
      );
      expect(find.byKey(const Key('photo-credit')), findsOneWidget);
      expect(
        tester.widget<Text>(find.byKey(const Key('photo-credit'))).data,
        'Photo by a-contributor, Open Products Facts, CC BY-SA 3.0',
      );
    });

    testWidgets('back from the question without choosing: nothing leaves the '
        'phone, nothing is kept, and the next scan asks again', (tester) async {
      final http = foundOpenFacts();
      final (state, _) = await openItemForm(tester, http: http);
      await scan(tester);
      expect(find.byType(BarcodeConsentScreen), findsOneWidget);
      Navigator.of(tester.element(find.byType(BarcodeConsentScreen))).pop();
      await tester.pumpAndSettle();
      expect(find.byType(BarcodeConsentScreen), findsNothing);
      expect(http.asked, isEmpty);
      expect(state.barcodeLookupAllowed, isNull);
      expect(await state.repository.barcodeLookupAllowed(), isNull);
      expect(find.byKey(const Key('ean-answer-done')), findsNothing);
      expect(
        tester
            .widget<TextFormField>(find.byKey(const Key('ean-field')))
            .controller!
            .text,
        _ean,
      );
      await scan(tester);
      expect(find.byType(BarcodeConsentScreen), findsOneWidget);
      expect(http.asked, isEmpty);
    });

    testWidgets('refused: nothing leaves the phone, the scan fills only the '
        'code, and the switch of Settings turns it on', (tester) async {
      final http = foundOpenFacts();
      final (state, _) = await openItemForm(tester, http: http);
      await scan(tester);
      await tester.tap(find.byKey(const Key('barcode-consent-refuse')));
      await tester.pumpAndSettle();
      expect(http.asked, isEmpty);
      expect(state.barcodeLookupAllowed, isFalse);
      expect(find.text(l10n.barcodeOffAlone), findsOneWidget);
      expect(
        tester
            .widget<TextFormField>(find.byKey(const Key('ean-field')))
            .controller!
            .text,
        _ean,
      );
      // A second scan does not ask again.
      await scan(tester);
      expect(find.byType(BarcodeConsentScreen), findsNothing);
      expect(http.asked, isEmpty);
      await state.setBarcodeLookup(true);
      expect(await state.repository.barcodeLookupAllowed(), isTrue);
    });

    testWidgets('the switch in Settings, alone', (tester) async {
      await onPhone(tester, height: 1600);
      final state = await pumpApp(tester, seed: Lot2b.seed);
      await tester.tap(
        find
            .descendant(
              of: find.byType(NavigationBar),
              matching: find.byType(NavigationDestination),
            )
            .last,
      );
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.byKey(const Key('barcode-lookup-switch')),
        200,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.pumpAndSettle();
      expect(find.text(l10n.barcodeLookupSetting), findsWidgets);
      await tester.tap(find.byKey(const Key('barcode-lookup-switch')));
      await tester.pumpAndSettle();
      expect(state.barcodeLookupAllowed, isTrue);
      await tester.tap(find.byKey(const Key('barcode-lookup-switch')));
      await tester.pumpAndSettle();
      expect(await state.repository.barcodeLookupAllowed(), isFalse);
    });

    testWidgets('offline: a calm message, and the code is filled', (
      tester,
    ) async {
      final http = FakeOpenFacts()..offline = true;
      await openItemForm(tester, http: http, allowed: true);
      await scan(tester);
      expect(find.text(l10n.barcodeOffline), findsOneWidget);
      expect(
        tester
            .widget<TextFormField>(find.byKey(const Key('ean-field')))
            .controller!
            .text,
        _ean,
      );
    });

    testWidgets('a code typed by hand is checked, and never looked up', (
      tester,
    ) async {
      final http = foundOpenFacts();
      await openItemForm(tester, http: http, allowed: true);
      await tester.enterText(find.byKey(const Key('item-name')), 'Alarm');
      await tester.enterText(
        find.byKey(const Key('ean-field')),
        '4006381333932',
      );
      await tester.tap(find.text(l10n.save));
      await tester.pumpAndSettle();
      expect(find.text(l10n.errEanInvalid), findsOneWidget);
      expect(http.asked, isEmpty);
    });

    testWidgets('a stock item: its label from the photo found, credited', (
      tester,
    ) async {
      await onPhone(tester, height: 1600);
      final http = foundOpenFacts();
      late Lot2b data;
      final state = await pumpApp(
        tester,
        seed: (r) async {
          data = await Lot2b.seed(r);
          await r.setBarcodeLookupAllowed(true);
        },
        codeCamera: () =>
            FakeCodeCamera(code: const ScannedCode(CodeFormat.ean13, _ean)),
        openFactsHttp: () => http,
      );
      await openScreen(tester, ArticleFormScreen(homeId: data.homes.main));
      await tester.ensureVisible(find.byKey(const Key('ean-scan')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('ean-scan')));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const Key('ean-use')));
      await tester.tap(find.byKey(const Key('ean-use')));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.save));
      await tester.pumpAndSettle();
      final entry = (await state.repository.articles(
        data.homes.main,
        query: _ean,
      )).single;
      expect(entry.article.name, 'Acme Smoke alarm battery');
      expect(entry.article.label, isNotNull);
      expect(
        readAttribution(entry.article.labelAttribution)?['source'],
        'Open Products Facts',
      );
      // The page of the stock item shows the credit under its label.
      await openScreen(
        tester,
        ArticleScreen(homeId: data.homes.main, articleId: entry.article.id),
      );
      expect(find.byKey(const Key('article-label')), findsOneWidget);
      expect(find.byKey(const Key('photo-credit')), findsOneWidget);
    });

    testWidgets('a stock item: the values fill its empty fields only', (
      tester,
    ) async {
      await onPhone(tester, height: 1600);
      final http = foundOpenFacts();
      late Lot2b data;
      late String article;
      final state = await pumpApp(
        tester,
        seed: (r) async {
          data = await Lot2b.seed(r);
          await r.setBarcodeLookupAllowed(true);
          article = await r.addArticle(
            data.homes.main,
            const ArticleInput(
              name: 'My battery',
              manufacturerReference: 'REF-9V',
              notes: 'In the drawer',
            ),
          );
        },
        codeCamera: () =>
            FakeCodeCamera(code: const ScannedCode(CodeFormat.ean13, _ean)),
        openFactsHttp: () => http,
      );
      await openScreen(
        tester,
        ArticleFormScreen(homeId: data.homes.main, articleId: article),
      );
      await tester.ensureVisible(find.byKey(const Key('ean-scan')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('ean-scan')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('ean-answer-done')), findsOneWidget);
      await tester.ensureVisible(find.byKey(const Key('ean-use')));
      await tester.tap(find.byKey(const Key('ean-use')));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.save));
      await tester.pumpAndSettle();
      final row = (await state.repository.article(article))!;
      expect(row.ean, _ean);
      expect(row.name, 'My battery');
      expect(row.manufacturerReference, 'REF-9V');
      expect(row.notes, 'In the drawer');
    });

    test('with a server, the open databases are never asked from the '
        'phone', () async {
      final r = await openRepository();
      addTearDown(r.db.close);
      final http = foundOpenFacts();
      final state = AppState(r, openFactsHttp: () => http)
        ..syncMode = SyncMode.server
        ..barcodeLookupAllowed = true;
      final answer = await state.lookUpBarcode('h', _ean);
      expect(answer.state, isNot(LookupState.done));
      expect(http.asked, isEmpty);
    });

    test(
      'alone and never asked: the lookup is off, nothing is asked',
      () async {
        final r = await openRepository();
        addTearDown(r.db.close);
        final http = foundOpenFacts();
        final state = AppState(r, openFactsHttp: () => http)
          ..syncMode = SyncMode.alone;
        expect(state.barcodeLookupAllowed, isNull);
        final answer = await state.lookUpBarcode('h', _ean);
        expect(answer.state, LookupState.off);
        expect(http.asked, isEmpty);
        state.barcodeLookupAllowed = false;
        expect((await state.lookUpBarcode('h', _ean)).state, LookupState.off);
        expect(http.asked, isEmpty);
      },
    );

    test('in the family way (relay), the open databases are never asked, '
        'even allowed', () async {
      final r = await openRepository();
      addTearDown(r.db.close);
      final http = foundOpenFacts();
      final state = AppState(r, openFactsHttp: () => http)
        ..syncMode = SyncMode.relay
        ..barcodeLookupAllowed = true;
      final answer = await state.lookUpBarcode('h', _ean);
      expect(answer.state, LookupState.off);
      expect(http.asked, isEmpty);
    });
  });
}

class _NoState implements ServerStateStore {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
