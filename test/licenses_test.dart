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
