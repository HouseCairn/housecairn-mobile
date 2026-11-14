// SPDX-License-Identifier: AGPL-3.0-only

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../tool/check_licenses.dart';

const mit = '''
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction.''';

const bsd3 = '''
Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
    * Neither the name of Google LLC nor the names of its
      contributors may be used to endorse or promote products derived
      from this software without specific prior written permission.''';

const gpl = '''
This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License.''';

List<String> forbidden() => readList('tool/licenses/forbidden-packages.txt');

void main() {
  group('identifyLicences', () {
    test('names permissive licences', () {
      expect(identifyLicences(mit), {'MIT'});
      expect(identifyLicences(bsd3), {'BSD-3-Clause'});
      expect(
        identifyLicences(
          'Redistribution and use in source and binary forms, with or without '
          'modification, are permitted provided that the following conditions are met:',
        ),
        {'BSD-2-Clause'},
      );
      expect(identifyLicences('Apache License\n Version 2.0, January 2004'), {
        'Apache-2.0',
      });
    });

    test('names copyleft licences, so that they are refused', () {
      expect(identifyLicences(gpl), {'GPL'});
      expect(identifyLicences('Mozilla Public License Version 2.0'), {'MPL'});
    });

    test('recognises nothing in a text that is no licence', () {
      expect(identifyLicences('All rights reserved.'), isEmpty);
    });
  });

  group('check', () {
    final allowed = readList('tool/licenses/allowed-licenses.txt').toSet();

    List<PackageResult> checkOne(String name, String licence) {
      final dir = Directory.systemTemp.createTempSync('housecairn-licence-');
      addTearDown(() => dir.deleteSync(recursive: true));
      File('${dir.path}/LICENSE').writeAsStringSync(licence);
      return check(
        packages: [LockedPackage(name, '1.0.0', 'transitive', 'hosted')],
        roots: {name: dir},
        flutterRoot: null,
        allowed: allowed,
        forbidden: forbidden(),
      );
    }

    test('passes a package under an allowed licence', () {
      expect(checkOne('some_package', mit).single.problems, isEmpty);
    });

    test('fails a package under a licence that is not allowed', () {
      expect(checkOne('some_package', gpl).single.problems, [
        'licence not allowed: GPL',
      ]);
    });

    test('fails a package whose licence is not recognised', () {
      expect(
        checkOne('some_package', 'All rights reserved.').single.problems.single,
        startsWith('licence not recognised'),
      );
    });

    for (final name in [
      'firebase_analytics',
      'firebase_crashlytics',
      'sentry_flutter',
      'google_mobile_ads',
      'mixpanel_flutter',
      'appsflyer_sdk',
      'amplitude_flutter',
      'posthog_flutter',
    ]) {
      test(
        'fails $name, an analytics or advertising package, even under MIT',
        () {
          expect(
            checkOne(name, mit).single.problems.single,
            startsWith('forbidden package'),
          );
        },
      );
    }

    test('does not refuse the packages the plan takes later', () {
      for (final name in [
        'firebase_messaging',
        'firebase_core',
        'flutter_local_notifications',
        'leak_tracker',
        'in_app_purchase',
        'workmanager',
      ]) {
        expect(forbiddenMatches(name, forbidden()), isEmpty, reason: name);
      }
    });
  });

  test('parseLock reads every package of pubspec.lock', () {
    final text = File('pubspec.lock').readAsStringSync();
    final packages = parseLock(text);
    final names = RegExp(
      r'^  ([A-Za-z0-9_]+):$',
      multiLine: true,
    ).allMatches(text).map((m) => m.group(1)).toList();
    expect(packages.map((p) => p.name).toList(), names);
    expect(packages, isNotEmpty);
    expect(
      packages.firstWhere((p) => p.name == 'drift').dependency,
      'direct main',
    );
  });

  group('bundled fonts', () {
    test('sha256Hex is SHA-256', () {
      expect(
        sha256Hex(const []),
        'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
      );
      expect(
        sha256Hex('abc'.codeUnits),
        'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad',
      );
      // Two blocks of padding (56 bytes and more).
      expect(
        sha256Hex(
          'abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq'.codeUnits,
        ),
        '248d6a61d20638b8e5c026930c3e6039a33ce45964ff2167f6ecedd419db06c1',
      );
    });

    test('names the SIL Open Font License', () {
      expect(
        identifyLicences(
          File('assets/fonts/Manrope-OFL.txt').readAsStringSync(),
        ),
        {'OFL-1.1'},
      );
    });

    test('every font of assets/fonts passes, with its recorded SHA-256', () {
      final results = checkProjectFonts(Directory.current);
      expect(results.map((r) => r.path.split('/').last).toList(), [
        'manrope-bold.ttf',
        'manrope-extrabold.ttf',
        'manrope-regular.ttf',
        'manrope-semibold.ttf',
      ]);
      for (final r in results) {
        expect(r.problems, isEmpty, reason: r.path);
        expect(r.licences, {'OFL-1.1'}, reason: r.path);
      }
    });

    test('fails a font that changed, is not listed, or has no licence', () {
      final dir = Directory.systemTemp.createTempSync('fonts');
      addTearDown(() => dir.deleteSync(recursive: true));
      File('${dir.path}/a.ttf').writeAsStringSync('font a');
      File('${dir.path}/b.ttf').writeAsStringSync('font b');
      File('${dir.path}/c.ttf').writeAsStringSync('font c');
      File('${dir.path}/OFL.txt').writeAsStringSync(
        File('assets/fonts/Manrope-OFL.txt').readAsStringSync(),
      );
      final shaA = sha256Hex('font a'.codeUnits);
      final shaC = sha256Hex('font c'.codeUnits);
      File('${dir.path}/README.md').writeAsStringSync(
        '| `a.ttf` | 400 | `$shaA` | `OFL.txt` |\n'
        '| `c.ttf` | 400 | `$shaC` | `GPL.txt` |\n',
      );
      final results = {
        for (final r in checkFonts(dir, {'OFL-1.1'}))
          r.path.split('/').last: r.problems,
      };
      expect(results['a.ttf'], isEmpty);
      expect(results['b.ttf']!.single, startsWith('not in'));
      expect(results['c.ttf']!.single, 'no licence file GPL.txt');
      File('${dir.path}/a.ttf').writeAsStringSync('font a, changed');
      expect(
        checkFonts(dir, {'OFL-1.1'}).first.problems.single,
        startsWith('SHA-256 differs'),
      );
      expect(
        checkFonts(dir, {'MIT'}).first.problems.last,
        'licence not allowed: OFL-1.1',
      );
    });
  });

  test('every dependency of this project passes the policy', () {
    final results = checkProject(Directory.current);
    final refused = [
      for (final r in results)
        if (r.problems.isNotEmpty)
          '${r.package.name}: ${r.problems.join('; ')}',
    ];
    expect(refused, isEmpty);
    expect(
      results.length,
      parseLock(File('pubspec.lock').readAsStringSync()).length,
    );
  });
}
