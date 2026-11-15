// SPDX-License-Identifier: AGPL-3.0-only

import 'dart:convert';
import 'dart:typed_data';

import 'transport.dart';

/// The keys of an operation (docs/protocol.md section 2.2): `t`, `h`, `id`,
/// `k`, `c` and `f` as the protocol writes them, plus two that the engine
/// carries with each operation because a pull mixes the operations of
/// several devices: `d`, the writer's device (the `device` of the batch
/// header on a relay, `server_device` for an edit made on a Housecairn
/// server), in `b64`, and `sv`, the writer's schema version (the `sv` of the
/// batch header).
abstract final class Op {
  static const type = 't';
  static const home = 'h';
  static const id = 'id';
  static const kind = 'k';
  static const clock = 'c';
  static const device = 'd';
  static const schema = 'sv';
  static const fields = 'f';

  static const put = 'put';
  static const delete = 'delete';
  static const restore = 'restore';
}

/// `b64` of docs/protocol.md section 1: base64url without padding.
String b64(List<int> bytes) => base64Url.encode(bytes).replaceAll('=', '');

/// The bytes of a `b64` text.
Uint8List unb64(String text) => base64Url.decode(base64Url.normalize(text));

/// Orders two writes of one field: by clock, then by the device's bytes
/// (docs/protocol.md section 1). Negative when the first is older.
int compareWrites(
  String clockA,
  List<int> deviceA,
  String clockB,
  List<int> deviceB,
) {
  final byClock = clockA.compareTo(clockB);
  if (byClock != 0) return byClock;
  final length = deviceA.length < deviceB.length
      ? deviceA.length
      : deviceB.length;
  for (var i = 0; i < length; i++) {
    if (deviceA[i] != deviceB[i]) return deviceA[i] - deviceB[i];
  }
  return deviceA.length - deviceB.length;
}

/// The fields an operation sets, `deleted_at` included for `delete` and
/// `restore` (docs/protocol.md section 2.2, "Apply").
Map<String, Object?> fieldsOf(SyncOperation op) {
  final fields = <String, Object?>{
    ...?(op[Op.fields] as Map?)?.cast<String, Object?>(),
  };
  switch (op[Op.kind]) {
    case Op.delete:
      fields['deleted_at'] = op[Op.clock];
    case Op.restore:
      fields['deleted_at'] = null;
  }
  return fields;
}

/// A merged row as a snapshot holds it (docs/protocol.md section 2.4): each
/// field with its value, its clock and its writer.
class SnapshotRow {
  const SnapshotRow({
    required this.type,
    required this.home,
    required this.id,
    required this.fields,
  });

  final String type;
  final String? home;
  final String id;

  /// Field name to `[value, hlc, device_b64]`.
  final Map<String, List<Object?>> fields;

  Map<String, Object?> toJson() => {
    't': type,
    if (home != null) 'h': home,
    'id': id,
    'f': fields,
  };

  /// The operations that give this row on a phone that has nothing: one per
  /// clock and writer, in the order of their clocks.
  List<SyncOperation> operations({required int schemaVersion}) {
    final byWrite = <String, Map<String, Object?>>{};
    for (final MapEntry(:key, :value) in fields.entries) {
      final write = '${value[1]}|${value[2]}';
      (byWrite[write] ??= {})[key] = value[0];
    }
    final writes = byWrite.keys.toList()..sort();
    return [
      for (final write in writes)
        {
          Op.type: type,
          Op.home: ?home,
          Op.id: id,
          Op.kind: Op.put,
          Op.clock: write.split('|')[0],
          Op.device: write.split('|')[1],
          Op.schema: schemaVersion,
          Op.fields: byWrite[write],
        },
    ];
  }
}

/// The merged state of this phone (docs/protocol.md section 2.4): its rows,
/// tombstones included, and the operations it keeps for types it does not
/// know yet. Rows of a purged home are not in it.
class SyncSnapshot {
  const SyncSnapshot({
    required this.schemaVersion,
    required this.rows,
    this.pending = const [],
  });

  final int schemaVersion;
  final List<SnapshotRow> rows;
  final List<SyncOperation> pending;

  /// The JSON lines of the snapshot's plaintext, one per row, then one per
  /// operation kept for later.
  List<String> lines() => [
    for (final row in rows) jsonEncode(row.toJson()),
    for (final op in pending) jsonEncode({'pending': op}),
  ];

  /// Every operation that rebuilds this state on a new phone.
  List<SyncOperation> operations() => [
    for (final row in rows) ...row.operations(schemaVersion: schemaVersion),
    ...pending,
  ];
}
