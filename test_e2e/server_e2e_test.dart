// SPDX-License-Identifier: AGPL-3.0-only

// The third way against a real Housecairn server (docs/plan.md, lot 4b,
// first criterion), started in CI from its released image by the job
// "Sync with a Housecairn server (e2e)" of .github/workflows/ci.yml, and
// prepared by tool/e2e/provision.py. Skipped when HC_E2E_URL is not set, so
// `flutter test test_e2e` does nothing on a machine without the server.

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:housecairn_mobile/core/hlc.dart';
import 'package:housecairn_mobile/core/store.dart';
import 'package:housecairn_mobile/data/repository.dart';
import 'package:housecairn_mobile/domain/day.dart';
import 'package:housecairn_mobile/domain/file_reference.dart';
import 'package:housecairn_mobile/domain/photos.dart';
import 'package:housecairn_mobile/domain/recurrence.dart' as recurrence;
import 'package:housecairn_mobile/domain/stock.dart' as stock;
import 'package:housecairn_mobile/sync/operation.dart';
import 'package:housecairn_mobile/sync/server_address.dart';
import 'package:housecairn_mobile/sync/server_http_io.dart';
import 'package:housecairn_mobile/sync/server_sign_in.dart';
import 'package:housecairn_mobile/sync/server_transport.dart';
import 'package:housecairn_mobile/sync/transport.dart';
import 'package:uuid/uuid.dart';

import '../test/support/fakes.dart' show jpegWithGps;
import '../test/support/sync_fixture.dart';

final _env = Platform.environment;
final _url = _env['HC_E2E_URL'];

void main() {
  final skip = _url == null ? 'HC_E2E_URL is not set' : null;
  late ServerAddress address;
  late _Web web;
  late _MemoryStore store;
  late Phone phone;
  late ServerTransport transport;
  late String home;

  setUpAll(() async {
    if (skip != null) return;
    address = ServerAddress.parse(_url!).$1!;
    home = _env['HC_E2E_HOME']!;
    web = _Web(address, _env['HC_E2E_API_TOKEN']!);
    store = _MemoryStore();
    phone = await Phone.open(1);
    // The real clock of the phone: the server refuses a clock more than a
    // day ahead of its own, and the test fixture's clock is in 2026.
    phone.clock.set(DateTime.now().toUtc());
  });

  tearDownAll(() {
    if (skip == null) web.close();
  });

  test(
    'a server too old or wrong is refused in words; this one is not',
    () async {
      final info = await web.json('GET', '/api/v1/sync/info', auth: false);
      final oauth = oauthOfInfo(address, info);
      expect(oauth.clientId, oauthClientId);
      expect(
        () => oauthOfInfo(address, {'detail': 'Not found.'}),
        throwsA(isA<SignInException>()),
      );
    },
    skip: skip,
  );

  test(
    'sign-in in the browser with PKCE: consent page, code, tokens',
    () async {
      final info = await web.json('GET', '/api/v1/sync/info', auth: false);
      final oauth = oauthOfInfo(address, info);
      final request = SignInRequest(
        oauth: oauth,
        createHomes: false,
        deviceName: 'E2E phone',
      );
      // The system browser, already signed in: it opens the consent page and
      // presses Connect with the first home ticked.
      final callback = await web.consent(
        request.authorizeUrl,
        session: _env['HC_E2E_SESSION']!,
        homes: [home],
      );
      final code = request.codeOf(callback);
      final answer = await web.form(oauth.token, request.tokenForm(code));
      final credential = ServerCredential.fromTokenAnswer(answer, oauth);
      expect(credential.access, startsWith('hca_'));
      expect(credential.refresh, startsWith('hcr_'));
      await credential.write(store);
      transport = ServerTransport(
        address: address,
        http: IoServerHttp(address),
        store: store,
        state: phone.repo.serverState,
        device: phone.repo.deviceB64,
        schemaVersion: phone.repo.schemaVersion,
      );
      phone.on(transport);
      final capabilities = await transport.capabilities();
      expect(capabilities.version, isNotEmpty);
      final homes = await transport.homes();
      expect(homes.map((h) => h.id), [home], reason: 'only the home ticked');
      expect(homes.single.owner, isTrue);
      expect(homes.single.members.single.name, isNotEmpty);
    },
    skip: skip,
  );

  test('the first sync brings the server\'s home to the phone', () async {
    final report = await phone.sync();
    expect(report.received, greaterThan(0));
    final names = (await phone.repo.homes()).map((h) => h.name);
    expect(names, ['E2E house']);
  }, skip: skip);

  test('an access the server refuses (401) is renewed by the refresh token, '
      'without a CSRF cookie, and the call goes through', () async {
    final before = (await ServerCredential.read(store))!;
    await ServerCredential(
      access: 'hca_not-an-access-of-this-server',
      refresh: before.refresh,
      token: before.token,
      revoke: before.revoke,
    ).write(store);
    final homes = await transport.homes();
    expect(homes.map((h) => h.id), [home]);
    final after = (await ServerCredential.read(store))!;
    expect(after.access, startsWith('hca_'));
    expect(after.access, isNot('hca_not-an-access-of-this-server'));
    expect(after.refresh, isNot(before.refresh), reason: 'rotated');
  }, skip: skip);

  test('a change made on the phone is read through the web API', () async {
    phone.clock.set(DateTime.now().toUtc());
    final room = await phone.repo.createRoom(home, name: 'Kitchen');
    await phone.sync();
    expect([
      for (final r in transport.rejections) '${r.code} ${r.operation}',
    ], isEmpty);
    final rooms = await web.list('/api/v1/homes/$home/rooms/');
    final found = rooms.where((r) => r['id'] == room).toList();
    expect(found, hasLength(1), reason: 'the server keeps the phone\'s id');
    expect(found.single['name'], 'Kitchen');
  }, skip: skip);

  test('a change made through the web API reaches the phone', () async {
    final created = await web.json(
      'POST',
      '/api/v1/homes/$home/rooms/',
      body: {'name': 'Garage', 'kind': 'other'},
    );
    final id = created['id']! as String;
    await phone.sync();
    final rooms = await phone.repo.rooms(home);
    expect(rooms.map((r) => r.name), contains('Garage'));
    await web.json(
      'PATCH',
      '/api/v1/homes/$home/rooms/$id/',
      body: {'name': 'Workshop'},
    );
    await phone.sync();
    final renamed = await phone.repo.rooms(home);
    expect(renamed.map((r) => r.name), contains('Workshop'));
    expect(renamed.map((r) => r.name), isNot(contains('Garage')));
  }, skip: skip);

  test('a deletion made on the web reaches the phone', () async {
    final room = await phone.repo.createRoom(home, name: 'Attic');
    await phone.sync();
    await web.send('DELETE', '/api/v1/homes/$home/rooms/$room/');
    await phone.sync();
    final rooms = await phone.repo.rooms(home);
    expect(rooms.map((r) => r.id), isNot(contains(room)));
  }, skip: skip);

  test('the same push sent twice runs once: no duplicate', () async {
    final before = await web.list('/api/v1/homes/$home/rooms/');
    final room = await phone.repo.createRoom(home, name: 'Cellar');
    final out = await phone.repo.outgoing();
    final ops = [for (final o in out) o.operation];
    await transport.push(ops);
    await transport.push(ops);
    await phone.sync();
    final after = await web.list('/api/v1/homes/$home/rooms/');
    expect(after.where((r) => r['id'] == room), hasLength(1));
    expect(after.length, before.length + 1);
  }, skip: skip);

  // The cases of docs/adr/0003-sync-protocol.md with the phone offline on one
  // side and the web on the other (docs/plan.md, lot 4b): after the sync,
  // the phone and the server are equal, field by field.

  /// A task that repeats every three months after the last time, due today,
  /// sent to the server; its open occurrence.
  Future<(String, String)> repeatingTask(String title) async {
    phone.clock.set(DateTime.now().toUtc());
    final task = await phone.repo.createTask(
      home,
      TaskInput(
        title: title,
        dueOn: phone.repo.today(),
        repeatMode: recurrence.afterLast,
        repeatUnit: recurrence.monthUnit,
        repeatInterval: 3,
      ),
    );
    await phone.sync();
    expect([
      for (final r in transport.rejections) '${r.code} ${r.operation}',
    ], isEmpty);
    return (task, (await phone.repo.openOccurrencesOf(task)).single.id);
  }

  Future<List<Map<String, Object?>>> webOccurrences(String task) async {
    final (status, text, _) = await web.raw(
      'GET',
      address.resolve('/api/v1/homes/$home/occurrences/', {'task': task}),
      headers: {
        'accept': 'application/json',
        'authorization': 'Bearer ${web.apiToken}',
      },
    );
    expect(status, 200, reason: text);
    return [
      for (final r in (jsonDecode(text) as Map)['results']! as List)
        (r as Map).cast<String, Object?>(),
    ];
  }

  /// Every occurrence of [task] on the phone and on the web, with the fields
  /// both have: the same list on both sides.
  Future<void> expectOccurrencesEqual(String task) async {
    String text(Object? v) => v == null ? '' : '$v';
    final onWeb = {
      for (final o in await webOccurrences(task))
        o['id']! as String: [
          text(o['status']),
          text(o['due_on']),
          text(o['completed_on']),
          text(o['postponed_from']),
        ],
    };
    final onPhone = {
      for (final o in await phone.repo.occurrencesOf(task))
        o.id: [
          o.status,
          '${o.dueOn}',
          text(o.completedOn),
          text(o.postponedFrom),
        ],
    };
    expect(onPhone, onWeb);
  }

  Future<void> syncTwice() async {
    phone.clock.set(DateTime.now().toUtc());
    await phone.sync();
    await phone.sync();
  }

  test('ADR 0003, two closings of one occurrence: done on the phone offline '
      'and on the web give one next occurrence, the same on both', () async {
    final (task, occurrence) = await repeatingTask('Filter of the hood');
    await phone.repo.complete(occurrence);
    await web.send(
      'POST',
      '/api/v1/homes/$home/occurrences/$occurrence/complete/',
      body: {'note': ''},
    );
    await syncTwice();
    expect(await phone.repo.openOccurrencesOf(task), hasLength(1));
    await expectOccurrencesEqual(task);
  }, skip: skip);

  test('ADR 0003, postpone against done: postponed on the phone offline, '
      'done on the web; one open occurrence, the same on both', () async {
    final (task, occurrence) = await repeatingTask('Gutters');
    await phone.repo.postpone(occurrence, phone.repo.today().addDays(3));
    await web.send(
      'POST',
      '/api/v1/homes/$home/occurrences/$occurrence/complete/',
      body: {'note': ''},
    );
    await syncTwice();
    expect(await phone.repo.openOccurrencesOf(task), hasLength(1));
    await expectOccurrencesEqual(task);
  }, skip: skip);

  test('ADR 0003, undo against an edit of the successor: the edit on the web '
      'wins, the undo of the phone is taken back', () async {
    final (task, occurrence) = await repeatingTask('Smoke alarm battery');
    final closing = await phone.repo.complete(occurrence);
    await phone.sync();
    await phone.repo.undo(occurrence);
    // An edit of the successor on the web: it is moved to another day.
    await web.send(
      'POST',
      '/api/v1/homes/$home/occurrences/${closing.nextId}/postpone/',
      body: {'due_on': '${phone.repo.today().addDays(120)}'},
    );
    final report = await phone.sync();
    await syncTwice();
    expect(
      report.notices.map((n) => n.kind),
      contains(SyncNoticeKind.undoReverted),
    );
    expect((await phone.repo.occurrence(occurrence))!.status, 'done');
    expect(await phone.repo.occurrence(closing.nextId!), isNotNull);
    await expectOccurrencesEqual(task);
  }, skip: skip);

  test('ADR 0003, deletion against edit: deleted on the phone offline, renamed '
      'on the web; the row stays deleted on both', () async {
    final room = await phone.repo.createRoom(home, name: 'Laundry');
    await phone.sync();
    await phone.repo.deleteRoom(room);
    await web.json(
      'PATCH',
      '/api/v1/homes/$home/rooms/$room/',
      body: {'name': 'Utility room'},
    );
    await syncTwice();
    expect(await phone.repo.room(room), isNull);
    final (status, _, _) = await web.raw(
      'GET',
      address.resolve('/api/v1/homes/$home/rooms/$room/'),
      headers: {'authorization': 'Bearer ${web.apiToken}'},
    );
    expect(status, 404);
  }, skip: skip);

  test('ADR 0003, two fields of one row: each side keeps its change', () async {
    final room = await phone.repo.createRoom(home, name: 'Study');
    await phone.sync();
    await phone.repo.updateRoom(room, const RoomInput(name: 'Office'));
    await web.json(
      'PATCH',
      '/api/v1/homes/$home/rooms/$room/',
      body: {'notes': 'North light'},
    );
    await syncTwice();
    final onPhone = (await phone.repo.room(room))!;
    final onWeb = await web.json('GET', '/api/v1/homes/$home/rooms/$room/');
    expect(onPhone.name, 'Office');
    expect(onPhone.notes, 'North light');
    expect([onWeb['name'], onWeb['notes']], [onPhone.name, onPhone.notes]);
  }, skip: skip);

  test(
    'ADR 0003, one field on both sides: the later write wins on both',
    () async {
      final room = await phone.repo.createRoom(home, name: 'Porch');
      await phone.sync();
      await phone.repo.updateRoom(room, const RoomInput(name: 'Veranda'));
      // The web writes after the phone, by the clocks of both.
      await Future<void>.delayed(const Duration(milliseconds: 20));
      await web.json(
        'PATCH',
        '/api/v1/homes/$home/rooms/$room/',
        body: {'name': 'Sunroom'},
      );
      await syncTwice();
      final onWeb = await web.json('GET', '/api/v1/homes/$home/rooms/$room/');
      expect((await phone.repo.room(room))!.name, 'Sunroom');
      expect(onWeb['name'], 'Sunroom');
    },
    skip: skip,
  );

  // The three cases of ADR 0003 the engine tests of lot 4 ran between two
  // phones only (decision C of the maintainer, 2026-11-16): against the web.

  SyncOperation ownOp(String id, String kind, String clock) => {
    Op.type: 'rooms.room',
    Op.home: home,
    Op.id: id,
    Op.kind: kind,
    Op.clock: clock,
    Op.device: phone.repo.deviceB64,
    Op.schema: phone.repo.schemaVersion,
  };

  String clockIn(Duration after) => Hlc.format(
    DateTime.now().toUtc().add(after).millisecondsSinceEpoch << 16,
  );

  Future<int> webRoomStatus(String room) async {
    final (status, _, _) = await web.raw(
      'GET',
      address.resolve('/api/v1/homes/$home/rooms/$room/'),
      headers: {'authorization': 'Bearer ${web.apiToken}'},
    );
    return status;
  }

  test('ADR 0003, restore: a restore older than the deletion does not bring '
      'the row back, a later one does, on the web and on the phone', () async {
    phone.clock.set(DateTime.now().toUtc());
    final room = await phone.repo.createRoom(home, name: 'Boiler room');
    await phone.sync();
    await phone.repo.deleteRoom(room);
    await phone.sync();
    expect(await webRoomStatus(room), 404);
    final deleted =
        (await phone.repo.snapshot()).rows
                .singleWhere((r) => r.id == room)
                .fields['deleted_at']![1]!
            as String;
    final older = Hlc.format(Hlc.parse(deleted) - (1 << 16));
    var result = await transport.push([ownOp(room, Op.restore, older)]);
    expect(result.refused, isEmpty);
    await phone.sync();
    expect(await webRoomStatus(room), 404);
    expect(await phone.repo.room(room), isNull);
    result = await transport.push([
      ownOp(room, Op.restore, clockIn(const Duration(seconds: 1))),
    ]);
    expect(result.refused, isEmpty);
    await phone.sync();
    expect(await webRoomStatus(room), 200);
    expect((await phone.repo.room(room))?.name, 'Boiler room');
  }, skip: skip);

  test('ADR 0003, the same article drawn twice: done on the phone offline and '
      'on the web; one draw row, and the same stock on both', () async {
    final (task, occurrence) = await repeatingTask('Filter of the extractor');
    final article = await phone.repo.addArticle(
      home,
      const ArticleInput(name: 'Extractor filter'),
    );
    await phone.repo.recordMovement(
      article,
      kind: stock.entryKind,
      quantity: '3',
    );
    await phone.repo.addMaterial(task, article, '1');
    await phone.sync();
    expect([
      for (final r in transport.rejections) '${r.code} ${r.operation}',
    ], isEmpty);
    await phone.repo.complete(occurrence);
    await web.send(
      'POST',
      '/api/v1/homes/$home/occurrences/$occurrence/complete/',
      body: {'note': ''},
    );
    await syncTwice();
    expect([
      for (final r in transport.rejections) '${r.code} ${r.operation}',
    ], isEmpty);
    final draws = await phone.repo.db.select(phone.repo.db.materialDraws).get();
    expect(draws.where((d) => d.occurrenceId == occurrence), hasLength(1));
    final onWeb = await web.json(
      'GET',
      '/api/v1/homes/$home/articles/$article/',
    );
    expect(
      Decimal.parse('${onWeb['quantity']}'),
      await phone.repo.stockLevel(article),
    );
    await expectOccurrencesEqual(task);
  }, skip: skip);

  test('a stock item added from the materials of the task of an item fits '
      'that item on the server, which lists it for the item and its room, '
      'without a refusal', () async {
    // The equipment is there already, made on the web and synced.
    final room =
        (await web.json(
              'POST',
              '/api/v1/homes/$home/rooms/',
              body: {'name': 'Boiler room', 'kind': 'other'},
            ))['id']!
            as String;
    final item =
        (await web.json(
              'POST',
              '/api/v1/homes/$home/items/',
              body: {'room': room, 'name': 'Wall boiler', 'kind': 'equipment'},
            ))['id']!
            as String;
    phone.clock.set(DateTime.now().toUtc());
    await phone.sync();
    expect((await phone.repo.item(item))?.name, 'Wall boiler');
    // What the task form writes: the task on the item, then the stock item
    // of *Add a stock item…*, fitting the item, and its line.
    final task = await phone.repo.createTask(
      home,
      TaskInput(title: 'Change the seal', roomId: room, itemId: item),
    );
    final seal = await phone.repo.addArticle(
      home,
      ArticleInput(name: 'Boiler seal', unit: 'piece', itemIds: [item]),
    );
    await phone.repo.saveMaterial(task, seal, '2');
    await phone.sync();
    expect([
      for (final r in transport.rejections) '${r.code} ${r.operation}',
    ], isEmpty);
    final onWeb = await web.json('GET', '/api/v1/homes/$home/articles/$seal/');
    expect(onWeb['compatible_items'], [item]);
    expect(onWeb['unit'], 'piece');
    Future<List<Object?>> listed(Map<String, String> query) async {
      final (status, text, _) = await web.raw(
        'GET',
        address.resolve('/api/v1/homes/$home/articles/', query),
        headers: {
          'accept': 'application/json',
          'authorization': 'Bearer ${web.apiToken}',
        },
      );
      expect(status, 200, reason: text);
      return [
        for (final a in (jsonDecode(text) as Map)['results']! as List)
          (a as Map)['id'],
      ];
    }

    expect(await listed({'item': item}), [seal]);
    expect(await listed({'room': room}), [seal]);
    // The link removed on the web reaches the phone.
    await web.json(
      'PATCH',
      '/api/v1/homes/$home/articles/$seal/',
      body: {'compatible_items': <String>[]},
    );
    await phone.sync();
    expect(await phone.repo.compatibleItemsOf(seal), isEmpty);
    expect(await phone.repo.articlesOfRoom(room), isEmpty);
  }, skip: skip);

  test('ADR 0003, versions: a field of a newer app is kept by the server and '
      'by this phone, which does not know it; a phone below the server\'s '
      'lowest sv reads but does not write', () async {
    phone.clock.set(DateTime.now().toUtc());
    final room = await phone.repo.createRoom(home, name: 'Loft');
    await phone.sync();
    // A newer app wrote a field this version has no column for.
    final result = await transport.push([
      {
        ...ownOp(room, Op.put, clockIn(const Duration(seconds: 1))),
        Op.fields: {'energy_rating': 'A'},
      },
    ]);
    expect(result.refused, isEmpty);
    await phone.sync();
    expect(await phone.repo.extraFields('rooms.room', room), {
      'energy_rating': 'A',
    });
    // This phone changes the row: the field it does not know stays.
    phone.clock.set(DateTime.now().toUtc().add(const Duration(seconds: 2)));
    await phone.repo.updateRoom(room, const RoomInput(name: 'Attic room'));
    await phone.sync();
    final access = (await ServerCredential.read(store))!.access;
    final (status, text, _) = await web.raw(
      'GET',
      address.resolve('/api/v1/sync/homes/$home/snapshot'),
      headers: {'authorization': 'Bearer $access'},
    );
    expect(status, 200);
    final row = [
      for (final line in const LineSplitter().convert(text))
        if (line.trim().isNotEmpty) jsonDecode(line) as Map,
    ].singleWhere((r) => r['id'] == room);
    final fields = (row['f']! as Map).cast<String, Object?>();
    expect((fields['energy_rating']! as List).first, 'A');
    expect((fields['name']! as List).first, 'Attic room');
    // Below the lowest schema version of the server (1): nothing written.
    final old = ServerTransport(
      address: address,
      http: IoServerHttp(address),
      store: store,
      // A number this connection never used, so that the server reads the
      // schema version and not the number.
      state: _MemoryState()..value = ServerSyncState(nextPush: 900000).encode(),
      device: phone.repo.deviceB64,
      schemaVersion: 0,
    );
    await expectLater(
      old.push([
        {
          ...ownOp(room, Op.put, clockIn(const Duration(seconds: 3))),
          Op.fields: {'name': 'Old app'},
        },
      ]),
      throwsA(
        isA<ServerStopped>().having(
          (e) => e.reason,
          'reason',
          ServerStop.updateApp,
        ),
      ),
    );
    final onWeb = await web.json('GET', '/api/v1/homes/$home/rooms/$room/');
    expect(onWeb['name'], 'Attic room');
  }, skip: skip);

  test('decision A: an operation the server cannot read is kept aside with '
      'its reason, the others of the push are written', () async {
    phone.clock.set(DateTime.now().toUtc());
    final good = const Uuid().v4();
    final bad = const Uuid().v4();
    final result = await transport.push([
      {
        ...ownOp(good, Op.put, clockIn(Duration.zero)),
        Op.fields: {'name': 'Pantry', 'kind': 'other'},
      },
      // A clock out of form: the server cannot read the operation.
      {
        ...ownOp(bad, Op.put, 'not-a-clock'),
        Op.fields: {'name': 'Larder', 'kind': 'other'},
      },
    ]);
    expect(result.refused.map((r) => (r.operation[Op.id], r.code)), [
      (bad, 'malformed'),
    ]);
    expect(await webRoomStatus(good), 200);
  }, skip: skip);

  test('an item made on the phone with every field goes to the server as the '
      'web keeps it, and the web\'s edit of its links comes back', () async {
    phone.clock.set(DateTime.now().toUtc());
    final room = await phone.repo.createRoom(home, name: 'Utility room');
    final contractor = await phone.repo.createContractor(
      home,
      name: 'Acme Heating',
    );
    final full = await phone.repo.addItem(
      room,
      ItemInput(
        name: 'Boiler',
        brand: 'Acme',
        model: 'B-200',
        serialNumber: 'SN-0187',
        ean: '4006381333931',
        installedOn: Day(2025, 3, 1),
        purchasedOn: Day(2025, 2, 20),
        warrantyDuration: 2,
        warrantyProvider: 'manufacturer',
        warrantyProviderName: 'Acme',
        contractContractorId: contractor,
        contractNumber: 'C-2024-0187',
        contractUrl: 'https://example.com/contract',
        links: const [
          ItemLink(url: 'https://example.com/manual', label: 'Manual'),
          ItemLink(url: 'https://example.com/parts'),
        ],
        notes: 'Serviced every autumn.',
      ),
    );
    // The least an item has: its name; no barcode, no link, no warranty.
    final bare = await phone.repo.addItem(
      room,
      const ItemInput(name: 'Radiator'),
    );
    await phone.repo.addPhoto(
      home,
      processPhoto(jpegWithGps(width: 320, orientation: 1)),
      itemId: full,
    );

    final report = await phone.sync();

    expect([
      for (final r in await phone.repo.refusedChanges())
        '${r.code} ${r.detail} ${r.operation}',
    ], isEmpty);
    expect([
      for (final r in transport.rejections) '${r.code} ${r.operation}',
    ], isEmpty);
    expect(report.filesSent, 1);
    final items = {
      for (final i in await web.list('/api/v1/homes/$home/items/')) i['id']: i,
    };
    expect(items[full], isNotNull, reason: 'the server keeps the phone\'s id');
    expect(items[full]!['links'], [
      {'url': 'https://example.com/manual', 'label': 'Manual'},
      {'url': 'https://example.com/parts'},
    ]);
    expect(items[full]!['ean'], '4006381333931');
    expect(items[full]!['warranty_duration'], 2);
    expect(items[full]!['warranty_ends_on'], '2027-02-20');
    expect(items[full]!['contract_contractor'], contractor);
    expect(items[bare]!['links'], isEmpty);
    expect(items[bare]!['ean'], '');

    await web.json(
      'PATCH',
      '/api/v1/homes/$home/items/$bare/',
      body: {
        'links': [
          {'url': 'https://example.com/radiator', 'label': 'Valve'},
        ],
      },
    );
    await phone.sync();
    final back = (await phone.repo.item(bare))!;
    expect(Repository.linksOf(back).map((l) => (l.url, l.label)), [
      ('https://example.com/radiator', 'Valve'),
    ]);
  }, skip: skip);

  test('a photo goes to the server and comes back (file routes of web 0.5.0): '
      'sent before its row, kept by the server, fetched again as the '
      'server\'s copy without any error', () async {
    phone.clock.set(DateTime.now().toUtc());
    final room = await phone.repo.createRoom(home, name: 'Hall');
    final id = await phone.repo.addPhoto(
      home,
      processPhoto(jpegWithGps(width: 320, orientation: 1)),
      roomId: room,
    );
    final photo = (await phone.repo.photo(id))!;
    final reference = FileReference.parse(photo.image, rowId: id)!;

    final sent = await phone.sync();

    expect(sent.filesSent, 1);
    expect([
      for (final r in transport.rejections) '${r.code} ${r.operation}',
    ], isEmpty);
    final kept = await transport.getFile(home, reference.file);
    expect(kept.take(2), [0xFF, 0xD8], reason: 'the server\'s own JPEG');
    expect((await phone.repo.fileQueue()).toSend, 0);

    // The phone loses the file and its list: the server's copy comes back,
    // whose bytes are not the ones the digest names, and is no error.
    phone.repo.photoFile(photo).deleteSync();
    await phone.repo.forgetFileSync();
    final back = await phone.sync();
    expect(back.filesFetched, 1);
    expect(phone.repo.photoFile(photo).existsSync(), isTrue);
    await phone.sync();
    final queue = await phone.repo.fileQueue();
    expect([queue.waiting, queue.failed, queue.fetching], [0, 0, 0]);
  }, skip: skip);

  test('revoking the access on the server stops the phone at its next call, '
      'and the phone says so', () async {
    final access = (await ServerCredential.read(store))!.access;
    final info = await web.raw(
      'GET',
      address.resolve('/api/v1/sync/info'),
      headers: {'authorization': 'Bearer $access'},
    );
    final connection =
        ((jsonDecode(info.$2) as Map)['connection'] as Map)['id'] as String;
    await web.revokeConnection(connection, session: _env['HC_E2E_SESSION']!);
    await expectLater(
      phone.sync(),
      throwsA(
        isA<ServerStopped>().having(
          (e) => e.reason,
          'reason',
          ServerStop.disconnected,
        ),
      ),
    );
    // The phone keeps its copy of the homes.
    expect((await phone.repo.homes()).map((h) => h.name), ['E2E house']);
  }, skip: skip);

  test('disconnect deletes the credential from Store', () async {
    await transport.disconnect();
    expect(await ServerCredential.read(store), isNull);
    expect(store.values, isEmpty);
    await expectLater(
      transport.homes(),
      throwsA(
        isA<ServerStopped>().having(
          (e) => e.reason,
          'reason',
          ServerStop.disconnected,
        ),
      ),
    );
  }, skip: skip);

  test('/o/token/ and /o/revoke_token/ take a request without a CSRF cookie, '
      'as a phone sends it (web v0.4.1)', () async {
    for (final route in ['/o/token/', '/o/revoke_token/']) {
      final reply = await web.raw(
        'POST',
        address.resolve(route),
        headers: {'content-type': 'application/x-www-form-urlencoded'},
        body: 'client_id=$oauthClientId',
      );
      expect(reply.$1, isNot(403), reason: route);
    }
  }, skip: skip);
}

class _MemoryState implements ServerStateStore {
  String? value;

  @override
  Future<String?> readServerState() async => value;

  @override
  Future<void> writeServerState(String? state) async => value = state;
}

class _MemoryStore implements Store {
  final values = <String, Uint8List>{};

  @override
  Future<Uint8List?> read(String key) async => values[key];

  @override
  Future<void> write(String key, Uint8List value) async => values[key] = value;

  @override
  Future<void> delete(String key) async => values.remove(key);
}

/// The web side of the test: the resources of the API with an API token,
/// and a browser for the consent page.
class _Web {
  _Web(this.address, this.apiToken);

  final ServerAddress address;
  final String apiToken;
  final _client = HttpClient();

  /// The CSRF cookie the consent page set, for the pages of the browser
  /// only: the token requests go without it, as a phone sends them.
  String? csrf;

  void close() => _client.close(force: true);

  Future<(int, String, HttpHeaders)> raw(
    String method,
    Uri url, {
    Map<String, String> headers = const {},
    String? body,
  }) async {
    final request = await _client.openUrl(method, url);
    request.followRedirects = false;
    headers.forEach(request.headers.set);
    if (body != null) {
      final bytes = utf8.encode(body);
      request.contentLength = bytes.length;
      request.add(bytes);
    }
    final response = await request.close();
    return (
      response.statusCode,
      await utf8.decodeStream(response),
      response.headers,
    );
  }

  Future<(int, String)> send(
    String method,
    String route, {
    Object? body,
    bool auth = true,
  }) async {
    final reply = await raw(
      method,
      address.resolve(route),
      headers: {
        'accept': 'application/json',
        if (body != null) 'content-type': 'application/json',
        if (auth) 'authorization': 'Bearer $apiToken',
      },
      body: body == null ? null : jsonEncode(body),
    );
    if (reply.$1 >= 400) {
      throw StateError('$method $route: ${reply.$1} ${reply.$2}');
    }
    return (reply.$1, reply.$2);
  }

  Future<Map<String, Object?>> json(
    String method,
    String route, {
    Object? body,
    bool auth = true,
  }) async {
    final (_, text) = await send(method, route, body: body, auth: auth);
    return (jsonDecode(text) as Map).cast<String, Object?>();
  }

  Future<List<Map<String, Object?>>> list(String route) async {
    final page = await json('GET', route);
    return [
      for (final r in page['results']! as List)
        (r as Map).cast<String, Object?>(),
    ];
  }

  Future<Map<String, Object?>> form(Uri url, Map<String, String> fields) async {
    final reply = await raw(
      'POST',
      url,
      headers: {
        'accept': 'application/json',
        'content-type': 'application/x-www-form-urlencoded',
      },
      body: Uri(queryParameters: fields).query,
    );
    if (reply.$1 != 200) throw StateError('token: ${reply.$1} ${reply.$2}');
    return (jsonDecode(reply.$2) as Map).cast<String, Object?>();
  }

  /// Opens [authorize] as the signed-in browser, ticks [homes] and presses
  /// Connect; gives the redirect to the app's scheme.
  Future<Uri> consent(
    Uri authorize, {
    required String session,
    required List<String> homes,
  }) async {
    var cookies = 'sessionid=$session';
    final page = await raw('GET', authorize, headers: {'cookie': cookies});
    if (page.$1 != 200) {
      throw StateError('consent page: ${page.$1} ${page.$2}');
    }
    final csrf = page.$3[HttpHeaders.setCookieHeader]
        ?.map(Cookie.fromSetCookieValue)
        .where((c) => c.name == 'csrftoken')
        .firstOrNull;
    if (csrf != null) {
      cookies = '$cookies; csrftoken=${csrf.value}';
      this.csrf = csrf.value;
    }
    final hidden = <String, String>{
      for (final m in RegExp(
        r'<input[^>]*type="hidden"[^>]*>',
      ).allMatches(page.$2))
        if (RegExp(r'name="([^"]+)"').firstMatch(m.group(0)!) case final n?)
          n.group(1)!: _unescape(
            RegExp(r'value="([^"]*)"').firstMatch(m.group(0)!)?.group(1) ?? '',
          ),
    };
    final body = [
      for (final MapEntry(:key, :value) in hidden.entries)
        '${Uri.encodeQueryComponent(key)}=${Uri.encodeQueryComponent(value)}',
      for (final h in homes) 'homes=$h',
      'allow=1',
    ].join('&');
    final answer = await raw(
      'POST',
      authorize,
      headers: {
        'cookie': cookies,
        'content-type': 'application/x-www-form-urlencoded',
        'referer': authorize.toString(),
      },
      body: body,
    );
    final location = answer.$3.value(HttpHeaders.locationHeader);
    if (answer.$1 != 302 || location == null) {
      throw StateError('consent: ${answer.$1} ${answer.$2}');
    }
    return Uri.parse(location);
  }

  /// Revokes the connection [id] from the account's page, as its owner
  /// does on the web (Connected apps, Revoke).
  Future<void> revokeConnection(String id, {required String session}) async {
    final url = address.resolve('/me/tokens/apps/$id/revoke/');
    final page = await raw(
      'GET',
      url,
      headers: {'cookie': 'sessionid=$session'},
    );
    if (page.$1 != 200) throw StateError('revoke page: ${page.$1}');
    final token = RegExp(r'name="csrfmiddlewaretoken" value="([^"]+)"')
        .firstMatch(page.$2)!
        .group(1)!;
    final set = page.$3[HttpHeaders.setCookieHeader]
        ?.map(Cookie.fromSetCookieValue)
        .where((c) => c.name == 'csrftoken')
        .firstOrNull;
    final answer = await raw(
      'POST',
      url,
      headers: {
        'cookie': 'sessionid=$session; csrftoken=${set?.value ?? csrf}',
        'content-type': 'application/x-www-form-urlencoded',
      },
      body: 'csrfmiddlewaretoken=$token',
    );
    if (answer.$1 != 302) throw StateError('revoke: ${answer.$1} ${answer.$2}');
  }

  static String _unescape(String text) => text
      .replaceAll('&quot;', '"')
      .replaceAll('&#x27;', "'")
      .replaceAll('&#39;', "'")
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&amp;', '&');
}
