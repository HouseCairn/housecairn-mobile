// SPDX-License-Identifier: AGPL-3.0-only

import 'dart:convert';
import 'dart:io';

/// The release and commit of the web a measure of its rendering may name:
/// the pin of `web_parity` in tool/web_alignment.json, or the earlier one
/// the reference test/parity/web_fr_390.json says it still carries, when the
/// pin moved for a screen measured alone (`tool/web_parity.py --only`). A
/// measure taken at any other release is stale.
Set<(String, String)> parityReleases() {
  final pin =
      (jsonDecode(File('tool/web_alignment.json').readAsStringSync())
              as Map<String, dynamic>)['elements']['web_parity']
          as Map<String, dynamic>;
  final reference = jsonDecode(
    File('test/parity/web_fr_390.json').readAsStringSync(),
  ) as Map<String, dynamic>;
  final carried = reference['carried'] as Map<String, dynamic>?;
  return {
    (pin['release'] as String, pin['commit'] as String),
    if (carried != null)
      (carried['release'] as String, carried['commit'] as String),
  };
}
