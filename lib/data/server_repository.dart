// SPDX-License-Identifier: AGPL-3.0-only

part of 'repository.dart';

/// What the third way keeps on the phone (docs/adr/0010, "The way of the
/// phone"): the server's address and the transport's state in
/// `local_settings`, never synced, never in an export; the credential is in
/// `Store`, never here.
extension ServerSettings on Repository {
  /// The address typed, as `ServerAddress.display` gives it.
  Future<String?> serverAddress() => _setting('server_address');

  Future<void> setServerAddress(String? address) =>
      _setSetting('server_address', address);

  /// This phone's device id, in `b64`, as the server's push reads it.
  String get deviceB64 => b64(_device);

  /// The [ServerStateStore] of the transport, on `local_settings`.
  ServerStateStore get serverState => _RepositoryServerState(this);
}

class _RepositoryServerState implements ServerStateStore {
  _RepositoryServerState(this.repository);

  final Repository repository;

  @override
  Future<String?> readServerState() => repository._setting('server_sync');

  @override
  Future<void> writeServerState(String? state) =>
      repository._setSetting('server_sync', state);
}
