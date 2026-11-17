// SPDX-License-Identifier: AGPL-3.0-only

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:housecairn_mobile/core/clock.dart';
import 'package:housecairn_mobile/data/database.dart'
    show ArticleRow, ReportRow, TaskAttachmentRow, uuidBytes;
import 'package:housecairn_mobile/data/repository.dart';
import 'package:housecairn_mobile/domain/file_reference.dart';
import 'package:housecairn_mobile/domain/photos.dart';
import 'package:housecairn_mobile/domain/templates.dart';
import 'package:housecairn_mobile/sync/files.dart';
import 'package:housecairn_mobile/sync/mode.dart';
import 'package:housecairn_mobile/sync/operation.dart';
import 'package:housecairn_mobile/sync/server_address.dart';
import 'package:housecairn_mobile/sync/server_sign_in.dart';
import 'package:housecairn_mobile/sync/server_transport.dart';
import 'package:housecairn_mobile/ui/state.dart';

import 'support/fakes.dart';
import 'support/files_server.dart';
import 'support/fixture.dart';
import 'support/server_fake.dart' show MemoryStore;

/// The files of lot 4d (docs/adr/0013): the attachments of a task, the
/// photo of a report and the label of a stock article, sent, fetched,
/// deleted, refused and resumed by the engine of lot 4c, against the
/// scripted server of test/support/files_server.dart on the contract of the
/// web (the same routes as `rooms.photo`).
void main() {
  final address = ServerAddress.parse('https://hc.example.com').$1!;
  const web = '7a1d9e2a-7b4f-4c8d-9e1a-2b3c4d5e6f71';

  late FixedClock clock;
  late Repository repo;
  late FilesServer server;
  late AppState state;
  late MemoryStore store;
  late String home;
  late String task;

  Future<void> sync() async => state.syncWithServer(throwing: true);

  Future<void> startPhone() async {
    clock = FixedClock(testNow);
    repo = await openRepository(clock: clock);
    addTearDown(repo.db.close);
    home = await repo.createHome(name: 'House');
    task = await repo.createTask(home, const TaskInput(title: 'Boiler'));
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
    state = AppState(
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
    addTearDown(state.dispose);
    await state.refresh();
    await sync();
  }

  Uint8List jpeg([int width = 64]) =>
      processPhoto(jpegWithGps(width: width, orientation: 1)).image;
  final pdf = Uint8List.fromList('%PDF-1.4 invoice'.codeUnits);

  List<String> puts() => server.log.where((l) => l.startsWith('PUT ')).toList();
  List<String> gets() => server.log.where((l) => l.startsWith('GET ')).toList();

  FileReference referenceOf(String? text, String id) =>
      FileReference.parse(text, rowId: id)!;

  Future<TaskAttachmentRow> attachmentMade({bool photo = false}) async {
    final id = await repo.addAttachment(
      task,
      name: photo ? 'boiler.jpg' : 'invoice.pdf',
      bytes: photo ? jpegWithGps(orientation: 1) : pdf,
      contentType: photo ? 'image/jpeg' : 'application/pdf',
    );
    return (await repo.attachment(id))!;
  }

  Future<ReportRow> reportMade() async {
    final id = await repo.createReport(
      home,
      title: 'Leak under the sink',
      photo: processPhoto(jpegWithGps(orientation: 1)),
    );
    return (await repo.report(id))!;
  }

  /// A label the phone holds under a reference with its digest (the app
  /// makes no label itself: it is the case of a label this phone fetched and
  /// whose list of files was forgotten, or of a later build that makes one).
  Future<ArticleRow> labelHeld() async {
    final id = await repo.addArticle(home, const ArticleInput(name: 'Filter'));
    final bytes = jpeg();
    final file = repo.fileOfRow('articles', home, id)
      ..parent.createSync(recursive: true)
      ..writeAsBytesSync(bytes);
    expect(file.existsSync(), isTrue);
    await repo.db.customStatement(
      'UPDATE articles SET label = ? WHERE id = ?',
      [FileReference.fresh(bytes, type: 'image/jpeg').encode(), uuidBytes(id)],
    );
    return (await repo.article(id))!;
  }

  group('an attachment of a task', () {
    setUp(startPhone);

    test('made on the phone, a PDF: its file goes before its row, with its '
        'digest; the columns the server reads in the reference are not '
        'sent', () async {
      final a = await attachmentMade();
      final reference = referenceOf(a.file, a.id);
      expect(reference.type, 'application/pdf');
      expect(repo.attachmentFile(a).readAsBytesSync(), pdf);

      await sync();

      expect(server.files[reference.file], pdf);
      final upload = server.log.indexOf('PUT ${reference.file}');
      expect(upload, lessThan(server.log.lastIndexOf('push')));
      final op = server.pushed.firstWhere(
        (o) => o['t'] == 'tasks.attachment' && o['id'] == a.id,
      );
      final fields = op['f'] as Map;
      expect((fields['file'] as Map)['sha256'], sha256Hex(pdf));
      expect(fields['task_id'], task);
      expect(fields['name'], 'invoice.pdf');
      expect(fields.containsKey('content_type'), isFalse);
      expect(fields.containsKey('size_bytes'), isFalse);
      expect((await repo.fileQueue()).toSend, 0);
    });

    test('a photo is re-encoded, stored and sent as a JPEG', () async {
      final a = await attachmentMade(photo: true);
      expect(a.isImage, isTrue);
      await sync();
      final reference = referenceOf(a.file, a.id);
      expect(reference.type, 'image/jpeg');
      expect(
        server.files[reference.file],
        repo.attachmentFile(a).readAsBytesSync(),
      );
    });

    test('made on the web: the row comes, then its file, fetched once and '
        'never sent back', () async {
      server.addWebFileRow('tasks.attachment', web, pdf, {
        'task_id': task,
        'occurrence_id': null,
        'name': 'manual.pdf',
        'is_image': false,
      }, contentType: 'application/pdf');

      await sync();

      final a = (await repo.attachment(web))!;
      expect(a.name, 'manual.pdf');
      expect(repo.attachmentIsImage(a), isFalse);
      expect(repo.attachmentFile(a).readAsBytesSync(), pdf);
      expect((await repo.attachmentsOf(task)).map((r) => r.id), [web]);
      await sync();
      expect(gets(), ['GET $web']);
      expect(puts(), isEmpty);
    });

    test('deleted on the phone: a delete goes, the file stays 30 days, then '
        'is swept', () async {
      final a = await attachmentMade();
      await sync();
      await repo.deleteAttachment(a.id);
      await sync();
      expect(server.pushed.lastWhere((o) => o['id'] == a.id)['k'], Op.delete);
      expect(repo.attachmentFile(a).existsSync(), isTrue);
      clock.advance(const Duration(days: 31));
      await sync();
      expect(repo.attachmentFile(a).existsSync(), isFalse);
    });

    test('deleted with its task', () async {
      final a = await attachmentMade();
      await repo.deleteTask(task);
      expect(await repo.attachment(a.id), isNull);
      await sync();
      expect(server.pushed.lastWhere((o) => o['id'] == a.id)['k'], Op.delete);
    });

    test('refused for its digest (400): told, never in a loop, sent again '
        'by hand', () async {
      server.refuseUploads = (400, 'malformed');
      final a = await attachmentMade();
      await sync();
      await sync();
      expect(puts(), hasLength(1));
      expect((await repo.fileQueue()).codes, {'malformed'});
      expect((await repo.fileProblems())[a.id], 'malformed');
      server.refuseUploads = null;
      await state.retryFiles();
      expect(server.files.containsKey(referenceOf(a.file, a.id).file), isTrue);
      expect((await repo.fileQueue()).toSend, 0);
    });

    test('a cut: it waits, then goes', () async {
      server.cutUploads = true;
      final a = await attachmentMade();
      await sync();
      expect((await repo.fileQueue()).waiting, 1);
      server.cutUploads = false;
      clock.advance(const Duration(seconds: 31));
      await sync();
      expect(server.files.containsKey(referenceOf(a.file, a.id).file), isTrue);
    });

    test('at most 30 on a task, a photo or a PDF only', () async {
      for (var i = 0; i < maxAttachmentsPerTask; i++) {
        await repo.addAttachment(
          task,
          name: '$i.pdf',
          bytes: pdf,
          contentType: 'application/pdf',
        );
      }
      await expectLater(
        repo.addAttachment(
          task,
          name: 'more.pdf',
          bytes: pdf,
          contentType: 'application/pdf',
        ),
        throwsA(
          isA<Refused>().having(
            (r) => r.reason,
            'reason',
            Refusal.tooManyAttachments,
          ),
        ),
      );
      final other = await repo.createTask(home, const TaskInput(title: 'Roof'));
      await expectLater(
        repo.addAttachment(
          other,
          name: 'a.txt',
          bytes: pdf,
          contentType: 'text/plain',
        ),
        throwsA(
          isA<Refused>().having(
            (r) => r.reason,
            'reason',
            Refusal.fileTypeRefused,
          ),
        ),
      );
    });
  });

  group('the photo of a report', () {
    setUp(startPhone);

    test('taken on the phone: goes to the server with its id and digest, '
        'before the report', () async {
      final r = await reportMade();
      final reference = referenceOf(r.photo, r.id);
      expect(reference.file, isNot(r.id));
      final bytes = repo.reportPhoto(r).readAsBytesSync();
      expect(reference.sha256, sha256Hex(bytes));

      await sync();

      expect(server.files[reference.file], bytes);
      expect(
        server.log.indexOf('PUT ${reference.file}'),
        lessThan(server.log.lastIndexOf('push')),
      );
      final op = server.pushed.firstWhere(
        (o) => o['t'] == 'reports.report' && o['id'] == r.id,
      );
      expect(((op['f'] as Map)['photo'] as Map)['sha256'], reference.sha256);
    });

    test('of the first builds, without id nor digest: completed, then '
        'sent', () async {
      final r = await reportMade();
      await repo.db.customStatement(
        'UPDATE reports SET photo = ? WHERE id = ?',
        ['{"size":3,"type":"image/jpeg"}', uuidBytes(r.id)],
      );
      await sync();
      final fileId = FileReference.legacyFile(r.id);
      expect(server.files[fileId], repo.reportPhoto(r).readAsBytesSync());
    });

    test('made on the web: fetched as the photo of the report', () async {
      final bytes = jpeg(48);
      server.addWebFileRow('reports.report', web, bytes, {
        'title': 'Crack in the wall',
        'status': 'open',
      });
      await sync();
      final r = (await repo.report(web))!;
      expect(referenceOf(r.photo, r.id).file, web);
      expect(repo.reportPhoto(r).readAsBytesSync(), bytes);
      expect(puts(), isEmpty);
    });

    test('deleted on the web: the file goes after 30 days', () async {
      server.addWebFileRow('reports.report', web, jpeg(), {
        'title': 'Crack in the wall',
        'status': 'open',
      });
      await sync();
      final r = (await repo.report(web))!;
      server.deleteOnWeb('reports.report', web);
      await sync();
      expect(repo.reportPhoto(r).existsSync(), isTrue);
      clock.advance(const Duration(days: 31));
      await sync();
      expect(repo.reportPhoto(r).existsSync(), isFalse);
    });

    test('refused for its digest (400): told and not tried again by '
        'itself', () async {
      server.refuseUploads = (400, 'malformed');
      final r = await reportMade();
      await sync();
      await sync();
      expect(puts(), hasLength(1));
      expect((await repo.fileProblems())[r.id], 'malformed');
    });

    test('not yet on the server: it waits, then comes', () async {
      server.addWebFileRow('reports.report', web, jpeg(), {
        'title': 'Crack in the wall',
        'status': 'open',
      });
      server.missing.add(web);
      await sync();
      final r = (await repo.report(web))!;
      expect(repo.reportPhoto(r).existsSync(), isFalse);
      expect((await repo.fileQueue()).fetching, 1);
      server.missing.clear();
      clock.advance(const Duration(seconds: 31));
      await sync();
      expect(repo.reportPhoto(r).existsSync(), isTrue);
    });
  });

  group('the label of a stock article', () {
    setUp(startPhone);

    test('made on the web, with no size in its reference: fetched', () async {
      final bytes = jpeg(48);
      server.addWebFileRow('stock.article', web, bytes, {'name': 'Filter'});
      await sync();
      final a = (await repo.article(web))!;
      expect(referenceOf(a.label, a.id).file, web);
      expect(repo.fileOfRow('articles', home, web).readAsBytesSync(), bytes);
      await sync();
      expect(gets(), ['GET $web']);
      expect(puts(), isEmpty);
    });

    test('held by the phone under its digest and not on the server: '
        'sent', () async {
      final a = await labelHeld();
      await sync();
      final reference = referenceOf(a.label, a.id);
      expect(
        server.files[reference.file],
        repo.fileOfRow('articles', home, a.id).readAsBytesSync(),
      );
    });

    test('deleted with its article: the file goes after 30 days', () async {
      server.addWebFileRow('stock.article', web, jpeg(), {'name': 'Filter'});
      await sync();
      final file = repo.fileOfRow('articles', home, web);
      expect(file.existsSync(), isTrue);
      await repo.deleteArticle(web);
      await sync();
      expect(file.existsSync(), isTrue);
      clock.advance(const Duration(days: 31));
      await sync();
      expect(file.existsSync(), isFalse);
    });

    test('refused for its digest (400): told', () async {
      server.refuseUploads = (400, 'malformed');
      final a = await labelHeld();
      await sync();
      await sync();
      expect(puts(), hasLength(1));
      expect((await repo.fileProblems())[a.id], 'malformed');
    });

    test('a cut: it waits, then goes', () async {
      server.cutUploads = true;
      final a = await labelHeld();
      await sync();
      expect((await repo.fileQueue()).waiting, 1);
      server.cutUploads = false;
      clock.advance(const Duration(seconds: 31));
      await sync();
      expect(server.files.containsKey(referenceOf(a.label, a.id).file), isTrue);
    });
  });

  group('Settings', () {
    setUp(startPhone);

    test('count the three kinds of files, and Send now sends them', () async {
      server.cutUploads = true;
      await attachmentMade();
      await reportMade();
      await labelHeld();
      expect((await repo.fileQueue()).waiting, 3);
      server.cutUploads = false;
      await state.retryFiles();
      expect((await repo.fileQueue()).toSend, 0);
      expect(puts().toSet(), hasLength(3));
    });
  });

  group('erasing a home', () {
    setUp(startPhone);

    test('takes the files of its attachments, report photos and labels with '
        'it', () async {
      final a = await attachmentMade();
      final r = await reportMade();
      final l = await labelHeld();
      final files = [
        repo.attachmentFile(a),
        repo.reportPhoto(r),
        repo.fileOfRow('articles', home, l.id),
      ];
      expect(files.every((f) => f.existsSync()), isTrue);
      await repo.purgeHome(home);
      expect(files.any((f) => f.existsSync()), isFalse);
      expect(await repo.attachment(a.id), isNull);
    });
  });

  test('the wire: the photo of a report and the label of an article are '
      'objects, the attachment drops what the server reads in its '
      'reference', () {
    final reference = FileReference(
      file: web,
      sha256: 'a' * 64,
      size: 3,
      type: 'image/jpeg',
    ).encode();
    for (final (type, field) in [
      ('reports.report', 'photo'),
      ('stock.article', 'label'),
      ('tasks.attachment', 'file'),
    ]) {
      final op = ServerTransport.wire({
        Op.type: type,
        Op.home: web,
        Op.id: web,
        Op.kind: Op.put,
        Op.clock: '0193a1b2c3d40001',
        Op.fields: {field: reference, 'content_type': 'x', 'size_bytes': 3},
      }).single;
      final fields = op[Op.fields]! as Map;
      expect(fields[field], isA<Map<String, Object?>>(), reason: type);
      if (type == 'tasks.attachment') {
        expect(fields.keys, [field]);
      }
    }
  });
}
