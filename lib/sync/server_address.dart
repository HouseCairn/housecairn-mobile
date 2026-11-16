// SPDX-License-Identifier: AGPL-3.0-only

/// The address of a Housecairn server, as the person typed it, and the rule
/// of plain HTTP of docs/protocol.md section 2.10: `https://` always, and
/// `http://` only towards an IP literal that is not a public address by the
/// rule of the web's `core.netguard.is_public` (web ADR 0078, "HTTPS, and
/// plain HTTP between local addresses"). A name, `.local` and `.home.arpa`
/// included, needs `https://`.
library;

/// Why a typed address is refused.
enum ServerAddressError {
  /// Not an address: empty, no host, a scheme other than http(s), a user
  /// name, a query or a fragment.
  invalid,

  /// `http://` towards a name or a public address.
  httpNeedsLocalIp,
}

/// A server address that passed the rule: only its origin is kept, and every
/// request of the app goes to it and nowhere else.
class ServerAddress {
  const ServerAddress._(this.secure, this.host, this.port, this.path);

  /// `https` when true, `http` (a local IP literal) when false.
  final bool secure;

  /// The host as written in a URL (an IPv6 literal without its brackets).
  final String host;

  final int port;

  /// The path the instance is served under, without a trailing `/` (often
  /// empty).
  final String path;

  /// Plain HTTP: the warning of ADR 0010 is shown first.
  bool get plainHttp => !secure;

  String get scheme => secure ? 'https' : 'http';

  /// The origin and path, as shown to the person and stored in
  /// `local_settings`.
  String get display => origin.toString() + path;

  Uri get origin => Uri(
    scheme: scheme,
    host: host,
    port: port == (secure ? 443 : 80) ? null : port,
  );

  /// The URL of [route] (`/api/v1/sync/info`) on this server.
  Uri resolve(String route, [Map<String, String>? query]) => Uri(
    scheme: scheme,
    host: host,
    port: port,
    path: '$path$route',
    queryParameters: query == null || query.isEmpty ? null : query,
  );

  /// Whether [url] is on this server: same scheme, host and port. Every
  /// address the server gives (the OAuth endpoints of `info`) is checked so
  /// before the app calls it.
  bool owns(Uri url) =>
      url.scheme == scheme &&
      url.host.toLowerCase() == host.toLowerCase() &&
      url.port == port;

  /// The address [typed], or why it is refused. `https://` is assumed when
  /// no scheme is typed.
  static (ServerAddress?, ServerAddressError?) parse(String typed) {
    var text = typed.trim();
    if (text.isEmpty || text.contains(RegExp(r'\s'))) {
      return (null, ServerAddressError.invalid);
    }
    if (!text.contains('://')) text = 'https://$text';
    final Uri uri;
    try {
      uri = Uri.parse(text);
    } on FormatException {
      return (null, ServerAddressError.invalid);
    }
    final scheme = uri.scheme.toLowerCase();
    if ((scheme != 'https' && scheme != 'http') ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty ||
        uri.hasQuery ||
        uri.hasFragment) {
      return (null, ServerAddressError.invalid);
    }
    final host = uri.host.toLowerCase();
    final secure = scheme == 'https';
    if (!secure && !isLocalIpLiteral(host)) {
      return (null, ServerAddressError.httpNeedsLocalIp);
    }
    var path = uri.path;
    while (path.endsWith('/')) {
      path = path.substring(0, path.length - 1);
    }
    return (ServerAddress._(secure, host, uri.port, path), null);
  }

  /// Rebuilds an address stored by [display]; `null` when it no longer
  /// passes the rule.
  static ServerAddress? stored(String? value) =>
      value == null ? null : parse(value).$1;
}

/// Whether [host] is an IP literal (IPv4, or IPv6 with or without brackets)
/// that is not a public address, by the rule of the web's
/// `core.netguard.is_public`: loopback, private networks, the shared space
/// 100.64.0.0/10, link-local, unique local and site-local IPv6, the
/// documentation ranges and every other range that is not global; an IPv6
/// address that carries an IPv4 one (mapped, NAT64, 6to4, Teredo) is judged
/// by the IPv4 address. A name is never local.
bool isLocalIpLiteral(String host) {
  var text = host;
  if (text.startsWith('[') && text.endsWith(']')) {
    text = text.substring(1, text.length - 1);
  }
  final v4 = _parseIPv4(text);
  if (v4 != null) return !_publicIPv4(v4);
  if (!text.contains(':')) return false;
  final List<int> bytes;
  try {
    bytes = Uri.parseIPv6Address(text);
  } on FormatException {
    return false;
  }
  return !_publicIPv6(bytes);
}

List<int>? _parseIPv4(String text) {
  if (!RegExp(r'^\d{1,3}(\.\d{1,3}){3}$').hasMatch(text)) return null;
  final parts = text.split('.');
  // A leading zero is refused, as Python's ipaddress does (octal ambiguity).
  if (parts.any((p) => p.length > 1 && p.startsWith('0'))) return null;
  final bytes = parts.map(int.parse).toList();
  return bytes.every((b) => b <= 255) ? bytes : null;
}

int _v4(List<int> b) => (b[0] << 24) | (b[1] << 16) | (b[2] << 8) | b[3];

bool _inV4(int address, List<int> network, int bits) {
  final base = _v4(network);
  final mask = bits == 0 ? 0 : (0xFFFFFFFF << (32 - bits)) & 0xFFFFFFFF;
  return (address & mask) == (base & mask);
}

/// The IPv4 ranges Python's `ipaddress` does not call global (the IANA
/// special-purpose registry), the multicast range, and the metadata service
/// of a cloud provider that `is_public` refuses by name.
const _notGlobalV4 = <(List<int>, int)>[
  ([0, 0, 0, 0], 8),
  ([10, 0, 0, 0], 8),
  ([100, 64, 0, 0], 10),
  ([127, 0, 0, 0], 8),
  ([169, 254, 0, 0], 16),
  ([172, 16, 0, 0], 12),
  ([192, 0, 0, 0], 24),
  ([192, 0, 2, 0], 24),
  ([192, 168, 0, 0], 16),
  ([198, 18, 0, 0], 15),
  ([198, 51, 100, 0], 24),
  ([203, 0, 113, 0], 24),
  ([224, 0, 0, 0], 4),
  ([240, 0, 0, 0], 4),
  ([100, 100, 100, 200], 32),
];

bool _publicIPv4(List<int> bytes) {
  final address = _v4(bytes);
  // Two addresses of 192.0.0.0/24 are global for `ipaddress` (anycast).
  if (_inV4(address, [192, 0, 0, 9], 32) ||
      _inV4(address, [192, 0, 0, 10], 32)) {
    return true;
  }
  return !_notGlobalV4.any((r) => _inV4(address, r.$1, r.$2));
}

bool _prefix(List<int> bytes, List<int> start, int bits) {
  for (var i = 0; i < bits; i++) {
    final byte = i ~/ 8;
    final bit = 7 - i % 8;
    if (((bytes[byte] >> bit) & 1) != ((start[byte] >> bit) & 1)) return false;
  }
  return true;
}

List<int> _six(String text) => Uri.parseIPv6Address(text);

/// IPv6 ranges that are not global, as `ipaddress` and `netguard` read them.
final _notGlobalV6 = <(List<int>, int)>[
  (_six('::'), 128), // unspecified
  (_six('::1'), 128), // loopback
  (_six('64:ff9b:1::'), 48), // local-use NAT64
  (_six('100::'), 64), // discard
  (_six('2001::'), 23), // IETF protocol assignments
  (_six('2001:db8::'), 32), // documentation
  (_six('3fff::'), 20), // documentation (RFC 9637)
  (_six('fc00::'), 7), // unique local
  (_six('fe80::'), 10), // link-local
  (_six('fec0::'), 10), // site-local, refused by netguard
  (_six('ff00::'), 8), // multicast
  (_six('fd00:ec2::254'), 128), // a metadata service
];

/// The global exceptions inside 2001::/23 that Python keeps global.
final _globalInside2001 = <(List<int>, int)>[
  (_six('2001:1::1'), 128),
  (_six('2001:1::2'), 128),
  (_six('2001:3::'), 32),
  (_six('2001:4:112::'), 48),
  (_six('2001:20::'), 28),
  (_six('2001:30::'), 28),
];

bool _publicIPv6(List<int> bytes) {
  final carried = _embeddedIPv4(bytes);
  if (carried != null) return _publicIPv4(carried);
  if (_globalInside2001.any((r) => _prefix(bytes, r.$1, r.$2))) return true;
  return !_notGlobalV6.any((r) => _prefix(bytes, r.$1, r.$2));
}

/// The IPv4 address an IPv6 one carries, as `netguard.embedded_ipv4`:
/// mapped (::ffff:0:0/96), NAT64 (64:ff9b::/96), 6to4 (2002::/16) or the
/// client of Teredo (2001::/32, inverted).
List<int>? _embeddedIPv4(List<int> b) {
  if (_prefix(b, _six('::ffff:0:0'), 96)) return b.sublist(12, 16);
  if (_prefix(b, _six('64:ff9b::'), 96)) return b.sublist(12, 16);
  if (_prefix(b, _six('2002::'), 16)) return b.sublist(2, 6);
  if (_prefix(b, _six('2001::'), 32)) {
    return [for (final x in b.sublist(12, 16)) x ^ 0xFF];
  }
  return null;
}
