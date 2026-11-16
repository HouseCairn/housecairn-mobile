// SPDX-License-Identifier: AGPL-3.0-only

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:housecairn_mobile/core/clock.dart';
import 'package:housecairn_mobile/data/repository.dart';
import 'package:housecairn_mobile/data/database.dart' show PhotoRow;
import 'package:housecairn_mobile/domain/file_reference.dart';
import 'package:housecairn_mobile/domain/photos.dart';
import 'package:housecairn_mobile/domain/templates.dart';
import 'package:housecairn_mobile/l10n/app_localizations_en.dart';
import 'package:housecairn_mobile/l10n/app_localizations_fr.dart';
import 'package:housecairn_mobile/sync/engine.dart' show SyncReport;
import 'package:housecairn_mobile/sync/files.dart';
import 'package:housecairn_mobile/sync/mode.dart';
import 'package:housecairn_mobile/sync/server_address.dart';
import 'package:housecairn_mobile/sync/operation.dart';
import 'package:housecairn_mobile/sync/server_http.dart';
import 'package:housecairn_mobile/sync/server_sign_in.dart';
import 'package:housecairn_mobile/sync/server_transport.dart';
import 'package:housecairn_mobile/sync/transport.dart';
import 'package:housecairn_mobile/ui/state.dart';
import 'package:housecairn_mobile/ui/ways.dart' show filesProblem;

import 'support/files_server.dart';
import 'support/fakes.dart';
import 'support/fixture.dart';
import 'support/server_fake.dart' show MemoryStore;

/// The photos and files of the third way (lot 4c, docs/adr/0012): a phone
/// and a server that has the file routes of web ADR 0077, from the sending of
/// a photo to its deletion, the refusals, and a cut then a resumption. The
/// server is the scripted one of test/support/files_server.dart; the real one
/// runs in the e2e job.
void main() {
  final address = ServerAddress.parse('https://hc.example.com').$1!;
  const uuid = '3c1d9e2a-7b4f-4c8d-9e1a-2b3c4d5e6f70';

  late FixedClock clock;
  late Repository repo;
  late FilesServer server;
  late AppState state;
  late String home;
  late String room;

  Future<SyncReport?> sync() => state.syncWithServer(throwing: true);

  AppState stateOf() => AppState(
    repo,
    store: store,
    serverHttp: (a) => server..address = a,
    syncDelay: const Duration(days: 1),
    photoProcessor: (bytes) async => processPhoto(bytes),
    thumbnailer: thumbnailHere,
    loadTemplates: () async =>
        parseTemplates(File('assets/task_templates.yaml').readAsStringSync()),
    openUrl: (_) async => true,
  );

  /// A phone in the third way, with its home and its room Kitchen, and the
  /// server that has them.
  Future<void> startPhone() async {
    clock = FixedClock(testNow);
    repo = await openRepository(clock: clock);
    addTearDown(repo.db.close);
    home = await repo.createHome(name: 'House');
    room = await repo.createRoom(home, name: 'Kitchen');
    server = FilesServer(home)
      ..phoneDevice = repo.deviceB64
      ..nowMs = () => clock.now().millisecondsSinceEpoch;
    store = MemoryStore();
    await ServerCredential(
      access: 'hca_one',
      refresh: 'hcr_one',
      token: address.resolve('/o/token/'),
      revoke: address.resolve('/o/revoke_token/'),
    ).write(store);
    await repo.setServerAddress(address.display);
    await repo.setSyncMode(SyncMode.server);
    state = stateOf();
    addTearDown(state.dispose);
    await state.refresh();
    await sync();
  }

  Uint8List jpeg([int width = 64]) =>
      processPhoto(jpegWithGps(width: width, orientation: 1)).image;

  Future<PhotoRow> photoMade({Uint8List? bytes}) async {
    final id = await repo.addPhoto(
      home,
      processPhoto(bytes ?? jpegWithGps(orientation: 1)),
      roomId: room,
    );
    return (await repo.photo(id))!;
  }

  FileReference referenceOf(PhotoRow photo) =>
      FileReference.parse(photo.image, rowId: photo.id)!;

  List<String> puts() => server.log.where((l) => l.startsWith('PUT ')).toList();
  List<String> gets() => server.log.where((l) => l.startsWith('GET ')).toList();

  group('a photo made on the phone', () {
    setUp(startPhone);

    test('goes to the server with its id and its digest, before the row that '
        'refers to it', () async {
      final photo = await photoMade();
      final reference = referenceOf(photo);
      final bytes = repo.photoFile(photo).readAsBytesSync();
      expect(reference.file, isNot(photo.id));
      expect(reference.sha256, sha256Hex(bytes));

      final report = await state.syncWithServer(throwing: true);

      expect(report!.filesSent, 1);
      expect(server.files[reference.file], bytes);
      expect(server.digests[reference.file], sha256Hex(bytes));
      final upload = server.log.indexOf('PUT ${reference.file}');
      final push = server.log.lastIndexOf('push');
      expect(upload, greaterThanOrEqualTo(0));
      expect(upload, lessThan(push), reason: 'the file, then the row');
      final op = server.pushed.firstWhere((o) => o['id'] == photo.id);
      final wire = (op['f'] as Map)['image'] as Map;
      expect(wire['file'], reference.file);
      expect(wire['sha256'], reference.sha256);
      expect(wire['type'], 'image/jpeg');
      expect((await repo.fileQueue()).toSend, 0);
    });

    test('is sent once: a second round sends nothing', () async {
      final photo = await photoMade();
      await sync();
      await sync();
      await sync();
      expect(puts(), ['PUT ${referenceOf(photo).file}']);
    });

    test(
      'a photo of the first builds, whose reference has no id and no digest, '
      'is completed before it goes',
      () async {
        final id = await repo.createPhotoRow(
          home,
          roomId: room,
          image: jsonEncode({
            'size': 3,
            'type': 'image/jpeg',
            'width': 64,
            'height': 32,
          }),
        );
        final bytes = jpeg();
        repo.homeDirectory(home).createSync(recursive: true);
        File('${repo.homeDirectory(home).path}/$id.jpg')
            .writeAsBytesSync(bytes);

        await sync();

        final fileId = FileReference.legacyFile(id);
        expect(server.files[fileId], bytes);
        final op = server.pushed.firstWhere((o) => o['id'] == id);
        final wire = (op['f'] as Map)['image'] as Map;
        expect(wire['file'], fileId);
        expect(wire['sha256'], sha256Hex(bytes));
        final row = (await repo.photo(id))!;
        expect(referenceOf(row).sha256, sha256Hex(bytes));
      },
    );

    test('a file of a project goes as a photo does, without the columns the '
        'server reads in the reference', () async {
      final project = await repo.createProject(
        home,
        const ProjectInput(title: 'Kitchen'),
      );
      final fileId = await repo.addProjectFile(
        project,
        name: 'plan.jpg',
        bytes: jpegWithGps(orientation: 1),
        contentType: 'image/jpeg',
      );
      final row = (await repo.filesOf(project)).single;
      final reference = FileReference.parse(row.file, rowId: fileId)!;

      await sync();

      expect(server.files.containsKey(reference.file), isTrue);
      final op = server.pushed.firstWhere(
        (o) => o['t'] == 'projects.projectfile' && o['id'] == fileId,
      );
      final fields = op['f'] as Map;
      expect((fields['file'] as Map)['sha256'], reference.sha256);
      expect(fields.containsKey('content_type'), isFalse);
      expect(fields.containsKey('size_bytes'), isFalse);
    });

    test(
      'a file larger than the server takes is not sent, and says so',
      () async {
        server.fileMaxBytes = 10;
        final photo = await photoMade();
        await sync();
        expect(puts(), isEmpty);
        final queue = await repo.fileQueue();
        expect(queue.failed, 1);
        expect(queue.codes, {'too_large'});
        // The row went all the same: the file never holds the rows back.
        expect(server.pushed.any((o) => o['id'] == photo.id), isTrue);
      },
    );
  });

  group('a photo made elsewhere', () {
    setUp(startPhone);

    test(
      'arrives with its row, its file is fetched and not sent back',
      () async {
        final bytes = jpeg(48);
        server.addWebPhoto(uuid, bytes, roomId: room);

        final report = await state.syncWithServer(throwing: true);

        expect(report!.filesFetched, 1);
        final photo = (await repo.photo(uuid))!;
        expect(photo.caption, 'From the web');
        expect(referenceOf(photo).file, uuid);
        expect(repo.photoFile(photo).readAsBytesSync(), bytes);
        expect(repo.thumbnailFile(photo).existsSync(), isTrue);
        await sync();
        await sync();
        expect(puts(), isEmpty, reason: 'a file fetched is not sent back');
        expect(gets(), ['GET $uuid'], reason: 'and fetched once');
      },
    );

    test('a file the server does not have yet waits, with no error and the '
        'row shown', () async {
      server.addWebPhoto(uuid, jpeg());
      server.missing.add(uuid);

      await sync();

      final photo = (await repo.photo(uuid))!;
      expect(repo.photoFile(photo).existsSync(), isFalse);
      expect((await repo.fileQueue()).fetching, 1);
      // Not tried again at once: it waits, then the wait is over.
      await sync();
      expect(gets(), hasLength(1));
      server.missing.clear();
      clock.advance(const Duration(seconds: 31));
      await sync();
      expect(repo.photoFile(photo).existsSync(), isTrue);
      expect((await repo.fileQueue()).fetching, 0);
    });
  });

  group('after the phone left the server and came back', () {
    setUp(startPhone);

    test('a photo made elsewhere, held as the server copy, is not an error '
        'nor to send', () async {
      final photo = await photoMade();
      await sync();
      // What the phone holds of a photo another phone made: the server's
      // re-encoded copy, whose bytes are not the ones the reference names.
      repo.photoFile(photo).writeAsBytesSync(jpeg(80));
      await repo.forgetFileSync();

      await sync();

      final queue = await repo.fileQueue();
      expect([queue.waiting, queue.failed, queue.toSend], [0, 0, 0]);
      expect(queue.codes, isEmpty);
      expect(puts(), hasLength(1), reason: 'only the first send');
    });

    test('a photo made here and not yet sent is sent after the entries '
        'were forgotten', () async {
      server.cutUploads = true;
      final photo = await photoMade();
      await sync();
      expect((await repo.fileQueue()).waiting, 1);
      await repo.forgetFileSync();
      server.cutUploads = false;

      await sync();

      expect(server.files.containsKey(referenceOf(photo).file), isTrue);
      expect((await repo.fileQueue()).toSend, 0);
    });
  });

  group('a photo deleted', () {
    setUp(startPhone);

    test('before it was sent: it is not counted, and not sent', () async {
      server.cutUploads = true;
      final photo = await photoMade();
      expect((await repo.fileQueue()).toSend, 1);
      await repo.deletePhoto(photo.id);

      await sync();

      expect((await repo.fileQueue()).toSend, 0);
      server.cutUploads = false;
      clock.advance(const Duration(minutes: 5));
      await sync();
      expect(puts(), isEmpty);
    });

    test(
      'in a home that is not of the server: its file is not swept',
      () async {
        final other = await repo.createHome(name: 'Cabin');
        final id = await repo.addPhoto(
          other,
          processPhoto(jpegWithGps(orientation: 1)),
          roomId: await repo.createRoom(other, name: 'Hall'),
        );
        final photo = (await repo.photo(id))!;
        await repo.deletePhoto(id);
        clock.advance(const Duration(days: 31));

        expect(await repo.sweepFiles(), 0);

        expect(repo.photoFile(photo).existsSync(), isTrue);
      },
    );

    test(
      'on the phone: the server hears it, the file goes after 30 days',
      () async {
        final photo = await photoMade();
        await sync();
        await repo.deletePhoto(photo.id);
        await sync();
        final op = server.pushed.lastWhere((o) => o['id'] == photo.id);
        expect(op['k'], 'delete');
        expect(
          repo.photoFile(photo).existsSync(),
          isTrue,
          reason: 'can be restored',
        );

        clock.advance(const Duration(days: 29));
        await sync();
        expect(repo.photoFile(photo).existsSync(), isTrue);
        clock.advance(const Duration(days: 2));
        await sync();
        expect(repo.photoFile(photo).existsSync(), isFalse);
        expect(repo.thumbnailFile(photo).existsSync(), isFalse);
        expect((await repo.fileQueue()).toSend, 0);
      },
    );

    test(
      'on the web: the row is deleted here, the file goes after 30 days',
      () async {
        server.addWebPhoto(uuid, jpeg(), roomId: room);
        await sync();
        final photo = (await repo.photo(uuid))!;
        server.deleteOnWeb('rooms.photo', uuid);
        await sync();
        expect(await repo.photo(uuid), isNull);
        expect(repo.photoFile(photo).existsSync(), isTrue);
        clock.advance(const Duration(days: 31));
        await sync();
        expect(repo.photoFile(photo).existsSync(), isFalse);
      },
    );
  });

  group('when a file cannot go', () {
    setUp(startPhone);

    test('refused for its digest (400): a visible failure, tried again only '
        'when the person says so, never in a loop', () async {
      server.refuseUploads = (400, 'malformed');
      final photo = await photoMade();

      await sync();
      await sync();
      await sync();

      expect(puts(), hasLength(1), reason: 'no loop');
      final queue = await repo.fileQueue();
      expect([queue.waiting, queue.failed], [0, 1]);
      expect(queue.codes, {'malformed'});
      expect(
        server.pushed.any((o) => o['id'] == photo.id),
        isTrue,
        reason: 'the rows go all the same',
      );

      server.refuseUploads = null;
      await state.retryFiles();
      expect(puts(), hasLength(2));
      expect((await repo.fileQueue()).toSend, 0);
      expect(server.files.containsKey(referenceOf(photo).file), isTrue);
    });

    test('a file that is not the one its row names is not sent', () async {
      final photo = await photoMade();
      // The phone has seen the photo (so it knows it made it) when the file
      // changes under it.
      await repo.fileQueue();
      repo.photoFile(photo).writeAsBytesSync([1, 2, 3, 4]);
      await sync();
      expect(puts(), isEmpty);
      expect((await repo.fileQueue()).codes, {'malformed'});
    });

    test('over the quota (413): explained, and tried again by hand', () async {
      server.refuseUploads = (413, 'quota_exceeded');
      await photoMade();
      await sync();
      final queue = await repo.fileQueue();
      expect(queue.codes, {'quota_exceeded'});
      expect(
        filesProblem(AppLocalizationsEn(), queue.codes),
        AppLocalizationsEn().filesRefusedQuota,
      );
      expect(
        filesProblem(AppLocalizationsFr(), queue.codes),
        AppLocalizationsFr().filesRefusedQuota,
      );
    });

    test('a cut: the file waits with a longer wait each time, and goes when '
        'the connection is back, even after the app was closed', () async {
      server.cutUploads = true;
      final photo = await photoMade();

      await sync();
      expect(puts(), hasLength(1));
      expect((await repo.fileQueue()).waiting, 1);
      await sync();
      expect(puts(), hasLength(1), reason: 'the wait is not over');

      clock.advance(const Duration(seconds: 31));
      await sync();
      expect(puts(), hasLength(2));
      clock.advance(const Duration(seconds: 31));
      await sync();
      expect(puts(), hasLength(2), reason: 'the second wait is longer: 60 s');

      // The app is closed and opened again; the connection is back.
      state = stateOf();
      addTearDown(state.dispose);
      await state.refresh();
      server.cutUploads = false;
      clock.advance(const Duration(minutes: 2));
      await sync();

      expect(puts(), hasLength(3));
      expect(server.files.containsKey(referenceOf(photo).file), isTrue);
      expect((await repo.fileQueue()).toSend, 0);
    });

    test('the server out of reach: the files wait, nothing is lost', () async {
      final photo = await photoMade();
      server.offline = true;
      await expectLater(sync(), throwsA(anything));
      server.offline = false;
      clock.advance(const Duration(minutes: 1));
      await sync();
      expect(server.files.containsKey(referenceOf(photo).file), isTrue);
    });
  });

  test('the waits of a file grow, six hours at most', () {
    expect(
      [for (var n = 0; n <= 4; n++) fileRetryDelay(n).inSeconds],
      [0, 30, 60, 120, 240],
    );
    expect(fileRetryDelay(40), const Duration(hours: 6));
  });

  test('alone, nothing is sent and no file is looked at', () async {
    clock = FixedClock(testNow);
    repo = await openRepository(clock: clock);
    addTearDown(repo.db.close);
    home = await repo.createHome(name: 'House');
    room = await repo.createRoom(home, name: 'Kitchen');
    server = FilesServer(home);
    store = MemoryStore();
    state = stateOf();
    addTearDown(state.dispose);
    await state.refresh();
    await photoMade();
    expect(await state.syncWithServer(), isNull);
    expect(server.log, isEmpty);
    expect((await repo.fileQueue()).toSend, 0);
  });

  group('the transport, against the answers of the file routes', () {
    late _Answering http;
    late ServerTransport transport;
    final bytes = Uint8List.fromList([1, 2, 3, 4]);

    setUp(() async {
      http = _Answering();
      final store = MemoryStore();
      await ServerCredential(
        access: 'hca_one',
        refresh: 'hcr_one',
        token: address.resolve('/o/token/'),
        revoke: address.resolve('/o/revoke_token/'),
      ).write(store);
      transport = ServerTransport(
        address: address,
        http: http,
        store: store,
        state: _NoState(),
        device: 'AAECAwQFBgcICQoLDA0ODw',
        schemaVersion: 8,
      );
    });

    test(
      'an upload: the bytes as an octet-stream, the digest in HC-Sha256',
      () async {
        http.status = 201;
        await transport.putFile(
          uuid,
          uuid,
          bytes,
          sha256: sha256Hex(bytes),
          type: 'image/jpeg',
        );
        final request = http.requests.single;
        expect(request.method, 'PUT');
        expect(request.url.path, '/api/v1/sync/homes/$uuid/files/$uuid');
        expect(request.headers['content-type'], 'application/octet-stream');
        expect(request.headers['hc-sha256'], sha256Hex(bytes));
        expect(request.headers['authorization'], 'Bearer hca_one');
        expect(request.body, bytes);
      },
    );

    test('the same bytes again (200) are taken', () async {
      http.status = 200;
      await transport.putFile(uuid, uuid, bytes, sha256: 'x', type: 't');
    });

    test('what the server refuses for good says its code; busy and absent '
        'are told apart', () async {
      for (final (status, code) in [
        (400, 'malformed'),
        (403, 'forbidden'),
        (409, 'file_conflict'),
        (413, 'too_large'),
        (413, 'quota_exceeded'),
        (415, 'unsupported_type'),
      ]) {
        http
          ..status = status
          ..code = code;
        await expectLater(
          transport.putFile(uuid, uuid, bytes, sha256: 'x', type: 't'),
          throwsA(isA<FileRefused>().having((e) => e.code, 'code', code)),
          reason: '$status $code',
        );
      }
      http.status = 404;
      await expectLater(
        transport.putFile(uuid, uuid, bytes, sha256: 'x', type: 't'),
        throwsA(isA<FileNotFound>()),
      );
      for (final status in [408, 429, 500, 503]) {
        http.status = status;
        await expectLater(
          transport.putFile(uuid, uuid, bytes, sha256: 'x', type: 't'),
          throwsA(isA<ServerBusy>()),
        );
      }
    });

    test('a download: the file, or not found', () async {
      http
        ..status = 200
        ..answer = bytes;
      expect(await transport.getFile(uuid, uuid), bytes);
      expect(http.requests.single.method, 'GET');
      http.status = 404;
      await expectLater(
        transport.getFile(uuid, uuid),
        throwsA(isA<FileNotFound>()),
      );
    });

    test('a server has no route to delete a file: nothing is sent', () async {
      await transport.deleteFile(uuid, uuid);
      expect(http.requests, isEmpty);
    });

    test('the reference of a photo is an object on the wire, a text on the '
        'phone; the columns the server reads in it are not sent', () {
      final reference = FileReference(
        file: uuid,
        sha256: 'a' * 64,
        size: 3,
        type: 'image/jpeg',
      ).encode();
      final photo = ServerTransport.wire({
        Op.type: 'rooms.photo',
        Op.home: uuid,
        Op.id: uuid,
        Op.kind: Op.put,
        Op.clock: '0193a1b2c3d40001',
        Op.fields: {'image': reference, 'category': 'general'},
      }).single;
      expect((photo[Op.fields]! as Map)['image'], isA<Map<String, Object?>>());
      final file = ServerTransport.wire({
        Op.type: 'projects.projectfile',
        Op.home: uuid,
        Op.id: uuid,
        Op.kind: Op.put,
        Op.clock: '0193a1b2c3d40001',
        Op.fields: {
          'file': reference,
          'name': 'plan.pdf',
          'content_type': 'application/pdf',
          'size_bytes': 3,
        },
      }).single;
      expect((file[Op.fields]! as Map).keys.toSet(), {'file', 'name'});
    });
  });

  test(
    'the digest of a large file is the same, computed in an isolate',
    () async {
      final big = Uint8List.fromList(List.generate(300 * 1024, (i) => i % 251));
      expect(await sha256HexOffMain(big), sha256Hex(big));
      expect(await sha256HexOffMain(Uint8List(3)), sha256Hex(Uint8List(3)));
    },
  );

  group('the file reference', () {
    test('is read from a server, a first build or nothing', () {
      expect(FileReference.parse(null, rowId: uuid), isNull);
      expect(FileReference.parse('not json', rowId: uuid), isNull);
      final web = FileReference.parse(
        jsonEncode({'file': uuid, 'size': 5, 'type': 'image/png'}),
        rowId: 'other',
      )!;
      expect(web.file, uuid);
      expect(web.sha256, isNull);
      final first = FileReference.parse(
        jsonEncode({'id': 'x', 'size': 5, 'content_type': 'application/pdf'}),
        rowId: uuid,
      )!;
      expect(first.file, FileReference.legacyFile(uuid));
      expect(first.type, 'application/pdf');
      expect(
        FileReference.isLegacy(jsonEncode({'size': 1, 'type': 't'})),
        isTrue,
      );
      expect(
        FileReference.isLegacy(jsonEncode({'file': uuid, 'size': 1})),
        isFalse,
      );
    });
  });
}

late MemoryStore store;

/// One request the transport sent.
class _Request {
  _Request(this.method, this.url, this.headers, this.body);

  final String method;
  final Uri url;
  final Map<String, String> headers;
  final Uint8List? body;
}

/// A server that answers every request with [status] (and [code]).
class _Answering implements ServerHttp {
  int status = 200;
  String? code;
  Uint8List answer = Uint8List(0);
  final requests = <_Request>[];

  @override
  Future<ServerReply> send(
    String method,
    Uri url, {
    Map<String, String> headers = const {},
    Uint8List? body,
  }) async {
    requests.add(_Request(method, url, headers, body));
    return ServerReply(
      status,
      status == 200 && method == 'GET'
          ? answer
          : Uint8List.fromList(
              utf8.encode(jsonEncode({'detail': 'x', 'code': ?code})),
            ),
    );
  }
}

class _NoState implements ServerStateStore {
  String? _text;

  @override
  Future<String?> readServerState() async => _text;

  @override
  Future<void> writeServerState(String? state) async => _text = state;
}
