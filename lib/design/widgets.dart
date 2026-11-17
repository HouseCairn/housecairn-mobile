// SPDX-License-Identifier: AGPL-3.0-only

import 'package:material_ui/material_ui.dart';

import 'icons.dart';
import 'page.dart';
import 'theme.dart';
import 'tokens.dart';

export 'page.dart';

/// The components of the web application (`static/css/components.css`,
/// `tasks.css`), for the screens of the app. A screen uses these, or the
/// themed Material widgets (buttons, fields, the bar, the undo bar), and no
/// colour or size of its own (test/design_rules_test.dart).

/// The heading of a group of rows (`h2`): small capitals, muted, or in the
/// danger colour for what is overdue (`.section-overdue`).
class HcSectionHeading extends StatelessWidget {
  const HcSectionHeading(this.text, {super.key, this.danger = false});

  final String text;
  final bool danger;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(
      HcSpace.s1,
      HcSpace.s6,
      HcSpace.s1,
      HcSpace.s2,
    ),
    child: Semantics(
      header: true,
      child: Text(
        text.toUpperCase(),
        semanticsLabel: text,
        style: HcText.sectionHeading.copyWith(
          color: danger ? HcColors.danger : HcColors.textMuted,
        ),
      ),
    ),
  );
}

/// A list in a card (`.card-list`, `.task-list`): white, a border, large
/// corners, a line between rows.
class HcCardList extends StatelessWidget {
  const HcCardList({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: HcColors.surface,
      border: Border.all(color: HcColors.border),
      borderRadius: BorderRadius.circular(HcRadius.lg),
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(HcRadius.lg),
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final (i, child) in children.indexed) ...[
              if (i > 0) const Divider(),
              child,
            ],
          ],
        ),
      ),
    ),
  );
}

/// A card (`.card`): white, a border, large corners, padding.
class HcCard extends StatelessWidget {
  const HcCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: HcColors.surface,
      border: Border.all(color: HcColors.border),
      borderRadius: BorderRadius.circular(HcRadius.lg),
    ),
    child: Padding(padding: const EdgeInsets.all(HcSpace.s4), child: child),
  );
}

/// A row of a list (`.row`): a title, a line of text, pills, and at the end
/// a chevron when it opens a screen. The whole row is the touch target.
class HcRow extends StatelessWidget {
  const HcRow({
    super.key,
    required this.title,
    this.text,
    this.pills = const [],
    this.moreText,
    this.leading,
    this.trailing,
    this.onTap,
  });

  final String title;
  final String? text;
  final List<Widget> pills;

  /// A second line of text, under the pills (`.row-text` after `.pill`).
  final String? moreText;
  final Widget? leading;

  /// Defaults to a chevron when the row opens something.
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final end =
        trailing ??
        (onTap == null
            ? null
            : const HcIcon(
                HcIcons.chevron,
                size: HcComponent.chevronSize,
                color: HcColors.textMuted,
              ));
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: HcComponent.rowMinHeight),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: HcSpace.s4,
            vertical: HcSpace.s3,
          ),
          child: Row(
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: HcSpace.s3),
              ],
              Expanded(
                child: _RowBody(
                  title: title,
                  text: text,
                  pills: pills,
                  moreText: moreText,
                ),
              ),
              if (end != null) ...[const SizedBox(width: HcSpace.s3), end],
            ],
          ),
        ),
      ),
    );
  }
}

class _RowBody extends StatelessWidget {
  const _RowBody({
    required this.title,
    this.text,
    this.pills = const [],
    this.moreText,
  });

  final String title;
  final String? text;
  final List<Widget> pills;
  final String? moreText;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(title, style: HcText.rowTitle),
      if (text != null && text!.isNotEmpty) ...[
        const SizedBox(height: HcComponent.rowTextGap),
        Text(text!, style: HcText.rowText),
      ],
      if (pills.isNotEmpty) ...[
        const SizedBox(height: HcSpace.s1),
        Wrap(spacing: HcSpace.s2, runSpacing: HcSpace.s1, children: pills),
      ],
      if (moreText != null && moreText!.isNotEmpty) ...[
        const SizedBox(height: HcComponent.rowTextGap),
        Text(moreText!, style: HcText.rowText),
      ],
    ],
  );
}

/// A task in a list (`.task-row`): the row, which opens the task, and the
/// Done button of one tap; overdue, the row is in the danger colour.
/// [onMore] adds a menu button for the other actions of the row.
class HcTaskRow extends StatelessWidget {
  const HcTaskRow({
    super.key,
    required this.title,
    this.text,
    this.pill,
    this.extraPills = const [],
    this.overdue = false,
    required this.doneLabel,
    this.onDone,
    this.onTap,
    this.more,
  });

  final String title;
  final String? text;
  final Widget? pill;

  /// Pills after [pill], on the same line when they fit.
  final List<Widget> extraPills;
  final bool overdue;
  final String doneLabel;
  final VoidCallback? onDone;
  final VoidCallback? onTap;

  /// The menu of the other actions (skip, postpone), if any.
  final Widget? more;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: overdue ? HcColors.dangerSoft : HcColors.surface,
    child: Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: HcComponent.rowMinHeight,
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  HcSpace.s4,
                  HcSpace.s3,
                  HcSpace.s2,
                  HcSpace.s3,
                ),
                child: _RowBody(
                  title: title,
                  text: text,
                  pills: [?pill, ...extraPills],
                ),
              ),
            ),
          ),
        ),
        if (onDone != null)
          FilledButton(
            onPressed: onDone,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: HcSpace.s3,
                vertical: HcSpace.s2,
              ),
              textStyle: HcText.buttonSmall,
            ),
            child: Text(doneLabel),
          ),
        if (more != null) more! else const SizedBox(width: HcSpace.s3),
      ],
    ),
  );
}

/// The tone of a [HcPill] (`.pill-*`).
enum HcPillTone {
  neutral(HcColors.primary, HcColors.sageSoft),
  success(HcColors.success, HcColors.successSoft),
  danger(HcColors.danger, HcColors.dangerSoft),
  warning(HcColors.warning, HcColors.warningSoft),
  info(HcColors.info, HcColors.infoSoft),
  sand(HcColors.textSand, HcColors.sandSoft),
  ghost(HcColors.textMuted, null);

  const HcPillTone(this.foreground, this.background);

  final Color foreground;

  /// `null`: no fill, a border (`.pill-ghost`).
  final Color? background;
}

/// A pill (`.pill`): a short state, such as the date of a task.
class HcPill extends StatelessWidget {
  const HcPill(this.label, {super.key, this.tone = HcPillTone.neutral});

  final String label;
  final HcPillTone tone;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: tone.background,
      border: tone.background == null
          ? Border.all(color: HcColors.borderStrong)
          : null,
      borderRadius: BorderRadius.circular(HcRadius.pill),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: HcComponent.pillPaddingX,
        vertical: HcComponent.pillPaddingY,
      ),
      child: Text(label, style: HcText.pill.copyWith(color: tone.foreground)),
    ),
  );
}

/// The empty state of a list (`.empty`): a dashed frame, centred muted text.
class HcEmpty extends StatelessWidget {
  const HcEmpty(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: const _DashedFrame(),
    child: Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: HcSpace.s4,
        vertical: HcSpace.s6,
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: HcText.body.copyWith(color: HcColors.textMuted),
      ),
    ),
  );
}

class _DashedFrame extends CustomPainter {
  const _DashedFrame();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = HcColors.borderStrong
      ..style = PaintingStyle.stroke
      ..strokeWidth = HcComponent.borderWidth;
    final frame = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          (Offset.zero & size).deflate(HcComponent.borderWidth / 2),
          const Radius.circular(HcRadius.lg),
        ),
      );
    for (final metric in frame.computeMetrics()) {
      for (var d = 0.0; d < metric.length; d += HcSpace.s2) {
        canvas.drawPath(metric.extractPath(d, d + HcSpace.s1), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DashedFrame old) => false;
}

/// A form field with its label above it, as on the web (`label`, then the
/// field), instead of a label inside the field.
class HcField extends StatelessWidget {
  const HcField({super.key, required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: HcSpace.s3),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: HcText.fieldLabel),
        const SizedBox(height: HcSpace.s1),
        child,
      ],
    ),
  );
}

/// The action of an app bar (Save): a text button in the small size of the
/// web (`.button-small`), so that it leaves room for the back button and the
/// title.
class HcBarAction extends StatelessWidget {
  const HcBarAction({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  // Its text grows with the text size of the phone up to 1.3 times, as the
  // buttons of the navigation bar of iOS do: larger, it would push the back
  // button and the title out of the bar.
  //
  // The label is the web's, word for word ("Send the report"): never cut, it
  // is drawn smaller when it does not fit next to the back button.
  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: BoxConstraints(
      maxWidth:
          MediaQuery.sizeOf(context).width - HcComponent.appbarMinHeight * 2,
    ),
    child: MediaQuery.withClampedTextScaling(
      maxScaleFactor: 1.3,
      child: TextButton(
        style: TextButton.styleFrom(textStyle: HcText.buttonSmall),
        onPressed: onPressed,
        child: FittedBox(fit: BoxFit.scaleDown, child: Text(label)),
      ),
    ),
  );
}

/// The style of a small button (`.button-small`): text at 14, padding of 8
/// and 12, the touch target of the theme (48) kept.
ButtonStyle hcSmallButtonStyle() => OutlinedButton.styleFrom(
  padding: const EdgeInsets.symmetric(
    horizontal: HcSpace.s3,
    vertical: HcSpace.s2,
  ),
  textStyle: HcText.buttonSmall,
);

/// The style of the button of an action that destroys (`.button-danger`).
ButtonStyle hcDangerStyle() => FilledButton.styleFrom(
  backgroundColor: HcColors.danger,
  foregroundColor: HcColors.textInverse,
);

/// The button that deletes a record, at the end of its form or page: the web's
/// `.button.button-danger.button-block`, filled in the danger colour and the
/// width of the column, the one style of Delete (design/patterns.md of the web,
/// Forms). Not an outlined button, whatever the record.
class HcDeleteButton extends StatelessWidget {
  const HcDeleteButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: HcSpace.s4),
    child: FilledButton(
      style: hcDangerStyle(),
      onPressed: onPressed,
      child: Text(label),
    ),
  );
}

/// The button that adds to a list, after it, as on the web (`.button`,
/// `.button-block`): primary or secondary, the width of the column or of its
/// label, a gap of `--hc-space-3` above it. Not a floating button: the web
/// has none, and a floating button covers the last row.
class HcAddButton extends StatelessWidget {
  const HcAddButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.primary = true,
    this.block = true,
    this.gap = HcSpace.s3,
  });

  final String label;
  final VoidCallback onPressed;
  final bool primary;
  final bool block;

  /// The space above: 12 after a list, 8 after an empty state (the web's
  /// margins, measured in test/web_parity_test.dart).
  final double gap;

  @override
  Widget build(BuildContext context) {
    final child = Text(label, textAlign: TextAlign.center);
    final button = primary
        ? FilledButton(onPressed: onPressed, child: child)
        : OutlinedButton(onPressed: onPressed, child: child);
    return Padding(
      padding: EdgeInsets.only(top: gap),
      child: block
          ? button
          : Align(alignment: AlignmentDirectional.centerStart, child: button),
    );
  }
}

/// The list of a screen: the margins of `.content`, and room at the end for
/// the undo bar.
class HcScreenList extends StatelessWidget {
  const HcScreenList({super.key, required this.children});

  final List<Widget> children;

  // The title of the screen ([HcScaffold]) is its first line, as the `h1` of
  // a page of the web (design/patterns.md, Header).
  @override
  Widget build(BuildContext context) {
    final title = HcPageTitle.of(context);
    final below = HcPageTitle.belowOf(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        HcSpace.s4,
        HcSpace.s2,
        HcSpace.s4,
        HcSpace.s12 + HcSpace.s12,
      ),
      children: [
        if (title != null) HcLargeTitle(title),
        // The selector of the home, a compact line under the `h1` of a
        // section root.
        ?below,
        ...children,
      ],
    );
  }
}

/// A banner of the page (`.undo-banner`, `tasks.css`): sage-soft on a
/// border, the text at the left and its action at the right on the same
/// line, 12 px (`space-3`) under it. The text takes the room the action does
/// not (the action at most three fifths of the line); from a text size of
/// 1.3 the action goes under the text.
class HcBanner extends StatelessWidget {
  const HcBanner({super.key, required this.child, required this.action});

  final Widget child;
  final Widget action;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: HcSpace.s3),
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: HcColors.sageSoft,
        border: Border.all(color: HcColors.border),
        borderRadius: BorderRadius.circular(HcRadius.md),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: HcSpace.s4,
          vertical: HcSpace.s2,
        ),
        // Side by side up to a text size of 1.3, as the field pairs (ADR
        // 0011); beyond, the action under the text, which would break its
        // words in the share it has left.
        child: MediaQuery.textScalerOf(context).scale(1) > 1.3
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  child,
                  const SizedBox(height: HcSpace.s2),
                  action,
                ],
              )
            : LayoutBuilder(
                builder: (context, constraints) => Row(
                  children: [
                    Expanded(child: child),
                    const SizedBox(width: HcSpace.s3),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: constraints.maxWidth * 3 / 5,
                      ),
                      child: action,
                    ),
                  ],
                ),
              ),
      ),
    ),
  );
}

/// The tabs of a section (`components/tabs.html`, `.tabs-fit`): sister
/// screens side by side, each a target of 48, the current one in bold with
/// the accent line under it; a line under the whole bar.
class HcTabs extends StatelessWidget {
  const HcTabs({
    super.key,
    required this.labels,
    required this.current,
    required this.onSelect,
  });

  final List<String> labels;
  final int current;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: HcSpace.s3),
    child: DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: HcColors.border)),
      ),
      child: Row(
        children: [
          for (final (i, label) in labels.indexed)
            Expanded(
              child: Semantics(
                selected: i == current,
                button: true,
                child: InkWell(
                  onTap: i == current ? null : () => onSelect(i),
                  child: Container(
                    constraints: const BoxConstraints(
                      minHeight: HcLayout.touchTargetLg,
                    ),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(
                      horizontal: HcSpace.s1,
                      vertical: HcSpace.s2,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: i == current
                              ? HcColors.accent
                              : Colors.transparent,
                          // 3 px on the web (`.tab`).
                          width: HcComponent.borderWidth * 3,
                        ),
                      ),
                    ),
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: i == current ? HcText.tabCurrent : HcText.tab,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    ),
  );
}

/// A folded section of a form, the web's `details.form-section`: a triangle
/// and a title (16/700) that open or fold what is optional. It starts open
/// when one of its fields has a value ([open]).
class HcFoldSection extends StatefulWidget {
  const HcFoldSection({
    super.key,
    required this.title,
    required this.children,
    this.open = false,
  });

  final String title;
  final List<Widget> children;
  final bool open;

  @override
  State<HcFoldSection> createState() => _HcFoldSectionState();
}

class _HcFoldSectionState extends State<HcFoldSection> {
  late bool _open = widget.open;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: HcSpace.s3),
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: HcColors.surface,
        border: Border.all(color: HcColors.border),
        borderRadius: BorderRadius.circular(HcRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            button: true,
            expanded: _open,
            child: InkWell(
              borderRadius: BorderRadius.circular(HcRadius.lg),
              onTap: () => setState(() => _open = !_open),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: HcComponent.rowMinHeight,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: HcSpace.s4,
                    vertical: HcSpace.s3,
                  ),
                  child: Row(
                    children: [
                      ExcludeSemantics(
                        child: Icon(
                          _open ? Icons.arrow_drop_down : Icons.arrow_right,
                          color: HcColors.text,
                        ),
                      ),
                      const SizedBox(width: HcSpace.s1),
                      Expanded(
                        child: Text(widget.title, style: HcText.cardTitle),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (_open)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                HcSpace.s4,
                0,
                HcSpace.s4,
                HcSpace.s4,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: widget.children,
              ),
            ),
        ],
      ),
    ),
  );
}

/// A link in a line of text, as the web's `a`: primary, underlined, a touch
/// target of the height of a row.
class HcLink extends StatelessWidget {
  const HcLink(this.text, {super.key, required this.onTap});

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    link: true,
    child: InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: HcLayout.touchTargetLg),
        child: Align(
          widthFactor: 1,
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            text,
            style: HcText.rowText.copyWith(
              color: HcColors.primary,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ),
    ),
  );
}
