// SPDX-License-Identifier: AGPL-3.0-only

// In-memory doubles of the two sides a SyncTransport talks to
// (docs/adr/0010-three-ways-to-use-the-app.md): a relay, which keeps
// batches in order with their positions and a snapshot, and a Housecairn
// server, which merges each field as it receives it, keeps the result, gives
// its own feed with a cursor, and answers a push with the value that won for
// each field that lost. Neither knows the model beyond the fields.

import 'dart:typed_data';

import 'package:housecairn_mobile/sync/operation.dart';
import 'package:housecairn_mobile/sync/transport.dart';

SyncOperation copyOf(SyncOperation op) => {
  ...op,
  if (op[Op.fields] != null)
    Op.fields: {...(op[Op.fields]! as Map).cast<String, Object?>()},
};

/// The relay: batches in the order they came, positions growing by one, a
/// snapshot that lets it drop older batches, and purges (the records
/// `purge` of the membership log).
class RelayDouble {
  final _batches = <(SyncPosition, List<SyncOperation>)>[];
  final purged = <String>[];
  SyncSnapshot? _snapshot;
  SyncPosition _covers = 0;

  /// Batches at or below this position were dropped after a snapshot.
  SyncPosition get oldest => _covers;
  SyncPosition get head => _batches.isEmpty ? _covers : _batches.last.$1;

  /// How many batches a pull gives at most.
  int pageSize = 3;

  SyncPosition _append(List<SyncOperation> ops) {
    final pos = head + 1;
    _batches.add((pos, [for (final op in ops) copyOf(op)]));
    return pos;
  }

  /// Stores [snapshot], which covers every batch up to [covers], and drops
  /// those batches (docs/protocol.md section 3.3, retention).
  void storeSnapshot(SyncSnapshot snapshot, SyncPosition covers) {
    _snapshot = snapshot;
    _covers = covers;
    _batches.removeWhere((b) => b.$1 <= covers);
  }

  RelayTransport transport() => RelayTransport(this);
}

class RelayTransport implements SyncTransport {
  RelayTransport(this.relay);

  final RelayDouble relay;

  @override
  Future<SyncCapabilities> capabilities() async =>
      const SyncCapabilities(version: 'relay-double/1');

  @override
  Future<PushResult> push(List<SyncOperation> operations) async {
    relay._append(operations);
    return const PushResult();
  }

  @override
  Future<PullResult> pull({SyncPosition? after}) async {
    final start = after ?? 0;
    final fromSnapshot = after == null && relay._snapshot != null;
    if (!fromSnapshot && start < relay.oldest) {
      return PullResult(position: start, restart: true);
    }
    final from = fromSnapshot ? relay._covers : start;
    final page = relay._batches
        .where((b) => b.$1 > from)
        .take(relay.pageSize)
        .toList();
    final position = page.isEmpty ? from : page.last.$1;
    return PullResult(
      operations: [
        if (fromSnapshot) ...relay._snapshot!.operations(),
        for (final (_, ops) in page)
          for (final op in ops) copyOf(op),
      ],
      position: position,
      more: relay._batches.any((b) => b.$1 > position),
    );
  }

  @override
  Future<void> putFile(String id, Uint8List bytes) async {}

  @override
  Future<Uint8List> getFile(String id) async => Uint8List(0);

  @override
  Future<void> deleteFile(String id) async {}

  @override
  Future<List<String>> homesGone() async => [...relay.purged];
}

class _Write {
  _Write(this.value, this.clock, this.device);

  final Object? value;
  final String clock;
  final String device;
}

/// A Housecairn server: it keeps one merged row per id, field by field by
/// the rule of ADR 0003, a feed of what it accepted with its own positions,
/// and answers a push with the value that won for each field that lost.
class ServerDouble {
  final _rows = <String, (String, String?, Map<String, _Write>)>{};
  final _feed = <(SyncPosition, SyncOperation)>[];
  final gone = <String>[];

  /// Changes at or below this position are no longer kept (a cursor older
  /// gets 410).
  SyncPosition expired = 0;

  int pageSize = 7;

  SyncPosition get head => _feed.isEmpty ? expired : _feed.last.$1;

  /// Applies [op] as the server does; returns the operations that give the
  /// values that won against it.
  List<SyncOperation> _apply(SyncOperation op) {
    final home = op[Op.home] as String?;
    if (home != null && gone.contains(home)) return const [];
    final id = op[Op.id] as String;
    final clock = op[Op.clock] as String;
    final device = op[Op.device] as String;
    final row = _rows[id] ??= (op[Op.type] as String, home, {});
    final won = <String, Object?>{};
    final lost = <String, _Write>{};
    for (final MapEntry(key: field, :value) in fieldsOf(op).entries) {
      final stored = row.$3[field];
      final order = stored == null
          ? 1
          : compareWrites(
              clock,
              unb64(device),
              stored.clock,
              unb64(stored.device),
            );
      if (order > 0) {
        row.$3[field] = _Write(value, clock, device);
        won[field] = value;
      } else if (order < 0) {
        lost[field] = stored!;
      }
    }
    if (won.isNotEmpty) {
      _feed.add((head + 1, {...op, Op.kind: Op.put, Op.fields: won}));
    }
    return [
      for (final MapEntry(key: field, value: w) in lost.entries)
        {
          Op.type: row.$1,
          Op.home: ?row.$2,
          Op.id: id,
          Op.kind: Op.put,
          Op.clock: w.clock,
          Op.device: w.device,
          Op.fields: {field: w.value},
        },
    ];
  }

  /// The server's snapshot: every row, each field with its clock.
  List<SyncOperation> _snapshot() => [
    for (final MapEntry(key: id, value: row) in _rows.entries)
      if (row.$2 == null || !gone.contains(row.$2))
        for (final MapEntry(key: field, value: w) in row.$3.entries)
          {
            Op.type: row.$1,
            Op.home: ?row.$2,
            Op.id: id,
            Op.kind: Op.put,
            Op.clock: w.clock,
            Op.device: w.device,
            Op.fields: {field: w.value},
          },
  ];

  /// Erases a home, as the web does; its routes then answer `home_gone`.
  void eraseHome(String home) {
    gone.add(home);
    _rows.removeWhere((_, row) => row.$2 == home);
  }

  ServerTransport transport() => ServerTransport(this);
}

class ServerTransport implements SyncTransport {
  ServerTransport(this.server);

  final ServerDouble server;

  @override
  Future<SyncCapabilities> capabilities() async =>
      const SyncCapabilities(version: 'server-double/1');

  @override
  Future<PushResult> push(List<SyncOperation> operations) async => PushResult(
    lost: [for (final op in operations) ...server._apply(copyOf(op))],
  );

  @override
  Future<PullResult> pull({SyncPosition? after}) async {
    if (after != null && after < server.expired) {
      return PullResult(position: after, restart: true);
    }
    if (after == null) {
      return PullResult(operations: server._snapshot(), position: server.head);
    }
    final page = server._feed
        .where((c) => c.$1 > after)
        .take(server.pageSize)
        .toList();
    final position = page.isEmpty ? after : page.last.$1;
    return PullResult(
      operations: [for (final (_, op) in page) copyOf(op)],
      position: position,
      more: server._feed.any((c) => c.$1 > position),
    );
  }

  @override
  Future<void> putFile(String id, Uint8List bytes) async {}

  @override
  Future<Uint8List> getFile(String id) async => Uint8List(0);

  @override
  Future<void> deleteFile(String id) async {}

  @override
  Future<List<String>> homesGone() async => [...server.gone];
}
