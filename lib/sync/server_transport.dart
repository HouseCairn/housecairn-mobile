// SPDX-License-Identifier: AGPL-3.0-only

import 'dart:convert';
import 'dart:typed_data';

import '../core/store.dart';
import 'operation.dart';
import 'server_address.dart';
import 'server_http.dart';
import 'server_sign_in.dart';
import 'transport.dart';

/// A member of a home on the server (an account), read only on the phone.
class ServerMember {
  const ServerMember({
    required this.id,
    required this.name,
    required this.role,
  });

  final String id;
  final String name;
  final String role;

  Map<String, Object?> toJson() => {'id': id, 'name': name, 'role': role};

  static ServerMember fromJson(Map<String, Object?> json) => ServerMember(
    id: json['id']! as String,
    name: json['name'] as String? ?? '',
    role: json['role'] as String? ?? '',
  );
}

/// A home of the access, as `GET /api/v1/sync/homes/` gives it.
class ServerHome {
  const ServerHome({
    required this.id,
    required this.name,
    required this.role,
    required this.members,
    this.archivedAt,
  });

  final String id;
  final String name;

  /// The role of the signed-in account in it (`owner`, `member`,
  /// `read_only`).
  final String role;
  final String? archivedAt;
  final List<ServerMember> members;

  bool get readOnly => role == 'read_only';
  bool get owner => role == 'owner';

  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'role': role,
    'archived_at': archivedAt,
    'members': [for (final m in members) m.toJson()],
  };

  static ServerHome fromJson(Map<String, Object?> json) => ServerHome(
    id: json['id']! as String,
    name: json['name'] as String? ?? '',
    role: json['role'] as String? ?? '',
    archivedAt: json['archived_at'] as String?,
    members: [
      for (final m in (json['members'] as List? ?? const []))
        ServerMember.fromJson((m as Map).cast<String, Object?>()),
    ],
  );
}

/// What the transport keeps between two rounds, in `local_settings` (never
/// synced, never exported, no credential in it): the cursor of each home,
/// the number of the next push, a push whose answer never came, and what the
/// last list of homes said.
class ServerSyncState {
  ServerSyncState({
    Map<String, int>? cursors,
    this.nextPush = 1,
    this.unanswered,
    List<ServerHome>? homes,
    Set<String>? gone,
    this.round = 0,
    Map<String, int>? staged,
    this.stagedAt,
  }) : cursors = cursors ?? {},
       homes = homes ?? [],
       gone = gone ?? {},
       staged = staged ?? {};

  /// `pos` of the last change of each home the phone applied.
  final Map<String, int> cursors;

  int nextPush;

  /// A push sent whose answer never came: sent again first, with the same
  /// number and the same bytes, so that the server answers it once.
  ({String home, int number, String body})? unanswered;

  final List<ServerHome> homes;
  final Set<String> gone;

  /// The last position given to the engine, and the cursors it stands for:
  /// they become [cursors] when the engine asks for the next page after it,
  /// which means it applied this one.
  int round;
  final Map<String, int> staged;
  int? stagedAt;

  String encode() => jsonEncode({
    'cursors': cursors,
    'next_push': nextPush,
    if (unanswered case final u?)
      'unanswered': {'home': u.home, 'number': u.number, 'body': u.body},
    'homes': [for (final h in homes) h.toJson()],
    'gone': gone.toList()..sort(),
    'round': round,
    'staged': staged,
    'staged_at': stagedAt,
  });

  static ServerSyncState decode(String? text) {
    if (text == null) return ServerSyncState();
    final json = jsonDecode(text) as Map<String, Object?>;
    final u = json['unanswered'] as Map?;
    return ServerSyncState(
      cursors: (json['cursors'] as Map? ?? {}).cast<String, int>(),
      nextPush: json['next_push'] as int? ?? 1,
      unanswered: u == null
          ? null
          : (
              home: u['home'] as String,
              number: u['number'] as int,
              body: u['body'] as String,
            ),
      homes: [
        for (final h in (json['homes'] as List? ?? const []))
          ServerHome.fromJson((h as Map).cast<String, Object?>()),
      ],
      gone: {for (final g in (json['gone'] as List? ?? const [])) g as String},
      round: json['round'] as int? ?? 0,
      staged: (json['staged'] as Map? ?? {}).cast<String, int>(),
      stagedAt: json['staged_at'] as int?,
    );
  }
}

/// Where the transport keeps its [ServerSyncState].
abstract interface class ServerStateStore {
  Future<String?> readServerState();
  Future<void> writeServerState(String? state);
}

/// Where the transport keeps the mark "seen by the server" of each row
/// (docs/protocol.md section 2.10): in the phone's sync tables.
abstract interface class ServerSeenStore {
  /// Marks the rows `(t, h, id)`.
  Future<void> markSeen(Iterable<(String, String, String)> rows);
}

/// Why the server stopped this phone.
enum ServerStop {
  /// The access was revoked on the server, or expired: sign in again.
  disconnected,

  /// The server is too old for the sync API ([minimumServerVersion]).
  tooOld,

  /// The instance turned the mobile app off.
  mobileAppOff,

  /// The server refused plain HTTP (`insecure_transport`).
  insecureTransport,

  /// This version of the app reads but does not write (`sync_version`).
  updateApp,
}

class ServerStopped implements Exception {
  const ServerStopped(this.reason, [this.detail]);

  final ServerStop reason;
  final String? detail;

  @override
  String toString() => 'ServerStopped(${reason.name})';
}

/// One operation the server refused (`rejected`), shown on its row.
class ServerRejection {
  const ServerRejection(this.operation, this.code);

  final SyncOperation operation;
  final String code;
}

/// The [SyncTransport] of the third way (docs/adr/0010, "Architecture"): the
/// operations of docs/protocol.md section 2.2, in clear, to the sync API of
/// a Housecairn server (web ADR 0077), with the access kept in [Store].
class ServerTransport implements SyncTransport {
  ServerTransport({
    required this.address,
    required this.http,
    required this.store,
    required this.state,
    required this.device,
    required this.schemaVersion,
    this.seenStore,
  });

  final ServerAddress address;
  final ServerHttp http;
  final Store store;
  final ServerStateStore state;

  /// This phone's device id, in `b64`.
  final String device;
  final int schemaVersion;

  /// The mark "seen by the server"; `null` keeps it in [seen] only (tests).
  final ServerSeenStore? seenStore;

  Future<void> _mark(Iterable<(String, String, String)> rows) async {
    final list = rows.toList();
    if (list.isNotEmpty) await seenStore?.markSeen(list);
  }

  /// The operations the server refused in the last push, for the screens.
  final rejections = <ServerRejection>[];

  /// The results of the last pushes, by operation `(t, id)`: `true` when the
  /// server saw the row (`applied`, `ignored`, `repaired`).
  final seen = <(String, String), bool>{};

  /// The page size of the feed.
  static const pageSize = 500;

  /// Operations of the phone per push: each may become two on the wire
  /// ([wire]), and the server takes 500 (`ops_per_push`).
  static const pushSize = 200;

  ServerSyncState? _cached;

  Future<ServerSyncState> _state() async =>
      _cached ??= ServerSyncState.decode(await state.readServerState());

  Future<void> _save(ServerSyncState s) async {
    _cached = s;
    await state.writeServerState(s.encode());
  }

  // ---------- requests ----------

  Future<ServerReply> _call(
    String method,
    String route, {
    Map<String, String>? query,
    Object? json,
    bool auth = true,
  }) async {
    final body = json == null ? null : utf8.encode(jsonEncode(json));
    return _send(
      method,
      address.resolve(route, query),
      body: body,
      auth: auth,
      contentType: json == null ? null : 'application/json',
    );
  }

  Future<ServerReply> _send(
    String method,
    Uri url, {
    Uint8List? body,
    bool auth = true,
    String? contentType,
    bool retried = false,
  }) async {
    final credential = auth ? await ServerCredential.read(store) : null;
    if (auth && credential == null) {
      throw const ServerStopped(ServerStop.disconnected);
    }
    final reply = await http.send(
      method,
      url,
      headers: {
        'accept': 'application/json',
        'content-type': ?contentType,
        if (credential != null) 'authorization': 'Bearer ${credential.access}',
      },
      body: body,
    );
    if (reply.status == 401 && auth && !retried) {
      await _refresh(credential!);
      return _send(
        method,
        url,
        body: body,
        auth: auth,
        contentType: contentType,
        retried: true,
      );
    }
    if (reply.status == 401 && auth) {
      throw const ServerStopped(ServerStop.disconnected);
    }
    if (reply.status == 403) {
      switch (_code(reply)) {
        case 'insecure_transport':
          throw const ServerStopped(ServerStop.insecureTransport);
        case 'mobile_app_disabled':
          throw const ServerStopped(ServerStop.mobileAppOff);
        case 'sync_needs_connection':
          throw const ServerStopped(ServerStop.disconnected);
      }
    }
    return reply;
  }

  /// A new access token by the refresh token (rotated by the server); a
  /// refusal means the access was revoked or expired.
  Future<void> _refresh(ServerCredential credential) async {
    if (!address.owns(credential.token)) {
      throw const ServerStopped(ServerStop.disconnected);
    }
    final reply = await http.send(
      'POST',
      credential.token,
      headers: {
        'accept': 'application/json',
        'content-type': 'application/x-www-form-urlencoded',
      },
      body: utf8.encode(
        Uri(
          queryParameters: {
            'grant_type': 'refresh_token',
            'refresh_token': credential.refresh,
            'client_id': oauthClientId,
          },
        ).query,
      ),
    );
    if (reply.status != 200) {
      throw const ServerStopped(ServerStop.disconnected);
    }
    try {
      await credential.refreshed(_json(reply)).write(store);
    } on SignInException {
      throw const ServerStopped(ServerStop.disconnected);
    }
  }

  static Map<String, Object?> _json(ServerReply reply) {
    final value = jsonDecode(utf8.decode(reply.body));
    return value is Map ? value.cast<String, Object?>() : {};
  }

  static String? _code(ServerReply reply) {
    try {
      return _json(reply)['code'] as String?;
    } on FormatException {
      return null;
    }
  }

  Never _unexpected(ServerReply reply) {
    Object? detail;
    try {
      final json = _json(reply);
      detail = json['index'] == null
          ? json['detail']
          : '${json['detail']} (operation ${json['index']})';
    } on FormatException {
      detail = null;
    }
    throw StateError(
      'Unexpected answer ${reply.status} (${_code(reply)}): $detail',
    );
  }

  // ---------- SyncTransport ----------

  @override
  Future<SyncCapabilities> capabilities() async {
    final reply = await _call('GET', '/api/v1/sync/info');
    if (reply.status == 404) throw const ServerStopped(ServerStop.tooOld);
    if (reply.status != 200) _unexpected(reply);
    final info = _json(reply);
    final versions = info['sync'];
    final server = info['server'];
    if (versions is! List ||
        !versions.any(supportedSyncVersions.contains) ||
        server is! String) {
      throw ServerStopped(ServerStop.tooOld, server is String ? server : null);
    }
    final limits = <String, int>{
      for (final MapEntry(:key, :value)
          in ((info['limits'] as Map?) ?? const {}).entries)
        if (value is int) key as String: value,
    };
    return SyncCapabilities(version: server, limits: limits);
  }

  /// The homes of the access, and those erased while bound to it; kept in
  /// the state for [homesGone] and the members of each home.
  Future<List<ServerHome>> homes() async {
    final reply = await _call('GET', '/api/v1/sync/homes/');
    if (reply.status != 200) _unexpected(reply);
    final json = _json(reply);
    final listed = [
      for (final h in (json['homes'] as List? ?? const []))
        ServerHome.fromJson((h as Map).cast<String, Object?>()),
    ];
    final s = await _state();
    final before = {for (final h in s.homes) h.id};
    final now = {for (final h in listed) h.id};
    s.gone
      ..addAll([
        for (final g in (json['gone'] as List? ?? const []))
          (g as Map)['id'] as String,
      ])
      // A home no longer covered by the access is gone for this phone.
      ..addAll(before.difference(now));
    s.homes
      ..clear()
      ..addAll(listed);
    await _save(s);
    return listed;
  }

  @override
  Future<List<String>> homesGone() async {
    await homes();
    final s = await _state();
    return s.gone.toList()..sort();
  }

  @override
  Future<PushResult> push(List<SyncOperation> operations) async {
    final s = await _state();
    final lost = <SyncOperation>[];
    rejections.clear();
    if (s.unanswered case final u?) {
      await _sendPush(s, u.home, u.number, u.body, const [], lost);
    }
    final byHome = <String, List<SyncOperation>>{};
    for (final op in operations) {
      final home = op[Op.home] as String?;
      // Family types have no home: they exist only with the relay.
      if (home == null || s.gone.contains(home)) continue;
      (byHome[home] ??= []).add(op);
    }
    // A cursor the server no longer keeps: the pull starts again from the
    // snapshot, and the rule of protocol section 2.10 decides first which of
    // these operations still go (a change to a row purged there does not).
    for (final home in byHome.keys) {
      final cursor = s.cursors[home];
      if (cursor == null) continue;
      final probe = await _call(
        'GET',
        '/api/v1/sync/homes/$home/changes',
        query: {'after': '$cursor', 'limit': '1'},
      );
      if (probe.status == 410 && _code(probe) == 'cursor_expired') {
        return const PushResult(held: true);
      }
    }
    for (final MapEntry(key: home, value: ops) in byHome.entries) {
      for (var start = 0; start < ops.length; start += pushSize) {
        final chunk = ops.sublist(
          start,
          start + pushSize > ops.length ? ops.length : start + pushSize,
        );
        final number = s.nextPush++;
        final wired = <Map<String, Object?>>[];
        final sources = <SyncOperation>[];
        for (final op in chunk) {
          for (final w in wire(op)) {
            wired.add(w);
            sources.add(op);
          }
        }
        final body = jsonEncode({
          'push': number,
          'sv': schemaVersion,
          'device': device,
          'ops': wired,
        });
        s.unanswered = (home: home, number: number, body: body);
        await _save(s);
        await _sendPush(s, home, number, body, sources, lost);
      }
    }
    return PushResult(lost: lost);
  }

  /// The types whose `created_at` the server takes from the phone (web
  /// v0.4.0, `send=CREATED` in `stock/syncing.py` and `reports/syncing.py`).
  static const _createdAtSent = {
    'stock.article',
    'stock.supplier',
    'stock.movement',
    'reports.report',
  };

  /// A column the server keeps for itself (web `sync.pushing`, `server_owned`:
  /// `created_at` and `updated_at` but where it takes `created_at`, and the
  /// derived fields, `SYNC_DERIVED`: `visible_from` of an occurrence): an
  /// operation that sets one is rejected `forbidden` as a whole, so the
  /// phone does not send it. The server writes its own.
  static bool _serverOwned(String? type, String field) =>
      field == 'updated_at' ||
      (field == 'created_at' && !_createdAtSent.contains(type)) ||
      (field == 'visible_from' && type == 'tasks.occurrence');

  /// The operation as the server reads it: the keys of section 2.2 only
  /// (the device is the push's, and `sv` the body's), and `deleted_at`,
  /// which the phone writes as a field of a `put`, as the `delete` or
  /// `restore` of section 2.2 (web ADR 0077: "deleted_at is written by a
  /// delete or a restore"). One operation of the phone may so be two.
  static List<Map<String, Object?>> wire(SyncOperation op) {
    final base = {
      for (final MapEntry(:key, :value) in op.entries)
        if (key != Op.device && key != Op.schema && key != Op.fields)
          key: value,
    };
    final fields = <String, Object?>{
      for (final MapEntry(:key, :value)
          in ((op[Op.fields] as Map?)?.cast<String, Object?>() ?? const {})
              .entries)
        if (!_serverOwned(op[Op.type] as String?, key)) key: value,
    };
    if (op[Op.kind] == Op.put && fields.isEmpty) return const [];
    if (op[Op.kind] != Op.put || !fields.containsKey('deleted_at')) {
      return [
        {...base, if (op[Op.fields] != null) Op.fields: fields},
      ];
    }
    final deleted = fields.remove('deleted_at');
    return [
      if (fields.isNotEmpty) {...base, Op.fields: fields},
      if (deleted != null)
        {...base, Op.kind: Op.delete}
      else if (fields.isEmpty)
        {...base, Op.kind: Op.restore},
    ];
  }

  Future<void> _sendPush(
    ServerSyncState s,
    String home,
    int number,
    String body,
    List<SyncOperation> chunk,
    List<SyncOperation> lost,
  ) async {
    final reply = await _send(
      'POST',
      address.resolve('/api/v1/sync/homes/$home/push'),
      body: utf8.encode(body),
      contentType: 'application/json',
    );
    final code = _code(reply);
    if (reply.status == 410 && code == 'home_gone') {
      s.gone.add(home);
    } else if (reply.status == 400 && code == 'sync_version') {
      s.unanswered = null;
      await _save(s);
      throw const ServerStopped(ServerStop.updateApp);
    } else if (reply.status == 404) {
      // Not a home of this access (any more): it goes with the next list.
    } else if (reply.status != 200) {
      _unexpected(reply);
    } else {
      final sent = chunk.isNotEmpty
          ? chunk
          : [
              for (final op in (jsonDecode(body) as Map)['ops'] as List)
                (op as Map).cast<String, Object?>(),
            ];
      final marked = <(String, String, String)>[];
      for (final result in (_json(reply)['results'] as List? ?? const [])) {
        final r = (result as Map).cast<String, Object?>();
        final op = sent[r['i']! as int];
        final key = (op[Op.type]! as String, op[Op.id]! as String);
        final status = r['status'];
        seen[key] = status != 'rejected';
        if (status != 'rejected') marked.add((key.$1, home, key.$2));
        if (status == 'rejected') {
          rejections.add(ServerRejection(op, r['code'] as String? ?? ''));
        }
        final fields = (r['lost'] as Map?)?.cast<String, Object?>();
        if (fields != null) lost.addAll(_lostOperations(op, fields));
      }
      await _mark(marked);
    }
    s.unanswered = null;
    await _save(s);
  }

  /// One operation per write that won on the server against [op].
  static List<SyncOperation> _lostOperations(
    SyncOperation op,
    Map<String, Object?> fields,
  ) {
    final byWrite = <(String, String), Map<String, Object?>>{};
    for (final MapEntry(key: field, :value) in fields.entries) {
      final won = value! as List;
      (byWrite[(won[1]! as String, won[2]! as String)] ??= {})[field] = won[0];
    }
    return [
      for (final MapEntry(key: (clock, device), value: f) in byWrite.entries)
        {
          Op.type: op[Op.type],
          Op.home: op[Op.home],
          Op.id: op[Op.id],
          Op.kind: Op.put,
          Op.clock: clock,
          Op.device: device,
          Op.fields: f,
        },
    ];
  }

  @override
  Future<PullResult> pull({SyncPosition? after}) async {
    final s = await _state();
    if (after != null && s.stagedAt == after) {
      s.cursors.addAll(s.staged);
    }
    s.staged.clear();
    if (after == null) s.cursors.clear();
    if (s.homes.isEmpty) await this.homes();
    final homes = [
      for (final h in s.homes)
        if (!s.gone.contains(h.id)) h.id,
    ];
    final operations = <SyncOperation>[];
    final complete = <String, Set<(String, String)>>{};
    var more = false;
    for (final (index, home) in homes.indexed) {
      final cursor = s.cursors[home];
      if (cursor == null) {
        final (ops, covers, rows) = await _snapshot(home);
        if (covers == null) continue;
        operations.addAll(ops);
        complete[home] = rows;
        await _mark([for (final (t, id) in complete[home]!) (t, home, id)]);
        s.staged[home] = covers;
      } else {
        final reply = await _call(
          'GET',
          '/api/v1/sync/homes/$home/changes',
          query: {'after': '$cursor', 'limit': '$pageSize'},
        );
        final code = _code(reply);
        if (reply.status == 410 && code == 'cursor_expired') {
          s.round++;
          s.stagedAt = null;
          await _save(s);
          return PullResult(position: s.round, restart: true);
        }
        if (reply.status == 410 && code == 'home_gone') {
          s.gone.add(home);
          continue;
        }
        if (reply.status == 404) continue;
        if (reply.status != 200) _unexpected(reply);
        final json = _json(reply);
        final marked = <(String, String, String)>[];
        for (final change in (json['changes'] as List? ?? const [])) {
          final c = (change as Map).cast<String, Object?>();
          final op = (c['op']! as Map).cast<String, Object?>();
          operations.add({...op, Op.device: c['device']});
          marked.add((op[Op.type]! as String, home, op[Op.id]! as String));
          s.staged[home] = c['pos']! as int;
        }
        await _mark(marked);
        if (json['more'] == true) more = true;
      }
      // One home a page when it is large, so a page stays bounded.
      if (operations.length >= pageSize && index < homes.length - 1) {
        more = true;
        break;
      }
    }
    s.round++;
    s.stagedAt = s.round;
    await _save(s);
    return PullResult(
      operations: operations,
      position: s.round,
      more: more,
      complete: complete,
    );
  }

  /// The snapshot of [home] as operations, its `covers`, and every row of
  /// it (`(t, id)`); `null` covers when the home is gone.
  Future<(List<SyncOperation>, int?, Set<(String, String)>)> _snapshot(
    String home,
  ) async {
    final reply = await _call('GET', '/api/v1/sync/homes/$home/snapshot');
    const none = (<SyncOperation>[], null, <(String, String)>{});
    if (reply.status == 410) {
      (await _state()).gone.add(home);
      return none;
    }
    if (reply.status == 404) return none;
    if (reply.status != 200) _unexpected(reply);
    final ops = <SyncOperation>[];
    final rows = <(String, String)>{};
    int? covers;
    for (final line in const LineSplitter().convert(utf8.decode(reply.body))) {
      if (line.trim().isEmpty) continue;
      final json = (jsonDecode(line) as Map).cast<String, Object?>();
      if (json.containsKey('covers')) {
        covers = json['covers']! as int;
      } else if (json.containsKey('members')) {
        continue;
      } else {
        ops.addAll(snapshotRowOperations(json));
        rows.add((json['t']! as String, json['id']! as String));
      }
    }
    return (ops, covers, rows);
  }

  /// A row of the server's snapshot (`{"t", "h", "id", "f": {field: [value,
  /// clock, device]}}`) as operations: one per write.
  static List<SyncOperation> snapshotRowOperations(Map<String, Object?> row) {
    final byWrite = <(String, String), Map<String, Object?>>{};
    for (final MapEntry(key: field, :value)
        in ((row['f'] as Map?) ?? const {}).entries) {
      final w = value as List;
      (byWrite[(w[1]! as String, w[2]! as String)] ??= {})[field as String] =
          w[0];
    }
    final writes = byWrite.keys.toList()..sort((a, b) => a.$1.compareTo(b.$1));
    // `deleted_at` stays a field with its clock, as the merge reads it
    // (operation.dart, `fieldsOf`): a tombstone is a row whose `deleted_at`
    // is set.
    return [
      for (final write in writes)
        {
          Op.type: row['t'],
          Op.home: row['h'],
          Op.id: row['id'],
          Op.kind: Op.put,
          Op.clock: write.$1,
          Op.device: write.$2,
          Op.fields: byWrite[write],
        },
    ];
  }

  @override
  Future<void> putFile(String id, Uint8List bytes) => throw UnsupportedError(
    'Files need a server with the file routes of web ADR 0077.',
  );

  @override
  Future<Uint8List> getFile(String id) => throw UnsupportedError(
    'Files need a server with the file routes of web ADR 0077.',
  );

  @override
  Future<void> deleteFile(String id) async {}

  /// Disconnect: the access is revoked on the server when it answers, and
  /// the credential is deleted from [store] whatever happens.
  Future<void> disconnect() async {
    final credential = await ServerCredential.read(store);
    try {
      if (credential != null && address.owns(credential.revoke)) {
        await http.send(
          'POST',
          credential.revoke,
          headers: {'content-type': 'application/x-www-form-urlencoded'},
          body: utf8.encode(
            Uri(
              queryParameters: {
                'token': credential.refresh,
                'token_type_hint': 'refresh_token',
                'client_id': oauthClientId,
              },
            ).query,
          ),
        );
      }
    } on ServerHttpException {
      // Offline: the access can still be revoked on the server's page.
    } finally {
      await ServerCredential.forget(store);
      await state.writeServerState(null);
      _cached = null;
    }
  }
}
