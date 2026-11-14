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
// - a package has no licence file, or one whose licence is not recognised.
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
    'permission is hereby granted, free of charge, to any person obtaining a copy',
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

void main() {
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
