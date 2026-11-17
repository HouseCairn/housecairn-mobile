// SPDX-License-Identifier: AGPL-3.0-only

import 'package:flutter_test/flutter_test.dart';
import 'package:housecairn_mobile/core/document_source.dart';
import 'package:housecairn_mobile/data/repository.dart';
import 'package:housecairn_mobile/l10n/app_localizations_en.dart';
import 'package:housecairn_mobile/ui/report_screens.dart';
import 'package:housecairn_mobile/ui/state.dart' show FileOpener;
import 'package:housecairn_mobile/ui/stock_screens.dart';
import 'package:housecairn_mobile/ui/task_screen.dart';
import 'package:material_ui/material_ui.dart';

import 'support/app.dart';
import 'support/fakes.dart';
import 'support/lot2b.dart';
import 'support/lot3b.dart' show FakeDocuments;
import 'support/lot4d.dart';

/// The photos and files of a task, the photo of a report and the label of
/// an article on their screens (lot 4d, docs/adr/0013).
void main() {
  final l = AppLocalizationsEn();

  Future<Lot4d> open(
    WidgetTester tester,
    Widget Function(Lot4d data) screen, {
    FakeDocuments? documents,
    FileOpener? openFile,
    bool archived = false,
  }) async {
    await onPhone(tester, height: 1600);
    late Lot4d data;
    await pumpApp(
      tester,
      seed: (r) async {
        data = await Lot4d.seed(r);
        if (archived) {
          await r.createHome(name: 'Other');
          await r.archiveHome(data.home);
        }
      },
      photoSource: cameraWith(),
      documentSource: documents ?? FakeDocuments(),
      notifier: FakeNotifier(),
      openFile: openFile,
    );
    await openScreen(tester, screen(data));
    return data;
  }

  Future<void> scrollTo(WidgetTester tester, Finder finder) async {
    await tester.scrollUntilVisible(
      finder,
      200,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();
  }

  TaskScreen taskOf(Lot4d d) => TaskScreen(homeId: d.home, taskId: d.task);

  testWidgets('the page of a task lists its photos, then its files with '
      'their size, under Photos and files, then the add button', (
    tester,
  ) async {
    final d = await open(tester, taskOf);
    await scrollTo(tester, find.byKey(const Key('attachment-add')));
    expect(find.text(l.attachmentsHeading.toUpperCase()), findsOneWidget);
    expect(find.text('boiler.jpg'), findsOneWidget);
    expect(find.text('valve.jpg'), findsOneWidget);
    expect(find.text('invoice.pdf'), findsOneWidget);
    expect(find.text(l.fileSizeKb('2.5')), findsOneWidget);
    expect(find.text(l.addAttachments), findsOneWidget);
    final photoTop = tester.getTopLeft(
      find.byKey(Key('attachment-${d.photo}')),
    );
    final pdfTop = tester.getTopLeft(find.byKey(Key('attachment-${d.pdf}')));
    expect(photoTop.dy, lessThan(pdfTop.dy), reason: 'photos, then files');
    expect(
      find.bySemanticsLabel(
        RegExp('${l.attachmentPhotoLabel('valve.jpg')}, ${l.photoNotHere}'),
      ),
      findsOneWidget,
      reason: 'a photo not on the phone is a tile, said as such',
    );
  });

  testWidgets('a PDF picked is attached to the task', (tester) async {
    final documents = FakeDocuments(
      PickedDocument('quote.pdf', Lot4d.pdfBytes, 'application/pdf'),
    );
    await open(tester, taskOf, documents: documents);
    await scrollTo(tester, find.byKey(const Key('attachment-add')));
    await tester.tap(find.byKey(const Key('attachment-add')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('attachment-document')));
    await tester.pumpAndSettle();
    expect(documents.asked, 1);
    await scrollTo(tester, find.text('quote.pdf'));
    expect(find.text('quote.pdf'), findsOneWidget);
  });

  testWidgets('a photo taken is attached to the task', (tester) async {
    final d = await open(tester, taskOf);
    final repository = stateOf(tester).repository;
    await scrollTo(tester, find.byKey(const Key('attachment-add')));
    await tester.tap(find.byKey(const Key('attachment-add')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('attachment-camera')));
    await tester.pumpAndSettle();
    // The photo is re-encoded and written on the real file system.
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 300)),
    );
    await tester.pumpAndSettle();
    await scrollTo(tester, find.text('photo.jpg'));
    expect(find.text('photo.jpg'), findsOneWidget);
    final all = await tester.runAsync(() => repository.attachmentsOf(d.task));
    expect(all, hasLength(4));
    expect(all!.last.isImage, isTrue);
  });

  testWidgets('a file opens in another app, and is deleted after a '
      'confirmation', (tester) async {
    final opened = <(String, String)>[];
    final d = await open(
      tester,
      taskOf,
      openFile: (path, {required name, required type, origin}) async {
        opened.add((name, type));
        return true;
      },
    );
    await scrollTo(tester, find.byKey(Key('attachment-${d.pdf}')));
    await tester.tap(find.byKey(Key('attachment-${d.pdf}')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('attachment-open')));
    await tester.pumpAndSettle();
    expect(opened, [('invoice.pdf', 'application/pdf')]);
    await tester.tap(find.byKey(const Key('attachment-delete')));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l.delete).last);
    await tester.pumpAndSettle();
    final repository = stateOf(tester).repository;
    expect(await tester.runAsync(() => repository.attachment(d.pdf)), isNull);
    expect(find.text('invoice.pdf'), findsNothing);
  });

  testWidgets('a photo opens full width', (tester) async {
    final d = await open(tester, taskOf);
    await scrollTo(tester, find.byKey(Key('attachment-${d.photo}')));
    await tester.tap(find.byKey(Key('attachment-${d.photo}')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('attachment-image')), findsOneWidget);
  });

  testWidgets('in an archived home: no add button, nothing to delete', (
    tester,
  ) async {
    final d = await open(tester, taskOf, archived: true);
    await scrollTo(tester, find.text('invoice.pdf'));
    expect(find.byKey(const Key('attachment-add')), findsNothing);
    await tester.tap(find.byKey(Key('attachment-${d.pdf}')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('attachment-delete')), findsNothing);
  });

  testWidgets('the photo of a report not on the phone yet is a tile', (
    tester,
  ) async {
    await open(tester, (d) => ReportScreen(homeId: d.home, reportId: d.report));
    expect(find.byKey(const Key('report-photo-missing')), findsOneWidget);
    expect(find.byKey(const Key('report-photo')), findsNothing);
  });

  testWidgets('the label of an article not on the phone yet is a tile', (
    tester,
  ) async {
    await open(
      tester,
      (d) => ArticleScreen(homeId: d.home, articleId: d.article),
    );
    expect(find.byKey(const Key('article-label-missing')), findsOneWidget);
    expect(
      find.bySemanticsLabel(
        RegExp('${l.articleLabelPhoto('Boiler filter')}, ${l.photoNotHere}'),
      ),
      findsOneWidget,
    );
  });
}
