// SPDX-License-Identifier: AGPL-3.0-only

import 'dart:typed_data';

import 'package:housecairn_mobile/sync/transport.dart';

/// A [SyncTransport] in memory: keeps what is pushed and the files, and
/// answers a pull with the operations pushed after the cursor. It stands for
/// the relay and the server until the engine of lot 4 is written against it.
class FakeSyncTransport implements SyncTransport {
  FakeSyncTransport({this.gone = const []});

  /// The ids [homesGone] answers.
  final List<String> gone;

  final log = <SyncOperation>[];
  final files = <String, Uint8List>{};
  int capabilityCalls = 0;

  @override
  Future<SyncCapabilities> capabilities() async {
    capabilityCalls++;
    return const SyncCapabilities(version: 'fake', limits: {'batch': 500});
  }

  @override
  Future<PushResult> push(List<SyncOperation> operations) async {
    log.addAll(operations);
    return const PushResult();
  }

  @override
  Future<PullResult> pull({SyncPosition? after}) async {
    final from = after ?? 0;
    return PullResult(operations: log.sublist(from), position: log.length);
  }

  @override
  Future<void> putFile(
    String home,
    String id,
    Uint8List bytes, {
    required String sha256,
    required String type,
  }) async => files[id] = bytes;

  @override
  Future<Uint8List> getFile(String home, String id) async => files[id]!;

  @override
  Future<void> deleteFile(String home, String id) async => files.remove(id);

  @override
  Future<List<String>> homesGone() async => gone;
}
