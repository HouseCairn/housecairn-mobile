// SPDX-License-Identifier: AGPL-3.0-only

// QR labels on the phone (docs/adr/0014-qr-labels.md): the code and what the
// QR code holds, the reader of the scanner on images made here (QR, EAN-8,
// EAN-13, UPC-A), the sheet in the web's layouts, the rules of the
// repository, the migration to schema 11, and the screens.

import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:housecairn_mobile/core/code_camera.dart';
import 'package:housecairn_mobile/data/database.dart';
import 'package:housecairn_mobile/data/repository.dart';
import 'package:housecairn_mobile/domain/label_sheet.dart';
import 'package:housecairn_mobile/domain/guide.dart';
import 'package:housecairn_mobile/domain/labels.dart';
import 'package:housecairn_mobile/domain/scanned_code.dart';
import 'package:housecairn_mobile/l10n/app_localizations_en.dart';
import 'package:housecairn_mobile/ui/label_screens.dart';
import 'package:housecairn_mobile/ui/rooms.dart';
import 'package:housecairn_mobile/ui/scanner.dart';
import 'package:material_ui/material_ui.dart';
import 'package:zxing_lib/oned.dart';
import 'package:zxing_lib/zxing.dart';

import 'drift/housecairn/generated/schema.dart';
import 'support/app.dart';
import 'support/fixture.dart';
import 'support/lot2b.dart';

/// [rows] of modules drawn at [scale] pixels each, with the quiet zone, as
/// the luminance of a frame: 0 for a dark module, 255 for a light one.
LumaFrame frameOf(List<List<bool>> rows, {int scale = 4, int quiet = 4}) {
  final side = (rows.length + 2 * quiet) * scale;
  final bytes = Uint8List(side * side)..fillRange(0, side * side, 255);
  for (var r = 0; r < rows.length; r++) {
    for (var c = 0; c < rows[r].length; c++) {
      if (!rows[r][c]) continue;
      for (var y = 0; y < scale; y++) {
        for (var x = 0; x < scale; x++) {
          bytes[((r + quiet) * scale + y) * side + (c + quiet) * scale + x] = 0;
        }
      }
    }
  }
  return LumaFrame(bytes, side, side);
}

/// The bars of a product code made by ZXing's writer, as a frame.
LumaFrame barsOf(Writer writer, String text, BarcodeFormat format) {
  final matrix = writer.encode(text, format, 400, 120);
  final bytes = Uint8List(matrix.width * matrix.height);
  for (var y = 0; y < matrix.height; y++) {
    for (var x = 0; x < matrix.width; x++) {
      bytes[y * matrix.width + x] = matrix.get(x, y) ? 0 : 255;
    }
  }
  return LumaFrame(bytes, matrix.width, matrix.height);
}

/// A camera that gives [code] once started, or throws [error].
class FakeCodeCamera implements CodeCamera {
  FakeCodeCamera({this.code, this.error});

  final ScannedCode? code;
  final Object? error;
  int starts = 0;
  int stops = 0;

  @override
  Future<void> start(
    Set<CodeFormat> formats,
    void Function(ScannedCode code) onCode,
  ) async {
    starts++;
    if (error != null) throw error!;
    final found = code;
    if (found != null) Future<void>.delayed(Duration.zero, () => onCode(found));
  }

  @override
  Widget preview() => const ColoredBox(color: Colors.black);

  @override
  Future<void> stop() async => stops++;
}

const _code = 'AbCdEfGhIjKlMnOpQrSt_-';

/// Where the sheet puts the first labels, read from the objects of an
/// uncompressed PDF: the white square under each QR code (`x y side`) and the
/// start of each name (`x y`), in points.
class _Placed {
  _Placed(String pdf)
    : squares = [
        for (final m in RegExp(
          r'1 1 1 rg ([\d.]+) ([\d.]+) ([\d.]+) ([\d.]+) re f',
        ).allMatches(pdf))
          [for (var i = 1; i <= 4; i++) double.parse(m.group(i)!)],
      ],
      names = [
        for (final m in RegExp(
          r'/F\d+ [\d.]+ Tf ([\d.]+) ([\d.]+) Td',
        ).allMatches(pdf))
          [double.parse(m.group(1)!), double.parse(m.group(2)!)],
      ],
      module = double.parse(
        RegExp(r'0 0 0 rg [\d.]+ [\d.]+ [\d.]+ ([\d.]+) re')
            .firstMatch(pdf)!
            .group(1)!,
      );

  final List<List<double>> squares;
  final List<List<double>> names;

  /// The height of the first dark run: one module.
  final double module;
}

void _near(List<double> actual, List<double> expected) {
  expect(actual, hasLength(expected.length));
  for (var i = 0; i < expected.length; i++) {
    expect(actual[i], closeTo(expected[i], 0.01), reason: 'value $i');
  }
}

void main() {
  group('the code and what the QR code holds', () {
    test('a new code is the web\'s: 16 bytes, 22 URL-safe characters', () {
      final random = Random(7);
      final codes = {for (var i = 0; i < 200; i++) newLabelCode(random)};
      expect(codes, hasLength(200));
      for (final code in codes) {
        expect(code, hasLength(labelCodeLength));
        expect(isLabelCode(code), isTrue, reason: code);
        expect(base64Url.decode('$code=='), hasLength(labelCodeBytes));
      }
    });

    test('the QR code of a label holds the code alone: no address', () {
      final payload = labelPayload(_code);
      expect(payload, _code);
      expect(payload, isNot(contains('/')));
      expect(payload, isNot(contains('.')));
      expect(payload, isNot(contains(':')));
    });

    test('a scanned code: the code alone, or the code of a web sticker', () {
      expect(labelCodeIn(_code), _code);
      expect(labelCodeIn(' $_code\n'), _code);
      expect(labelCodeIn('https://housecairn.example.com/l/$_code/'), _code);
      expect(labelCodeIn('http://192.0.2.10:8000/l/$_code'), _code);
      expect(labelCodeIn('https://example.com/sub/l/$_code/'), _code);
      expect(labelCodeIn('https://example.com/x/$_code/'), isNull);
      expect(labelCodeIn('https://example.com/l/$_code/?next=/'), isNull);
      expect(labelCodeIn('ftp://example.com/l/$_code/'), isNull);
      expect(labelCodeIn('${_code}x'), isNull);
      expect(labelCodeIn('hcinvite:1:abc'), isNull);
      expect(labelCodeIn(''), isNull);
    });

    test(
      'text of a label: one line, cut at 120, ? where Helvetica has none',
      () {
        expect(printableLabelText('  Boiler\n\tcellar  '), 'Boiler cellar');
        expect(printableLabelText('Prix 5 € – œuvre'), 'Prix 5 € – œuvre');
        expect(printableLabelText('Fuse 🙂 box'), 'Fuse ? box');
        expect(printableLabelText('Ω'), '?');
        expect(printableLabelText('a' * 200), 'a' * 120);
        expect(winAnsiText('5 €'), '5 \u0080');
      },
    );
  });

  group('the reader of the scanner', () {
    test('reads back the QR code of a label, at error correction Q', () {
      final random = Random(3);
      for (var i = 0; i < 5; i++) {
        final code = newLabelCode(random);
        final frame = frameOf(labelMatrix(labelPayload(code)));
        expect(
          readCode(frame, {CodeFormat.qr}),
          ScannedCode(CodeFormat.qr, code),
        );
      }
      // Version 3 at level Q for 22 bytes: 29 modules a side.
      expect(labelMatrix(_code), hasLength(29));
    });

    test('reads EAN-13, EAN-8 and UPC-A with the same function', () {
      const formats = {CodeFormat.ean8, CodeFormat.ean13, CodeFormat.upcA};
      expect(
        readCode(
          barsOf(EAN13Writer(), '4006381333931', BarcodeFormat.ean13),
          formats,
        ),
        const ScannedCode(CodeFormat.ean13, '4006381333931'),
      );
      expect(
        readCode(barsOf(EAN8Writer(), '96385074', BarcodeFormat.ean8), formats),
        const ScannedCode(CodeFormat.ean8, '96385074'),
      );
      expect(
        readCode(
          barsOf(UPCAWriter(), '036000291452', BarcodeFormat.upcA),
          formats,
        ),
        const ScannedCode(CodeFormat.upcA, '036000291452'),
      );
    });

    test('reads only the kinds asked for', () {
      final qr = frameOf(labelMatrix(_code));
      expect(readCode(qr, {CodeFormat.ean13}), isNull);
      expect(readCode(qr, const {}), isNull);
      final bars = barsOf(EAN13Writer(), '4006381333931', BarcodeFormat.ean13);
      expect(readCode(bars, {CodeFormat.qr}), isNull);
      final blank = LumaFrame(
        Uint8List(64 * 64)..fillRange(0, 4096, 255),
        64,
        64,
      );
      expect(readCode(blank, {...CodeFormat.values}), isNull);
    });
  });

  group('the sheet', () {
    List<Sticker> stickers(int n) => [
      for (var i = 0; i < n; i++)
        Sticker(name: 'Boiler $i', place: 'Cellar', code: _code),
    ];

    test(
      'A4, 3 by 8: 25 labels on two pages of A4, set in Helvetica',
      () async {
        final pdf = latin1.decode(
          await labelSheet(stickers(25), a4Sheet, compress: false),
        );
        expect(RegExp(r'/Type\s*/Page\b').allMatches(pdf), hasLength(2));
        expect(pdf, contains('/MediaBox[0 0 595.27559 841.88976]'));
        expect(pdf, contains('/Helvetica-Bold'));
        expect(pdf, contains('/WinAnsiEncoding'));
        expect(pdf, isNot(contains('/FontFile')));
        expect(pdf, isNot(contains('/URI')));
        expect(pdf, contains('(Boiler 24)'));
        expect(pdf, contains('(Cellar)'));
      },
    );

    test('the roll: one label per page of 62 by 40 mm', () async {
      final pdf = latin1.decode(
        await labelSheet(stickers(3), roll62, compress: false),
      );
      expect(RegExp(r'/Type\s*/Page\b').allMatches(pdf), hasLength(3));
      expect(pdf, contains('/MediaBox[0 0 175.74803 113.38583]'));
    });

    // The numbers of `labels/printing.py` of the web v0.5.1, computed from
    // its layouts (ReportLab points, A4 = 595.27559 by 841.88976).
    test('A4: the first labels where the web puts them', () async {
      final placed = _Placed(
        latin1.decode(await labelSheet(stickers(2), a4Sheet, compress: false)),
      );
      // Square, then name: left 7.2 + 1.5 mm, top 15.1 mm, QR 27 mm.
      _near(placed.squares[0], [24.66142, 712.77165, 76.53543, 76.53543]);
      _near(placed.names[0], [105.44882, 786.33465]);
      // Next column: 63.5 + 2.5 mm to the right (the gap).
      _near(placed.squares[1], [211.74803, 712.77165, 76.53543, 76.53543]);
      _near(placed.names[2], [292.53543, 786.33465]);
    });

    test('the roll: the label where the web puts it', () async {
      final placed = _Placed(
        latin1.decode(await labelSheet(stickers(1), roll62, compress: false)),
      );
      _near(placed.squares.single, [4.25197, 11.33858, 90.70866, 90.70866]);
      _near(placed.names.first, [99.2126, 99.13386]);
    });

    test('the quiet zone is 4 modules, in the PDF too', () async {
      expect(labelQuietZone, 4);
      final modules = labelMatrix(labelPayload(_code)).length;
      for (final layout in labelLayouts) {
        final placed = _Placed(
          latin1.decode(await labelSheet(stickers(1), layout, compress: false)),
        );
        expect(
          placed.module,
          closeTo(placed.squares.first[2] / (modules + 8), 0.0001),
          reason: layout.code,
        );
      }
    });

    test('between 1 and 200 labels', () async {
      expect(() => labelSheet(const [], a4Sheet), throwsArgumentError);
      expect(() => labelSheet(stickers(201), a4Sheet), throwsArgumentError);
      expect(await labelSheet(stickers(200), a4Sheet), isNotEmpty);
    });

    test('the web\'s numbers', () {
      expect(a4Sheet.perPage, 24);
      expect(a4Sheet.label.$1, closeTo(180.0, 0.01));
      expect(a4Sheet.label.$2, closeTo(96.09, 0.01));
      expect(labelLayouts.first, a4Sheet);
      expect([for (final l in labelLayouts) l.code], ['a4-3x8', 'roll-62']);
    });
  });

  group('the repository', () {
    late Repository repo;
    late String home;
    late String room;
    late String item;
    late String article;

    setUp(() async {
      repo = await openRepository();
      addTearDown(repo.db.close);
      home = await repo.createHome(name: 'Main home');
      room = await repo.createRoom(home, name: 'Kitchen');
      item = await repo.createItem(home, roomId: room, name: 'Boiler');
      article = await repo.addArticle(
        home,
        const ArticleInput(name: 'Filter', storageLocation: 'Shelf 2'),
      );
    });

    Future<int> count(String table) async =>
        (await repo.db
                    .customSelect('SELECT COUNT(*) AS n FROM $table')
                    .getSingle())
                .data['n']
            as int;

    test('one active label per object, with a code of the web', () async {
      final (label, created) = await repo.createLabel(
        home,
        LabelKind.item,
        item,
      );
      expect(created, isTrue);
      expect(isLabelCode(label.code), isTrue);
      final (again, createdAgain) = await repo.createLabel(
        home,
        LabelKind.item,
        item,
      );
      expect(createdAgain, isFalse);
      expect(again.id, label.id);
      expect(await repo.labelText(label), ('Boiler', 'Kitchen'));
      final (other, _) = await repo.createLabel(
        home,
        LabelKind.article,
        article,
      );
      expect(await repo.labelText(other), ('Filter', 'Shelf 2'));
      expect(other.code, isNot(label.code));
    });

    test('kept on the phone: no clock, no operation', () async {
      final before = (await count('op_log'), await count('field_clock'));
      final (label, _) = await repo.createLabel(home, LabelKind.room, room);
      await repo.regenerateLabel(label.id);
      expect((await count('op_log'), await count('field_clock')), before);
    });

    test('regenerate: the old code is revoked, the new one opens', () async {
      final (label, _) = await repo.createLabel(home, LabelKind.room, room);
      final fresh = await repo.regenerateLabel(label.id);
      expect(fresh.code, isNot(label.code));
      expect((await repo.lookUpLabel(label.code)).lookup, LabelLookup.revoked);
      final found = await repo.lookUpLabel(fresh.code);
      expect(found.lookup, LabelLookup.found);
      expect(found.label!.id, fresh.id);
      expect((await repo.activeLabel(LabelKind.room, room))!.id, fresh.id);
      await expectLater(
        repo.regenerateLabel(label.id),
        throwsA(isA<Refused>()),
      );
    });

    test('revoke: the sticker opens nothing, the row stays', () async {
      final (label, _) = await repo.createLabel(home, LabelKind.room, room);
      await repo.revokeLabel(label.id);
      expect(await repo.activeLabel(LabelKind.room, room), isNull);
      expect((await repo.lookUpLabel(label.code)).lookup, LabelLookup.revoked);
      expect(await count('labels'), 1);
      final (next, created) = await repo.createLabel(
        home,
        LabelKind.room,
        room,
      );
      expect(created, isTrue);
      expect(next.code, isNot(label.code));
    });

    test('unknown, gone, and not shaped as a code', () async {
      expect((await repo.lookUpLabel(_code)).lookup, LabelLookup.unknown);
      expect((await repo.lookUpLabel('nope')).lookup, LabelLookup.unknown);
      final (label, _) = await repo.createLabel(home, LabelKind.item, item);
      await repo.deleteItem(item);
      expect((await repo.lookUpLabel(label.code)).lookup, LabelLookup.gone);
    });

    test(
      'refused in an archived home, for an object of another home, ',
      () async {
        final second = await repo.createHome(name: 'Second home');
        await expectLater(
          repo.createLabel(second, LabelKind.room, room),
          throwsA(isA<Refused>()),
        );
        await repo.archiveHome(home);
        await expectLater(
          repo.createLabel(home, LabelKind.room, room),
          throwsA(isA<Refused>()),
        );
        expect(await count('labels'), 0);
      },
    );

    test('the list and the print, in the order of the web', () async {
      final hall = await repo.createRoom(home, name: 'Hall', position: 1);
      await repo.createItem(home, roomId: hall, name: 'Alarm');
      final entries = await repo.labelEntries(home);
      expect(
        [for (final e in entries) (e.kind, e.name, e.place)],
        [
          (LabelKind.room, 'Kitchen', ''),
          (LabelKind.room, 'Hall', ''),
          (LabelKind.item, 'Boiler', 'Kitchen'),
          (LabelKind.item, 'Alarm', 'Hall'),
          (LabelKind.article, 'Filter', 'Shelf 2'),
        ],
      );
      final printed = await repo.labelsToPrint(home, [
        (LabelKind.article, article),
        (LabelKind.room, room),
        (LabelKind.room, room),
      ]);
      expect([for (final l in printed) l.kind], ['article', 'room']);
      expect(await count('labels'), 2);
      await expectLater(
        repo.labelsToPrint(home, const []),
        throwsA(isA<Refused>()),
      );
    });

    group('the example home of the guide has no label', () {
      late String example;
      late String exampleRoom;

      setUp(() async {
        final guide = parseGuide(File('design/guide.json').readAsStringSync());
        example = await repo.createExampleHome(guide);
        exampleRoom = await repo.createRoom(example, name: 'Kitchen');
        // A row that could only come from outside: the repository never
        // makes one in the example home.
        await repo.db.customStatement(
          'INSERT INTO labels (id, created_at, updated_at, home_id, kind, '
          'room_id, code) SELECT x\'0123456789ab4def8123456789abcdef\', 1, 1, '
          'h.id, ?, r.id, ? FROM homes h JOIN rooms r ON r.home_id = h.id '
          'WHERE h.is_example = 1',
          ['room', _code],
        );
      });

      Future<LabelRow> planted() async =>
          (await repo.db.select(repo.db.labels).getSingle());

      Matcher notFound() => throwsA(
        isA<Refused>().having((r) => r.reason, 'reason', Refusal.notFound),
      );

      test('createLabel is refused', () async {
        await expectLater(
          repo.createLabel(example, LabelKind.room, exampleRoom),
          notFound(),
        );
        expect(await count('labels'), 1);
      });

      test('regenerateLabel is refused', () async {
        final label = await planted();
        await expectLater(repo.regenerateLabel(label.id), notFound());
        expect(await count('labels'), 1);
        expect((await planted()).revokedAt, isNull);
      });

      test('revokeLabel is refused', () async {
        final label = await planted();
        await expectLater(repo.revokeLabel(label.id), notFound());
        expect((await planted()).revokedAt, isNull);
      });
    });

    test('erased with its home', () async {
      final second = await repo.createHome(name: 'Second home');
      final secondRoom = await repo.createRoom(second, name: 'Attic');
      await repo.createLabel(home, LabelKind.room, room);
      await repo.createLabel(second, LabelKind.room, secondRoom);
      await repo.deleteHome(second, typedName: 'Second home');
      expect(await count('labels'), 1);
    });
  });

  group('schema 11', () {
    test(
      'a schema 10 file with data keeps its rows, and has no label',
      () async {
        final verifier = SchemaVerifier(GeneratedHelper());
        final schema = await verifier.schemaAt(10);
        final raw = schema.rawDatabase;
        Uint8List id(int n) => Uint8List.fromList(List.filled(16, n));
        raw.execute(
          'INSERT INTO homes (id, created_at, updated_at, name, currency, '
          'hemisphere, is_example) VALUES (?, 1, 1, ?, ?, ?, 0)',
          [id(1), 'Main home', 'EUR', 'north'],
        );
        raw.execute(
          'INSERT INTO rooms (id, created_at, updated_at, home_id, name) '
          'VALUES (?, 1, 1, ?, ?)',
          [id(2), id(1), 'Kitchen'],
        );
        final db = AppDatabase(schema.newConnection());
        await verifier.migrateAndValidate(db, 11);
        final rooms = await db.customSelect('SELECT name FROM rooms').get();
        expect([for (final r in rooms) r.data['name']], ['Kitchen']);
        final labels = await db
            .customSelect('SELECT COUNT(*) AS n FROM labels')
            .getSingle();
        expect(labels.data['n'], 0);
        expect(await db.integrityCheck(), 'ok');
        await db.close();
      },
    );
  });

  group('the screens', () {
    final l10n = AppLocalizationsEn();

    testWidgets('a room: make its label, see what the code holds, print it', (
      tester,
    ) async {
      await onPhone(tester);
      late Lot2b data;
      final shared = <(String, String, bool)>[];
      await pumpApp(
        tester,
        seed: (r) async => data = await Lot2b.seed(r),
        openFile: (path, {required name, required type, origin}) async {
          shared.add((name, type, File(path).existsSync()));
          return true;
        },
      );
      await openScreen(
        tester,
        RoomScreen(homeId: data.homes.main, roomId: data.kitchen),
      );
      await tester.ensureVisible(find.byKey(const Key('label-make-room')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('label-make-room')));
      await tester.pumpAndSettle();
      expect(find.byType(LabelScreen), findsOneWidget);
      final repo = stateOf(tester).repository;
      final label = (await tester.runAsync(
        () => repo.activeLabel(LabelKind.room, data.kitchen),
      ))!;
      expect(find.text(label.code), findsOneWidget);
      expect(find.text(l10n.labelHolds), findsOneWidget);
      expect(
        find.bySemanticsLabel(l10n.labelQrOf('Main kitchen')),
        findsOneWidget,
      );
      await tester.ensureVisible(find.byKey(const Key('label-print')));
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        await tester.tap(find.byKey(const Key('label-print')));
        await Future<void>.delayed(const Duration(milliseconds: 500));
      });
      await tester.pumpAndSettle();
      expect(shared, [('housecairn-labels.pdf', 'application/pdf', true)]);
      expect(Directory('${repo.files.path}/print').listSync(), isEmpty);
    });

    testWidgets('revoke after a confirmation', (tester) async {
      await onPhone(tester);
      late Lot2b data;
      await pumpApp(
        tester,
        seed: (r) async {
          data = await Lot2b.seed(r);
          await r.createLabel(data.homes.main, LabelKind.room, data.kitchen);
        },
      );
      await openScreen(
        tester,
        RoomScreen(homeId: data.homes.main, roomId: data.kitchen),
      );
      await tester.ensureVisible(find.byKey(const Key('label-room')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('label-room')));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.byKey(const Key('label-revoke')),
        200,
        scrollable: find
            .descendant(
              of: find.byType(LabelScreen),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('label-revoke')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('label-revoke-confirm')));
      await tester.pumpAndSettle();
      expect(find.text(l10n.labelRevoked), findsOneWidget);
      expect(find.byKey(const Key('label-make-room')), findsOneWidget);
    });

    Future<FakeCodeCamera> scan(
      WidgetTester tester,
      Future<String?> Function(Repository r, Lot2b data) seed, {
      Object? error,
    }) async {
      await onPhone(tester);
      late FakeCodeCamera camera;
      String? text;
      await pumpApp(
        tester,
        seed: (r) async => text = await seed(r, await Lot2b.seed(r)),
        codeCamera: () => camera = FakeCodeCamera(
          code: text == null ? null : ScannedCode(CodeFormat.qr, text!),
          error: error,
        ),
      );
      await tester.tap(
        find
            .descendant(
              of: find.byType(NavigationBar),
              matching: find.byType(NavigationDestination),
            )
            .last,
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const Key('more-labels')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('more-labels')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('labels-scan')));
      await tester.pumpAndSettle();
      return camera;
    }

    testWidgets('scan a label of this phone: its page opens', (tester) async {
      final camera = await scan(tester, (r, data) async {
        final (label, _) = await r.createLabel(
          data.homes.main,
          LabelKind.room,
          data.kitchen,
        );
        return label.code;
      });
      expect(camera.starts, 1);
      expect(camera.stops, 1);
      expect(find.byType(RoomScreen), findsOneWidget);
      expect(find.byType(CodeScannerScreen), findsNothing);
    });

    testWidgets('scan the sticker of the web whose code this phone has', (
      tester,
    ) async {
      await scan(tester, (r, data) async {
        final (label, _) = await r.createLabel(
          data.homes.main,
          LabelKind.room,
          data.kitchen,
        );
        return 'https://housecairn.example.com/l/${label.code}/';
      });
      expect(find.byType(RoomScreen), findsOneWidget);
    });

    testWidgets('scan an unknown, a revoked, a foreign code', (tester) async {
      await scan(tester, (r, data) async => _code);
      expect(find.text(l10n.scanUnknown), findsOneWidget);
    });

    testWidgets('scan a revoked label', (tester) async {
      await scan(tester, (r, data) async {
        final (label, _) = await r.createLabel(
          data.homes.main,
          LabelKind.room,
          data.kitchen,
        );
        await r.revokeLabel(label.id);
        return label.code;
      });
      expect(find.text(l10n.scanRevoked), findsOneWidget);
    });

    testWidgets('scan a QR code that is not a label', (tester) async {
      await scan(tester, (r, data) async => 'https://example.com/');
      expect(find.text(l10n.scanNotLabel), findsOneWidget);
    });

    testWidgets('the camera is asked for at the scan only; refused, the '
        'scanner says so', (tester) async {
      final camera = await scan(
        tester,
        (r, data) async => null,
        error: const CodeCameraDenied(),
      );
      expect(camera.starts, 1);
      expect(find.text(l10n.scanDenied), findsOneWidget);
    });

    testWidgets('the list of labels meets the accessibility guidelines', (
      tester,
    ) async {
      await onPhone(tester);
      late Lot2b data;
      await pumpApp(tester, seed: (r) async => data = await Lot2b.seed(r));
      await openScreen(tester, LabelsScreen(homeId: data.homes.main));
      final handle = tester.ensureSemantics();
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      handle.dispose();
    });
  });
}
