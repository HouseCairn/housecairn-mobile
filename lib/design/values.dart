// SPDX-License-Identifier: AGPL-3.0-only

import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:material_ui/material_ui.dart';

import 'theme.dart';
import 'tokens.dart';
import 'widgets.dart';

/// The text styles of the figures of a card, as the web draws them
/// (`.facts`, `.table-stack`, `.stock-quantity`, `.small`), measured by
/// test/web_parity_values_test.dart.
abstract final class HcValueText {
  /// `.facts dt`: the label of a value, 14/400, muted.
  static const label = TextStyle(
    fontFamily: HcFont.family,
    fontSize: HcFont.sizeSm,
    fontWeight: HcFont.regular,
    height: HcFont.lineHeight,
    color: HcColors.textMuted,
  );

  /// `.facts dd`: the value, 16/600, at the right.
  static const value = TextStyle(
    fontFamily: HcFont.family,
    fontSize: HcFont.sizeBase,
    fontWeight: HcFont.medium,
    height: HcFont.lineHeight,
    color: HcColors.text,
  );

  /// `.table-stack td::before`: the label of a figure of a budget table, 13/400.
  static const denseLabel = TextStyle(
    fontFamily: HcFont.family,
    fontSize: HcFont.sizeXs,
    fontWeight: HcFont.regular,
    height: HcFont.lineHeight,
    color: HcColors.textMuted,
  );

  /// `.table-stack td`: the figure of a budget table, 14/400.
  static const denseValue = TextStyle(
    fontFamily: HcFont.family,
    fontSize: HcFont.sizeSm,
    fontWeight: HcFont.regular,
    height: HcFont.lineHeight,
    color: HcColors.text,
  );

  /// `.stock-quantity strong`: the figure, 32/700.
  static const figure = TextStyle(
    fontFamily: HcFont.family,
    fontSize: HcFont.size2xl,
    fontWeight: HcFont.bold,
    height: HcFont.lineHeight,
    color: HcColors.text,
  );

  /// The unit after the figure: body text.
  static const unit = HcText.body;

  /// `.small` next to a gauge: 13/400, muted.
  static const note = TextStyle(
    fontFamily: HcFont.family,
    fontSize: HcFont.sizeXs,
    fontWeight: HcFont.regular,
    height: HcFont.lineHeight,
    color: HcColors.textMuted,
  );
}

/// A label at the left and its value at the right, the web's `.facts > div`.
///
/// The value keeps up to 60 % of the width, as on the web (`max-width: 60%`),
/// and the label wraps in what is left. Only when the line cannot hold them
/// (the longest word of the label beside the value, or a value wider than
/// 60 %), at a large text size, the value goes under the label, at the left.
/// [dense] is a figure of a budget table (`.table-stack td`).
class HcValueRow extends StatelessWidget {
  const HcValueRow(
    this.label,
    this.value, {
    super.key,
    this.child,
    this.dense = false,
  });

  final String label;

  /// The value as a text; [child] replaces it with a widget (a pill).
  final String value;
  final Widget? child;
  final bool dense;

  @override
  Widget build(BuildContext context) => MergeSemantics(
    child: _ValueLine(
      gap: dense ? HcSpace.s3 : HcSpace.s4,
      under: HcSpace.s1,
      children: [
        Text(label, style: dense ? HcValueText.denseLabel : HcValueText.label),
        child ??
            // On one line, the value is laid at the right in one line of its
            // own width; under the label, it starts at the left.
            Text(
              value,
              style: dense ? HcValueText.denseValue : HcValueText.value,
            ),
      ],
    ),
  );
}

/// Rows of [HcValueRow], separated by a line, as the web's `dl.facts`: 12
/// above and under each row, none above the first nor under the last.
class HcValueList extends StatelessWidget {
  const HcValueList({super.key, required this.children, this.dense = false});

  final List<Widget> children;

  /// The figures of a budget table: 4 above and under, no line.
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final pad = dense ? HcSpace.s1 : HcSpace.s3;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (i, row) in children.indexed)
          DecoratedBox(
            decoration: BoxDecoration(
              border: i == 0 || dense
                  ? null
                  : const Border(
                      top: BorderSide(
                        color: HcColors.border,
                        width: HcComponent.borderWidth,
                      ),
                    ),
            ),
            child: Padding(
              padding: EdgeInsets.only(
                // The line above a row takes its width, as a CSS border.
                top: dense
                    ? pad
                    : i == 0
                    ? 0
                    : pad + HcComponent.borderWidth,
                bottom: i == children.length - 1 && !dense ? 0 : pad,
              ),
              child: row,
            ),
          ),
      ],
    );
  }
}

/// A figure and its unit, with a pill of its state after them, the web's
/// `.stock-quantity`.
class HcFigure extends StatelessWidget {
  const HcFigure(this.figure, {super.key, this.unit = '', this.pill});

  final String figure;
  final String unit;
  final HcPill? pill;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: HcSpace.s2,
    runSpacing: HcSpace.s1,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      MergeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(figure, style: HcValueText.figure),
            if (unit.isNotEmpty) ...[
              const SizedBox(width: HcSpace.s2),
              Flexible(child: Text(unit, style: HcValueText.unit)),
            ],
          ],
        ),
      ),
      ?pill,
    ],
  );
}

/// A gauge of [percent] (none above 100 drawn), in the primary colour on the
/// muted surface, in the warning colour beyond 100 %, with its text at the
/// right ([text], \"56 % spent\"): the web's `progress` and its `.small`.
class HcProgress extends StatelessWidget {
  const HcProgress({
    super.key,
    required this.percent,
    required this.text,
    required this.label,
  });

  final int percent;
  final String text;

  /// What the gauge measures, for screen readers.
  final String label;

  static const height = HcSpace.s2;

  @override
  Widget build(BuildContext context) {
    final over = percent > 100;
    final shown = math.min(math.max(percent, 0), 100) / 100;
    return Semantics(
      label: label,
      value: text,
      excludeSemantics: true,
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(HcRadius.pill),
              child: SizedBox(
                height: height,
                child: ColoredBox(
                  color: HcColors.surfaceMuted,
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: FractionallySizedBox(
                      widthFactor: shown,
                      heightFactor: 1,
                      child: ColoredBox(
                        color: over ? HcColors.warning : HcColors.primary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: HcSpace.s2),
          Flexible(child: Text(text, style: HcValueText.note)),
        ],
      ),
    );
  }
}

/// Two children, a label and a value, on one line when it holds them,
/// else one under the other (see [HcValueRow]).
class _ValueLine extends MultiChildRenderObjectWidget {
  const _ValueLine({
    required this.gap,
    required this.under,
    required super.children,
  });

  final double gap;
  final double under;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderValueLine(gap, under, Directionality.of(context));

  @override
  void updateRenderObject(BuildContext context, _RenderValueLine renderObject) {
    renderObject
      ..gap = gap
      ..under = under
      ..textDirection = Directionality.of(context);
  }
}

class _ValueLineData extends ContainerBoxParentData<RenderBox> {}

/// Whether a label and a value hold on one line of [width]: the value within
/// 60 % of it, and the longest word of the label beside the value.
bool valuesHoldOnOneLine({
  required double width,
  required double labelMinWidth,
  required double valueWidth,
  required double gap,
}) => valueWidth <= width * 0.6 && labelMinWidth + gap + valueWidth <= width;

class _RenderValueLine extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _ValueLineData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _ValueLineData> {
  _RenderValueLine(this._gap, this._under, this._textDirection);

  double _gap;
  set gap(double v) {
    if (v == _gap) return;
    _gap = v;
    markNeedsLayout();
  }

  double _under;
  set under(double v) {
    if (v == _under) return;
    _under = v;
    markNeedsLayout();
  }

  TextDirection _textDirection;
  set textDirection(TextDirection v) {
    if (v == _textDirection) return;
    _textDirection = v;
    markNeedsLayout();
  }

  /// Whether the last layout put the value under the label.
  bool stacked = false;

  RenderBox get _label => firstChild!;
  RenderBox get _value => lastChild!;

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _ValueLineData) {
      child.parentData = _ValueLineData();
    }
  }

  @override
  double computeMinIntrinsicWidth(double height) => math.max(
    _label.getMinIntrinsicWidth(double.infinity),
    _value.getMinIntrinsicWidth(double.infinity),
  );

  @override
  double computeMaxIntrinsicWidth(double height) =>
      _label.getMaxIntrinsicWidth(double.infinity) +
      _gap +
      _value.getMaxIntrinsicWidth(double.infinity);

  @override
  double computeMinIntrinsicHeight(double width) =>
      _measure(width, dry: true).height;

  @override
  double computeMaxIntrinsicHeight(double width) =>
      _measure(width, dry: true).height;

  @override
  Size computeDryLayout(covariant BoxConstraints constraints) =>
      constraints.constrain(_measure(constraints.maxWidth, dry: true));

  Size _measure(double width, {required bool dry}) {
    final valueWidth = _value.getMaxIntrinsicWidth(double.infinity);
    final labelMin = _label.getMinIntrinsicWidth(double.infinity);
    final oneLine = valuesHoldOnOneLine(
      width: width,
      labelMinWidth: labelMin,
      valueWidth: valueWidth,
      gap: _gap,
    );
    Size lay(RenderBox child, BoxConstraints c) => dry
        ? child.getDryLayout(c)
        : (child..layout(c, parentUsesSize: true)).size;
    if (oneLine) {
      final value = lay(_value, BoxConstraints(maxWidth: width * 0.6));
      final label = lay(
        _label,
        BoxConstraints(maxWidth: math.max(0, width - _gap - value.width)),
      );
      if (!dry) {
        stacked = false;
        // The first lines of both on one baseline, as `align-items: baseline`.
        final lb = _label.getDistanceToBaseline(TextBaseline.alphabetic) ?? 0;
        final vb = _value.getDistanceToBaseline(TextBaseline.alphabetic) ?? 0;
        final base = math.max(lb, vb);
        final ltr = _textDirection == TextDirection.ltr;
        (_label.parentData! as _ValueLineData).offset = Offset(
          ltr ? 0 : width - label.width,
          base - lb,
        );
        (_value.parentData! as _ValueLineData).offset = Offset(
          ltr ? width - value.width : 0,
          base - vb,
        );
        return Size(
          width,
          math.max(base - lb + label.height, base - vb + value.height),
        );
      }
      return Size(width, math.max(label.height, value.height));
    }
    final label = lay(_label, BoxConstraints(maxWidth: width));
    final value = lay(_value, BoxConstraints(maxWidth: width));
    if (!dry) {
      stacked = true;
      final ltr = _textDirection == TextDirection.ltr;
      (_label.parentData! as _ValueLineData).offset = Offset(
        ltr ? 0 : width - label.width,
        0,
      );
      (_value.parentData! as _ValueLineData).offset = Offset(
        ltr ? 0 : width - value.width,
        label.height + _under,
      );
    }
    return Size(width, label.height + _under + value.height);
  }

  @override
  void performLayout() {
    size = constraints.constrain(_measure(constraints.maxWidth, dry: false));
  }

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) =>
      defaultComputeDistanceToFirstActualBaseline(baseline);

  @override
  void paint(PaintingContext context, Offset offset) =>
      defaultPaint(context, offset);

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);
}
