// SPDX-License-Identifier: AGPL-3.0-only

import 'dart:async';

import 'package:flutter/semantics.dart';
import 'package:material_ui/material_ui.dart';

import '../data/repository.dart';
import '../design/theme.dart';
import '../design/tokens.dart';
import '../l10n/app_localizations.dart';
import 'messages.dart';
import 'state.dart';

/// How long the typing pauses before a change is saved (`static/js/autosave.js`
/// of the web: 800 ms after the last key).
const autosavePause = Duration(milliseconds: 800);

/// The sheet of an existing row saves itself as it is changed (web ADR 0082):
/// a choice or a date at once, a text after a pause of typing, one write per
/// change through the repository, which writes only the fields that differ.
/// A field the form refuses keeps what was typed and shows its error under
/// it; a refusal of the repository is shown as any other. "Saved" is shown,
/// discreetly, and said by the screen reader. A creation and a deletion keep
/// their button.
mixin AutosaveSheet<T extends StatefulWidget> on State<T> {
  Timer? _timer;
  bool _ready = false;
  bool _saved = false;

  /// The form of the sheet.
  GlobalKey<FormState> get sheetForm;

  /// Whether the sheet is of an existing row (a new one waits for its button).
  bool get existing;

  /// Writes the sheet; throws [Refused] when the repository refuses it.
  Future<void> writeSheet(Repository repository);

  /// Called once the row is in the fields: from then on, a change is saved.
  void sheetLoaded() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _ready = true);
  }

  /// A field changed: saved after a pause, or at once.
  void sheetChanged({bool now = false}) {
    if (!_ready || !existing) return;
    _timer?.cancel();
    if (_saved) setState(() => _saved = false);
    if (now) {
      _autosave();
    } else {
      _timer = Timer(autosavePause, _autosave);
    }
  }

  /// Stops a save that waits (the button saves, or the sheet closes).
  void cancelAutosave() => _timer?.cancel();

  Future<void> _autosave() async {
    // A save that waited may find the sheet no longer saving itself: a room,
    // an item, a contractor or a stock item to add with it waits for the
    // button, and its empty fields are not flagged meanwhile.
    if (!mounted || !existing) return;
    final form = sheetForm.currentState;
    if (form == null || !form.validate()) return;
    final state = AppScope.of(context);
    final l10n = AppLocalizations.of(context);
    final direction = Directionality.of(context);
    try {
      await writeSheet(state.repository);
    } on Refused catch (refused) {
      if (mounted) showRefusal(context, refused);
      return;
    }
    await state.refresh();
    if (!mounted) return;
    setState(() => _saved = true);
    // The screen reader says it, as the web's `aria-live="polite"` status.
    unawaited(
      SemanticsService.sendAnnouncement(
        View.of(context),
        l10n.saved,
        direction,
        assertiveness: Assertiveness.polite,
      ),
    );
  }

  /// The discreet "Saved" of the sheet, in its bar so that it is seen
  /// wherever the sheet is scrolled; empty until a change is saved.
  Widget savedStatus() {
    final l10n = AppLocalizations.of(context);
    return Semantics(
      liveRegion: true,
      container: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: HcSpace.s2),
        child: _saved
            ? Text(
                l10n.saved,
                key: const Key('autosave-status'),
                style: HcText.bodySmall,
              )
            : const SizedBox.shrink(),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
