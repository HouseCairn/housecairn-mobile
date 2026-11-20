// SPDX-License-Identifier: AGPL-3.0-only

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Fails when the choice [text] that the select [select] shows is not read
/// whole in its field: ended in an ellipsis, cut at the bottom by a field
/// lower than its lines (the dense button of Android's menu, one line high),
/// or drawn past the edges of the field. A choice cut without an ellipsis
/// overflows nothing, so only its laid out height tells it.
void expectChoiceWhole(
  WidgetTester tester,
  Finder select,
  String text,
  String where,
) {
  final shown = tester
      .renderObjectList<RenderParagraph>(
        find.descendant(of: select, matching: find.byType(RichText)),
      )
      .where((p) => p.text.toPlainText() == text)
      .toList();
  expect(shown, hasLength(1), reason: '$where: « $text » is not shown');
  final paragraph = shown.single;
  expect(
    paragraph.didExceedMaxLines,
    isFalse,
    reason: '$where: « $text » ends in an ellipsis',
  );
  final needed = paragraph.getMaxIntrinsicHeight(paragraph.size.width);
  expect(
    paragraph.size.height,
    greaterThanOrEqualTo(needed - 0.5),
    reason:
        '$where: « $text » needs ${needed.toStringAsFixed(1)} px, '
        'its field gives it ${paragraph.size.height.toStringAsFixed(1)}',
  );
  final box = MatrixUtils.transformRect(
    paragraph.getTransformTo(null),
    Offset.zero & paragraph.size,
  );
  final field = tester.getRect(
    find.descendant(of: select, matching: find.byType(InputDecorator)).first,
  );
  expect(
    field.inflate(0.5).contains(box.topLeft) &&
        field.inflate(0.5).contains(box.bottomRight),
    isTrue,
    reason: '$where: « $text » ($box) goes out of its field ($field)',
  );
}
