// SPDX-License-Identifier: AGPL-3.0-only

// Licence check of every dependency of the app (lot 1 of docs/plan.md).
//
//   dart run tool/check_licenses.dart
//
// Reads pubspec.lock (every package, direct and transitive, of the app, of its
// build and of its tests) and .dart_tool/package_config.json (where `flutter
// pub get` put each package), finds the licence file of each package, names
// the licences it contains, and fails when:
// - a package matches a pattern of tool/licenses/forbidden-packages.txt
//   (analytics, crash reporting, advertising), whatever its licence;
// - a licence is not in tool/licenses/allowed-licenses.txt;
// - a package has no licence file, or one whose licence is not recognised;
// - a font file bundled in assets/fonts is not in the table of
//   assets/fonts/README.md with its SHA-256, or its licence file is missing,
//   not recognised or not allowed.
// Packages of the Flutter SDK (`source: sdk`) are under the licence of the
// SDK, whose LICENSE file is checked the same way.
//
// It prints one line per package. Only Dart's own libraries are used, so that
// the check depends on nothing it checks.

import 'dart:convert';
import 'dart:io';

/// A package of pubspec.lock.
class LockedPackage {
  const LockedPackage(this.name, this.version, this.dependency, this.source);

  final String name;
  final String version;

  /// `direct main`, `direct dev`, `direct overridden` or `transitive`.
  final String dependency;

  /// `hosted`, `sdk`, `git` or `path`.
  final String source;
}

/// The packages of a pubspec.lock file. The format is YAML written by pub,
/// always in the same layout: two spaces before a package name, four before
/// its fields.
List<LockedPackage> parseLock(String text) {
  final packages = <LockedPackage>[];
  final lines = const LineSplitter().convert(text);
  final start = lines.indexOf('packages:');
  if (start < 0) throw const FormatException('pubspec.lock has no "packages:"');
  String? name;
  var fields = <String, String>{};
  void flush() {
    final current = name;
    if (current == null) return;
    for (final field in ['dependency', 'source', 'version']) {
      if (!fields.containsKey(field)) {
        throw FormatException('pubspec.lock: $current has no "$field"');
      }
    }
    packages.add(
      LockedPackage(
        current,
        fields['version']!,
        fields['dependency']!,
        fields['source']!,
      ),
    );
  }

  for (final line in lines.skip(start + 1)) {
    if (line.isEmpty) continue;
    if (!line.startsWith(' ')) break; // the next section, `sdks:`
    final package = RegExp(r'^  ([A-Za-z0-9_]+):$').firstMatch(line);
    if (package != null) {
      flush();
      name = package.group(1);
      fields = {};
      continue;
    }
    final field = RegExp(r'^    ([a-z]+): (.+)$').firstMatch(line);
    if (field != null) {
      fields[field.group(1)!] = field.group(2)!.replaceAll('"', '');
    }
  }
  flush();
  return packages;
}

/// The SPDX identifiers of the licences in a licence file. A file may hold
/// several (a package and the code it bundles); an empty set means that no
/// licence was recognised.
Set<String> identifyLicences(String text) {
  final t = text.toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  final found = <String>{};
  if (t.contains('apache license') && t.contains('version 2.0')) {
    found.add('Apache-2.0');
  }
  if (t.contains(
    // "of this software": the SIL Open Font License opens with the same words
    // about "the Font Software".
    'permission is hereby granted, free of charge, to any person obtaining a copy of this software',
  )) {
    found.add('MIT');
  }
  if (t.contains('redistribution and use in source and binary forms')) {
    // The third clause of BSD-3-Clause forbids using the names of the
    // authors to endorse a derived product.
    final third = RegExp(
      r'(neither the name|the names? of (its|the) (contributors|copyright holders?|authors?)'
      r'|name of the copyright holder).{0,200}(endorse|promote)',
    );
    found.add(third.hasMatch(t) ? 'BSD-3-Clause' : 'BSD-2-Clause');
  }
  if (t.contains(
        'permission to use, copy, modify, and/or distribute this software for any purpose',
      ) ||
      t.contains(
        'permission to use, copy, modify, and distribute this software for any purpose with or without fee',
      )) {
    found.add('ISC');
  }
  if (t.contains(
        "this software is provided 'as-is', without any express or implied warranty",
      ) &&
      t.contains('altered source versions must be plainly marked')) {
    found.add('Zlib');
  }
  if (t.contains('sil open font license') && t.contains('version 1.1')) {
    found.add('OFL-1.1');
  }
  if (t.contains('gnu affero general public license')) found.add('AGPL');
  if (t.contains('gnu lesser general public license') ||
      t.contains('gnu library general public license')) {
    found.add('LGPL');
  }
  if (t.contains('gnu general public license')) found.add('GPL');
  if (t.contains('mozilla public license')) found.add('MPL');
  if (t.contains('eclipse public license')) found.add('EPL');
  if (t.contains('server side public license')) found.add('SSPL');
  if (t.contains('business source license')) found.add('BUSL');
  if (t.contains('creative commons')) found.add('CC');
  return found;
}

/// Reads a list file of tool/licenses: one entry per line, `#` comments.
List<String> readList(String path) =>
    File(path)
        .readAsLinesSync()
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty && !line.startsWith('#'))
        .toList();

/// Whether [name] matches [pattern], where `*` stands for any characters.
bool matchesPattern(String name, String pattern) {
  final regex = RegExp(
    '^${pattern.split('*').map(RegExp.escape).join('.*')}\$',
  );
  return regex.hasMatch(name);
}

/// The patterns of [forbidden] that [name] matches.
List<String> forbiddenMatches(String name, List<String> forbidden) =>
    forbidden.where((pattern) => matchesPattern(name, pattern)).toList();

/// The licence file of the package at [root]: LICENSE, LICENSE.md, COPYING…
File? licenceFile(Directory root) {
  if (!root.existsSync()) return null;
  final candidates = root.listSync().whereType<File>().where((file) {
    final name = file.uri.pathSegments.last.toUpperCase();
    return name.startsWith('LICENSE') ||
        name.startsWith('LICENCE') ||
        name.startsWith('COPYING');
  }).toList()..sort((a, b) => a.path.length.compareTo(b.path.length));
  return candidates.isEmpty ? null : candidates.first;
}

/// The result of the check of one package.
class PackageResult {
  PackageResult(this.package, this.licences, this.problems);

  final LockedPackage package;
  final Set<String> licences;
  final List<String> problems;
}

/// Checks [packages]. [roots] gives the directory of each package;
/// [flutterRoot] is the Flutter SDK, for the packages of `source: sdk`.
List<PackageResult> check({
  required List<LockedPackage> packages,
  required Map<String, Directory> roots,
  required Directory? flutterRoot,
  required Set<String> allowed,
  required List<String> forbidden,
}) {
  final sdkLicences = flutterRoot == null
      ? <String>{}
      : identifyLicences(
          File('${flutterRoot.path}/LICENSE').readAsStringSync(),
        );
  return [
    for (final package in packages)
      () {
        final problems = <String>[];
        final banned = forbiddenMatches(package.name, forbidden);
        if (banned.isNotEmpty) {
          problems.add('forbidden package (pattern ${banned.join(', ')})');
        }
        Set<String> licences;
        if (package.source == 'sdk') {
          licences = sdkLicences;
          if (licences.isEmpty) {
            problems.add('licence of the Flutter SDK not recognised');
          }
        } else {
          final root = roots[package.name];
          final file = root == null ? null : licenceFile(root);
          if (file == null) {
            licences = {};
            problems.add('no licence file (is `flutter pub get` done?)');
          } else {
            licences = identifyLicences(file.readAsStringSync());
            if (licences.isEmpty) {
              problems.add('licence not recognised in ${file.path}');
            }
          }
        }
        final refused = licences.difference(allowed);
        if (refused.isNotEmpty) {
          problems.add('licence not allowed: ${refused.join(', ')}');
        }
        return PackageResult(package, licences, problems);
      }(),
  ];
}

/// The directory of each package, from .dart_tool/package_config.json.
Map<String, Directory> packageRoots(File config) {
  final json = jsonDecode(config.readAsStringSync()) as Map<String, dynamic>;
  final base = config.uri;
  return {
    for (final entry
        in (json['packages'] as List<dynamic>).cast<Map<String, dynamic>>())
      entry['name'] as String: Directory.fromUri(
        base.resolve(entry['rootUri'] as String),
      ),
  };
}

/// The Flutter SDK of the current `flutter` or `dart` command.
Directory? findFlutterRoot() {
  final fromEnv = Platform.environment['FLUTTER_ROOT'];
  if (fromEnv != null && fromEnv.isNotEmpty) return Directory(fromEnv);
  // dart is <flutter>/bin/cache/dart-sdk/bin/dart.
  var dir = File(Platform.resolvedExecutable).parent;
  for (var i = 0; i < 6; i++) {
    if (File('${dir.path}/bin/flutter').existsSync() &&
        File('${dir.path}/LICENSE').existsSync()) {
      return dir;
    }
    dir = dir.parent;
  }
  return null;
}

/// Runs the check on the project in [projectDir]; returns the results.
List<PackageResult> checkProject(Directory projectDir) {
  final p = projectDir.path;
  return check(
    packages: parseLock(File('$p/pubspec.lock').readAsStringSync()),
    roots: packageRoots(File('$p/.dart_tool/package_config.json')),
    flutterRoot: findFlutterRoot(),
    allowed: readList('$p/tool/licenses/allowed-licenses.txt').toSet(),
    forbidden: readList('$p/tool/licenses/forbidden-packages.txt'),
  );
}

/// SHA-256 of [data], in lower-case hexadecimal (FIPS 180-4). Written here so
/// that the check needs no package.
String sha256Hex(List<int> data) {
  const k = [
    0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, //
    0x923f82a4, 0xab1c5ed5, 0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3,
    0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174, 0xe49b69c1, 0xefbe4786,
    0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
    0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147,
    0x06ca6351, 0x14292967, 0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13,
    0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85, 0xa2bfe8a1, 0xa81a664b,
    0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
    0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a,
    0x5b9cca4f, 0x682e6ff3, 0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208,
    0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2,
  ];
  final h = [
    0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a, //
    0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19,
  ];
  int rotr(int x, int n) => ((x >> n) | (x << (32 - n))) & 0xffffffff;
  final bitLength = data.length * 8;
  final padded = [...data, 0x80];
  while (padded.length % 64 != 56) {
    padded.add(0);
  }
  for (var i = 7; i >= 0; i--) {
    padded.add((bitLength >> (8 * i)) & 0xff);
  }
  final w = List<int>.filled(64, 0);
  for (var chunk = 0; chunk < padded.length; chunk += 64) {
    for (var i = 0; i < 16; i++) {
      final j = chunk + 4 * i;
      w[i] =
          (padded[j] << 24) |
          (padded[j + 1] << 16) |
          (padded[j + 2] << 8) |
          padded[j + 3];
    }
    for (var i = 16; i < 64; i++) {
      final s0 = rotr(w[i - 15], 7) ^ rotr(w[i - 15], 18) ^ (w[i - 15] >> 3);
      final s1 = rotr(w[i - 2], 17) ^ rotr(w[i - 2], 19) ^ (w[i - 2] >> 10);
      w[i] = (w[i - 16] + s0 + w[i - 7] + s1) & 0xffffffff;
    }
    var [a, b, c, d, e, f, g, hh] = h;
    for (var i = 0; i < 64; i++) {
      final s1 = rotr(e, 6) ^ rotr(e, 11) ^ rotr(e, 25);
      final ch = (e & f) ^ (~e & 0xffffffff & g);
      final t1 = (hh + s1 + ch + k[i] + w[i]) & 0xffffffff;
      final s0 = rotr(a, 2) ^ rotr(a, 13) ^ rotr(a, 22);
      final maj = (a & b) ^ (a & c) ^ (b & c);
      final t2 = (s0 + maj) & 0xffffffff;
      hh = g;
      g = f;
      f = e;
      e = (d + t1) & 0xffffffff;
      d = c;
      c = b;
      b = a;
      a = (t1 + t2) & 0xffffffff;
    }
    for (final (i, v) in [a, b, c, d, e, f, g, hh].indexed) {
      h[i] = (h[i] + v) & 0xffffffff;
    }
  }
  return h.map((v) => v.toRadixString(16).padLeft(8, '0')).join();
}

/// The result of the check of one bundled asset (a font file).
class AssetResult {
  AssetResult(this.path, this.licences, this.problems);

  final String path;
  final Set<String> licences;
  final List<String> problems;
}

/// Checks the font files of [fontsDir] against the table of its README.md:
/// every file has a row, its SHA-256 is the one of the row, and the licence
/// file the row names exists and holds only allowed licences.
List<AssetResult> checkFonts(Directory fontsDir, Set<String> allowed) {
  if (!fontsDir.existsSync()) return [];
  final readme = File('${fontsDir.path}/README.md');
  final rows = <String, ({String sha, String licence})>{};
  if (readme.existsSync()) {
    final row = RegExp(
      r'^\| `([^`]+)` \|[^|]*\| `([0-9a-f]{64})` \| `([^`]+)` \|$',
      multiLine: true,
    );
    for (final m in row.allMatches(readme.readAsStringSync())) {
      rows[m.group(1)!] = (sha: m.group(2)!, licence: m.group(3)!);
    }
  }
  final files =
      fontsDir
          .listSync()
          .whereType<File>()
          .where((f) => RegExp(r'\.(ttf|otf)$').hasMatch(f.path))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));
  return [
    for (final file in files)
      () {
        final name = file.uri.pathSegments.last;
        final problems = <String>[];
        var licences = <String>{};
        final row = rows[name];
        if (row == null) {
          problems.add('not in ${readme.path}');
        } else {
          if (sha256Hex(file.readAsBytesSync()) != row.sha) {
            problems.add('SHA-256 differs from ${readme.path}');
          }
          final licence = File('${fontsDir.path}/${row.licence}');
          if (!licence.existsSync()) {
            problems.add('no licence file ${row.licence}');
          } else {
            licences = identifyLicences(licence.readAsStringSync());
            if (licences.isEmpty) problems.add('licence not recognised');
          }
        }
        final refused = licences.difference(allowed);
        if (refused.isNotEmpty) {
          problems.add('licence not allowed: ${refused.join(', ')}');
        }
        return AssetResult(file.path, licences, problems);
      }(),
  ];
}

/// Checks the bundled fonts of the project in [projectDir].
List<AssetResult> checkProjectFonts(Directory projectDir) => checkFonts(
  Directory('${projectDir.path}/assets/fonts'),
  readList('${projectDir.path}/tool/licenses/allowed-licenses.txt').toSet(),
);

void main() {
  final fonts = checkProjectFonts(Directory.current);
  var refusedFonts = 0;
  for (final r in fonts) {
    final licences = r.licences.isEmpty ? '?' : r.licences.join(' AND ');
    final status = r.problems.isEmpty ? 'ok' : 'FAIL: ${r.problems.join('; ')}';
    stdout.writeln('${r.path} [bundled font] $licences: $status');
    if (r.problems.isNotEmpty) refusedFonts++;
  }
  stdout.writeln(
    '${fonts.length} bundled fonts checked, $refusedFonts refused.',
  );
  if (refusedFonts > 0) exitCode = 1;
  final results = checkProject(Directory.current);
  var failed = 0;
  for (final r in results) {
    final p = r.package;
    final licences = r.licences.isEmpty
        ? '?'
        : (r.licences.toList()..sort()).join(' AND ');
    final where = p.source == 'sdk' ? 'Flutter SDK' : p.source;
    final status = r.problems.isEmpty ? 'ok' : 'FAIL: ${r.problems.join('; ')}';
    stdout.writeln(
      '${p.name} ${p.version} [${p.dependency}, $where] $licences: $status',
    );
    if (r.problems.isNotEmpty) failed++;
  }
  stdout.writeln('${results.length} packages checked, $failed refused.');
  if (results.isEmpty || failed > 0) exitCode = 1;
}
