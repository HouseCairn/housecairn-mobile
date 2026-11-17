// SPDX-License-Identifier: AGPL-3.0-only

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:drift/drift.dart' show Variable;
import 'package:flutter_test/flutter_test.dart';
import 'package:housecairn_mobile/core/clock.dart';
import 'package:housecairn_mobile/data/database.dart' show uuidBytes;
import 'package:housecairn_mobile/data/repository.dart';
import 'package:housecairn_mobile/domain/file_reference.dart';
import 'package:housecairn_mobile/domain/photos.dart';
import 'package:housecairn_mobile/sync/files.dart';
import 'package:housecairn_mobile/domain/templates.dart';
import 'package:housecairn_mobile/sync/mode.dart';
import 'package:housecairn_mobile/sync/server_address.dart';
import 'package:housecairn_mobile/sync/server_sign_in.dart';
import 'package:housecairn_mobile/ui/state.dart';

import 'support/fakes.dart';
import 'support/files_server.dart';
import 'support/fixture.dart';
import 'support/server_fake.dart' show MemoryStore;

/// The file references an earlier build kept in `extra` (docs/adr/0013,
/// "References received by an earlier build"): before the files, a reference
/// came from the server as an object, a text column could not hold it and it
/// was kept as an unknown field, the column staying empty. The phone is put
/// in that state (column empty, reference in `extra`, cursor at the end of
/// the feed) and synced by the current build against the scripted server.
void main() {
  final address = ServerAddress.parse('https://hc.example.com').$1!;
  const web = '7a1d9e2a-7b4f-4c8d-9e1a-2b3c4d5e6f71';
  const other = '8b2e0f3b-8c50-4d9e-8f2b-3c4d5e6f7a82';

  late FixedClock clock;
  late Repository repo;
  late FilesServer server;
  late AppState state;
  late String home;
  late String room;
  late String task;

  Future<void> sync() async => state.syncWithServer(throwing: true);

  Future<void> startPhone() async {
    clock = FixedClock(testNow);
    repo = await openRepository(clock: clock);
    addTearDown(repo.db.close);
    home = await repo.createHome(name: 'House');
    room = await repo.createRoom(home, name: 'Kitchen');
    task = await repo.createTask(home, const TaskInput(title: 'Boiler'));
    server = FilesServer(home)
      ..phoneDevice = repo.deviceB64
      ..nowMs = () => clock.now().millisecondsSinceEpoch;
    final store = MemoryStore();
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

  List<String> gets() => server.log.where((l) => l.startsWith('GET ')).toList();

  Future<String?> columnOf(String table, String column, String id) async {
    final row = await repo.db
        .customSelect(
          'SELECT $column AS v FROM $table WHERE id = ?',
          variables: [Variable<Uint8List>(uuidBytes(id))],
        )
        .getSingle();
    return row.data['v'] as String?;
  }

  /// The row [id] of [table] as an earlier build left it: the reference the
  /// server sent as an object is in `extra`, the column is empty, the file
  /// is not on the phone and no entry of the list of files exists.
  Future<void> earlierBuild(
    String entity,
    String table,
    String column,
    String id,
  ) async {
    final text = (await columnOf(table, column, id))!;
    await repo.db.customStatement(
      'UPDATE $table SET $column = NULL WHERE id = ?',
      [uuidBytes(id)],
    );
    final extra = (await repo.extraFields(entity, id))
      ..addAll({column: jsonDecode(text)});
    await repo.db.customStatement(
      'INSERT OR REPLACE INTO extra (entity, row_id, home_id, json) '
      'VALUES (?, ?, ?, ?)',
      [entity, uuidBytes(id), uuidBytes(home), jsonEncode(extra)],
    );
    await repo.db.customStatement('DELETE FROM file_sync');
    final directory = repo.homeDirectory(home);
    if (directory.existsSync()) directory.deleteSync(recursive: true);
    expect(await columnOf(table, column, id), isNull);
  }

  group('a reference an earlier build kept in extra', () {
    setUp(startPhone);

    test('a photo: the next sync gives it to its column, fetches its file '
        'and shows it', () async {
      final bytes = jpeg(48);
      server.addWebPhoto(web, bytes, roomId: room);
      await sync();
      await earlierBuild('rooms.photo', 'photos', 'image', web);
      server.log.clear();

      await sync();

      final photo = (await repo.photo(web))!;
      expect(FileReference.parse(photo.image, rowId: web)!.file, web);
      expect(gets(), ['GET $web']);
      expect(repo.photoFile(photo).readAsBytesSync(), bytes);
      expect(repo.thumbnailFile(photo).existsSync(), isTrue);
      expect(await repo.extraFields('rooms.photo', web), isEmpty);
      expect((await repo.fileQueue()).fetching, 0);
    });

    test('the photo is counted at once, before any fetch', () async {
      server.addWebPhoto(web, jpeg(), roomId: room);
      server.missing.add(web);
      await sync();
      await earlierBuild('rooms.photo', 'photos', 'image', web);

      expect((await repo.fileQueue()).fetching, 1);
    });

    test('the four other holders as well: a project file, an attachment, '
        'the photo of a report and a label', () async {
      final project = await repo.createProject(
        home,
        const ProjectInput(title: 'Kitchen'),
      );
      await sync();
      final bytes = jpeg();
      server.addWebFileRow('projects.projectfile', web, bytes, {
        'project_id': project,
        'name': 'plan.jpg',
        'is_image': true,
      });
      server.addWebFileRow('tasks.attachment', other, bytes, {
        'task_id': task,
        'occurrence_id': null,
        'name': 'boiler.jpg',
        'is_image': true,
      });
      const report = '9c3f1a4c-9d61-4eaf-9a3c-4d5e6f7a8b93';
      const label = 'ad40b25d-ae72-4fb0-8b4d-5e6f7a8b9ca4';
      server.addWebFileRow('reports.report', report, bytes, {'title': 'Leak'});
      server.addWebFileRow('stock.article', label, bytes, {'name': 'Filter'});
      await sync();
      await earlierBuild('projects.projectfile', 'project_files', 'file', web);
      await earlierBuild('tasks.attachment', 'task_attachments', 'file', other);
      await earlierBuild('reports.report', 'reports', 'photo', report);
      await earlierBuild('stock.article', 'articles', 'label', label);
      server.log.clear();

      await sync();

      expect(
        gets()..sort(),
        ['GET $web', 'GET $other', 'GET $report', 'GET $label']..sort(),
      );
      for (final (table, column, id) in [
        ('project_files', 'file', web),
        ('task_attachments', 'file', other),
        ('reports', 'photo', report),
        ('articles', 'label', label),
      ]) {
        expect(
          FileReference.parse(await columnOf(table, column, id), rowId: id),
          isNotNull,
          reason: table,
        );
        expect(repo.fileOfRow(table, home, id).existsSync(), isTrue);
      }
    });

    test('what the column holds is not overwritten: it was written after '
        '(its clock), whatever the old value in extra', () async {
      server.addWebPhoto(web, jpeg(), roomId: room);
      await sync();
      await earlierBuild('rooms.photo', 'photos', 'image', web);
      final newer = FileReference(
        file: other,
        size: 3,
        type: 'image/jpeg',
        sha256: sha256Hex(Uint8List(3)),
      ).encode();
      await repo.db.customStatement(
        'UPDATE photos SET image = ? WHERE id = ?',
        [newer, uuidBytes(web)],
      );
      server.log.clear();

      await sync();

      expect(await columnOf('photos', 'image', web), newer);
      expect(gets(), isNot(contains('GET $web')));
    });

    test('the other fields kept in extra stay, only the reference leaves '
        'it', () async {
      server.addWebPhoto(web, jpeg(), roomId: room);
      await sync();
      await earlierBuild('rooms.photo', 'photos', 'image', web);
      final extra = await repo.extraFields('rooms.photo', web);
      await repo.db.customStatement(
        'UPDATE extra SET json = ? WHERE row_id = ?',
        [
          jsonEncode({...extra, 'colour': 'teal'}),
          uuidBytes(web),
        ],
      );

      await sync();

      expect(await repo.extraFields('rooms.photo', web), {'colour': 'teal'});
    });

    test('the reference does not go back to the server: giving it to its '
        'column is no local change', () async {
      server.addWebPhoto(web, jpeg(), roomId: room);
      await sync();
      await earlierBuild('rooms.photo', 'photos', 'image', web);
      server.pushed.clear();
      server.log.clear();

      await sync();
      await sync();

      expect(server.pushed.where((o) => o['id'] == web), isEmpty);
      expect(gets(), ['GET $web']);
    });

    test('a pending operation of an earlier build, whose reference has no '
        'file and no digest, still goes complete', () async {
      server.addWebPhoto(web, jpeg(), roomId: room);
      await sync();
      await earlierBuild('rooms.photo', 'photos', 'image', web);
      final made = await repo.createPhotoRow(
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
      File('${repo.homeDirectory(home).path}/$made.jpg')
          .writeAsBytesSync(bytes);

      await sync();

      final op = server.pushed.firstWhere((o) => o['id'] == made);
      final wire = (op['f'] as Map)['image'] as Map;
      expect(wire['file'], FileReference.legacyFile(made));
      expect(wire['sha256'], sha256Hex(bytes));
      expect(server.files[FileReference.legacyFile(made)], bytes);
      expect(gets(), contains('GET $web'));
    });
  });
}
