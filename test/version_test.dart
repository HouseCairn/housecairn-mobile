// SPDX-License-Identifier: AGPL-3.0-only

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:housecairn_mobile/version.dart';

void main() {
  test(
    'appVersion is the version of pubspec.yaml, without the build number',
    () {
      final line = File('pubspec.yaml')
          .readAsLinesSync()
          .firstWhere((line) => line.startsWith('version: '));
      expect(line.substring('version: '.length).split('+').first, appVersion);
    },
  );
}
