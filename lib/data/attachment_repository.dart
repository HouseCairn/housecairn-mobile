// SPDX-License-Identifier: AGPL-3.0-only

part of 'repository.dart';

/// At most 30 photos and files on a task (`MAX_ATTACHMENTS_PER_TASK`,
/// `tasks/models.py:39`).
const maxAttachmentsPerTask = 30;

/// The photos and files attached to a task (`tasks.attachment`, web ADR
/// 0034; lot 4d, docs/adr/0013-more-files-with-a-server.md). On the phone, a
/// photo or a PDF, as for a quote (docs/spec.md, "Photos and files"); a file
/// of another type made on the web is shown by its name and kept as it came.
extension AttachmentRepository on Repository {
  /// The live attachments of [taskId], in the order of the web: oldest first.
  Future<List<TaskAttachmentRow>> attachmentsOf(String taskId) =>
      (db.select(db.taskAttachments)
            ..where((a) => a.taskId.equalsValue(taskId) & a.deletedAt.isNull())
            ..orderBy([
              (a) => OrderingTerm.asc(a.createdAt),
              (a) => OrderingTerm.asc(a.id),
            ]))
          .get();

  Future<TaskAttachmentRow?> attachment(String id) =>
      (db.select(db.taskAttachments)
            ..where((a) => a.id.equalsValue(id) & a.deletedAt.isNull()))
          .getSingleOrNull();

  /// The file of an attachment on the phone, named by its id.
  File attachmentFile(TaskAttachmentRow row) =>
      fileOfRow('task_attachments', row.homeId, row.id);

  /// Whether an attachment is a photo: by the column the phone wrote, else by
  /// the type of its reference (a server sends the type there only).
  bool attachmentIsImage(TaskAttachmentRow row) =>
      row.isImage ||
      (FileReference.parse(
            row.file,
            rowId: row.id,
          )?.type.startsWith('image/') ??
          false);

  /// The size of the file of an attachment, in bytes: of its reference, else
  /// what the phone stored.
  int attachmentSize(TaskAttachmentRow row) =>
      FileReference.parse(row.file, rowId: row.id)?.size ?? row.sizeBytes;

  /// Attaches a photo or a PDF to the task [taskId] (`add_attachment`): every
  /// image is re-encoded first (upright, no metadata, at most 2560 px), a PDF
  /// is kept as picked. The name shown is cleaned of any path, never used on
  /// disk. A failure leaves no file.
  Future<String> addAttachment(
    String taskId, {
    required String name,
    required Uint8List bytes,
    required String contentType,
  }) async {
    final owner = await task(taskId);
    if (owner == null) throw const Refused(Refusal.notFound);
    await _writableHome(owner.homeId);
    if ((await attachmentsOf(taskId)).length >= maxAttachmentsPerTask) {
      throw const Refused(Refusal.tooManyAttachments);
    }
    if (bytes.isEmpty || bytes.length > maxFileBytes) {
      throw const Refused(Refusal.photoTooLarge);
    }
    final isImage = contentType.startsWith('image/');
    if (!isImage && contentType != 'application/pdf') {
      throw const Refused(Refusal.fileTypeRefused);
    }
    var stored = bytes;
    var storedType = contentType;
    int? width;
    int? height;
    if (isImage) {
      try {
        final photo = processPhoto(bytes);
        stored = photo.image;
        width = photo.width;
        height = photo.height;
      } on PhotoRefused catch (refused) {
        throw Refused(
          refused.problem == PhotoProblem.unreadable
              ? Refusal.photoUnreadable
              : Refusal.photoTooLarge,
        );
      }
      storedType = 'image/jpeg';
    }
    final id = newId();
    final directory = homeDirectory(owner.homeId)..createSync(recursive: true);
    final file = File('${directory.path}/$id');
    try {
      file.writeAsBytesSync(stored, flush: true);
      await db.transaction(
        () => _put(
          'task_attachments',
          id,
          {
            'task_id': taskId,
            'occurrence_id': null,
            'name': BudgetRepository._fileName(name),
            'file': FileReference.fresh(
              stored,
              type: storedType,
              width: width,
              height: height,
            ).encode(),
            'content_type': storedType,
            'is_image': isImage,
            'size_bytes': stored.length,
            'deleted_at': null,
          },
          homeId: owner.homeId,
          create: true,
        ),
      );
    } catch (_) {
      if (file.existsSync()) file.deleteSync();
      rethrow;
    }
    return id;
  }

  /// Deletes an attachment (`delete_attachment`). Its file stays on the
  /// phone 30 days, as a photo's (docs/adr/0012).
  Future<void> deleteAttachment(String id) async {
    final current = await attachment(id);
    if (current == null) throw const Refused(Refusal.notFound);
    await _writableHome(current.homeId);
    await db.transaction(
      () => _put('task_attachments', id, {'deleted_at': _now()}),
    );
  }
}
