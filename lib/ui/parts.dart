// SPDX-License-Identifier: AGPL-3.0-only

import 'package:material_ui/material_ui.dart';

import '../data/repository.dart';
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
  const DataView({super.key, required this.load, required this.builder});

  final Future<T> Function(Repository repository) load;
  final Widget Function(BuildContext context, T data) builder;

  @override
  State<DataView<T>> createState() => _DataViewState<T>();
}

class _DataViewState<T> extends State<DataView<T>> {
  T? _data;
  int _revision = -1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = AppScope.of(context);
    if (state.revision != _revision) {
      _revision = state.revision;
      _load(state.repository);
    }
  }

  Future<void> _load(Repository repository) async {
    final data = await widget.load(repository);
    if (mounted) setState(() => _data = data);
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
}) => HcField(
  label: label,
  child: DropdownButtonFormField<T>(
    key: key,
    initialValue: value,
    isExpanded: true,
    items: [
      for (final (choice, text) in choices)
        DropdownMenuItem(value: choice, child: Text(text)),
    ],
    onChanged: enabled ? (v) => onChanged(v as T) : null,
  ),
);

/// A date with its label above, a button to choose it and one to remove it.
class HcDateField extends StatelessWidget {
  const HcDateField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    required this.noDate,
  });

  final String label;
  final Day? value;
  final ValueChanged<Day?> onChanged;

  /// What is shown when there is no date.
  final String noDate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final repository = AppScope.of(context).repository;
    return HcField(
      label: label,
      child: Wrap(
        spacing: HcSpace.s2,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            value == null ? noDate : formatDay(context, value!),
            style: HcText.body,
          ),
          TextButton(
            onPressed: () async {
              final today = repository.today();
              final picked = await showDatePicker(
                context: context,
                initialDate: asDateTime(value ?? today),
                firstDate: asDateTime(today.addYears(-dateSpanYears)),
                lastDate: asDateTime(today.addYears(dateSpanYears)),
              );
              if (picked != null) onChanged(Day.of(picked));
            },
            child: Text(l10n.taskChooseDate),
          ),
          if (value != null)
            TextButton(
              onPressed: () => onChanged(null),
              child: Text(l10n.taskClearDate),
            ),
        ],
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
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      scrollable: true,
      title: Text(title),
      content: Text(body),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          style: hcDangerStyle(),
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.delete),
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
