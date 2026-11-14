// SPDX-License-Identifier: AGPL-3.0-only

import 'package:yaml/yaml.dart';

import '../data/repository.dart';
import 'day.dart';
import 'recurrence.dart' as recurrence;

/// The library of task templates (web ADR 0049), shipped read only as
/// `assets/task_templates.yaml`, a copy of the file of the pinned web release
/// (docs/plan.md, "Alignment with the web application"). Each template is a
/// common task of a home, in English and French, with an indicative interval
/// and the public source that gives it.

/// A text in the two languages of the library.
class Text2 {
  const Text2(this.en, this.fr);

  final String en;
  final String fr;

  String of(String language) => language == 'fr' ? fr : en;
}

class Equipment {
  const Equipment(this.id, this.name);

  final String id;
  final Text2 name;
}

class TaskTemplate {
  const TaskTemplate({
    required this.id,
    required this.equipment,
    required this.title,
    required this.itemKind,
    required this.roomKinds,
    required this.interval,
    required this.unit,
    required this.minutes,
    required this.materials,
    required this.sourceTitle,
    required this.sourceUrl,
    this.season = '',
    this.procedure,
    this.region = '',
    this.note,
  });

  final String id;
  final String equipment;
  final Text2 title;
  final String itemKind;
  final List<String> roomKinds;
  final int interval;
  final String unit;
  final int minutes;
  final List<Text2> materials;
  final String sourceTitle;
  final String sourceUrl;
  final String season;
  final Text2? procedure;

  /// The country whose rule this is, `''` when it is for everyone.
  final String region;
  final Text2? note;

  /// The notes of the task made from the template, in [language]: the note,
  /// the material, and where the interval comes from (`Template.notes` of the
  /// web). [material] and [source] are the words of the two lines.
  String notes(
    String language, {
    required String Function(String list) material,
    required String Function(String title, String url) source,
  }) {
    final lines = [
      ?note?.of(language),
      if (materials.isNotEmpty)
        material(materials.map((m) => m.of(language)).join(', ')),
      source(sourceTitle, sourceUrl),
    ];
    return lines.join('\n\n');
  }

  /// The task a template makes: it repeats after the last time
  /// (`Template.task_fields`).
  TaskInput input(
    String language, {
    required String Function(String list) material,
    required String Function(String title, String url) source,
    String? roomId,
    Day? dueOn,
  }) => TaskInput(
    title: title.of(language),
    dueOn: dueOn,
    repeatMode: recurrence.afterLast,
    repeatUnit: unit,
    repeatInterval: interval,
    season: season,
    estimatedMinutes: minutes,
    procedure: procedure?.of(language) ?? '',
    notes: notes(language, material: material, source: source),
    roomId: roomId,
  );
}

class TemplateLibrary {
  const TemplateLibrary(this.equipment, this.templates);

  final List<Equipment> equipment;
  final List<TaskTemplate> templates;

  TaskTemplate? get(String id) =>
      templates.where((t) => t.id == id).firstOrNull;

  List<TaskTemplate> of(String equipmentId) =>
      templates.where((t) => t.equipment == equipmentId).toList();

  /// The templates that suit a room of [roomKind]: those that name it, plus
  /// those of no room kind.
  List<TaskTemplate> forRoom(String roomKind) => templates
      .where((t) => t.roomKinds.isEmpty || t.roomKinds.contains(roomKind))
      .toList();
}

Text2 _text(Object? raw) {
  if (raw is! Map || raw.keys.toSet().difference({'en', 'fr'}).isNotEmpty) {
    throw FormatException('A text of the library needs en and fr: $raw');
  }
  return Text2('${raw['en']}', '${raw['fr']}');
}

/// The library from the YAML of the asset; `FormatException` when it is not
/// one this code reads (version 1).
TemplateLibrary parseTemplates(String source) {
  final raw = loadYaml(source);
  if (raw is! Map || raw['version'] != 1) {
    throw const FormatException(
      'The library of task templates is not of version 1.',
    );
  }
  final equipment = [
    for (final e in raw['equipment'] as List)
      Equipment('${e['id']}', _text(e['name'])),
  ];
  final known = {for (final e in equipment) e.id};
  final templates = <TaskTemplate>[];
  for (final t in raw['templates'] as List) {
    if (!known.contains(t['equipment'])) {
      throw FormatException('Unknown equipment ${t['equipment']}');
    }
    final every = t['every'] as Map;
    final applies = t['applies_to'] as Map;
    final src = t['source'] as Map;
    templates.add(
      TaskTemplate(
        id: '${t['id']}',
        equipment: '${t['equipment']}',
        title: _text(t['title']),
        itemKind: '${applies['item_kind']}',
        roomKinds: [for (final k in applies['room_kinds'] as List) '$k'],
        interval: every['interval'] as int,
        unit: '${every['unit']}',
        minutes: (t['minutes'] ?? 0) as int,
        materials: [
          for (final m in (t['materials'] as List? ?? const <Object?>[]))
            _text(m),
        ],
        sourceTitle: '${src['title']}',
        sourceUrl: '${src['url']}',
        season: '${t['season'] ?? ''}',
        procedure: t['procedure'] == null ? null : _text(t['procedure']),
        region: '${t['region'] ?? ''}',
        note: t['note'] == null ? null : _text(t['note']),
      ),
    );
  }
  return TemplateLibrary(equipment, templates);
}
