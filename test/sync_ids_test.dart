// SPDX-License-Identifier: AGPL-3.0-only

// The deterministic ids of docs/adr/0003-sync-protocol.md against the
// vectors the web publishes (web ADR 0077): `test/fixtures/sync_ids.json` is
// a copy, byte for byte, of `tests/fixtures/sync_ids.json` of
// HouseCairn/housecairn at f5bba7c6dcca77380b1544bfc5e0dd5542223b31 (#153),
// not yet in a release of the web; tool/web_alignment.json pins it once the
// release that brings the sync API exists (lot 4b).

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:housecairn_mobile/data/repository.dart';

String idOf(String row, String home, Map<String, Object?> inputs) {
  String text(String key) => inputs[key]! as String;
  return switch (row) {
    'successor' => Repository.successorId(home, text('occurrence')),
    'material' => StockRepository.materialId(
      home,
      text('task'),
      text('article'),
    ),
    'draw' => StockRepository.drawId(home, text('occurrence'), text('article')),
    'envelope' => BudgetRepository.envelopeId(home, inputs['year']! as int),
    'link' => switch (text('entity')) {
      'projects.project_rooms' => BudgetRepository.projectRoomId(
        home,
        text('owner'),
        text('other'),
      ),
      'stock.article_rooms' => StockRepository.articleRoomId(
        home,
        text('owner'),
        text('other'),
      ),
      'stock.article_compatible_items' => StockRepository.articleItemId(
        home,
        text('owner'),
        text('other'),
      ),
      final other => throw StateError('No link table $other in the app'),
    },
    _ => throw StateError('No row $row in the app'),
  };
}

void main() {
  final document = jsonDecode(
    File('test/fixtures/sync_ids.json').readAsStringSync(),
  ) as Map<String, Object?>;
  final vectors = (document['vectors']! as List).cast<Map<String, Object?>>();

  test('the vectors of the web are there, every row of ADR 0003', () {
    expect(document['version'], 1);
    expect(vectors.map((v) => v['row']).toSet(), {
      'successor',
      'material',
      'draw',
      'envelope',
      'link',
    });
  });

  for (final (i, vector) in vectors.indexed) {
    test('vector $i (${vector['row']}): the app makes the web\'s id', () {
      final id = idOf(
        vector['row']! as String,
        vector['home']! as String,
        (vector['inputs']! as Map).cast<String, Object?>(),
      );
      expect(id, vector['id']);
    });
  }

  test('a year of an envelope has four decimal digits', () {
    expect(
      () => BudgetRepository.envelopeId(
        '6f1b2c3d-4e5f-4a6b-8c7d-9e0f1a2b3c4d',
        10000,
      ),
      throwsArgumentError,
    );
  });
}
