// SPDX-License-Identifier: AGPL-3.0-only

import 'package:flutter_test/flutter_test.dart';
import 'package:housecairn_mobile/core/clock.dart';

void main() {
  test('the system clock gives UTC instants and a local day without time', () {
    const Clock clock = SystemClock();
    expect(clock.now().isUtc, isTrue);
    final today = clock.today();
    expect(
      [today.hour, today.minute, today.second, today.millisecond],
      [0, 0, 0, 0],
    );
    expect(today.isUtc, isFalse);
  });

  test('a fixed clock returns its instant and moves only when told', () {
    final clock = FixedClock(DateTime.utc(2027, 2, 28, 23, 30));
    expect(clock.now(), DateTime.utc(2027, 2, 28, 23, 30));
    clock.advance(const Duration(hours: 1));
    expect(clock.now(), DateTime.utc(2027, 3, 1, 0, 30));
    final local = clock.now().toLocal();
    expect(clock.today(), DateTime(local.year, local.month, local.day));
  });
}
