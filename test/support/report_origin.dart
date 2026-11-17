// SPDX-License-Identifier: AGPL-3.0-only

import 'package:housecairn_mobile/data/database.dart' show uuidBytes;
import 'package:housecairn_mobile/data/repository.dart';
import 'package:housecairn_mobile/domain/photos.dart';

import 'fakes.dart';

/// A home with the tasks made from reports, as the web tells them apart:
/// a task whose report has a photo on the phone, one whose report has a
/// photo not come yet, one whose report has no photo, one whose report with a
/// photo was deleted, one whose report with a photo was closed afterwards, one
/// made from two reports, and a task made from nothing. Neutral names only.
class ReportOrigin {
  late String home;
  late String withPhoto;
  late String photoMissing;
  late String noPhoto;
  late String deleted;
  late String closed;
  late String twoReports;
  late String plain;
  late String reportWithPhoto;
  late String reportMissing;
  late String reportNoPhoto;
  late String reportDeleted;
  late String reportClosed;
  late String reportOlder;
  late String reportNewer;
  late String seasonal;
  late String seasonalOther;

  static Future<String> _made(
    Repository r,
    String home,
    String title, {
    required bool photo,
    required void Function(String report) into,
  }) async {
    final report = await r.createReport(
      home,
      title: title,
      photo: photo ? processPhoto(jpegWithGps(orientation: 1)) : null,
    );
    into(report);
    return r.makeTask(report);
  }

  /// Two more tasks made from a report with a photo, limited to the season
  /// that is on and without a date, so that they are in the section In
  /// season of Today. Apart from [seed]: the lists of the goldens stay as
  /// they are.
  Future<void> seedSeason(Repository r, {required int month}) async {
    seasonal = await _made(
      r,
      home,
      'Clear the gutters',
      photo: true,
      into: (_) {},
    );
    seasonalOther = await _made(
      r,
      home,
      'Cover the pool',
      photo: true,
      into: (_) {},
    );
    for (final id in [seasonal, seasonalOther]) {
      await r.db.customStatement(
        'UPDATE tasks SET season_start_month = ?, season_end_month = ? '
        'WHERE id = ?',
        [month, month, uuidBytes(id)],
      );
    }
  }

  static Future<ReportOrigin> seed(Repository r) async {
    final data = ReportOrigin();
    final home = data.home = await r.createHome(name: 'House');
    data.withPhoto = await _made(
      r,
      home,
      'Leak under the sink',
      photo: true,
      into: (id) => data.reportWithPhoto = id,
    );
    data.photoMissing = await _made(
      r,
      home,
      'Crack in the wall',
      photo: true,
      into: (id) => data.reportMissing = id,
    );
    r.reportPhoto((await r.report(data.reportMissing))!).deleteSync();
    data.noPhoto = await _made(
      r,
      home,
      'Door squeaks',
      photo: false,
      into: (id) => data.reportNoPhoto = id,
    );
    data.deleted = await _made(
      r,
      home,
      'Broken tile',
      photo: true,
      into: (id) => data.reportDeleted = id,
    );
    await r.db.customStatement(
      'UPDATE reports SET deleted_at = 1 WHERE id = ?',
      [uuidBytes(data.reportDeleted)],
    );
    data.closed = await _made(
      r,
      home,
      'Loose handrail',
      photo: true,
      into: (id) => data.reportClosed = id,
    );
    await r.closeReport(data.reportClosed, reportResolved);
    data.twoReports = await _made(
      r,
      home,
      'Damp patch',
      photo: false,
      into: (id) => data.reportOlder = id,
    );
    // A second report on the same task, made later.
    data.reportNewer = await r.createReport(
      home,
      title: 'Damp patch again',
      photo: processPhoto(jpegWithGps(orientation: 1)),
    );
    await r.db.customStatement(
      'UPDATE reports SET task_id = ?, created_at = created_at + 5000 '
      'WHERE id = ?',
      [uuidBytes(data.twoReports), uuidBytes(data.reportNewer)],
    );
    data.plain = await r.createTask(
      home,
      const TaskInput(title: 'Service the boiler'),
    );
    // One order on every run: the rows were made at the same instant, and
    // the lists order them by that instant, then by their random id.
    final order = [
      data.withPhoto,
      data.photoMissing,
      data.noPhoto,
      data.deleted,
      data.closed,
      data.twoReports,
      data.plain,
    ];
    for (var i = 0; i < order.length; i++) {
      await r.db.customStatement(
        'UPDATE occurrences SET created_at = created_at + ? WHERE task_id = ?',
        [i, uuidBytes(order[i])],
      );
    }
    return data;
  }
}
