// SPDX-License-Identifier: AGPL-3.0-only

part of 'repository.dart';

/// The tables whose rows hold a file, and the column of its reference (web
/// `sync/files.py`, `HOLDERS`): the photos of rooms and items, the files of
/// projects and the attachments of tasks (lot 4c and 4d), the photo of a
/// report and the label of a stock article (lot 4d,
/// docs/adr/0013-more-files-with-a-server.md).
const fileHolders = {
  'photos': 'image',
  'project_files': 'file',
  'task_attachments': 'file',
  'reports': 'photo',
  'articles': 'label',
};

/// The holders whose file is a photo kept as `<id>.jpg`: an image only on
/// both sides. The others (a file of a project, an attachment) are named by
/// the id alone, a PDF as well as a photo.
const _jpegHolders = {'photos', 'reports', 'articles'};

/// How long a deleted photo or file stays on the phone, so that it can be
/// restored (docs/spec.md, "Photos and files"): 30 days.
const fileKeepDays = 30;

/// The longest wait between two tries of one file: six hours.
const fileRetryMax = Duration(hours: 6);

/// The wait before the next try of a file that failed [attempts] times in a
/// row: 30 seconds, doubled each time, six hours at most.
Duration fileRetryDelay(int attempts) {
  if (attempts <= 0) return Duration.zero;
  final seconds = 30 * (1 << (attempts - 1).clamp(0, 20));
  final delay = Duration(seconds: seconds);
  return delay > fileRetryMax ? fileRetryMax : delay;
}

/// Which way a file goes.
enum FileWay {
  /// Made on this phone: to send.
  up,

  /// Made elsewhere: to fetch.
  down,
}

/// A file to send or to fetch, with what the engine needs to do it.
class FileJob {
  const FileJob({
    required this.fileId,
    required this.homeId,
    required this.holder,
    required this.rowId,
    required this.way,
    required this.attempts,
    required this.reference,
    required this.file,
  });

  /// `file` of the reference: the name of the file on the server.
  final String fileId;
  final String homeId;

  /// The table of the row, a key of [fileHolders].
  final String holder;
  final String rowId;
  final FileWay way;
  final int attempts;
  final FileReference reference;

  /// Where the file is, or goes, on the phone.
  final File file;
}

/// What waits to be sent, for the settings.
class FileQueue {
  const FileQueue({
    this.waiting = 0,
    this.failed = 0,
    this.codes = const {},
    this.fetching = 0,
  });

  /// Files to send, not tried yet or to try again.
  final int waiting;

  /// Files the server refused for good, to send again by hand.
  final int failed;

  /// The codes of those refusals (`malformed`, `too_large`, ...).
  final Set<String> codes;

  /// Files of other phones still to fetch.
  final int fetching;

  /// Everything the person may have to look at.
  int get toSend => waiting + failed;
}

/// The files of the rows of [fileHolders] with a Housecairn server (lots 4c
/// and 4d, docs/adr/0012-files-with-a-server.md and
/// docs/adr/0013-more-files-with-a-server.md): which are to send and to fetch,
/// the tries and their waits, the refusals, and the sweep of what was
/// deleted. The network is in lib/sync/files.dart.
extension FileSyncRepository on Repository {
  /// Where the file of the row [id] of [holder] is on the phone: a photo, the
  /// photo of a report and the label of an article are `<id>.jpg`, a file of
  /// a project and an attachment are `<id>`.
  File fileOfRow(String holder, String homeId, String id) => File(
    '${homeDirectory(homeId).path}/'
    '${_jpegHolders.contains(holder) ? '$id.jpg' : id}',
  );

  /// The thumbnail file of a photo.
  File thumbnailOfRow(String homeId, String id) =>
      File('${homeDirectory(homeId).path}/$id.thumb.jpg');

  /// The reference of a row of the first builds, which had no `file` nor
  /// `sha256`, completed from the file the phone holds; `null` when the file
  /// is not there. The id of the file is the same every time for a row.
  FileReference? completedReference(
    String holder,
    String homeId,
    String rowId,
    String text,
  ) {
    final ref = FileReference.parse(text, rowId: rowId);
    final file = fileOfRow(holder, homeId, rowId);
    if (ref == null || !file.existsSync()) return null;
    final bytes = file.readAsBytesSync();
    return FileReference(
      file: ref.file,
      sha256: sha256Hex(bytes),
      size: bytes.length,
      type: ref.type,
      width: ref.width,
      height: ref.height,
    );
  }

  /// Completes in place the file reference of the operations of the first
  /// builds that wait in `op_log` (the web refuses a photo whose reference
  /// has no `file` and no `sha256`: `400` `malformed`).
  Future<void> completeFileReferences(List<OutgoingOperation> out) async {
    final byEntity = {for (final e in entityOf.entries) e.value: e.key};
    for (final o in out) {
      final op = o.operation;
      final table = byEntity[op[Op.type]];
      final column = fileHolders[table];
      final fields = op[Op.fields];
      final home = op[Op.home] as String?;
      if (table == null || column == null || home == null) continue;
      if (fields is! Map || fields[column] is! String) continue;
      final text = fields[column] as String;
      if (!FileReference.isLegacy(text)) continue;
      final done = completedReference(table, home, op[Op.id]! as String, text);
      if (done != null) fields[column] = done.encode();
    }
  }

  // ---------- which files, and in which state ----------

  /// Makes the list of files agree with the rows: a file of a row of a home
  /// of the server gets its entry (to send when the phone holds it, to fetch
  /// when it does not), a reference of the first builds is completed, and an
  /// entry of a row that is gone is dropped. Reads the rows and `stat`s the
  /// files, writes only the entries that change.
  Future<void> scanFiles() async {
    final entries = {
      for (final r in await db.customSelect('SELECT * FROM file_sync').get())
        r.data['file_id'] as String: r.data,
    };
    final seen = <String>{};
    for (final MapEntry(key: holder, value: column) in fileHolders.entries) {
      final rows = await db
          .customSelect(
            'SELECT id, home_id, $column AS ref, deleted_at FROM $holder '
            'WHERE $column IS NOT NULL',
          )
          .get();
      for (final row in rows) {
        final rowId = Uuid.unparse(row.data['id'] as Uint8List);
        final homeId = Uuid.unparse(row.data['home_id'] as Uint8List);
        if (await serverRole(homeId) == null) continue;
        final text = row.data['ref'] as String;
        var ref = FileReference.parse(text, rowId: rowId);
        if (ref == null) continue;
        // A deleted row has nothing to send nor to fetch: it is not counted
        // (its entry is dropped below), and a restore makes the entry again.
        if (row.data['deleted_at'] != null) continue;
        final file = fileOfRow(holder, homeId, rowId);
        final exists = file.existsSync();
        if (FileReference.isLegacy(text) &&
            exists &&
            !entries.containsKey(ref.file)) {
          ref = completedReference(holder, homeId, rowId, text) ?? ref;
          await db.customStatement(
            'UPDATE $holder SET $column = ? WHERE id = ?',
            [ref.encode(), row.data['id']],
          );
        }
        seen.add(ref.file);
        final entry = entries[ref.file];
        if (entry == null) {
          // No entry: never seen, or forgotten when the phone left the
          // server. A file the phone holds is to send only when it is the
          // very file the reference names (same size, same digest): a
          // reference with no digest is a server's (a photo made on the
          // web), and a photo another phone made is held as the server's
          // re-encoded copy, whose bytes are not the ones its digest names
          // (ADR 0012). Both are there already: nothing to send.
          final String way;
          final String state;
          if (!exists) {
            way = 'down';
            state = 'waiting';
          } else if (await _isMadeHere(file, ref)) {
            way = 'up';
            state = 'waiting';
          } else {
            way = 'down';
            state = 'done';
          }
          await _insertFileEntry(ref.file, homeId, holder, rowId, way, state);
        } else if (entry['direction'] == 'down' &&
            exists &&
            entry['state'] != 'done') {
          await fileDone(ref.file);
        } else if (entry['direction'] == 'up' &&
            !exists &&
            entry['state'] != 'done') {
          // The file is gone from the phone before it was sent: fetch it if
          // the server has it.
          await db.customStatement(
            "UPDATE file_sync SET direction = 'down', state = 'waiting', "
            'attempts = 0, next_at = 0, code = NULL WHERE file_id = ?',
            [ref.file],
          );
        }
      }
    }
    for (final id in entries.keys.where((id) => !seen.contains(id))) {
      await db.customStatement('DELETE FROM file_sync WHERE file_id = ?', [id]);
    }
  }

  /// Whether [file] holds the bytes [ref] names: the proof that this phone
  /// made it. The size is read first, the digest only when it agrees.
  Future<bool> _isMadeHere(File file, FileReference ref) async {
    final digest = ref.sha256;
    if (digest == null || file.lengthSync() != ref.size) return false;
    return await sha256HexOffMain(file.readAsBytesSync()) == digest;
  }

  Future<void> _insertFileEntry(
    String fileId,
    String homeId,
    String holder,
    String rowId,
    String way,
    String state,
  ) => db.customInsert(
    'INSERT OR IGNORE INTO file_sync '
    '(file_id, home_id, holder, row_id, direction, state) '
    'VALUES (?, ?, ?, ?, ?, ?)',
    variables: [
      Variable<String>(fileId),
      Variable<Uint8List>(uuidBytes(homeId)),
      Variable<String>(holder),
      Variable<Uint8List>(uuidBytes(rowId)),
      Variable<String>(way),
      Variable<String>(state),
    ],
  );

  /// The files to try now, [way] only: waiting, and not before their wait is
  /// over (unless [ignoreWait]); the files to send oldest first, the ones to
  /// fetch newest first. At most [limit].
  Future<List<FileJob>> filesDue(
    FileWay way, {
    int limit = 1000,
    bool ignoreWait = false,
  }) async {
    final entries = await db
        .customSelect(
          "SELECT * FROM file_sync WHERE direction = ? AND state = 'waiting' "
          '${ignoreWait ? '' : 'AND next_at <= ? '}'
          'ORDER BY rowid ${way == FileWay.up ? 'ASC' : 'DESC'} LIMIT ?',
          variables: [
            Variable<String>(way.name),
            if (!ignoreWait) Variable<int>(_now()),
            Variable<int>(limit),
          ],
        )
        .get();
    final jobs = <FileJob>[];
    for (final e in entries) {
      final holder = e.data['holder'] as String;
      final column = fileHolders[holder]!;
      final home = Uuid.unparse(e.data['home_id'] as Uint8List);
      final rowId = Uuid.unparse(e.data['row_id'] as Uint8List);
      final row = await db
          .customSelect(
            'SELECT $column AS ref, deleted_at FROM $holder WHERE id = ?',
            variables: [Variable<Uint8List>(uuidBytes(rowId))],
          )
          .getSingleOrNull();
      final ref = FileReference.parse(
        row?.data['ref'] as String?,
        rowId: rowId,
      );
      if (row == null ||
          ref == null ||
          ref.file != e.data['file_id'] ||
          row.data['deleted_at'] != null) {
        // A row deleted or changed since: nothing to send nor to fetch for
        // it now. A restore finds the entry again by the next scan.
        continue;
      }
      jobs.add(
        FileJob(
          fileId: ref.file,
          homeId: home,
          holder: holder,
          rowId: rowId,
          way: way,
          attempts: e.data['attempts'] as int,
          reference: ref,
          file: fileOfRow(holder, home, rowId),
        ),
      );
    }
    return jobs;
  }

  /// The file is on both sides.
  Future<void> fileDone(String fileId) => db.customStatement(
    "UPDATE file_sync SET state = 'done', attempts = 0, next_at = 0, "
    'code = NULL WHERE file_id = ?',
    [fileId],
  );

  /// The other side refused the file for good ([code]): it is not tried again
  /// by itself, and the settings tell it.
  Future<void> fileFailed(String fileId, String code) => db.customStatement(
    "UPDATE file_sync SET state = 'failed', code = ? WHERE file_id = ?",
    [code, fileId],
  );

  /// The file was not taken now (the server busy or out of reach, or the file
  /// not there yet): tried again after a longer wait each time.
  Future<void> fileLater(FileJob job, {String? code}) {
    final attempts = job.attempts + 1;
    return db.customStatement(
      "UPDATE file_sync SET state = 'waiting', attempts = ?, next_at = ?, "
      'code = ? WHERE file_id = ?',
      [
        attempts,
        _now() + fileRetryDelay(attempts).inMilliseconds,
        code,
        job.fileId,
      ],
    );
  }

  /// "Try again": every file that is not done is tried at the next round
  /// with no wait, the refused ones too.
  Future<void> retryFiles() => db.customStatement(
    "UPDATE file_sync SET state = 'waiting', attempts = 0, next_at = 0, "
    "code = NULL WHERE state != 'done'",
  );

  /// The files that wait, for the settings.
  Future<FileQueue> fileQueue() async {
    await scanFiles();
    final rows = await db
        .customSelect(
          "SELECT direction, state, code FROM file_sync WHERE state != 'done'",
        )
        .get();
    var waiting = 0;
    var failed = 0;
    var fetching = 0;
    final codes = <String>{};
    for (final r in rows) {
      if (r.data['direction'] == 'down') {
        if (r.data['state'] == 'waiting') fetching++;
      } else if (r.data['state'] == 'failed') {
        failed++;
        if (r.data['code'] case final String code) codes.add(code);
      } else {
        waiting++;
      }
    }
    return FileQueue(
      waiting: waiting,
      failed: failed,
      codes: codes,
      fetching: fetching,
    );
  }

  /// The code of the last refusal of the file of [fileId] still to send, for
  /// the line of a photo or a file; `null` when none.
  Future<Map<String, String>> fileProblems() async {
    final rows = await db
        .customSelect(
          "SELECT row_id, code FROM file_sync WHERE direction = 'up' "
          "AND state = 'failed' AND code IS NOT NULL",
        )
        .get();
    return {
      for (final r in rows)
        Uuid.unparse(r.data['row_id'] as Uint8List): r.data['code'] as String,
    };
  }

  /// Stores the file [bytes] fetched for [job] (and [thumbnail] of a photo),
  /// then marks it done. Written whole before it is marked: a cut leaves no
  /// half file for the screens, which read the file only when it exists.
  Future<void> storeFetched(
    FileJob job,
    Uint8List bytes, {
    Uint8List? thumbnail,
  }) async {
    final directory = homeDirectory(job.homeId)..createSync(recursive: true);
    final target = job.file;
    final part = File('${directory.path}/${job.rowId}.part');
    part.writeAsBytesSync(bytes, flush: true);
    part.renameSync(target.path);
    if (job.holder == 'photos' && thumbnail != null) {
      thumbnailOfRow(
        job.homeId,
        job.rowId,
      ).writeAsBytesSync(thumbnail, flush: true);
    }
    await fileDone(job.fileId);
  }

  /// Removes from the phone the files of what was deleted more than
  /// [fileKeepDays] days ago (a deleted photo can be restored until then),
  /// and the entries of those files, in the homes of the server only: the
  /// phone keeps the files of the other homes as they are.
  Future<int> sweepFiles() async {
    final before =
        clock.now().millisecondsSinceEpoch -
        const Duration(days: fileKeepDays).inMilliseconds;
    var removed = 0;
    for (final MapEntry(key: holder, value: column) in fileHolders.entries) {
      final rows = await db
          .customSelect(
            'SELECT id, home_id, $column AS ref FROM $holder '
            'WHERE deleted_at IS NOT NULL AND deleted_at <= ?',
            variables: [Variable<int>(before)],
          )
          .get();
      for (final row in rows) {
        final rowId = Uuid.unparse(row.data['id'] as Uint8List);
        final home = Uuid.unparse(row.data['home_id'] as Uint8List);
        if (await serverRole(home) == null) continue;
        for (final file in [
          fileOfRow(holder, home, rowId),
          thumbnailOfRow(home, rowId),
        ]) {
          if (file.existsSync()) {
            file.deleteSync();
            removed++;
          }
        }
        final ref = FileReference.parse(
          row.data['ref'] as String?,
          rowId: rowId,
        );
        if (ref != null) {
          await db.customStatement('DELETE FROM file_sync WHERE file_id = ?', [
            ref.file,
          ]);
        }
      }
    }
    return removed;
  }

  /// Leaving the server: the list of files goes with the other marks of it.
  Future<void> forgetFileSync() => db.customStatement('DELETE FROM file_sync');
}
