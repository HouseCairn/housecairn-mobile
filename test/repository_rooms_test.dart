// SPDX-License-Identifier: AGPL-3.0-only

// Rooms, items, contractors, photos and task templates of lot 2b: the rules of
// the model of the web (`rooms/models.py`, `tasks/models.py`), written by the
// repository with the clocks of their fields.

import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show Variable;
import 'package:flutter_test/flutter_test.dart';
import 'package:housecairn_mobile/data/database.dart' show uuidBytes;
import 'package:housecairn_mobile/data/repository.dart';
import 'package:housecairn_mobile/domain/day.dart';
import 'package:housecairn_mobile/domain/photos.dart';
import 'package:housecairn_mobile/domain/templates.dart';

import 'support/fakes.dart';
import 'support/fixture.dart';

Matcher refusedWith(Refusal reason) =>
    throwsA(isA<Refused>().having((e) => e.reason, 'reason', reason));

void main() {
  late Repository repo;
  late TwoHomes homes;
  late String kitchen;

  setUp(() async {
    repo = await openRepository();
    homes = await TwoHomes.create(repo);
    kitchen = (await repo.rooms(homes.main))
        .firstWhere((r) => r.name == 'Main kitchen')
        .id;
  });

  group('rooms', () {
    test('listed in the household\'s order, then by creation', () async {
      final a = await repo.createRoom(homes.main, name: 'A', position: 5);
      final b = await repo.createRoom(homes.main, name: 'B', position: 3);
      final names = (await repo.rooms(homes.main)).map((r) => r.name).toList();
      expect(names.indexOf('B'), lessThan(names.indexOf('A')));
      expect(
        (await repo.rooms(homes.main)).map((r) => r.id),
        containsAll([a, b]),
      );
    });

    test('the memory of a room is saved, trimmed', () async {
      await repo.updateRoom(
        kitchen,
        const RoomInput(
          name: ' Kitchen ',
          kind: 'kitchen',
          paintColour: 'Sage',
          paintBrand: 'Brand',
          paintReference: 'R-12',
          paintBatch: 'L-9',
          floorCovering: 'Tiles',
          wallCovering: 'Paint',
          memoryNotes: 'Pipes behind the sink',
          notes: 'South facing',
        ),
      );
      final room = (await repo.room(kitchen))!;
      expect(room.name, 'Kitchen');
      expect(room.kind, 'kitchen');
      expect(room.paintColour, 'Sage');
      expect(room.memoryNotes, 'Pipes behind the sink');
    });

    test(
      'a name is required, a kind must be in the list, texts have a limit',
      () async {
        expect(
          () => repo.updateRoom(kitchen, const RoomInput(name: '  ')),
          refusedWith(Refusal.titleRequired),
        );
        expect(
          () => repo.updateRoom(
            kitchen,
            const RoomInput(name: 'X', kind: 'dungeon'),
          ),
          refusedWith(Refusal.choiceInvalid),
        );
        expect(
          () =>
              repo.updateRoom(kitchen, RoomInput(name: 'X', notes: 'a' * 4001)),
          refusedWith(Refusal.tooLong),
        );
        expect(
          () => repo.updateRoom(
            kitchen,
            RoomInput(name: 'X', paintColour: 'a' * 121),
          ),
          refusedWith(Refusal.tooLong),
        );
      },
    );

    test('only the fields that changed get a new clock', () async {
      final before = await repo.db
          .customSelect(
            "SELECT field, hlc FROM field_clock WHERE entity = 'rooms.room' "
            'AND row_id = ?',
            variables: [/* the id as bytes */ _bytes(kitchen)],
          )
          .get();
      final clocks = {for (final r in before) r.data['field']: r.data['hlc']};
      await repo.updateRoom(
        kitchen,
        const RoomInput(name: 'Main kitchen', paintColour: 'Sage'),
      );
      final after = await repo.db
          .customSelect(
            "SELECT field, hlc FROM field_clock WHERE entity = 'rooms.room' "
            'AND row_id = ?',
            variables: [_bytes(kitchen)],
          )
          .get();
      final next = {for (final r in after) r.data['field']: r.data['hlc']};
      expect(next['paint_colour'], isNotNull);
      expect(next['name'], clocks['name'], reason: 'the name did not change');
      expect(next['kind'], clocks['kind']);
    });

    test('an archived home is read only', () async {
      await repo.archiveHome(homes.second);
      final room = (await repo.rooms(homes.second)).first.id;
      expect(
        () => repo.updateRoom(room, const RoomInput(name: 'X')),
        refusedWith(Refusal.homeArchived),
      );
      expect(() => repo.deleteRoom(room), refusedWith(Refusal.homeArchived));
    });

    test('deleting a room deletes its items and photos; its tasks stay, with no room', () async {
      final cellar = (await repo.rooms(homes.main))
          .firstWhere((r) => r.name == 'Main cellar')
          .id;
      final item = (await repo.itemsOf(cellar)).single.id;
      final photo = (await repo.photosOf(roomId: cellar)).single.id;
      final task = await repo.createTask(
        homes.main,
        TaskInput(title: 'In the cellar', roomId: cellar, itemId: item),
      );
      await repo.deleteRoom(cellar);
      expect(await repo.room(cellar), isNull);
      expect(await repo.item(item), isNull);
      expect(await repo.photosOf(roomId: cellar), isEmpty);
      expect(photo, isNotEmpty);
      final kept = (await repo.task(task))!;
      expect(kept.roomId, isNull);
      expect(kept.itemId, isNull);
      // The other home is untouched.
      expect(await repo.rooms(homes.second), hasLength(2));
    });
  });

  group('items', () {
    test('an item with every field', () async {
      final provider = await repo.addContractor(
        homes.main,
        const ContractorInput(name: 'Acme Heating'),
      );
      final id = await repo.addItem(
        kitchen,
        ItemInput(
          name: 'Oven',
          brand: 'Brand',
          model: 'M1',
          serialNumber: 'SN-1',
          installedOn: Day(2024, 3, 1),
          warrantyEndsOn: Day(2027, 3, 1),
          contractContractorId: provider,
          contractNumber: 'C-2024-0187',
          contractUrl: 'https://example.com/contract',
          links: const [
            ItemLink(url: 'https://example.com/manual', label: 'Manual'),
            ItemLink(url: 'http://example.com/other'),
          ],
          notes: 'Clean the filter',
        ),
      );
      final item = (await repo.item(id))!;
      expect(item.homeId, homes.main);
      expect(item.roomId, kitchen);
      expect(item.installedOn, '2024-03-01');
      expect(item.contractContractorId, provider);
      expect(jsonDecode(item.links), [
        {'url': 'https://example.com/manual', 'label': 'Manual'},
        {'url': 'http://example.com/other'},
      ]);
      expect(Repository.linksOf(item).first.label, 'Manual');
    });

    test('the warranty is none, active or expired at a date', () async {
      final today = repo.today();
      Future<String> state(Day? ends) async {
        final id = await repo.addItem(
          kitchen,
          ItemInput(name: 'I${ends?.iso}', warrantyEndsOn: ends),
        );
        return Repository.warrantyState((await repo.item(id))!, today);
      }

      expect(await state(null), 'none');
      expect(await state(today), 'active', reason: 'the last day still counts');
      expect(await state(today.addDays(1)), 'active');
      expect(await state(today.addDays(-1)), 'expired');
    });

    test('links: at most 10, http or https only, 500 characters', () async {
      Future<void> save(List<ItemLink> links) =>
          repo.addItem(kitchen, ItemInput(name: 'X', links: links));
      await save([
        for (var i = 0; i < 10; i++) ItemLink(url: 'https://example.com/$i'),
      ]);
      expect(
        () => save([
          for (var i = 0; i < 11; i++) ItemLink(url: 'https://example.com/$i'),
        ]),
        refusedWith(Refusal.tooManyLinks),
      );
      for (final bad in [
        'javascript:alert(1)',
        'ftp://example.com',
        'file:///etc/passwd',
        'example.com',
        'https://',
        'https://example.com/a b',
        'https://example.com/${'a' * 500}',
      ]) {
        expect(
          () => save([ItemLink(url: bad)]),
          refusedWith(Refusal.urlInvalid),
          reason: bad,
        );
      }
      expect(
        () => repo.addItem(
          kitchen,
          const ItemInput(name: 'X', contractUrl: 'javascript:alert(1)'),
        ),
        refusedWith(Refusal.urlInvalid),
      );
    });

    test(
      'the provider of a contract is a contractor of the same home',
      () async {
        final other = await repo.addContractor(
          homes.second,
          const ContractorInput(name: 'Elsewhere'),
        );
        expect(
          () => repo.addItem(
            kitchen,
            ItemInput(name: 'X', contractContractorId: other),
          ),
          refusedWith(Refusal.notInHome),
        );
      },
    );

    test(
      'a date more than 100 years away is refused, a kind is checked',
      () async {
        expect(
          () => repo.addItem(
            kitchen,
            ItemInput(name: 'X', warrantyEndsOn: repo.today().addYears(101)),
          ),
          refusedWith(Refusal.dateOutOfRange),
        );
        expect(
          () => repo.addItem(kitchen, const ItemInput(name: 'X', kind: 'pet')),
          refusedWith(Refusal.choiceInvalid),
        );
      },
    );

    test('deleting an item deletes its photos; its tasks stay', () async {
      final id = await repo.addItem(kitchen, const ItemInput(name: 'Oven'));
      await repo.addPhoto(homes.main, processPhoto(jpegWithGps()), itemId: id);
      final task = await repo.createTask(
        homes.main,
        TaskInput(title: 'Clean the oven', itemId: id),
      );
      await repo.deleteItem(id);
      expect(await repo.item(id), isNull);
      expect(await repo.photosOf(itemId: id), isEmpty);
      expect((await repo.task(task))!.itemId, isNull);
    });
  });

  group('contractors', () {
    test('a contractor with every field, by name', () async {
      await repo.addContractor(
        homes.main,
        const ContractorInput(
          name: 'Acme',
          trade: 'other',
          tradeOther: 'Pool maintenance',
          phone: '+33 (0)1 99.00/12-34',
          email: 'office@example.com',
          address: '1 Example street',
          note: 'Ask for the manager',
        ),
      );
      final names = (await repo.contractors(homes.main)).map((c) => c.name);
      expect(names, ['Acme', 'Main plumber']);
    });

    test('phone, e-mail, trade and address follow the web', () async {
      Future<void> save(ContractorInput input) =>
          repo.addContractor(homes.main, input);
      expect(
        () => save(const ContractorInput(name: 'X', phone: '01 99 abc')),
        refusedWith(Refusal.phoneInvalid),
      );
      expect(
        () => save(const ContractorInput(name: 'X', phone: '12')),
        refusedWith(Refusal.phoneInvalid),
      );
      expect(
        () => save(const ContractorInput(name: 'X', email: 'nobody')),
        refusedWith(Refusal.emailInvalid),
      );
      expect(
        () => save(const ContractorInput(name: 'X', trade: 'other')),
        refusedWith(Refusal.tradeOtherRequired),
      );
      expect(
        () => save(const ContractorInput(name: 'X', trade: 'wizard')),
        refusedWith(Refusal.choiceInvalid),
      );
      expect(
        () => save(ContractorInput(name: 'X', address: 'a' * 401)),
        refusedWith(Refusal.tooLong),
      );
      await save(ContractorInput(name: 'Y', address: 'a' * 400));
    });

    test('"which trade" is kept for the trade Other only', () async {
      final id = await repo.addContractor(
        homes.main,
        const ContractorInput(name: 'X', trade: 'plumber', tradeOther: 'Old'),
      );
      expect((await repo.contractor(id))!.tradeOther, '');
    });

    test('deleting a contractor leaves the items and tasks that named them, with none', () async {
      final provider = await repo.addContractor(
        homes.main,
        const ContractorInput(name: 'Acme'),
      );
      final item = await repo.addItem(
        kitchen,
        ItemInput(
          name: 'Boiler',
          contractContractorId: provider,
          contractNumber: 'C-1',
        ),
      );
      final task = await repo.createTask(
        homes.main,
        TaskInput(title: 'Service'),
      );
      await repo.db.customStatement(
        'UPDATE tasks SET contractor_id = ? WHERE id = ?',
        [_bytes(provider).value, _bytes(task).value],
      );
      expect(await repo.tasksOfContractor(provider), hasLength(1));
      await repo.deleteContractor(provider);
      expect(await repo.contractor(provider), isNull);
      final kept = (await repo.item(item))!;
      expect(kept.contractContractorId, isNull);
      expect(kept.contractNumber, 'C-1');
      expect((await repo.task(task))!.contractorId, isNull);
    });
  });

  group('photos', () {
    test('a photo is stored under the id of its row, with its thumbnail and reference', () async {
      final stored = processPhoto(jpegWithGps());
      final id = await repo.addPhoto(
        homes.main,
        stored,
        roomId: kitchen,
        category: 'behind_walls',
      );
      final row = (await repo.photo(id))!;
      expect(row.homeId, homes.main);
      expect(row.roomId, kitchen);
      expect(row.itemId, isNull);
      expect(row.category, 'behind_walls');
      expect(jsonDecode(row.image!), jsonDecode(stored.reference));
      final file = repo.photoFile(row);
      expect(file.path, endsWith('/homes/${homes.main}/$id.jpg'));
      expect(file.readAsBytesSync(), stored.image);
      expect(repo.thumbnailFile(row).readAsBytesSync(), stored.thumbnail);
      // Never a name chosen by the person.
      expect(file.uri.pathSegments.last, '$id.jpg');
    });

    test('what is on disk and in the row has no metadata', () async {
      final id = await repo.addPhoto(
        homes.main,
        processPhoto(jpegWithGps()),
        roomId: kitchen,
      );
      final row = (await repo.photo(id))!;
      expect(jpegMetadata(repo.photoFile(row).readAsBytesSync()), isEmpty);
      expect(jpegMetadata(repo.thumbnailFile(row).readAsBytesSync()), isEmpty);
    });

    test('one of a room or an item, of this home, at most thirty', () async {
      final stored = processPhoto(jpegWithGps());
      expect(
        () => repo.addPhoto(homes.main, stored),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => repo.addPhoto(homes.main, stored, roomId: kitchen, itemId: 'x'),
        throwsA(isA<ArgumentError>()),
      );
      final other = (await repo.rooms(homes.second)).first.id;
      expect(
        () => repo.addPhoto(homes.main, stored, roomId: other),
        refusedWith(Refusal.notInHome),
      );
      expect(
        () => repo.addPhoto(
          homes.main,
          stored,
          roomId: kitchen,
          category: 'selfie',
        ),
        refusedWith(Refusal.choiceInvalid),
      );
      final room = await repo.createRoom(homes.main, name: 'Photo room');
      for (var i = 0; i < 30; i++) {
        await repo.addPhoto(homes.main, stored, roomId: room);
      }
      Set<String> files() =>
          repo.homeDirectory(homes.main).listSync().map((f) => f.path).toSet();
      final before = files();
      expect(
        () => repo.addPhoto(homes.main, stored, roomId: room),
        refusedWith(Refusal.tooManyPhotos),
      );
      expect((await repo.photosOf(roomId: room)).length, 30);
      expect(files(), before, reason: 'the refused photo left no file');
    });

    test('an archived home takes no photo', () async {
      await repo.archiveHome(homes.second);
      final room = (await repo.rooms(homes.second)).first.id;
      expect(
        () => repo.addPhoto(
          homes.second,
          processPhoto(jpegWithGps()),
          roomId: room,
        ),
        refusedWith(Refusal.homeArchived),
      );
    });

    test('category and caption change; a deleted photo leaves the list, its file stays 30 days', () async {
      final id = await repo.addPhoto(
        homes.main,
        processPhoto(jpegWithGps()),
        roomId: kitchen,
      );
      await repo.updatePhoto(id, category: 'before', caption: ' Before ');
      final row = (await repo.photo(id))!;
      expect([row.category, row.caption], ['before', 'Before']);
      expect(
        () => repo.updatePhoto(id, category: 'x'),
        refusedWith(Refusal.choiceInvalid),
      );
      await repo.deletePhoto(id);
      expect(await repo.photo(id), isNull);
      expect(
        (await repo.photosOf(roomId: kitchen)).map((p) => p.id),
        isNot(contains(id)),
      );
      expect(repo.photoFile(row).existsSync(), isTrue);
    });

    test('deleting a home erases its photos, rows and files', () async {
      final id = await repo.addPhoto(
        homes.second,
        processPhoto(jpegWithGps()),
        roomId: (await repo.rooms(homes.second)).first.id,
      );
      final row = (await repo.photo(id))!;
      final file = repo.photoFile(row);
      expect(file.existsSync(), isTrue);
      await repo.deleteHome(homes.second, typedName: 'Second home');
      expect(file.existsSync(), isFalse);
      expect(
        Directory(repo.homeDirectory(homes.second).path).existsSync(),
        isFalse,
      );
    });
  });

  group('reminder sources', () {
    test(
      'open occurrences with a date, of active homes, of live tasks',
      () async {
        final titles = (await repo.reminderSources()).map((s) => s.taskTitle);
        expect(
          titles,
          unorderedEquals([
            'Main smoke alarm',
            'Main boiler service',
            'Second smoke alarm',
            'Second boiler service',
          ]),
        );
        await repo.archiveHome(homes.second);
        expect((await repo.reminderSources()).map((s) => s.homeName).toSet(), {
          'Main home',
        });
      },
    );
  });

  group('the library of task templates', () {
    late TemplateLibrary library;
    setUpAll(() {
      library = parseTemplates(
        File('assets/task_templates.yaml').readAsStringSync(),
      );
    });

    test('is read: equipment, templates, both languages', () {
      expect(library.equipment, isNotEmpty);
      expect(library.templates.length, greaterThan(10));
      final ids = {for (final e in library.equipment) e.id};
      for (final t in library.templates) {
        expect(ids, contains(t.equipment));
        expect(t.title.en, isNotEmpty);
        expect(t.title.fr, isNotEmpty);
        expect(t.sourceUrl, startsWith('http'));
      }
    });

    test('a template makes a task that repeats after the last time', () {
      final t = library.get('smoke-alarm-test')!;
      final input = t.input(
        'en',
        material: (list) => 'Material: $list.',
        source: (title, url) => 'Interval from: $title, $url',
        roomId: 'r',
        dueOn: Day(2026, 12, 1),
      );
      expect(input.title, 'Test the smoke alarms');
      expect(input.repeatMode, 'after_last');
      expect([input.repeatUnit, input.repeatInterval], ['month', 1]);
      expect(input.estimatedMinutes, 5);
      expect(input.procedure, startsWith('Press the test button'));
      expect(input.notes, contains('Interval from: NFPA'));
      expect(input.roomId, 'r');
      expect(input.dueOn, Day(2026, 12, 1));
      final fr = t.input(
        'fr',
        material: (list) => 'Matériel : $list.',
        source: (title, url) => 'Intervalle d\'après : $title, $url',
      );
      expect(fr.title, 'Tester les détecteurs de fumée');
    });

    test('a template with a season keeps it; one with a region says so', () {
      final boiler = library.get('boiler-service')!;
      expect(boiler.season, 'autumn');
      expect(boiler.region, 'FR');
      expect(
        boiler
            .input('en', material: (l) => l, source: (t, u) => '$t $u')
            .season,
        'autumn',
      );
    });

    test('createTasks adds all the tasks in one go, or none', () async {
      final inputs = [
        for (final id in ['smoke-alarm-test', 'smoke-alarm-battery'])
          library
              .get(id)!
              .input(
                'en',
                material: (l) => l,
                source: (t, u) => '$t $u',
                roomId: kitchen,
                dueOn: repo.today().addDays(10),
              ),
      ];
      final ids = await repo.createTasks(homes.main, inputs);
      expect(ids, hasLength(2));
      final tasks = await repo.tasksOf(roomId: kitchen);
      expect(
        tasks.map((e) => e.task.title),
        containsAll([
          'Test the smoke alarms',
          'Replace the battery of the smoke alarms',
        ]),
      );
      final test = tasks.firstWhere(
        (e) => e.task.title == 'Test the smoke alarms',
      );
      expect(test.task.repeatMode, 'after_last');
      expect(test.task.estimatedMinutes, 5);
      expect(test.dueOn, repo.today().addDays(10));
      // One refused input: nothing of the batch is saved.
      final before = (await repo.tasksOf(roomId: kitchen)).length;
      expect(
        () => repo.createTasks(homes.main, [
          inputs.first,
          const TaskInput(title: ' '),
        ]),
        refusedWith(Refusal.titleRequired),
      );
      expect((await repo.tasksOf(roomId: kitchen)).length, before);
    });
  });
}

Variable _bytes(String id) => Variable<Object>(uuidBytes(id));
