// SPDX-License-Identifier: AGPL-3.0-only

import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:housecairn_mobile/core/hlc.dart';
import 'package:housecairn_mobile/sync/server_address.dart';
import 'package:housecairn_mobile/sync/server_http.dart';

/// A Housecairn server of one home with the sync API of web ADR 0077 and its
/// file routes, as far as the phone can tell (docs/api/sync.md of the web,
/// "Files"): the feed of changes, the snapshot, a push that refuses a photo
/// whose reference has no `file` and no `sha256`, or a `sha256` that is not
/// the digest of the file it holds under that `file` (`400` `malformed`), and
/// `PUT` and `GET` of `/files/{id}` with the answers of the web (`201`, `200`,
/// `400`, `404`, `409`, `413`, `415`). What it gets and sends is written down.
class FilesServer implements ServerHttp {
  FilesServer(this.home);

  final String home;
  late ServerAddress address;
  static const device = 'q2Xh0dVt3kWmYc1bS8fP9A';

  /// The device id of the phone that pushes, as the server writes it in the
  /// feed.
  String phoneDevice = 'AAECAwQFBgcICQoLDA0ODw';

  /// The bytes the server holds, by file id, and the digest the phone sent.
  final files = <String, Uint8List>{};
  final digests = <String, String>{};

  /// The rows, by type and id: `{'t', 'id', 'f': {field: [value, hlc, d]}}`.
  final rows = <(String, String), Map<String, Object?>>{};

  /// The feed: `{'pos', 'device', 'op'}`.
  final changes = <Map<String, Object?>>[];

  /// Every request, in order: `PUT file`, `GET file`, `push`, `changes`.
  final log = <String>[];

  /// The operations pushed, in order.
  final pushed = <Map<String, Object?>>[];

  bool offline = false;

  /// The largest file the server takes (`file_max_bytes` of `info`).
  int fileMaxBytes = 20 * 1024 * 1024;

  /// When set, every upload answers this status and code.
  (int, String)? refuseUploads;

  /// Files the server answers `404` to, by id (even when it holds them).
  final missing = <String>{};

  /// Uploads cut: the request is sent and the connection drops before the
  /// answer, as a phone that goes out of a tunnel.
  bool cutUploads = false;

  /// The server's clock, in UTC milliseconds.
  int Function() nowMs = () => DateTime.now().millisecondsSinceEpoch;

  int _counter = 0;
  int get head => changes.length;

  String _hlc() => Hlc.format((nowMs() << 16) | (_counter++ & 0xffff));

  ServerReply _json(int status, Object body) =>
      ServerReply(status, utf8.encode(jsonEncode(body)));

  /// A photo made on the web: the row names its file by its own id and has
  /// no `sha256` (docs/api/sync.md, "Files").
  void addWebPhoto(String id, Uint8List bytes, {String? roomId}) {
    files[id] = bytes;
    _put('rooms.photo', id, {
      'room_id': roomId,
      'item_id': null,
      'category': 'general',
      'caption': 'From the web',
      'image': {
        'file': id,
        'size': bytes.length,
        'type': 'image/jpeg',
        'width': 64,
        'height': 32,
      },
    });
  }

  /// A row made on the web that holds a file (lot 4d): an attachment of a
  /// task, the photo of a report, the label of an article. The reference is
  /// named by the id of the row and has no `sha256`; the label of an article
  /// has no size either (web `sync/reading.py`, `file_reference`).
  void addWebFileRow(
    String type,
    String id,
    Uint8List bytes,
    Map<String, Object?> fields, {
    String contentType = 'image/jpeg',
  }) {
    files[id] = bytes;
    final field = fileFieldOf(type)!;
    _put(type, id, {
      ...fields,
      field: {
        'file': id,
        'size': type == 'stock.article' ? null : bytes.length,
        'type': contentType,
        'width': null,
        'height': null,
      },
    });
  }

  /// The field of the file reference of [type], as the web reads it.
  static String? fileFieldOf(Object? type) => switch (type) {
    'rooms.photo' => 'image',
    'projects.projectfile' || 'tasks.attachment' => 'file',
    'reports.report' => 'photo',
    'stock.article' => 'label',
    _ => null,
  };

  /// Fields of the task [id] written on the web.
  void writeWebTask(String id, Map<String, Object?> fields) =>
      _put('tasks.task', id, fields);

  /// The row deleted on the web.
  void deleteOnWeb(String type, String id) {
    final clock = _hlc();
    final row = rows[(type, id)]!;
    (row['f']! as Map)['deleted_at'] = [clock, clock, device];
    changes.add({
      'pos': changes.length + 1,
      'device': device,
      'op': {'t': type, 'h': home, 'id': id, 'k': 'delete', 'c': clock},
    });
  }

  void _put(String type, String id, Map<String, Object?> fields) {
    final clock = _hlc();
    final row = rows.putIfAbsent((
      type,
      id,
    ), () => {'t': type, 'h': home, 'id': id, 'f': <String, Object?>{}});
    for (final MapEntry(:key, :value) in fields.entries) {
      (row['f']! as Map)[key] = [value, clock, device];
    }
    changes.add({
      'pos': changes.length + 1,
      'device': device,
      'op': {
        't': type,
        'h': home,
        'id': id,
        'k': 'put',
        'c': clock,
        'f': fields,
      },
    });
  }

  static String _digest(Uint8List bytes) => sha256.convert(bytes).toString();

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
    expect(address.owns(url), isTrue, reason: '$url');
    final path = url.path;
    if (path == '/o/token/') {
      return _json(200, {'access_token': 'hca_one', 'refresh_token': 'hcr_x'});
    }
    if (path == '/api/v1/sync/info') {
      return _json(200, {
        'sync': [1],
        'server': '0.5.0',
        'limits': {
          'file_max_bytes': fileMaxBytes,
          'pushes_per_minute': 60,
          'reads_per_minute': 600,
        },
      });
    }
    if (path == '/api/v1/sync/homes/') {
      return _json(200, {
        'homes': [
          {'id': home, 'name': 'House', 'role': 'owner', 'members': <Object>[]},
        ],
        'gone': <Object>[],
      });
    }
    if (path.endsWith('/snapshot')) {
      final lines = [
        for (final row in rows.values) row,
        {'covers': head},
      ];
      return ServerReply(
        200,
        utf8.encode(lines.map((l) => '${jsonEncode(l)}\n').join()),
      );
    }
    if (path.endsWith('/changes')) {
      final after = int.parse(url.queryParameters['after']!);
      if (url.queryParameters['limit'] != '1') log.add('changes');
      return _json(200, {
        'changes': [
          for (final c in changes)
            if ((c['pos']! as int) > after) c,
        ],
        'head': head,
        'more': false,
      });
    }
    if (path.endsWith('/push')) return _push(body!);
    final file = RegExp(r'/files/([0-9a-f-]{36})$').firstMatch(path);
    if (file != null) {
      final id = file.group(1)!;
      return method == 'PUT'
          ? _upload(id, headers, body!)
          : _download(id, headers);
    }
    return _json(404, {});
  }

  ServerReply _upload(String id, Map<String, String> headers, Uint8List body) {
    log.add('PUT $id');
    if (cutUploads) {
      throw const ServerHttpException(ServerHttpFailure.unreachable);
    }
    if (refuseUploads case (final status, final code)?) {
      return _json(status, {'detail': code, 'code': code});
    }
    final declared = headers['hc-sha256'];
    if (declared == null || !RegExp(r'^[0-9a-f]{64}$').hasMatch(declared)) {
      return _json(400, {'detail': 'HC-Sha256 missing', 'code': 'malformed'});
    }
    if (body.isEmpty || _digest(body) != declared) {
      return _json(400, {'detail': 'Not the digest', 'code': 'malformed'});
    }
    if (body.length > fileMaxBytes) {
      return _json(413, {'detail': 'Too large', 'code': 'too_large'});
    }
    if (files.containsKey(id) && digests[id] != declared) {
      return _json(409, {'detail': 'Taken', 'code': 'file_conflict'});
    }
    final created = !files.containsKey(id);
    files[id] = body;
    digests[id] = declared;
    return _json(created ? 201 : 200, {'file': id, 'sha256': declared});
  }

  ServerReply _download(String id, Map<String, String> headers) {
    log.add('GET $id');
    final bytes = files[id];
    if (bytes == null || missing.contains(id)) return _json(404, {});
    return ServerReply(
      200,
      bytes,
      headers: const {'content-type': 'image/jpeg'},
    );
  }

  ServerReply _push(Uint8List body) {
    log.add('push');
    final ops = ((jsonDecode(utf8.decode(body)) as Map)['ops'] as List)
        .cast<Map<String, dynamic>>();
    for (final (index, op) in ops.indexed) {
      final field = fileFieldOf(op['t']);
      final fields = op['f'] as Map?;
      if (field == null ||
          fields == null ||
          !fields.containsKey(field) ||
          fields[field] == null) {
        continue;
      }
      final ref = fields[field];
      final ok =
          ref is Map &&
          ref['file'] is String &&
          RegExp(r'^[0-9a-f]{64}$').hasMatch('${ref['sha256']}') &&
          (!digests.containsKey(ref['file']) ||
              digests[ref['file']] == ref['sha256']);
      if (!ok) {
        return _json(400, {
          'detail': 'A file is a reference: file, sha256, size and type.',
          'code': 'malformed',
          'index': index,
        });
      }
    }
    final results = <Map<String, Object?>>[];
    for (final (index, op) in ops.indexed) {
      pushed.add(op);
      final key = (op['t'] as String, op['id'] as String);
      if (op['k'] == 'delete') {
        if (rows.containsKey(key)) {
          final clock = _hlc();
          (rows[key]!['f']! as Map)['deleted_at'] = [clock, clock, device];
        }
        changes.add({
          'pos': changes.length + 1,
          'device': phoneDevice,
          'op': op,
        });
      } else {
        final row = rows.putIfAbsent(
          key,
          () => {
            't': key.$1,
            'h': home,
            'id': key.$2,
            'f': <String, Object?>{},
          },
        );
        for (final MapEntry(:key, :value)
            in ((op['f'] as Map?) ?? const {}).entries) {
          (row['f']! as Map)[key] = [value, op['c'], phoneDevice];
        }
        changes.add({
          'pos': changes.length + 1,
          'device': phoneDevice,
          'op': op,
        });
      }
      results.add({'i': index, 'status': 'applied'});
    }
    return _json(200, {'head': head, 'results': results});
  }
}
