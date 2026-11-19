// SPDX-License-Identifier: AGPL-3.0-only

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../core/photo_source.dart';
import '../data/database.dart';
import '../data/repository.dart';
import '../design/icons.dart';
import '../design/theme.dart';
import '../design/tokens.dart';
import '../design/widgets.dart';
import '../l10n/app_localizations.dart';
import 'guide_screens.dart';
import 'parts.dart';
import 'state.dart';

/// Columns of the grid of photos attached to a task, as the grid of photos.
const _columns = 3;

/// The photos and files of a task (`tasks/_attachments.html`, under the
/// heading Photos and files of `task_detail.html`): the photos as a grid of
/// tiles with their name, then the other files as a list with their name and
/// size, then the button that adds some. A file not on this phone yet (it
/// comes with the next sync, docs/adr/0013) is a plain tile, said as such.
class AttachmentSection extends StatelessWidget {
  const AttachmentSection({
    super.key,
    required this.homeId,
    required this.taskId,
    required this.writable,
  });

  final String homeId;
  final String taskId;

  /// False in an archived home, which is read only.
  final bool writable;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DataView<List<TaskAttachmentRow>>(
      load: (r) => r.attachmentsOf(taskId),
      builder: (context, attachments) {
        final repository = AppScope.of(context).repository;
        final images = [
          for (final a in attachments)
            if (repository.attachmentIsImage(a)) a,
        ];
        final documents = [
          for (final a in attachments)
            if (!repository.attachmentIsImage(a)) a,
        ];
        return Column(
          key: const Key('task-attachments'),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            HcSectionHeading(l10n.attachmentsHeading),
            if (images.isNotEmpty)
              LayoutBuilder(
                builder: (context, box) {
                  const gap = HcSpace.s2;
                  final side = (box.maxWidth - gap * (_columns - 1)) / _columns;
                  return Wrap(
                    spacing: gap,
                    runSpacing: gap,
                    children: [
                      for (final a in images)
                        _ImageTile(
                          attachment: a,
                          side: side,
                          writable: writable,
                        ),
                    ],
                  );
                },
              ),
            if (images.isNotEmpty && documents.isNotEmpty)
              const SizedBox(height: HcSpace.s3),
            if (documents.isNotEmpty)
              HcCardList(
                children: [
                  for (final a in documents)
                    HcRow(
                      key: Key('attachment-${a.id}'),
                      leading: const HcIcon(HcIcons.file),
                      title: a.name,
                      text: repository.attachmentFile(a).existsSync()
                          ? fileSizeLabel(context, repository.attachmentSize(a))
                          : l10n.fileNotHere,
                      onTap: () => _openAttachment(context, a, writable),
                    ),
                ],
              ),
            if (writable)
              HcAddButton(
                key: const Key('attachment-add'),
                label: l10n.addAttachments,
                primary: false,
                gap: HcSpace.s3,
                onPressed: () => _choose(context),
              )
            else if (attachments.isEmpty)
              HcEmpty(l10n.attachmentsEmpty),
          ],
        );
      },
    );
  }

  Future<void> _choose(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final way = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(HcSpace.s4),
          child: HcCardList(
            children: [
              HcRow(
                key: const Key('attachment-camera'),
                title: l10n.photoTake,
                onTap: () => Navigator.of(context).pop('camera'),
              ),
              HcRow(
                key: const Key('attachment-gallery'),
                title: l10n.photoPick,
                onTap: () => Navigator.of(context).pop('gallery'),
              ),
              HcRow(
                key: const Key('attachment-document'),
                title: l10n.attachmentPickFile,
                onTap: () => Navigator.of(context).pop('document'),
              ),
            ],
          ),
        ),
      ),
    );
    if (way == null || !context.mounted) return;
    await _add(context, way);
  }

  Future<void> _add(BuildContext context, String way) async {
    final l10n = AppLocalizations.of(context);
    final state = AppScope.of(context);
    final messenger = ScaffoldMessenger.of(context);
    void say(String text) => messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
    try {
      final String name;
      final Uint8List bytes;
      final String type;
      if (way == 'document') {
        final picked = await state.documentSource?.pickDocument();
        if (picked == null) return;
        (name, bytes, type) = (picked.name, picked.bytes, picked.contentType);
      } else {
        final source = state.photoSource;
        if (source == null) return;
        final taken = way == 'camera'
            ? await source.takePhoto()
            : await source.pickPhoto();
        if (taken == null) return;
        (name, bytes, type) = ('photo.jpg', taken, 'image/jpeg');
      }
      if (!context.mounted) return;
      await runChange(
        context,
        (r) => r.addAttachment(
          taskId,
          name: name,
          bytes: bytes,
          contentType: type,
        ),
      );
    } on PhotoPermissionDenied {
      say(l10n.photoDenied);
    } on PhotoCameraUnavailable {
      say(l10n.photoNoCamera);
    }
  }
}

void _openAttachment(
  BuildContext context,
  TaskAttachmentRow attachment,
  bool writable,
) => Navigator.of(context).push(
  hcRoute(AttachmentScreen(attachmentId: attachment.id, writable: writable)),
);

/// A size as the web's `filesizeformat` says it: bytes, KB, MB, one decimal
/// in the number format of the language.
String fileSizeLabel(BuildContext context, int bytes) {
  final l10n = AppLocalizations.of(context);
  final number = NumberFormat.decimalPatternDigits(
    locale: Localizations.localeOf(context).toString(),
    decimalDigits: 1,
  );
  if (bytes < 1024) return l10n.fileSizeBytes(bytes);
  if (bytes < 1024 * 1024) return l10n.fileSizeKb(number.format(bytes / 1024));
  return l10n.fileSizeMb(number.format(bytes / (1024 * 1024)));
}

/// [name] with a place to go down a line before its extension (a zero
/// width space before the last dot), as a word ends there.
@visibleForTesting
String fileNameBreakable(String name) {
  final dot = name.lastIndexOf('.');
  if (dot <= 0) return name;
  return '${name.substring(0, dot)}\u200B${name.substring(dot)}';
}

/// Whether [name] fits on one line of [width], in the small body text at the
/// text size of the person.
bool _fits(BuildContext context, String name, double width) {
  final painter = TextPainter(
    text: TextSpan(
      text: name,
      style: DefaultTextStyle.of(context).style.merge(HcText.bodySmall),
    ),
    textDirection: Directionality.of(context),
    textScaler: MediaQuery.textScalerOf(context),
    maxLines: 1,
  )..layout();
  final fits = painter.width <= width;
  painter.dispose();
  return fits;
}

class _ImageTile extends StatelessWidget {
  const _ImageTile({
    required this.attachment,
    required this.side,
    required this.writable,
  });

  final TaskAttachmentRow attachment;
  final double side;
  final bool writable;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final file = AppScope.of(context).repository.attachmentFile(attachment);
    final here = file.existsSync();
    return Semantics(
      button: true,
      label: here
          ? l10n.attachmentPhotoLabel(attachment.name)
          : '${l10n.attachmentPhotoLabel(attachment.name)}, '
                '${l10n.photoNotHere}',
      excludeSemantics: true,
      child: InkWell(
        key: Key('attachment-${attachment.id}'),
        onTap: () => _openAttachment(context, attachment, writable),
        child: SizedBox(
          width: side,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: side,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(HcRadius.sm),
                  child: ColoredBox(
                    color: HcColors.sageSoft,
                    child: here
                        ? Image.file(
                            file,
                            fit: BoxFit.cover,
                            cacheWidth: 360,
                            errorBuilder: (_, _, _) => const SizedBox.shrink(),
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: HcSpace.s1),
              // A name is never cut inside a word (boiler.j / pg on 320 px
              // at twice the size): when it does not fit on its line, it
              // goes down a line before its extension, and comes down in
              // size until its longest part fits, the rule of HcWholeWords.
              // A name that fits is drawn as before.
              if (_fits(context, attachment.name, side))
                Text(
                  attachment.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: HcText.bodySmall,
                )
              else
                Text(
                  fileNameBreakable(attachment.name),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: HcText.bodySmall,
                  textScaler: hcWholeWordsScaler(
                    context,
                    [fileNameBreakable(attachment.name)],
                    [HcText.bodySmall],
                    side,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One attachment: the photo full width, or the name and size of the file
/// with a way to open it in another app of the phone; then Delete.
class AttachmentScreen extends StatefulWidget {
  const AttachmentScreen({
    super.key,
    required this.attachmentId,
    required this.writable,
  });

  final String attachmentId;
  final bool writable;

  @override
  State<AttachmentScreen> createState() => _AttachmentScreenState();
}

class _AttachmentScreenState extends State<AttachmentScreen> {
  TaskAttachmentRow? _attachment;
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    AppScope.of(context).repository.attachment(widget.attachmentId).then((a) {
      if (a == null || !mounted) return;
      setState(() => _attachment = a);
    });
  }

  Future<void> _open(String path, TaskAttachmentRow attachment) async {
    final l10n = AppLocalizations.of(context);
    final state = AppScope.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final box = context.findRenderObject() as RenderBox?;
    final origin = box == null
        ? null
        : box.localToGlobal(Offset.zero) & box.size;
    final opened = await state.openFile(
      path,
      name: attachment.name,
      type: AppScope.of(context).repository.attachmentIsImage(attachment)
          ? 'image/jpeg'
          : (attachment.contentType.isEmpty
                ? 'application/octet-stream'
                : attachment.contentType),
      origin: origin,
    );
    if (!opened) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.fileOpenFailed)));
    }
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context);
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    if (!await confirmDelete(
      context,
      title: l10n.attachmentDelete,
      body: l10n.attachmentDeleteBody(_attachment!.name),
    )) {
      return;
    }
    if (!mounted) return;
    if (await runChange(
      context,
      (r) => r.deleteAttachment(widget.attachmentId),
    )) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.attachmentDeleted)));
      navigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final repository = AppScope.of(context).repository;
    final attachment = _attachment;
    final file = attachment == null
        ? null
        : repository.attachmentFile(attachment);
    final here = file != null && file.existsSync();
    final image =
        attachment != null && repository.attachmentIsImage(attachment);
    return HcScaffold(
      title: attachment?.name ?? l10n.attachmentsHeading,
      belowTitle: ExampleHomeBanner(homeId: attachment?.homeId),
      body: attachment == null
          ? const SizedBox.shrink()
          : HcScreenList(
              children: [
                const SizedBox(height: HcSpace.s2),
                if (image && here)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(HcRadius.lg),
                    child: Image.file(
                      file,
                      key: const Key('attachment-image'),
                      fit: BoxFit.contain,
                      semanticLabel: l10n.attachmentPhotoLabel(attachment.name),
                      errorBuilder: (_, _, _) => const SizedBox.shrink(),
                    ),
                  )
                else if (image)
                  HcEmpty(l10n.photoNotHere)
                else
                  HcCard(
                    child: Row(
                      children: [
                        const HcIcon(HcIcons.file),
                        const SizedBox(width: HcSpace.s3),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(attachment.name, style: HcText.cardTitle),
                              Text(
                                here
                                    ? fileSizeLabel(
                                        context,
                                        repository.attachmentSize(attachment),
                                      )
                                    : l10n.fileNotHere,
                                style: HcText.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                if (here) ...[
                  const SizedBox(height: HcSpace.s3),
                  OutlinedButton(
                    key: const Key('attachment-open'),
                    onPressed: () => _open(file.path, attachment),
                    child: Text(l10n.fileOpen),
                  ),
                ],
                if (widget.writable)
                  HcDeleteButton(
                    key: const Key('attachment-delete'),
                    label: l10n.attachmentDelete,
                    onPressed: _delete,
                  ),
                const SizedBox(height: HcSpace.s5),
              ],
            ),
    );
  }
}
