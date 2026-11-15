// SPDX-License-Identifier: AGPL-3.0-only

import 'clock.dart';

/// The hybrid logical clock of this phone, for the writes it makes
/// (docs/adr/0003-sync-protocol.md, docs/protocol.md section 1): 48 bits of
/// milliseconds since 1970-01-01 UTC and 16 bits of counter, written as 16
/// lowercase hexadecimal digits so that string order is numeric order.
///
/// Lot 2a only sends: each local write gets a clock greater than every clock
/// this phone gave before, even when the phone's time goes backwards. The
/// receive rule (a clock of another phone, the 24 h limit) comes with the
/// sync engine in lot 4.
class Hlc {
  Hlc(this._clock, {int last = 0})
    : _last = last; // ignore: prefer_initializing_formals

  final Clock _clock;
  int _last;

  /// The greatest clock given so far.
  int get last => _last;

  /// A new clock, greater than [last].
  int next() {
    final physical = _clock.now().millisecondsSinceEpoch << 16;
    _last = physical > _last ? physical : _last + 1;
    return _last;
  }

  /// 24 hours in milliseconds: a received clock further ahead of this
  /// phone's time is kept with its field but never adopted.
  static const maxAheadMs = 24 * 60 * 60 * 1000;

  /// Takes [remote], the clock of an operation of another phone (Kulkarni et
  /// al., receive rule): the next local clock is greater than it, unless it
  /// is more than [maxAheadMs] ahead of this phone's time, so that a phone
  /// with a wrong date cannot push the others into the future. Returns
  /// whether it was adopted.
  bool receive(int remote) {
    final physicalMs = _clock.now().millisecondsSinceEpoch;
    if ((remote >> 16) > physicalMs + maxAheadMs) return false;
    final physical = physicalMs << 16;
    final seen = remote > _last ? remote : _last;
    _last = physical > seen ? physical : seen + 1;
    return true;
  }

  static String format(int hlc) => hlc.toRadixString(16).padLeft(16, '0');

  static int parse(String text) => int.parse(text, radix: 16);
}
