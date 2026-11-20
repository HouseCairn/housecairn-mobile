// SPDX-License-Identifier: AGPL-3.0-only

import 'package:cupertino_ui/cupertino_ui.dart'
    show
        CupertinoActionSheet,
        CupertinoActionSheetAction,
        CupertinoAlertDialog,
        CupertinoButton,
        CupertinoDatePicker,
        CupertinoDatePickerMode,
        CupertinoDialogAction,
        CupertinoPicker,
        CupertinoSwitch,
        showCupertinoModalPopup;
import 'package:material_ui/material_ui.dart';

import '../l10n/app_localizations.dart';
import 'icons.dart';
import 'theme.dart';
import 'tokens.dart';
import 'widgets.dart';

// The controls that follow the platform (design lot D5; `design/patterns.md`
// of the web, "Platform adaptations", rows 1 to 4): on an iPhone the pickers,
// the alerts and the switch of iOS, on Android those of Material. One API for
// the screens, which never ask which platform they run on; the colours, the
// font and the sizes stay those of the tokens on both.

/// Whether the controls of iOS are drawn ([hcCupertino] of the header): the
/// platform of the theme, which follows the phone (and
/// `debugDefaultTargetPlatformOverride` in tests).
bool _ios(BuildContext context) => hcCupertino(Theme.of(context).platform);

/// The height iOS gives its wheel pickers (`UIDatePicker`, `UIPickerView`).
const _wheelHeight = 216.0;

/// The height of a line of a wheel, as `CupertinoPicker`'s own default.
const _wheelItemExtent = 36.0;

/// A date chosen by the person, or `null` when they cancel: the date picker of
/// iOS in a sheet with Cancel and Done on an iPhone, the calendar of Material
/// on Android.
Future<DateTime?> hcPickDate(
  BuildContext context, {
  required DateTime initial,
  required DateTime first,
  required DateTime last,
}) async {
  if (!_ios(context)) {
    return showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: last,
    );
  }
  var chosen = initial;
  final done = await _showWheelSheet(
    context,
    CupertinoDatePicker(
      key: const Key('hc-date-wheel'),
      mode: CupertinoDatePickerMode.date,
      initialDateTime: initial,
      minimumDate: first,
      maximumDate: last,
      onDateTimeChanged: (value) => chosen = value,
    ),
  );
  return done ? DateUtils.dateOnly(chosen) : null;
}

/// One of [choices] chosen by the person, as a record so that a `null` choice
/// differs from a cancel: the wheel of iOS in a sheet on an iPhone. Android
/// draws the menu of [HcSelect] itself.
Future<(T,)?> _pickFromWheel<T>(
  BuildContext context,
  List<(T, String)> choices,
  T value,
) async {
  var index = choices.indexWhere((c) => c.$1 == value);
  if (index < 0) index = 0;
  final controller = FixedExtentScrollController(initialItem: index);
  final done = await _showWheelSheet(
    context,
    CupertinoPicker(
      key: const Key('hc-select-wheel'),
      scrollController: controller,
      itemExtent: _wheelItemExtent,
      onSelectedItemChanged: (i) => index = i,
      children: [
        for (final (_, text) in choices)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: HcSpace.s4),
              child: Text(
                text,
                style: HcText.picker,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
      ],
    ),
  );
  controller.dispose();
  return done ? (choices[index].$1,) : null;
}

/// A sheet of iOS from the bottom: Cancel at the left of its bar, Done at the
/// right, then [picker]. `true` when the person pressed Done.
Future<bool> _showWheelSheet(BuildContext context, Widget picker) async {
  final l10n = AppLocalizations.of(context);
  final done = await showCupertinoModalPopup<bool>(
    context: context,
    builder: (context) => ColoredBox(
      color: HcColors.surface,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DecoratedBox(
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: HcColors.border)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    key: const Key('hc-sheet-cancel'),
                    padding: const EdgeInsets.symmetric(horizontal: HcSpace.s4),
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(
                      l10n.cancel,
                      style: HcText.button.copyWith(
                        color: HcColors.primary,
                        fontWeight: HcFont.regular,
                      ),
                    ),
                  ),
                  CupertinoButton(
                    key: const Key('hc-sheet-done'),
                    padding: const EdgeInsets.symmetric(horizontal: HcSpace.s4),
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text(
                      l10n.pickerDone,
                      style: HcText.button.copyWith(color: HcColors.primary),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: _wheelHeight, child: picker),
          ],
        ),
      ),
    ),
  );
  return done ?? false;
}

/// A list of choices in the look of a field (`HcSelect` of
/// `design/patterns.md`): the menu of Material on Android, as before; on an
/// iPhone a field that opens the wheel of iOS in a sheet. [onChanged] is
/// called with the new choice; the field shows [value], which the screen
/// keeps.
class HcSelect<T> extends StatelessWidget {
  const HcSelect({
    super.key,
    required this.value,
    required this.choices,
    required this.onChanged,
    this.validator,
    this.enabled = true,
    this.wrap = false,
  });

  final T value;
  final List<(T, String)> choices;
  final ValueChanged<T> onChanged;
  final FormFieldValidator<T>? validator;
  final bool enabled;

  /// Whether the choice shown on iOS wraps, its words whole (HcWholeWords),
  /// rather than end in an ellipsis on one line: for a list whose choices
  /// are sentences (Add a contractor…), read whole on the narrow phone with
  /// large text.
  final bool wrap;

  @override
  Widget build(BuildContext context) {
    if (!_ios(context)) {
      return DropdownButtonFormField<T>(
        initialValue: value,
        isExpanded: true,
        items: [
          for (final (choice, text) in choices)
            DropdownMenuItem(value: choice, child: Text(text)),
        ],
        validator: validator,
        onChanged: enabled ? (v) => onChanged(v as T) : null,
      );
    }
    String? text;
    for (final (choice, label) in choices) {
      if (choice == value) text = label;
    }
    return FormField<T>(
      initialValue: value,
      validator: validator == null ? null : (_) => validator!(value),
      builder: (field) => Semantics(
        button: true,
        enabled: enabled,
        child: InkWell(
          borderRadius: BorderRadius.circular(HcRadius.md),
          onTap: enabled
              ? () async {
                  final picked = await _pickFromWheel(context, choices, value);
                  if (picked == null) return;
                  field.didChange(picked.$1);
                  onChanged(picked.$1);
                }
              : null,
          child: InputDecorator(
            isEmpty: false,
            decoration: InputDecoration(
              enabled: enabled,
              errorText: field.errorText,
              suffixIcon: const _FieldIcon(HcIcons.chevronDown),
            ),
            child: wrap
                ? HcWholeWords(text ?? '', style: HcText.body)
                : Text(
                    text ?? '',
                    style: HcText.body,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
          ),
        ),
      ),
    );
  }
}

/// The icon at the end of a field, muted, in the size of the icons.
class _FieldIcon extends StatelessWidget {
  const _FieldIcon(this.icon);

  final HcIcons icon;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: HcLayout.touchTargetLg,
    child: Center(child: HcIcon(icon, color: HcColors.textMuted)),
  );
}

/// A date in the look of a field (`HcDateField` of `design/patterns.md`,
/// T8 of the audit): the date of the phone's language, a calendar icon, the
/// picker of the platform on a tap, and a button that removes the date when
/// [onClear] is given. Both platforms draw the field; only the picker
/// differs.
class HcDateInput extends StatelessWidget {
  const HcDateInput({
    super.key,
    required this.text,
    required this.empty,
    required this.onTap,
    required this.chooseLabel,
    this.onClear,
    this.clearLabel,
  });

  /// What the field shows: the date, or what is said when there is none.
  final String text;

  /// Whether there is no date (the text is then muted).
  final bool empty;
  final VoidCallback onTap;

  /// What a screen reader says the field does.
  final String chooseLabel;
  final VoidCallback? onClear;
  final String? clearLabel;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    hint: chooseLabel,
    child: InkWell(
      borderRadius: BorderRadius.circular(HcRadius.md),
      onTap: onTap,
      child: InputDecorator(
        isEmpty: false,
        decoration: InputDecoration(
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (onClear != null)
                IconButton(
                  key: const Key('hc-date-clear'),
                  tooltip: clearLabel,
                  onPressed: onClear,
                  icon: const HcIcon(HcIcons.clear, color: HcColors.textMuted),
                ),
              const _FieldIcon(HcIcons.calendar),
            ],
          ),
        ),
        child: Text(
          text,
          // Wraps at large text sizes: a date is never cut.
          style: empty
              ? HcText.body.copyWith(color: HcColors.textMuted)
              : HcText.body,
        ),
      ),
    ),
  );
}

/// What a dialog action does, for its look: [cancel] goes back (bold on iOS,
/// as iOS marks the safe choice), [plain] does the work, [danger] destroys
/// (the danger button on Android, the danger colour on iOS).
enum HcDialogKind { cancel, plain, danger }

/// A button of an [HcDialog].
class HcDialogAction {
  const HcDialogAction({
    required this.label,
    required this.onPressed,
    this.kind = HcDialogKind.plain,
    this.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final HcDialogKind kind;
  final Key? key;
}

/// Shows [builder] as the dialog of the platform: an alert of iOS on an
/// iPhone, the dialog of Material on Android.
Future<T?> showHcDialog<T>(BuildContext context, WidgetBuilder builder) =>
    showAdaptiveDialog<T>(
      context: context,
      barrierDismissible: true,
      builder: builder,
    );

/// A confirmation, an alert or a short form: the alert of iOS on an iPhone,
/// the dialog of Material on Android (row 3 of the adaptations).
class HcDialog extends StatelessWidget {
  const HcDialog({
    super.key,
    required this.title,
    this.content,
    required this.actions,
    this.scrollable = false,
  });

  final String title;
  final Widget? content;
  final List<HcDialogAction> actions;

  /// Whether the content scrolls (large text sizes), on Android.
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    if (!_ios(context)) {
      return AlertDialog(
        scrollable: scrollable,
        title: Text(title),
        content: content,
        // A label of one word is never cut in two, even at twice the size
        // on a narrow phone: it comes down in size instead.
        actions: [
          for (final a in actions)
            a.kind == HcDialogKind.danger
                ? FilledButton(
                    key: a.key,
                    style: hcDangerStyle(),
                    onPressed: a.onPressed,
                    child: HcWholeWord(a.label),
                  )
                : TextButton(
                    key: a.key,
                    onPressed: a.onPressed,
                    child: HcWholeWord(a.label),
                  ),
        ],
      );
    }
    final body = content;
    return CupertinoAlertDialog(
      title: Text(title, style: HcText.cardTitle, textAlign: TextAlign.center),
      // The fields of a short form are those of Material, in the alert.
      content: body == null
          ? null
          : Material(
              type: MaterialType.transparency,
              // A message is centred, as iOS does; a short form keeps its
              // labels at the start of its fields.
              child: DefaultTextStyle(
                style: HcText.bodySmall,
                textAlign: body is Text ? TextAlign.center : TextAlign.start,
                child: Padding(
                  padding: const EdgeInsets.only(top: HcSpace.s2),
                  child: body,
                ),
              ),
            ),
      actions: [
        for (final a in actions)
          CupertinoDialogAction(
            key: a.key,
            onPressed: a.onPressed,
            isDefaultAction: a.kind == HcDialogKind.cancel,
            isDestructiveAction: a.kind == HcDialogKind.danger,
            child: Text(
              a.label,
              style: HcText.button.copyWith(
                fontWeight: a.kind == HcDialogKind.cancel
                    ? HcFont.bold
                    : HcFont.regular,
                color: a.onPressed == null
                    ? HcColors.textMuted
                    : a.kind == HcDialogKind.danger
                    ? HcColors.danger
                    : HcColors.primary,
              ),
            ),
          ),
      ],
    );
  }
}

/// One of [choices] (key, value, text) chosen in a list of actions, or `null`
/// when cancelled: the action sheet of iOS on an iPhone, a simple dialog of
/// Material on Android.
Future<T?> showHcChoices<T>(
  BuildContext context, {
  required String title,
  required List<(Key?, T, String)> choices,
}) {
  if (!_ios(context)) {
    return showDialog<T>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(title),
        children: [
          for (final (key, value, text) in choices)
            SimpleDialogOption(
              key: key,
              onPressed: () => Navigator.of(context).pop(value),
              child: Text(text, style: HcText.body),
            ),
        ],
      ),
    );
  }
  final l10n = AppLocalizations.of(context);
  final action = HcText.button.copyWith(
    color: HcColors.primary,
    fontWeight: HcFont.regular,
  );
  return showCupertinoModalPopup<T>(
    context: context,
    builder: (context) => CupertinoActionSheet(
      title: Text(title, style: HcText.fieldLabel),
      actions: [
        for (final (key, value, text) in choices)
          CupertinoActionSheetAction(
            key: key,
            onPressed: () => Navigator.of(context).pop(value),
            child: Text(text, style: action),
          ),
      ],
      cancelButton: CupertinoActionSheetAction(
        isDefaultAction: true,
        onPressed: () => Navigator.of(context).pop(),
        child: Text(
          l10n.cancel,
          style: action.copyWith(fontWeight: HcFont.bold),
        ),
      ),
    ),
  );
}

/// A switch: the switch of iOS on an iPhone, in the primary colour; the
/// switch of Material on Android, as the theme draws it (row 4).
class HcSwitch extends StatelessWidget {
  const HcSwitch({super.key, required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) => _ios(context)
      ? CupertinoSwitch(
          value: value,
          onChanged: onChanged,
          activeTrackColor: HcColors.primary,
        )
      : Switch(value: value, onChanged: onChanged);
}
