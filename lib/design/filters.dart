// SPDX-License-Identifier: AGPL-3.0-only

import 'dart:async';

import 'package:cupertino_ui/cupertino_ui.dart'
    show CupertinoTextField, showCupertinoModalPopup;
import 'package:material_ui/material_ui.dart';

import '../l10n/app_localizations.dart';
import 'icons.dart';
import 'theme.dart';
import 'tokens.dart';
import 'widgets.dart';

// The filters and the search of a list (`design/patterns.md` of the web,
// "Filters and search"; design lot D13): segmented tabs for the state, a
// search field that follows what is typed, and a sheet "Filters (2)" for the
// other criteria. One component for every list, so that the same need is not
// drawn three ways: the tasks, the history and the stock use [HcFilterBar] and
// [showHcFilterSheet].

/// The pause after the last key before a search is made (the web's
/// `live_typing` waits 300 ms).
const hcSearchDelay = Duration(milliseconds: 300);

/// The tabs, the search field and the button of the sheet of filters of a
/// list, one under the other (the web's `filter_tabs` and `filter-bar`).
///
/// The search field is [searchController]'s: [onSearch] is called with the
/// text [hcSearchDelay] after the last key, at once on Enter and when the
/// field is emptied. The button "Filters (n)" is drawn when [filterCount] is
/// given, n being the criteria of the sheet that apply.
class HcFilterBar extends StatefulWidget {
  const HcFilterBar({
    super.key,
    required this.tabLabels,
    required this.currentTab,
    required this.onTab,
    required this.searchController,
    required this.searchLabel,
    required this.onSearch,
    this.searchKey,
    this.tabsKey,
    this.filterCount,
    this.onFilters,
    this.filtersKey,
  });

  final List<String> tabLabels;
  final int currentTab;
  final ValueChanged<int> onTab;
  final Key? tabsKey;

  final TextEditingController searchController;

  /// What the field searches, read by screen readers ("Search by name,
  /// reference or supplier"); the field itself says "Search".
  final String searchLabel;
  final ValueChanged<String> onSearch;
  final Key? searchKey;

  /// How many criteria of the sheet apply, or `null` without a sheet.
  final int? filterCount;
  final VoidCallback? onFilters;
  final Key? filtersKey;

  @override
  State<HcFilterBar> createState() => _HcFilterBarState();
}

class _HcFilterBarState extends State<HcFilterBar> {
  Timer? _pause;

  @override
  void dispose() {
    _pause?.cancel();
    super.dispose();
  }

  void _typed(String text) {
    _pause?.cancel();
    _pause = Timer(hcSearchDelay, () => widget.onSearch(text));
  }

  void _now(String text) {
    _pause?.cancel();
    widget.onSearch(text);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final count = widget.filterCount;
    final search = _SearchField(
      key: widget.searchKey,
      controller: widget.searchController,
      label: widget.searchLabel,
      hint: l10n.historySearch,
      clearLabel: l10n.searchClear,
      onChanged: _typed,
      onSubmitted: _now,
    );
    final button = count == null
        ? null
        : OutlinedButton(
            key: widget.filtersKey,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, HcLayout.touchTargetLg),
            ),
            onPressed: widget.onFilters,
            child: Text(
              count > 0 ? l10n.filtersCount(count) : l10n.historyFilters,
              textAlign: TextAlign.center,
            ),
          );
    // Side by side while there is room; one under the other at large text.
    final stacked = MediaQuery.textScalerOf(context).scale(16) > 22;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        HcTabs(
          key: widget.tabsKey,
          labels: widget.tabLabels,
          current: widget.currentTab,
          onSelect: widget.onTab,
        ),
        if (button == null)
          Padding(
            padding: const EdgeInsets.only(bottom: HcSpace.s3),
            child: search,
          )
        else if (stacked)
          Padding(
            padding: const EdgeInsets.only(bottom: HcSpace.s3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                search,
                const SizedBox(height: HcSpace.s2),
                button,
              ],
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.only(bottom: HcSpace.s3),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: search),
                const SizedBox(width: HcSpace.s2),
                button,
              ],
            ),
          ),
      ],
    );
  }
}

/// The search field of the platform (row 10 of the adaptations): the one of
/// iOS on an iPhone, a Material field on Android; the magnifier inside, the
/// button that empties it, nothing else.
class _SearchField extends StatelessWidget {
  const _SearchField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.clearLabel,
    required this.onChanged,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final String clearLabel;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    if (hcCupertino(Theme.of(context).platform)) {
      // The field of iOS: a rounded grey field, the magnifier inside, the
      // button that empties it while there is text. Drawn from the text field
      // of iOS with the icons of the app, which ships no font of icons of iOS.
      return Semantics(
        label: label,
        child: ListenableBuilder(
          listenable: controller,
          builder: (context, _) => CupertinoTextField(
            controller: controller,
            placeholder: hint,
            style: HcText.body,
            placeholderStyle: HcText.body.copyWith(color: HcColors.textMuted),
            textInputAction: TextInputAction.search,
            maxLength: 120,
            minLines: 1,
            padding: const EdgeInsets.symmetric(
              horizontal: HcSpace.s2,
              vertical: HcSpace.s3,
            ),
            decoration: BoxDecoration(
              color: const Color(0x1F767680),
              borderRadius: BorderRadius.circular(HcRadius.md),
            ),
            prefix: const Padding(
              padding: EdgeInsets.only(left: HcSpace.s2),
              child: HcIcon(HcIcons.search, color: HcColors.textMuted),
            ),
            suffix: controller.text.isEmpty
                ? null
                : IconButton(
                    key: const Key('search-clear'),
                    tooltip: clearLabel,
                    onPressed: () {
                      controller.clear();
                      onSubmitted('');
                    },
                    icon: const HcIcon(
                      HcIcons.clear,
                      color: HcColors.textMuted,
                    ),
                  ),
            onChanged: onChanged,
            onSubmitted: onSubmitted,
          ),
        ),
      );
    }
    return Semantics(
      label: label,
      textField: true,
      child: ListenableBuilder(
        listenable: controller,
        builder: (context, _) => TextField(
          controller: controller,
          textInputAction: TextInputAction.search,
          maxLength: 120,
          buildCounter: (
            _, {
            required currentLength,
            required isFocused,
            required maxLength,
          }) => null,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: const SizedBox.square(
              dimension: HcLayout.touchTargetLg,
              child: Center(
                child: HcIcon(HcIcons.search, color: HcColors.textMuted),
              ),
            ),
            suffixIcon: controller.text.isEmpty
                ? null
                : IconButton(
                    key: const Key('search-clear'),
                    tooltip: clearLabel,
                    onPressed: () {
                      controller.clear();
                      onSubmitted('');
                    },
                    icon: const HcIcon(
                      HcIcons.clear,
                      color: HcColors.textMuted,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

/// The sheet "Filters (n)" of a list: the sheet of iOS from the bottom on an
/// iPhone, the bottom sheet of Material on Android. [builder] draws the
/// criteria and is given a function to call when one of them changed, so that
/// the sheet draws itself again; [count] says how many apply, [onClear]
/// removes them all. The list behind follows every change, as the web's does.
Future<void> showHcFilterSheet(
  BuildContext context, {
  required int Function() count,
  required VoidCallback onClear,
  required Widget Function(BuildContext context, VoidCallback refresh) builder,
}) {
  Widget sheet(BuildContext context) =>
      _FilterSheet(count: count, onClear: onClear, builder: builder);
  if (hcCupertino(Theme.of(context).platform)) {
    return showCupertinoModalPopup<void>(
      context: context,
      builder: (context) =>
          Material(type: MaterialType.transparency, child: sheet(context)),
    );
  }
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: HcColors.surface,
    builder: sheet,
  );
}

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({
    required this.count,
    required this.onClear,
    required this.builder,
  });

  final int Function() count;
  final VoidCallback onClear;
  final Widget Function(BuildContext context, VoidCallback refresh) builder;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final count = widget.count();
    final height = MediaQuery.sizeOf(context).height;
    final bar = HcText.button.copyWith(color: HcColors.primary);
    return ColoredBox(
      color: HcColors.surface,
      child: SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: height * 0.85),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DecoratedBox(
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: HcColors.border)),
                ),
                // Wraps rather than overflows when the text is very large.
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    TextButton(
                      key: const Key('filters-sheet-clear'),
                      // Nothing to clear: the button keeps its place.
                      onPressed: count == 0
                          ? null
                          : () {
                              widget.onClear();
                              _refresh();
                            },
                      child: Text(
                        l10n.historyClear,
                        style: count == 0
                            ? bar.copyWith(color: HcColors.textMuted)
                            : bar,
                      ),
                    ),
                    TextButton(
                      key: const Key('filters-sheet-done'),
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(l10n.pickerDone, style: bar),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    HcSpace.s4,
                    HcSpace.s3,
                    HcSpace.s4,
                    HcSpace.s2,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: HcSpace.s3),
                        child: Semantics(
                          header: true,
                          child: Text(
                            key: const Key('filters-sheet-title'),
                            count > 0
                                ? l10n.filtersCount(count)
                                : l10n.historyFilters,
                            style: HcText.cardTitle,
                          ),
                        ),
                      ),
                      widget.builder(context, _refresh),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// What a list says when a search or a filter emptied it: the sentence of the
/// empty state, and a button that removes them all and shows everything again.
class HcNoMatch extends StatelessWidget {
  const HcNoMatch({super.key, required this.text, required this.onClear});

  final String text;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      HcEmpty(text),
      HcAddButton(
        key: const Key('filters-clear-all'),
        label: AppLocalizations.of(context).filtersClearAll,
        primary: false,
        gap: HcSpace.s2,
        onPressed: onClear,
      ),
    ],
  );
}
