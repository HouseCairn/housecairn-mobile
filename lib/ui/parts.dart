// SPDX-License-Identifier: AGPL-3.0-only

import 'package:material_ui/material_ui.dart';

import '../data/repository.dart';
import '../design/adaptive.dart';
import '../design/theme.dart';
import '../design/tokens.dart';
import '../design/widgets.dart';
import '../domain/day.dart';
import '../l10n/app_localizations.dart';
import 'messages.dart';
import 'state.dart';

/// Loads what a screen shows from the repository and loads it again each time
/// the data of the app changes ([AppState.revision]): a screen shows what is
/// stored now, whoever changed it.
class DataView<T> extends StatefulWidget {
  const DataView({
    super.key,
    required this.load,
    required this.builder,
    this.reloadKey,
  });

  final Future<T> Function(Repository repository) load;

  /// When it changes the data is read again, the previous data staying on
  /// screen until the new arrives (a list that follows a search).
  final Object? reloadKey;
  final Widget Function(BuildContext context, T data) builder;

  @override
  State<DataView<T>> createState() => _DataViewState<T>();
}

class _DataViewState<T> extends State<DataView<T>> {
  T? _data;
  int _revision = -1;
  int _reads = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = AppScope.of(context);
    if (state.revision != _revision) {
      _revision = state.revision;
      _load(state.repository);
    }
  }

  @override
  void didUpdateWidget(DataView<T> old) {
    super.didUpdateWidget(old);
    if (widget.reloadKey != old.reloadKey) {
      _load(AppScope.of(context).repository);
    }
  }

  Future<void> _load(Repository repository) async {
    final read = ++_reads;
    final data = await widget.load(repository);
    // A later read was asked for while this one ran: its answer wins.
    if (mounted && read == _reads) setState(() => _data = data);
  }

  @override
  Widget build(BuildContext context) {
    final data = _data;
    return data == null
        ? const SizedBox.shrink()
        : widget.builder(context, data as T);
  }
}

/// Runs a change of the repository and then reads the data again; a refusal
/// is shown in a bar. `true` when the change was made.
Future<bool> runChange(
  BuildContext context,
  Future<void> Function(Repository repository) change,
) async {
  final state = AppScope.of(context);
  try {
    await change(state.repository);
  } on Refused catch (refused) {
    if (context.mounted) showRefusal(context, refused);
    return false;
  }
  await state.refresh();
  return true;
}

/// A text field with its label above, as the web draws it.
Widget hcText(
  String label,
  TextEditingController controller, {
  Key? key,
  int minLines = 1,
  int maxLines = 1,
  TextInputType? keyboard,
  String? Function(String?)? validator,
  bool sentences = true,
  bool enabled = true,
}) => HcField(
  label: label,
  child: TextFormField(
    key: key,
    controller: controller,
    enabled: enabled,
    minLines: minLines,
    maxLines: maxLines,
    keyboardType: keyboard,
    textCapitalization: sentences
        ? TextCapitalization.sentences
        : TextCapitalization.none,
    validator: validator,
  ),
);

/// A list of choices with its label above.
Widget hcChoice<T>(
  String label,
  T value,
  List<(T, String)> choices,
  ValueChanged<T> onChanged, {
  Key? key,
  bool enabled = true,
  bool wrap = false,
}) => HcField(
  label: label,
  child: HcSelect<T>(
    key: key,
    value: value,
    choices: choices,
    onChanged: onChanged,
    enabled: enabled,
    wrap: wrap,
  ),
);

/// A date the person chooses, from [initial], within [dateSpanYears] of
/// today unless [first] is given: the picker of the platform (D5).
Future<Day?> pickDay(BuildContext context, {Day? initial, Day? first}) async {
  final today = AppScope.of(context).repository.today();
  final picked = await hcPickDate(
    context,
    initial: asDateTime(initial ?? today),
    first: asDateTime(first ?? today.addYears(-dateSpanYears)),
    last: asDateTime(today.addYears(dateSpanYears)),
  );
  return picked == null ? null : Day.of(picked);
}

/// A date with its label above, in the look of a field: the date, a calendar
/// icon, the picker of the platform on a tap and, when it may be removed, a
/// button that removes it (design lot D5, T8 of the audit).
class HcDateField extends StatelessWidget {
  const HcDateField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    required this.noDate,
    this.clearable = true,
  });

  final String label;
  final Day? value;
  final ValueChanged<Day?> onChanged;

  /// What is shown when there is no date.
  final String noDate;

  /// Whether the date may be removed (a movement always has one).
  final bool clearable;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return HcField(
      label: label,
      child: HcDateInput(
        text: value == null ? noDate : formatDay(context, value!),
        empty: value == null,
        chooseLabel: l10n.taskChooseDate,
        onTap: () async {
          final picked = await pickDay(context, initial: value);
          if (picked != null) onChanged(picked);
        },
        onClear: value != null && clearable ? () => onChanged(null) : null,
        clearLabel: l10n.taskClearDate,
      ),
    );
  }
}

/// The confirmation before something is deleted: the danger button, as for a
/// home. `true` when the person confirmed.
Future<bool> confirmDelete(
  BuildContext context, {
  required String title,
  required String body,
}) async {
  final l10n = AppLocalizations.of(context);
  final confirmed = await showHcDialog<bool>(
    context,
    (context) => HcDialog(
      scrollable: true,
      title: title,
      content: Text(body),
      actions: [
        HcDialogAction(
          label: l10n.cancel,
          kind: HcDialogKind.cancel,
          onPressed: () => Navigator.of(context).pop(false),
        ),
        HcDialogAction(
          label: l10n.delete,
          kind: HcDialogKind.danger,
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}

/// A line "label: value" of the facts of a card, as the web's `.facts`.
class HcFact extends StatelessWidget {
  const HcFact(this.label, this.value, {super.key});

  final String label;
  final Widget value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: HcSpace.s3),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: HcText.fieldLabel),
        const SizedBox(height: HcSpace.s1),
        value,
      ],
    ),
  );
}

/// The text of a fact.
Widget factText(String text) => Text(text, style: HcText.body);
