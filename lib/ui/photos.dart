// SPDX-License-Identifier: AGPL-3.0-only

import 'package:material_ui/material_ui.dart';

import '../core/photo_source.dart';
import '../data/database.dart';
import '../data/repository.dart';
import '../design/icons.dart';
import '../design/theme.dart';
import '../design/tokens.dart';
import '../design/widgets.dart';
import '../domain/choices.dart';
import '../domain/photos.dart';
import '../l10n/app_localizations.dart';
import 'choices.dart';
import 'parts.dart';
import 'state.dart';

/// Columns of the grid of photos.
const _columns = 3;

/// The photos of a room or an item: a grid of thumbnails, a button to add one
/// (docs/spec.md, "Photos and files"). The camera or the gallery is asked
/// for when the person adds a photo, and a refusal is said, not hidden.
class PhotoSection extends StatelessWidget {
  const PhotoSection({
    super.key,
    required this.homeId,
    this.roomId,
    this.itemId,
    required this.writable,
    this.heading,
    this.hideEmpty = false,
  });

  /// The heading, when it is not simply Photos.
  final String? heading;

  /// Shows nothing at all when there is no photo, as the photos of the place
  /// of a task do.
  final bool hideEmpty;

  final String homeId;
  final String? roomId;
  final String? itemId;

  /// False in an archived home, which is read only.
  final bool writable;

  Future<void> _add(BuildContext context, {required bool camera}) async {
    final l10n = AppLocalizations.of(context);
    final state = AppScope.of(context);
    final source = state.photoSource;
    if (source == null) return;
    final messenger = ScaffoldMessenger.of(context);
    void say(String text) => messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
    try {
      final bytes = camera
          ? await source.takePhoto()
          : await source.pickPhoto();
      if (bytes == null) return;
      final photo = await state.photoProcessor(bytes);
      if (!context.mounted) return;
      await runChange(
        context,
        (r) => r.addPhoto(homeId, photo, roomId: roomId, itemId: itemId),
      );
    } on PhotoPermissionDenied {
      say(l10n.photoDenied);
    } on PhotoCameraUnavailable {
      say(l10n.photoNoCamera);
    } on PhotoRefused catch (refused) {
      say(
        refused.problem == PhotoProblem.unreadable
            ? l10n.errPhotoUnreadable
            : l10n.errPhotoTooLarge,
      );
    }
  }

  Future<void> _choose(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final camera = await showModalBottomSheet<bool>(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(HcSpace.s4),
          child: HcCardList(
            children: [
              HcRow(
                title: l10n.photoTake,
                onTap: () => Navigator.of(context).pop(true),
              ),
              HcRow(
                title: l10n.photoPick,
                onTap: () => Navigator.of(context).pop(false),
              ),
            ],
          ),
        ),
      ),
    );
    if (camera != null && context.mounted) await _add(context, camera: camera);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DataView<List<PhotoRow>>(
      load: (r) => r.photosOf(roomId: roomId, itemId: itemId),
      builder: (context, photos) => hideEmpty && photos.isEmpty
          ? const SizedBox.shrink()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                HcSectionHeading(heading ?? l10n.photos),
                if (photos.isEmpty)
                  HcEmpty(l10n.photosEmpty)
                else
                  LayoutBuilder(
                    builder: (context, box) {
                      final gap = HcSpace.s2;
                      final side =
                          (box.maxWidth - gap * (_columns - 1)) / _columns;
                      return Wrap(
                        spacing: gap,
                        runSpacing: gap,
                        children: [
                          for (final photo in photos)
                            _Thumbnail(
                              photo: photo,
                              side: side,
                              writable: writable,
                            ),
                        ],
                      );
                    },
                  ),
                if (writable) ...[
                  const SizedBox(height: HcSpace.s3),
                  OutlinedButton.icon(
                    key: const Key('photo-add'),
                    onPressed: () => _choose(context),
                    icon: const HcIcon(HcIcons.add, color: HcColors.primary),
                    label: Text(l10n.addPhoto),
                  ),
                ],
              ],
            ),
    );
  }
}

/// The tile of a photo whose file is not on this phone yet (it comes with
/// the next sync, docs/adr/0012 and 0013): the plain tile of the grid of
/// photos, as wide as the column, said with [label] and "Photo not on this
/// phone".
class MissingPhotoTile extends StatelessWidget {
  const MissingPhotoTile({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Semantics(
      label: '$label, ${l10n.photoNotHere}',
      excludeSemantics: true,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(HcRadius.sm),
        child: ColoredBox(
          color: HcColors.sageSoft,
          child: AspectRatio(
            aspectRatio: 4 / 3,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(HcSpace.s3),
                child: Text(
                  l10n.photoNotHere,
                  textAlign: TextAlign.center,
                  style: HcText.bodySmall,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The photo of a report, as the pages of a report and of a task show it: the
/// picture, which opens full width, or the tile of a photo not on this phone
/// yet (lot 4c), which opens on the same message. [keySuffix] tells apart the
/// photos of several reports on one page.
class ReportPhoto extends StatelessWidget {
  const ReportPhoto({super.key, required this.report, this.keySuffix = ''});

  final ReportRow report;
  final String keySuffix;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final file = AppScope.of(context).repository.reportPhoto(report);
    final label = l10n.reportPhotoOf(report.title);
    final here = file.existsSync();
    return InkWell(
      key: Key('report-photo-open$keySuffix'),
      borderRadius: BorderRadius.circular(HcRadius.sm),
      onTap: () => Navigator.of(context).push(
        hcRoute(ReportPhotoScreen(homeId: report.homeId, reportId: report.id)),
      ),
      child: here
          ? Semantics(
              button: true,
              image: true,
              label: label,
              excludeSemantics: true,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(HcRadius.sm),
                child: Image.file(
                  file,
                  key: Key('report-photo$keySuffix'),
                  // Decoded at the width of a phone, not at the size of the file.
                  cacheWidth: 1080,
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                ),
              ),
            )
          : Semantics(
              button: true,
              label: '$label, ${l10n.photoNotHere}',
              excludeSemantics: true,
              child: MissingPhotoTile(
                key: Key('report-photo-missing$keySuffix'),
                label: label,
              ),
            ),
    );
  }
}

/// The photo of a report, full width, or the message that its file is not on
/// this phone yet.
class ReportPhotoScreen extends StatelessWidget {
  const ReportPhotoScreen({
    super.key,
    required this.homeId,
    required this.reportId,
  });

  final String homeId;
  final String reportId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DataView<ReportRow?>(
      load: (r) => r.report(reportId),
      builder: (context, report) {
        if (report == null) return HcScaffold();
        final file = AppScope.of(context).repository.reportPhoto(report);
        return HcScaffold(
          title: l10n.reportPhoto,
          body: HcScreenList(
            children: [
              const SizedBox(height: HcSpace.s2),
              if (file.existsSync())
                ClipRRect(
                  borderRadius: BorderRadius.circular(HcRadius.lg),
                  child: Image.file(
                    file,
                    key: const Key('report-photo-full'),
                    fit: BoxFit.contain,
                    semanticLabel: l10n.reportPhotoOf(report.title),
                    errorBuilder: (_, _, _) => const SizedBox.shrink(),
                  ),
                )
              else
                HcEmpty(
                  l10n.photoNotHere,
                  key: const Key('report-photo-full-missing'),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({
    required this.photo,
    required this.side,
    required this.writable,
  });

  final PhotoRow photo;
  final double side;
  final bool writable;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final repository = AppScope.of(context).repository;
    final file = repository.thumbnailFile(photo);
    final fallback = repository.photoFile(photo);
    final source = file.existsSync()
        ? file
        : (fallback.existsSync() ? fallback : null);
    return Semantics(
      button: true,
      // A photo whose file has not come yet is a plain tile, said as such:
      // the file is fetched with the next sync (docs/adr/0012).
      label: source == null
          ? '${l10n.photoLabel(photoCategoryLabel(l10n, photo.category))}, '
                '${l10n.photoNotHere}'
          : l10n.photoLabel(photoCategoryLabel(l10n, photo.category)),
      child: InkWell(
        onTap: () => Navigator.of(context)
            .push(hcRoute(PhotoScreen(photoId: photo.id, writable: writable))),
        child: SizedBox(
          width: side,
          height: side,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(HcRadius.sm),
            child: ColoredBox(
              color: HcColors.sageSoft,
              child: source == null
                  ? null
                  : Image.file(
                      source,
                      fit: BoxFit.cover,
                      excludeFromSemantics: true,
                      errorBuilder: (_, _, _) => const SizedBox.shrink(),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// One photo, full width, with its category and caption.
class PhotoScreen extends StatefulWidget {
  const PhotoScreen({super.key, required this.photoId, required this.writable});

  final String photoId;
  final bool writable;

  @override
  State<PhotoScreen> createState() => _PhotoScreenState();
}

class _PhotoScreenState extends State<PhotoScreen> {
  final _caption = TextEditingController();
  String _category = photoCategories.first;
  PhotoRow? _photo;
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    AppScope.of(context).repository.photo(widget.photoId).then((photo) {
      if (photo == null || !mounted) return;
      setState(() {
        _photo = photo;
        _caption.text = photo.caption;
        _category = photo.category;
      });
    });
  }

  @override
  void dispose() {
    _caption.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final navigator = Navigator.of(context);
    if (await runChange(
      context,
      (r) => r.updatePhoto(
        widget.photoId,
        category: _category,
        caption: _caption.text,
      ),
    )) {
      navigator.pop();
    }
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context);
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    if (await runChange(context, (r) => r.deletePhoto(widget.photoId))) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.photoDeleted)));
      navigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final repository = AppScope.of(context).repository;
    final photo = _photo;
    final file = photo == null ? null : repository.photoFile(photo);
    return HcScaffold(
      title: l10n.photos,
      actions: [
        if (widget.writable && photo != null)
          HcBarAction(label: l10n.save, onPressed: _save),
      ],
      body: HcScreenList(
        children: [
          const SizedBox(height: HcSpace.s2),
          if (file != null && file.existsSync())
            ClipRRect(
              borderRadius: BorderRadius.circular(HcRadius.lg),
              child: Image.file(
                file,
                fit: BoxFit.contain,
                semanticLabel: photoCategoryLabel(l10n, _category),
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            )
          else
            HcEmpty(l10n.photoNotHere),
          const SizedBox(height: HcSpace.s4),
          HcCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                hcChoice<String>(
                  l10n.photoCategoryField,
                  _category,
                  [
                    for (final code in photoCategories)
                      (code, photoCategoryLabel(l10n, code)),
                  ],
                  (value) => setState(() => _category = value),
                  key: const Key('photo-category'),
                  enabled: widget.writable,
                ),
                hcText(
                  l10n.photoCaption,
                  _caption,
                  key: const Key('photo-caption'),
                  enabled: widget.writable,
                ),
              ],
            ),
          ),
          if (widget.writable) ...[
            HcDeleteButton(
              key: const Key('photo-delete'),
              label: l10n.photoDelete,
              onPressed: _delete,
            ),
          ],
        ],
      ),
    );
  }
}
