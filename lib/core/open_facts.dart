// SPDX-License-Identifier: AGPL-3.0-only

import 'dart:async';
import 'dart:typed_data';

import '../domain/barcode_lookup.dart';
import '../domain/gtin.dart';

/// Why a read of an open database got no answer.
class OpenFactsUnreachable implements Exception {
  const OpenFactsUnreachable(this.reason);

  /// `offline`, `status`, `too_large`, `other_host`, `certificate`.
  final String reason;

  @override
  String toString() => 'OpenFactsUnreachable($reason)';
}

/// The one way the phone alone reaches a network (docs/adr/0015): a `GET`
/// of the read API of Open Products Facts or Open Food Facts, with the code
/// in its address and nothing else, or of a photo they publish. The app's
/// implementation is `IoOpenFactsHttp` (`open_facts_http_io.dart`); the
/// tests give a fake, and no test calls a real host.
abstract interface class OpenFactsHttp {
  /// The body of a `200` at [url], of at most [maxBytes]. Any other status,
  /// a redirect, another host than those of [lookupSources], no answer in
  /// time: [OpenFactsUnreachable].
  Future<Uint8List> get(
    Uri url, {
    required String accept,
    required int maxBytes,
  });
}

/// The most bytes read of an answer and of a photo (`barcodes/online.py`).
const lookupAnswerMaxBytes = 1024 * 1024;
const lookupImageMaxBytes = 5 * 1024 * 1024;

/// Asks the sources, in their order, what [code] is (`barcodes/online.py`):
/// the first that knows it answers, then its photo is read. A source that
/// cannot be read is skipped; none read at all is [LookupState.offline].
/// Called only when the person scanned or typed a code and allowed the
/// lookup (docs/adr/0015).
Future<BarcodeAnswer> lookUpAlone(OpenFactsHttp http, String code) async {
  if (!isValidGtin(code)) return BarcodeAnswer(code, LookupState.failed);
  var answered = false;
  for (final source in lookupSources) {
    final Uint8List body;
    try {
      body = await http.get(
        lookupUrl(source, code),
        accept: 'application/json',
        maxBytes: lookupAnswerMaxBytes,
      );
    } on OpenFactsUnreachable catch (e) {
      // A 404 is an answer: the source does not know the code.
      if (e.reason == 'status') answered = true;
      continue;
    }
    answered = true;
    final found = parseOpenFacts(source, code, body);
    if (found == null) continue;
    if (found.imageUrl.isEmpty) return found.withPhoto(null);
    try {
      return found.withPhoto(
        await http.get(
          Uri.parse(found.imageUrl),
          accept: 'image/jpeg,image/png,image/webp',
          maxBytes: lookupImageMaxBytes,
        ),
      );
    } on OpenFactsUnreachable {
      return found.withPhoto(null);
    }
  }
  return BarcodeAnswer(
    code,
    answered ? LookupState.notFound : LookupState.offline,
  );
}
