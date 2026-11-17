// SPDX-License-Identifier: AGPL-3.0-only

import 'dart:typed_data';

import 'package:housecairn_mobile/data/database.dart' show uuidBytes;
import 'package:housecairn_mobile/data/repository.dart';
import 'package:housecairn_mobile/domain/file_reference.dart';
import 'package:housecairn_mobile/domain/photos.dart';

import 'fakes.dart';

/// The data of the screens of lot 4d: a home with a task that has a photo
/// on the phone, a photo whose file has not come yet and a PDF; a report
/// whose photo has not come yet; a stock article whose label has not come
/// yet. Neutral names only.
class Lot4d {
  late String home;
  late String task;
  late String photo;
  late String missingPhoto;
  late String pdf;
  late String report;
  late String article;

  static final pdfBytes = Uint8List.fromList(
    List.generate(2600, (i) => i % 251),
  );

  static Future<Lot4d> seed(Repository r) async {
    final data = Lot4d();
    final home = data.home = await r.createHome(name: 'House');
    data.task = await r.createTask(
      home,
      const TaskInput(title: 'Service the boiler'),
    );
    data.photo = await r.addAttachment(
      data.task,
      name: 'boiler.jpg',
      bytes: jpegWithGps(orientation: 1),
      contentType: 'image/jpeg',
    );
    data.missingPhoto = await r.addAttachment(
      data.task,
      name: 'valve.jpg',
      bytes: jpegWithGps(orientation: 1),
      contentType: 'image/jpeg',
    );
    r.attachmentFile((await r.attachment(data.missingPhoto))!).deleteSync();
    // One order on every run: the rows were made at the same instant.
    await r.db.customStatement(
      'UPDATE task_attachments SET created_at = created_at + 1 WHERE id = ?',
      [uuidBytes(data.missingPhoto)],
    );
    data.pdf = await r.addAttachment(
      data.task,
      name: 'invoice.pdf',
      bytes: pdfBytes,
      contentType: 'application/pdf',
    );
    data.report = await r.createReport(
      home,
      title: 'Leak under the sink',
      photo: processPhoto(jpegWithGps(orientation: 1)),
    );
    r.reportPhoto((await r.report(data.report))!).deleteSync();
    data.article = await r.addArticle(
      home,
      const ArticleInput(name: 'Boiler filter'),
    );
    await r.db.customStatement('UPDATE articles SET label = ? WHERE id = ?', [
      FileReference(file: data.article, size: 0, type: 'image/jpeg').encode(),
      uuidBytes(data.article),
    ]);
    return data;
  }
}
