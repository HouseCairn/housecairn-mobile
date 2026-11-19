// SPDX-License-Identifier: AGPL-3.0-only

import 'package:material_ui/material_ui.dart';

import '../data/database.dart';
import '../data/repository.dart';
import '../design/adaptive.dart';
import '../design/qr_code.dart';
import '../design/theme.dart';
import '../design/tokens.dart';
import '../design/widgets.dart';
import '../domain/label_sheet.dart';
import '../domain/labels.dart';
import '../domain/scanned_code.dart';
import '../l10n/app_localizations.dart';
import 'item_screens.dart';
import 'messages.dart';
import 'parts.dart';
import 'rooms.dart';
import 'scanner.dart';
import 'state.dart';
import 'stock_screens.dart';

/// QR labels on the phone (web `labels/`, web ADR 0047; docs/adr/0014-qr-labels.md):
/// the button of a room, an item and a stock article, the page of a label,
/// the list of what to label and print, and the scan that opens a sticker.

String _kindName(AppLocalizations l10n, LabelKind kind) => switch (kind) {
  LabelKind.room => l10n.labelKindRoom,
  LabelKind.item => l10n.labelKindItem,
  LabelKind.article => l10n.labelKindArticle,
};

String _layoutName(AppLocalizations l10n, LabelLayout layout) =>
    layout == roll62 ? l10n.labelLayoutRoll : l10n.labelLayoutA4;

/// Whether labels are made in [home]: a home that is written, not the
/// example of the guide (web `labels/services.py`).
bool _labelsWritten(HomeRow? home, String? role) =>
    home != null &&
    home.archivedAt == null &&
    !home.isExample &&
    role != 'read_only';

/// The button of the record of a room, an item or a stock article, before
/// Report a problem (web `labels/_tools.html`): QR label when the object has
/// one, Make a QR label when it has none and the home is written, nothing
/// else.
class LabelButton extends StatelessWidget {
  const LabelButton({
    super.key,
    required this.homeId,
    required this.kind,
    required this.targetId,
  });

  final String homeId;
  final LabelKind kind;
  final String targetId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DataView<(LabelRow?, HomeRow?, String?)>(
      load: (r) async => (
        await r.activeLabel(kind, targetId),
        await r.home(homeId),
        await r.serverRole(homeId),
      ),
      builder: (context, data) {
        final (label, home, role) = data;
        if (home == null || home.isExample) return const SizedBox.shrink();
        void open(String id) =>
            Navigator.of(context)
                .push(hcRoute(LabelScreen(homeId: homeId, labelId: id)));
        if (label != null) {
          return OutlinedButton(
            key: Key('label-${kind.wire}'),
            onPressed: () => open(label.id),
            child: Text(l10n.qrLabel),
          );
        }
        if (!_labelsWritten(home, role)) return const SizedBox.shrink();
        return OutlinedButton(
          key: Key('label-make-${kind.wire}'),
          onPressed: () async {
            final state = AppScope.of(context);
            try {
              final (made, _) = await state.repository.createLabel(
                homeId,
                kind,
                targetId,
              );
              await state.refresh();
              open(made.id);
            } on Refused catch (e) {
              if (context.mounted) showRefusal(context, e);
            }
          },
          child: Text(l10n.makeQrLabel),
        );
      },
    );
  }
}

/// Makes the PDF of [labels] in [layout] and hands it to the share sheet of
/// the phone, from where it is printed or saved; the file is removed after.
Future<void> printLabels(
  BuildContext context,
  List<LabelRow> labels,
  LabelLayout layout,
) async {
  final state = AppScope.of(context);
  final l10n = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final box = context.findRenderObject() as RenderBox?;
  final origin = box == null ? null : box.localToGlobal(Offset.zero) & box.size;
  final stickers = <Sticker>[];
  for (final label in labels) {
    final (name, place) = await state.repository.labelText(label) ?? ('', '');
    stickers.add(Sticker(name: name, place: place, code: label.code));
  }
  final bytes = await labelSheet(stickers, layout);
  final path = await state.repository.writeLabelSheet(bytes);
  try {
    final shared = await state.openFile(
      path,
      name: 'housecairn-labels.pdf',
      type: 'application/pdf',
      origin: origin,
    );
    if (!shared) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.fileOpenFailed)));
    }
  } finally {
    await state.repository.removeLabelSheet(path);
  }
}

/// The page of a label (web `labels/label_detail.html`): the object, its QR
/// code and what it holds, Open the page, the print of this label alone,
/// and, when the home is written, a new label or its revocation.
class LabelScreen extends StatefulWidget {
  const LabelScreen({super.key, required this.homeId, required this.labelId});

  final String homeId;
  final String labelId;

  @override
  State<LabelScreen> createState() => _LabelScreenState();
}

class _LabelScreenState extends State<LabelScreen> {
  late String _labelId = widget.labelId;
  LabelLayout _layout = labelLayouts.first;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DataView<(LabelRow?, (String, String)?, HomeRow?, String?)>(
      reloadKey: _labelId,
      load: (r) async {
        final label = await r.label(_labelId);
        return (
          label,
          label == null ? null : await r.labelText(label),
          await r.home(widget.homeId),
          await r.serverRole(widget.homeId),
        );
      },
      builder: (context, data) {
        final (label, text, home, role) = data;
        if (label == null || text == null || label.revokedAt != null) {
          return HcScaffold(
            body: HcScreenList(children: [HcEmpty(l10n.errNotFound)]),
          );
        }
        final (name, place) = text;
        final kind = LabelKind.parse(label.kind)!;
        final written = _labelsWritten(home, role);
        return HcScaffold(
          title: name,
          body: HcScreenList(
            children: [
              const SizedBox(height: HcSpace.s2),
              HcCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      place.isEmpty
                          ? _kindName(l10n, kind)
                          : '${_kindName(l10n, kind)} · $place',
                      style: HcText.bodySmall,
                    ),
                    const SizedBox(height: HcSpace.s3),
                    Center(
                      child: HcQrCode(
                        key: const Key('label-qr'),
                        text: labelPayload(label.code),
                        semanticLabel: l10n.labelQrOf(name),
                      ),
                    ),
                    const SizedBox(height: HcSpace.s3),
                    Text(l10n.labelHolds, style: HcText.bodySmall),
                    SelectableText(
                      labelPayload(label.code),
                      key: const Key('label-code'),
                      style: HcText.body,
                    ),
                    RecordActions(
                      children: [
                        OutlinedButton(
                          key: const Key('label-open'),
                          onPressed: () => openLabelTarget(context, label),
                          child: Text(l10n.labelOpenPage),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              HcSectionHeading(l10n.labelPrint),
              HcCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(l10n.labelLayout, style: HcText.fieldLabel),
                    const SizedBox(height: HcSpace.s1),
                    HcSelect<LabelLayout>(
                      key: const Key('label-layout'),
                      value: _layout,
                      choices: [
                        for (final l in labelLayouts) (l, _layoutName(l10n, l)),
                      ],
                      onChanged: (l) => setState(() => _layout = l),
                    ),
                    const SizedBox(height: HcSpace.s3),
                    Builder(
                      builder: (context) => FilledButton(
                        key: const Key('label-print'),
                        onPressed: () => printLabels(context, [label], _layout),
                        child: Text(l10n.labelPrintThis),
                      ),
                    ),
                  ],
                ),
              ),
              if (written) ...[
                HcSectionHeading(l10n.labelLostTitle),
                HcCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(l10n.labelLostText, style: HcText.bodySmall),
                      RecordActions(
                        children: [
                          OutlinedButton(
                            key: const Key('label-regenerate'),
                            onPressed: () => _regenerate(label),
                            child: Text(l10n.labelRegenerate),
                          ),
                          FilledButton(
                            key: const Key('label-revoke'),
                            style: hcDangerStyle(),
                            onPressed: () => _revoke(label),
                            child: Text(l10n.labelRevoke),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Future<void> _regenerate(LabelRow label) async {
    final state = AppScope.of(context);
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final fresh = await state.repository.regenerateLabel(label.id);
      await state.refresh();
      setState(() => _labelId = fresh.id);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.labelRegenerated)));
    } on Refused catch (e) {
      if (mounted) showRefusal(context, e);
    }
  }

  Future<void> _revoke(LabelRow label) async {
    final state = AppScope.of(context);
    final l10n = AppLocalizations.of(context);
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showHcDialog<bool>(
      context,
      (context) => HcDialog(
        scrollable: true,
        title: l10n.labelRevokeTitle,
        content: Text(l10n.labelRevokeBody),
        actions: [
          HcDialogAction(
            label: l10n.cancel,
            kind: HcDialogKind.cancel,
            onPressed: () => Navigator.of(context).pop(false),
          ),
          HcDialogAction(
            key: const Key('label-revoke-confirm'),
            label: l10n.labelRevoke,
            kind: HcDialogKind.danger,
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await state.repository.revokeLabel(label.id);
      await state.refresh();
      navigator.pop();
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.labelRevoked)));
    } on Refused catch (e) {
      if (mounted) showRefusal(context, e);
    }
  }
}

/// Opens the page of the object of [label].
void openLabelTarget(BuildContext context, LabelRow label) {
  final id = LabelRepository.targetOf(label);
  final screen = switch (LabelKind.parse(label.kind)!) {
    LabelKind.room => RoomScreen(homeId: label.homeId, roomId: id),
    LabelKind.item => ItemScreen(homeId: label.homeId, itemId: id),
    LabelKind.article => ArticleScreen(homeId: label.homeId, articleId: id),
  };
  Navigator.of(context).push(hcRoute(screen));
}

/// The list of what to label (web `labels/label_list.html`): every room,
/// item and stock article of the home, a box to tick on each, the layout,
/// and Print the labels.
class LabelsScreen extends StatefulWidget {
  const LabelsScreen({super.key, required this.homeId});

  final String homeId;

  @override
  State<LabelsScreen> createState() => _LabelsScreenState();
}

class _LabelsScreenState extends State<LabelsScreen> {
  final Set<(LabelKind, String)> _ticked = {};
  LabelLayout _layout = labelLayouts.first;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DataView<(List<LabelEntry>, HomeRow?, String?)>(
      load: (r) async => (
        await r.labelEntries(widget.homeId),
        await r.home(widget.homeId),
        await r.serverRole(widget.homeId),
      ),
      builder: (context, data) {
        final (entries, home, role) = data;
        final written = _labelsWritten(home, role);
        final sections = [
          (l10n.labelSectionRooms, LabelKind.room),
          (l10n.labelSectionItems, LabelKind.item),
          (l10n.labelSectionArticles, LabelKind.article),
        ];
        return HcScaffold(
          title: l10n.qrLabels,
          body: HcScreenList(
            children: [
              Text(l10n.labelsIntro, style: HcText.bodySmall),
              const SizedBox(height: HcSpace.s3),
              // The scan, the one entry the web does not have (its stickers
              // are opened by the camera of the phone): first on the page.
              OutlinedButton(
                key: const Key('labels-scan'),
                onPressed: () => scanLabel(context),
                child: Text(l10n.scanLabel),
              ),
              const SizedBox(height: HcSpace.s3),
              if (entries.isEmpty)
                HcEmpty(l10n.labelsEmpty)
              else ...[
                Text(l10n.labelLayout, style: HcText.fieldLabel),
                const SizedBox(height: HcSpace.s1),
                HcSelect<LabelLayout>(
                  key: const Key('labels-layout'),
                  value: _layout,
                  choices: [
                    for (final l in labelLayouts) (l, _layoutName(l10n, l)),
                  ],
                  onChanged: (l) => setState(() => _layout = l),
                ),
                for (final (title, kind) in sections)
                  if (entries.any((e) => e.kind == kind)) ...[
                    HcSectionHeading(title),
                    HcCardList(
                      children: [
                        for (final e in entries.where((e) => e.kind == kind))
                          _entryRow(context, e, written),
                      ],
                    ),
                  ],
                const SizedBox(height: HcSpace.s3),
                Text(
                  '${l10n.labelsMax(maxLabelsPerSheet)} '
                  '${written ? l10n.labelsMadeForTicked : l10n.labelsReadOnly}',
                  style: HcText.bodySmall,
                ),
                const SizedBox(height: HcSpace.s3),
                Builder(
                  builder: (context) => FilledButton(
                    key: const Key('labels-print'),
                    onPressed: () => _print(context, entries, written),
                    child: Text(l10n.labelsPrint),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _entryRow(BuildContext context, LabelEntry e, bool written) {
    final l10n = AppLocalizations.of(context);
    final key = (e.kind, e.id);
    final ticked = _ticked.contains(key);
    final status = e.label != null
        ? l10n.qrLabel
        : (written ? l10n.labelNoneYet : l10n.labelNone);
    void toggle() =>
        setState(() => ticked ? _ticked.remove(key) : _ticked.add(key));
    return MergeSemantics(
      child: HcRow(
        key: Key('labels-${e.kind.wire}-${e.id}'),
        leading: Checkbox.adaptive(value: ticked, onChanged: (_) => toggle()),
        title: e.name,
        text: e.place.isEmpty ? status : '${e.place} · $status',
        trailing: const SizedBox.shrink(),
        onTap: toggle,
      ),
    );
  }

  Future<void> _print(
    BuildContext context,
    List<LabelEntry> entries,
    bool written,
  ) async {
    final state = AppScope.of(context);
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    // In the order of the list, as the web prints them.
    final wanted = [
      for (final e in entries)
        if (_ticked.contains((e.kind, e.id))) (e.kind, e.id),
    ];
    if (wanted.isEmpty) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.labelsChoose)));
      return;
    }
    final List<LabelRow> labels;
    if (written) {
      try {
        labels = await state.repository.labelsToPrint(widget.homeId, wanted);
      } on Refused catch (e) {
        if (context.mounted) showRefusal(context, e);
        return;
      }
      await state.refresh();
    } else {
      // A home that is not written prints the labels that exist, and makes
      // none (`labels_to_print` of the web, for a reader).
      labels = [
        for (final e in entries)
          if (_ticked.contains((e.kind, e.id)) && e.label != null) e.label!,
      ];
      if (labels.length != wanted.length) {
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(l10n.labelsReadOnly)));
        return;
      }
    }
    if (!context.mounted) return;
    await printLabels(context, labels, _layout);
  }
}

/// Scans a sticker and opens what it names, when this phone knows its code;
/// else says why it opens nothing (docs/adr/0014-qr-labels.md).
Future<void> scanLabel(BuildContext context) async {
  final state = AppScope.of(context);
  final l10n = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  void say(String text) => messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text)));
  final camera = state.codeCamera?.call();
  if (camera == null) return say(l10n.scanUnavailable);
  final scanned = await Navigator.of(context).push(
    hcRouteOf<ScannedCode>(
      CodeScannerScreen(
        camera: camera,
        formats: const {CodeFormat.qr},
        title: l10n.scanLabel,
        hint: l10n.scanHint,
      ),
    ),
  );
  if (scanned == null) return;
  final code = labelCodeIn(scanned.text);
  if (code == null) return say(l10n.scanNotLabel);
  final found = await state.repository.lookUpLabel(code);
  if (!context.mounted) return;
  switch (found.lookup) {
    case LabelLookup.found:
      openLabelTarget(context, found.label!);
    case LabelLookup.revoked:
      say(l10n.scanRevoked);
    case LabelLookup.gone:
      say(l10n.scanGone);
    case LabelLookup.unknown:
      say(l10n.scanUnknown);
  }
}
