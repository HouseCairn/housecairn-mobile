// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $HomesTable extends Homes with TableInfo<$HomesTable, HomeRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HomesTable(this.attachedDatabase, [this._alias]);
  @override
  late final GeneratedColumnWithTypeConverter<String, Uint8List> id =
      GeneratedColumn<Uint8List>(
        'id',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      ).withConverter<String>($HomesTable.$converterid);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('EUR'),
  );
  static const VerificationMeta _hemisphereMeta = const VerificationMeta(
    'hemisphere',
  );
  @override
  late final GeneratedColumn<String> hemisphere = GeneratedColumn<String>(
    'hemisphere',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('north'),
  );
  static const VerificationMeta _archivedAtMeta = const VerificationMeta(
    'archivedAt',
  );
  @override
  late final GeneratedColumn<int> archivedAt = GeneratedColumn<int>(
    'archived_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    name,
    currency,
    hemisphere,
    archivedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'homes';
  @override
  VerificationContext validateIntegrity(
    Insertable<HomeRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    }
    if (data.containsKey('hemisphere')) {
      context.handle(
        _hemisphereMeta,
        hemisphere.isAcceptableOrUnknown(data['hemisphere']!, _hemisphereMeta),
      );
    }
    if (data.containsKey('archived_at')) {
      context.handle(
        _archivedAtMeta,
        archivedAt.isAcceptableOrUnknown(data['archived_at']!, _archivedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HomeRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HomeRow(
      id: $HomesTable.$converterid.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}id'],
        )!,
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      hemisphere: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hemisphere'],
      )!,
      archivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}archived_at'],
      ),
    );
  }

  @override
  $HomesTable createAlias(String alias) {
    return $HomesTable(attachedDatabase, alias);
  }

  static TypeConverter<String, Uint8List> $converterid = const UuidConverter();
}

class HomeRow extends DataClass implements Insertable<HomeRow> {
  final String id;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;
  final String name;
  final String currency;
  final String hemisphere;
  final int? archivedAt;
  const HomeRow({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.name,
    required this.currency,
    required this.hemisphere,
    this.archivedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    {
      map['id'] = Variable<Uint8List>($HomesTable.$converterid.toSql(id));
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['name'] = Variable<String>(name);
    map['currency'] = Variable<String>(currency);
    map['hemisphere'] = Variable<String>(hemisphere);
    if (!nullToAbsent || archivedAt != null) {
      map['archived_at'] = Variable<int>(archivedAt);
    }
    return map;
  }

  HomesCompanion toCompanion(bool nullToAbsent) {
    return HomesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      name: Value(name),
      currency: Value(currency),
      hemisphere: Value(hemisphere),
      archivedAt: archivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(archivedAt),
    );
  }

  factory HomeRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HomeRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      name: serializer.fromJson<String>(json['name']),
      currency: serializer.fromJson<String>(json['currency']),
      hemisphere: serializer.fromJson<String>(json['hemisphere']),
      archivedAt: serializer.fromJson<int?>(json['archivedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'name': serializer.toJson<String>(name),
      'currency': serializer.toJson<String>(currency),
      'hemisphere': serializer.toJson<String>(hemisphere),
      'archivedAt': serializer.toJson<int?>(archivedAt),
    };
  }

  HomeRow copyWith({
    String? id,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    String? name,
    String? currency,
    String? hemisphere,
    Value<int?> archivedAt = const Value.absent(),
  }) => HomeRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    name: name ?? this.name,
    currency: currency ?? this.currency,
    hemisphere: hemisphere ?? this.hemisphere,
    archivedAt: archivedAt.present ? archivedAt.value : this.archivedAt,
  );
  HomeRow copyWithCompanion(HomesCompanion data) {
    return HomeRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      name: data.name.present ? data.name.value : this.name,
      currency: data.currency.present ? data.currency.value : this.currency,
      hemisphere: data.hemisphere.present
          ? data.hemisphere.value
          : this.hemisphere,
      archivedAt: data.archivedAt.present
          ? data.archivedAt.value
          : this.archivedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HomeRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('name: $name, ')
          ..write('currency: $currency, ')
          ..write('hemisphere: $hemisphere, ')
          ..write('archivedAt: $archivedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    name,
    currency,
    hemisphere,
    archivedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HomeRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.name == this.name &&
          other.currency == this.currency &&
          other.hemisphere == this.hemisphere &&
          other.archivedAt == this.archivedAt);
}

class HomesCompanion extends UpdateCompanion<HomeRow> {
  final Value<String> id;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<String> name;
  final Value<String> currency;
  final Value<String> hemisphere;
  final Value<int?> archivedAt;
  final Value<int> rowid;
  const HomesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.name = const Value.absent(),
    this.currency = const Value.absent(),
    this.hemisphere = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HomesCompanion.insert({
    required String id,
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    required String name,
    this.currency = const Value.absent(),
    this.hemisphere = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       name = Value(name);
  static Insertable<HomeRow> custom({
    Expression<Uint8List>? id,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<String>? name,
    Expression<String>? currency,
    Expression<String>? hemisphere,
    Expression<int>? archivedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (name != null) 'name': name,
      if (currency != null) 'currency': currency,
      if (hemisphere != null) 'hemisphere': hemisphere,
      if (archivedAt != null) 'archived_at': archivedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HomesCompanion copyWith({
    Value<String>? id,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<String>? name,
    Value<String>? currency,
    Value<String>? hemisphere,
    Value<int?>? archivedAt,
    Value<int>? rowid,
  }) {
    return HomesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      name: name ?? this.name,
      currency: currency ?? this.currency,
      hemisphere: hemisphere ?? this.hemisphere,
      archivedAt: archivedAt ?? this.archivedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<Uint8List>($HomesTable.$converterid.toSql(id.value));
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (hemisphere.present) {
      map['hemisphere'] = Variable<String>(hemisphere.value);
    }
    if (archivedAt.present) {
      map['archived_at'] = Variable<int>(archivedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HomesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('name: $name, ')
          ..write('currency: $currency, ')
          ..write('hemisphere: $hemisphere, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RoomsTable extends Rooms with TableInfo<$RoomsTable, RoomRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoomsTable(this.attachedDatabase, [this._alias]);
  @override
  late final GeneratedColumnWithTypeConverter<String, Uint8List> id =
      GeneratedColumn<Uint8List>(
        'id',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      ).withConverter<String>($RoomsTable.$converterid);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<String, Uint8List> homeId =
      GeneratedColumn<Uint8List>(
        'home_id',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      ).withConverter<String>($RoomsTable.$converterhomeId);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('other'),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _paintColourMeta = const VerificationMeta(
    'paintColour',
  );
  @override
  late final GeneratedColumn<String> paintColour = GeneratedColumn<String>(
    'paint_colour',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _paintBrandMeta = const VerificationMeta(
    'paintBrand',
  );
  @override
  late final GeneratedColumn<String> paintBrand = GeneratedColumn<String>(
    'paint_brand',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _paintReferenceMeta = const VerificationMeta(
    'paintReference',
  );
  @override
  late final GeneratedColumn<String> paintReference = GeneratedColumn<String>(
    'paint_reference',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _paintBatchMeta = const VerificationMeta(
    'paintBatch',
  );
  @override
  late final GeneratedColumn<String> paintBatch = GeneratedColumn<String>(
    'paint_batch',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _floorCoveringMeta = const VerificationMeta(
    'floorCovering',
  );
  @override
  late final GeneratedColumn<String> floorCovering = GeneratedColumn<String>(
    'floor_covering',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _wallCoveringMeta = const VerificationMeta(
    'wallCovering',
  );
  @override
  late final GeneratedColumn<String> wallCovering = GeneratedColumn<String>(
    'wall_covering',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _memoryNotesMeta = const VerificationMeta(
    'memoryNotes',
  );
  @override
  late final GeneratedColumn<String> memoryNotes = GeneratedColumn<String>(
    'memory_notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    homeId,
    name,
    kind,
    position,
    notes,
    paintColour,
    paintBrand,
    paintReference,
    paintBatch,
    floorCovering,
    wallCovering,
    memoryNotes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rooms';
  @override
  VerificationContext validateIntegrity(
    Insertable<RoomRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('paint_colour')) {
      context.handle(
        _paintColourMeta,
        paintColour.isAcceptableOrUnknown(
          data['paint_colour']!,
          _paintColourMeta,
        ),
      );
    }
    if (data.containsKey('paint_brand')) {
      context.handle(
        _paintBrandMeta,
        paintBrand.isAcceptableOrUnknown(data['paint_brand']!, _paintBrandMeta),
      );
    }
    if (data.containsKey('paint_reference')) {
      context.handle(
        _paintReferenceMeta,
        paintReference.isAcceptableOrUnknown(
          data['paint_reference']!,
          _paintReferenceMeta,
        ),
      );
    }
    if (data.containsKey('paint_batch')) {
      context.handle(
        _paintBatchMeta,
        paintBatch.isAcceptableOrUnknown(data['paint_batch']!, _paintBatchMeta),
      );
    }
    if (data.containsKey('floor_covering')) {
      context.handle(
        _floorCoveringMeta,
        floorCovering.isAcceptableOrUnknown(
          data['floor_covering']!,
          _floorCoveringMeta,
        ),
      );
    }
    if (data.containsKey('wall_covering')) {
      context.handle(
        _wallCoveringMeta,
        wallCovering.isAcceptableOrUnknown(
          data['wall_covering']!,
          _wallCoveringMeta,
        ),
      );
    }
    if (data.containsKey('memory_notes')) {
      context.handle(
        _memoryNotesMeta,
        memoryNotes.isAcceptableOrUnknown(
          data['memory_notes']!,
          _memoryNotesMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RoomRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RoomRow(
      id: $RoomsTable.$converterid.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}id'],
        )!,
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      homeId: $RoomsTable.$converterhomeId.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}home_id'],
        )!,
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
      paintColour: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}paint_colour'],
      )!,
      paintBrand: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}paint_brand'],
      )!,
      paintReference: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}paint_reference'],
      )!,
      paintBatch: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}paint_batch'],
      )!,
      floorCovering: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}floor_covering'],
      )!,
      wallCovering: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}wall_covering'],
      )!,
      memoryNotes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}memory_notes'],
      )!,
    );
  }

  @override
  $RoomsTable createAlias(String alias) {
    return $RoomsTable(attachedDatabase, alias);
  }

  static TypeConverter<String, Uint8List> $converterid = const UuidConverter();
  static TypeConverter<String, Uint8List> $converterhomeId =
      const UuidConverter();
}

class RoomRow extends DataClass implements Insertable<RoomRow> {
  final String id;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;
  final String homeId;
  final String name;
  final String kind;
  final int position;
  final String notes;
  final String paintColour;
  final String paintBrand;
  final String paintReference;
  final String paintBatch;
  final String floorCovering;
  final String wallCovering;
  final String memoryNotes;
  const RoomRow({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.homeId,
    required this.name,
    required this.kind,
    required this.position,
    required this.notes,
    required this.paintColour,
    required this.paintBrand,
    required this.paintReference,
    required this.paintBatch,
    required this.floorCovering,
    required this.wallCovering,
    required this.memoryNotes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    {
      map['id'] = Variable<Uint8List>($RoomsTable.$converterid.toSql(id));
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    {
      map['home_id'] = Variable<Uint8List>(
        $RoomsTable.$converterhomeId.toSql(homeId),
      );
    }
    map['name'] = Variable<String>(name);
    map['kind'] = Variable<String>(kind);
    map['position'] = Variable<int>(position);
    map['notes'] = Variable<String>(notes);
    map['paint_colour'] = Variable<String>(paintColour);
    map['paint_brand'] = Variable<String>(paintBrand);
    map['paint_reference'] = Variable<String>(paintReference);
    map['paint_batch'] = Variable<String>(paintBatch);
    map['floor_covering'] = Variable<String>(floorCovering);
    map['wall_covering'] = Variable<String>(wallCovering);
    map['memory_notes'] = Variable<String>(memoryNotes);
    return map;
  }

  RoomsCompanion toCompanion(bool nullToAbsent) {
    return RoomsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      homeId: Value(homeId),
      name: Value(name),
      kind: Value(kind),
      position: Value(position),
      notes: Value(notes),
      paintColour: Value(paintColour),
      paintBrand: Value(paintBrand),
      paintReference: Value(paintReference),
      paintBatch: Value(paintBatch),
      floorCovering: Value(floorCovering),
      wallCovering: Value(wallCovering),
      memoryNotes: Value(memoryNotes),
    );
  }

  factory RoomRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RoomRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      homeId: serializer.fromJson<String>(json['homeId']),
      name: serializer.fromJson<String>(json['name']),
      kind: serializer.fromJson<String>(json['kind']),
      position: serializer.fromJson<int>(json['position']),
      notes: serializer.fromJson<String>(json['notes']),
      paintColour: serializer.fromJson<String>(json['paintColour']),
      paintBrand: serializer.fromJson<String>(json['paintBrand']),
      paintReference: serializer.fromJson<String>(json['paintReference']),
      paintBatch: serializer.fromJson<String>(json['paintBatch']),
      floorCovering: serializer.fromJson<String>(json['floorCovering']),
      wallCovering: serializer.fromJson<String>(json['wallCovering']),
      memoryNotes: serializer.fromJson<String>(json['memoryNotes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'homeId': serializer.toJson<String>(homeId),
      'name': serializer.toJson<String>(name),
      'kind': serializer.toJson<String>(kind),
      'position': serializer.toJson<int>(position),
      'notes': serializer.toJson<String>(notes),
      'paintColour': serializer.toJson<String>(paintColour),
      'paintBrand': serializer.toJson<String>(paintBrand),
      'paintReference': serializer.toJson<String>(paintReference),
      'paintBatch': serializer.toJson<String>(paintBatch),
      'floorCovering': serializer.toJson<String>(floorCovering),
      'wallCovering': serializer.toJson<String>(wallCovering),
      'memoryNotes': serializer.toJson<String>(memoryNotes),
    };
  }

  RoomRow copyWith({
    String? id,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    String? homeId,
    String? name,
    String? kind,
    int? position,
    String? notes,
    String? paintColour,
    String? paintBrand,
    String? paintReference,
    String? paintBatch,
    String? floorCovering,
    String? wallCovering,
    String? memoryNotes,
  }) => RoomRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    homeId: homeId ?? this.homeId,
    name: name ?? this.name,
    kind: kind ?? this.kind,
    position: position ?? this.position,
    notes: notes ?? this.notes,
    paintColour: paintColour ?? this.paintColour,
    paintBrand: paintBrand ?? this.paintBrand,
    paintReference: paintReference ?? this.paintReference,
    paintBatch: paintBatch ?? this.paintBatch,
    floorCovering: floorCovering ?? this.floorCovering,
    wallCovering: wallCovering ?? this.wallCovering,
    memoryNotes: memoryNotes ?? this.memoryNotes,
  );
  RoomRow copyWithCompanion(RoomsCompanion data) {
    return RoomRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      homeId: data.homeId.present ? data.homeId.value : this.homeId,
      name: data.name.present ? data.name.value : this.name,
      kind: data.kind.present ? data.kind.value : this.kind,
      position: data.position.present ? data.position.value : this.position,
      notes: data.notes.present ? data.notes.value : this.notes,
      paintColour: data.paintColour.present
          ? data.paintColour.value
          : this.paintColour,
      paintBrand: data.paintBrand.present
          ? data.paintBrand.value
          : this.paintBrand,
      paintReference: data.paintReference.present
          ? data.paintReference.value
          : this.paintReference,
      paintBatch: data.paintBatch.present
          ? data.paintBatch.value
          : this.paintBatch,
      floorCovering: data.floorCovering.present
          ? data.floorCovering.value
          : this.floorCovering,
      wallCovering: data.wallCovering.present
          ? data.wallCovering.value
          : this.wallCovering,
      memoryNotes: data.memoryNotes.present
          ? data.memoryNotes.value
          : this.memoryNotes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RoomRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('homeId: $homeId, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('position: $position, ')
          ..write('notes: $notes, ')
          ..write('paintColour: $paintColour, ')
          ..write('paintBrand: $paintBrand, ')
          ..write('paintReference: $paintReference, ')
          ..write('paintBatch: $paintBatch, ')
          ..write('floorCovering: $floorCovering, ')
          ..write('wallCovering: $wallCovering, ')
          ..write('memoryNotes: $memoryNotes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    homeId,
    name,
    kind,
    position,
    notes,
    paintColour,
    paintBrand,
    paintReference,
    paintBatch,
    floorCovering,
    wallCovering,
    memoryNotes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RoomRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.homeId == this.homeId &&
          other.name == this.name &&
          other.kind == this.kind &&
          other.position == this.position &&
          other.notes == this.notes &&
          other.paintColour == this.paintColour &&
          other.paintBrand == this.paintBrand &&
          other.paintReference == this.paintReference &&
          other.paintBatch == this.paintBatch &&
          other.floorCovering == this.floorCovering &&
          other.wallCovering == this.wallCovering &&
          other.memoryNotes == this.memoryNotes);
}

class RoomsCompanion extends UpdateCompanion<RoomRow> {
  final Value<String> id;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<String> homeId;
  final Value<String> name;
  final Value<String> kind;
  final Value<int> position;
  final Value<String> notes;
  final Value<String> paintColour;
  final Value<String> paintBrand;
  final Value<String> paintReference;
  final Value<String> paintBatch;
  final Value<String> floorCovering;
  final Value<String> wallCovering;
  final Value<String> memoryNotes;
  final Value<int> rowid;
  const RoomsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.homeId = const Value.absent(),
    this.name = const Value.absent(),
    this.kind = const Value.absent(),
    this.position = const Value.absent(),
    this.notes = const Value.absent(),
    this.paintColour = const Value.absent(),
    this.paintBrand = const Value.absent(),
    this.paintReference = const Value.absent(),
    this.paintBatch = const Value.absent(),
    this.floorCovering = const Value.absent(),
    this.wallCovering = const Value.absent(),
    this.memoryNotes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RoomsCompanion.insert({
    required String id,
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    required String homeId,
    required String name,
    this.kind = const Value.absent(),
    this.position = const Value.absent(),
    this.notes = const Value.absent(),
    this.paintColour = const Value.absent(),
    this.paintBrand = const Value.absent(),
    this.paintReference = const Value.absent(),
    this.paintBatch = const Value.absent(),
    this.floorCovering = const Value.absent(),
    this.wallCovering = const Value.absent(),
    this.memoryNotes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       homeId = Value(homeId),
       name = Value(name);
  static Insertable<RoomRow> custom({
    Expression<Uint8List>? id,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<Uint8List>? homeId,
    Expression<String>? name,
    Expression<String>? kind,
    Expression<int>? position,
    Expression<String>? notes,
    Expression<String>? paintColour,
    Expression<String>? paintBrand,
    Expression<String>? paintReference,
    Expression<String>? paintBatch,
    Expression<String>? floorCovering,
    Expression<String>? wallCovering,
    Expression<String>? memoryNotes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (homeId != null) 'home_id': homeId,
      if (name != null) 'name': name,
      if (kind != null) 'kind': kind,
      if (position != null) 'position': position,
      if (notes != null) 'notes': notes,
      if (paintColour != null) 'paint_colour': paintColour,
      if (paintBrand != null) 'paint_brand': paintBrand,
      if (paintReference != null) 'paint_reference': paintReference,
      if (paintBatch != null) 'paint_batch': paintBatch,
      if (floorCovering != null) 'floor_covering': floorCovering,
      if (wallCovering != null) 'wall_covering': wallCovering,
      if (memoryNotes != null) 'memory_notes': memoryNotes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RoomsCompanion copyWith({
    Value<String>? id,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<String>? homeId,
    Value<String>? name,
    Value<String>? kind,
    Value<int>? position,
    Value<String>? notes,
    Value<String>? paintColour,
    Value<String>? paintBrand,
    Value<String>? paintReference,
    Value<String>? paintBatch,
    Value<String>? floorCovering,
    Value<String>? wallCovering,
    Value<String>? memoryNotes,
    Value<int>? rowid,
  }) {
    return RoomsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      homeId: homeId ?? this.homeId,
      name: name ?? this.name,
      kind: kind ?? this.kind,
      position: position ?? this.position,
      notes: notes ?? this.notes,
      paintColour: paintColour ?? this.paintColour,
      paintBrand: paintBrand ?? this.paintBrand,
      paintReference: paintReference ?? this.paintReference,
      paintBatch: paintBatch ?? this.paintBatch,
      floorCovering: floorCovering ?? this.floorCovering,
      wallCovering: wallCovering ?? this.wallCovering,
      memoryNotes: memoryNotes ?? this.memoryNotes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<Uint8List>($RoomsTable.$converterid.toSql(id.value));
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (homeId.present) {
      map['home_id'] = Variable<Uint8List>(
        $RoomsTable.$converterhomeId.toSql(homeId.value),
      );
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (paintColour.present) {
      map['paint_colour'] = Variable<String>(paintColour.value);
    }
    if (paintBrand.present) {
      map['paint_brand'] = Variable<String>(paintBrand.value);
    }
    if (paintReference.present) {
      map['paint_reference'] = Variable<String>(paintReference.value);
    }
    if (paintBatch.present) {
      map['paint_batch'] = Variable<String>(paintBatch.value);
    }
    if (floorCovering.present) {
      map['floor_covering'] = Variable<String>(floorCovering.value);
    }
    if (wallCovering.present) {
      map['wall_covering'] = Variable<String>(wallCovering.value);
    }
    if (memoryNotes.present) {
      map['memory_notes'] = Variable<String>(memoryNotes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoomsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('homeId: $homeId, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('position: $position, ')
          ..write('notes: $notes, ')
          ..write('paintColour: $paintColour, ')
          ..write('paintBrand: $paintBrand, ')
          ..write('paintReference: $paintReference, ')
          ..write('paintBatch: $paintBatch, ')
          ..write('floorCovering: $floorCovering, ')
          ..write('wallCovering: $wallCovering, ')
          ..write('memoryNotes: $memoryNotes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ItemsTable extends Items with TableInfo<$ItemsTable, ItemRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ItemsTable(this.attachedDatabase, [this._alias]);
  @override
  late final GeneratedColumnWithTypeConverter<String, Uint8List> id =
      GeneratedColumn<Uint8List>(
        'id',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      ).withConverter<String>($ItemsTable.$converterid);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<String, Uint8List> homeId =
      GeneratedColumn<Uint8List>(
        'home_id',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      ).withConverter<String>($ItemsTable.$converterhomeId);
  @override
  late final GeneratedColumnWithTypeConverter<String, Uint8List> roomId =
      GeneratedColumn<Uint8List>(
        'room_id',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      ).withConverter<String>($ItemsTable.$converterroomId);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('equipment'),
  );
  static const VerificationMeta _brandMeta = const VerificationMeta('brand');
  @override
  late final GeneratedColumn<String> brand = GeneratedColumn<String>(
    'brand',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _modelMeta = const VerificationMeta('model');
  @override
  late final GeneratedColumn<String> model = GeneratedColumn<String>(
    'model',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _serialNumberMeta = const VerificationMeta(
    'serialNumber',
  );
  @override
  late final GeneratedColumn<String> serialNumber = GeneratedColumn<String>(
    'serial_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _installedOnMeta = const VerificationMeta(
    'installedOn',
  );
  @override
  late final GeneratedColumn<String> installedOn = GeneratedColumn<String>(
    'installed_on',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _warrantyEndsOnMeta = const VerificationMeta(
    'warrantyEndsOn',
  );
  @override
  late final GeneratedColumn<String> warrantyEndsOn = GeneratedColumn<String>(
    'warranty_ends_on',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<String?, Uint8List>
  contractContractorId = GeneratedColumn<Uint8List>(
    'contract_contractor_id',
    aliasedName,
    true,
    type: DriftSqlType.blob,
    requiredDuringInsert: false,
  ).withConverter<String?>($ItemsTable.$convertercontractContractorIdn);
  static const VerificationMeta _contractNumberMeta = const VerificationMeta(
    'contractNumber',
  );
  @override
  late final GeneratedColumn<String> contractNumber = GeneratedColumn<String>(
    'contract_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _contractUrlMeta = const VerificationMeta(
    'contractUrl',
  );
  @override
  late final GeneratedColumn<String> contractUrl = GeneratedColumn<String>(
    'contract_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _linksMeta = const VerificationMeta('links');
  @override
  late final GeneratedColumn<String> links = GeneratedColumn<String>(
    'links',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    homeId,
    roomId,
    name,
    kind,
    brand,
    model,
    serialNumber,
    installedOn,
    warrantyEndsOn,
    contractContractorId,
    contractNumber,
    contractUrl,
    links,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'items';
  @override
  VerificationContext validateIntegrity(
    Insertable<ItemRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    }
    if (data.containsKey('brand')) {
      context.handle(
        _brandMeta,
        brand.isAcceptableOrUnknown(data['brand']!, _brandMeta),
      );
    }
    if (data.containsKey('model')) {
      context.handle(
        _modelMeta,
        model.isAcceptableOrUnknown(data['model']!, _modelMeta),
      );
    }
    if (data.containsKey('serial_number')) {
      context.handle(
        _serialNumberMeta,
        serialNumber.isAcceptableOrUnknown(
          data['serial_number']!,
          _serialNumberMeta,
        ),
      );
    }
    if (data.containsKey('installed_on')) {
      context.handle(
        _installedOnMeta,
        installedOn.isAcceptableOrUnknown(
          data['installed_on']!,
          _installedOnMeta,
        ),
      );
    }
    if (data.containsKey('warranty_ends_on')) {
      context.handle(
        _warrantyEndsOnMeta,
        warrantyEndsOn.isAcceptableOrUnknown(
          data['warranty_ends_on']!,
          _warrantyEndsOnMeta,
        ),
      );
    }
    if (data.containsKey('contract_number')) {
      context.handle(
        _contractNumberMeta,
        contractNumber.isAcceptableOrUnknown(
          data['contract_number']!,
          _contractNumberMeta,
        ),
      );
    }
    if (data.containsKey('contract_url')) {
      context.handle(
        _contractUrlMeta,
        contractUrl.isAcceptableOrUnknown(
          data['contract_url']!,
          _contractUrlMeta,
        ),
      );
    }
    if (data.containsKey('links')) {
      context.handle(
        _linksMeta,
        links.isAcceptableOrUnknown(data['links']!, _linksMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ItemRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ItemRow(
      id: $ItemsTable.$converterid.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}id'],
        )!,
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      homeId: $ItemsTable.$converterhomeId.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}home_id'],
        )!,
      ),
      roomId: $ItemsTable.$converterroomId.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}room_id'],
        )!,
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      brand: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}brand'],
      )!,
      model: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model'],
      )!,
      serialNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}serial_number'],
      )!,
      installedOn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}installed_on'],
      ),
      warrantyEndsOn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}warranty_ends_on'],
      ),
      contractContractorId: $ItemsTable.$convertercontractContractorIdn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}contract_contractor_id'],
        ),
      ),
      contractNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}contract_number'],
      )!,
      contractUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}contract_url'],
      )!,
      links: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}links'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
    );
  }

  @override
  $ItemsTable createAlias(String alias) {
    return $ItemsTable(attachedDatabase, alias);
  }

  static TypeConverter<String, Uint8List> $converterid = const UuidConverter();
  static TypeConverter<String, Uint8List> $converterhomeId =
      const UuidConverter();
  static TypeConverter<String, Uint8List> $converterroomId =
      const UuidConverter();
  static TypeConverter<String, Uint8List> $convertercontractContractorId =
      const UuidConverter();
  static TypeConverter<String?, Uint8List?> $convertercontractContractorIdn =
      NullAwareTypeConverter.wrap($convertercontractContractorId);
}

class ItemRow extends DataClass implements Insertable<ItemRow> {
  final String id;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;
  final String homeId;
  final String roomId;
  final String name;
  final String kind;
  final String brand;
  final String model;
  final String serialNumber;
  final String? installedOn;
  final String? warrantyEndsOn;
  final String? contractContractorId;
  final String contractNumber;
  final String contractUrl;

  /// JSON list of `{"url", "label"}` (label optional), at most 10, `http(s)` only
  /// (`rooms/models.py:15`, `:35-49`).
  final String links;
  final String notes;
  const ItemRow({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.homeId,
    required this.roomId,
    required this.name,
    required this.kind,
    required this.brand,
    required this.model,
    required this.serialNumber,
    this.installedOn,
    this.warrantyEndsOn,
    this.contractContractorId,
    required this.contractNumber,
    required this.contractUrl,
    required this.links,
    required this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    {
      map['id'] = Variable<Uint8List>($ItemsTable.$converterid.toSql(id));
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    {
      map['home_id'] = Variable<Uint8List>(
        $ItemsTable.$converterhomeId.toSql(homeId),
      );
    }
    {
      map['room_id'] = Variable<Uint8List>(
        $ItemsTable.$converterroomId.toSql(roomId),
      );
    }
    map['name'] = Variable<String>(name);
    map['kind'] = Variable<String>(kind);
    map['brand'] = Variable<String>(brand);
    map['model'] = Variable<String>(model);
    map['serial_number'] = Variable<String>(serialNumber);
    if (!nullToAbsent || installedOn != null) {
      map['installed_on'] = Variable<String>(installedOn);
    }
    if (!nullToAbsent || warrantyEndsOn != null) {
      map['warranty_ends_on'] = Variable<String>(warrantyEndsOn);
    }
    if (!nullToAbsent || contractContractorId != null) {
      map['contract_contractor_id'] = Variable<Uint8List>(
        $ItemsTable.$convertercontractContractorIdn.toSql(contractContractorId),
      );
    }
    map['contract_number'] = Variable<String>(contractNumber);
    map['contract_url'] = Variable<String>(contractUrl);
    map['links'] = Variable<String>(links);
    map['notes'] = Variable<String>(notes);
    return map;
  }

  ItemsCompanion toCompanion(bool nullToAbsent) {
    return ItemsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      homeId: Value(homeId),
      roomId: Value(roomId),
      name: Value(name),
      kind: Value(kind),
      brand: Value(brand),
      model: Value(model),
      serialNumber: Value(serialNumber),
      installedOn: installedOn == null && nullToAbsent
          ? const Value.absent()
          : Value(installedOn),
      warrantyEndsOn: warrantyEndsOn == null && nullToAbsent
          ? const Value.absent()
          : Value(warrantyEndsOn),
      contractContractorId: contractContractorId == null && nullToAbsent
          ? const Value.absent()
          : Value(contractContractorId),
      contractNumber: Value(contractNumber),
      contractUrl: Value(contractUrl),
      links: Value(links),
      notes: Value(notes),
    );
  }

  factory ItemRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ItemRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      homeId: serializer.fromJson<String>(json['homeId']),
      roomId: serializer.fromJson<String>(json['roomId']),
      name: serializer.fromJson<String>(json['name']),
      kind: serializer.fromJson<String>(json['kind']),
      brand: serializer.fromJson<String>(json['brand']),
      model: serializer.fromJson<String>(json['model']),
      serialNumber: serializer.fromJson<String>(json['serialNumber']),
      installedOn: serializer.fromJson<String?>(json['installedOn']),
      warrantyEndsOn: serializer.fromJson<String?>(json['warrantyEndsOn']),
      contractContractorId: serializer.fromJson<String?>(
        json['contractContractorId'],
      ),
      contractNumber: serializer.fromJson<String>(json['contractNumber']),
      contractUrl: serializer.fromJson<String>(json['contractUrl']),
      links: serializer.fromJson<String>(json['links']),
      notes: serializer.fromJson<String>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'homeId': serializer.toJson<String>(homeId),
      'roomId': serializer.toJson<String>(roomId),
      'name': serializer.toJson<String>(name),
      'kind': serializer.toJson<String>(kind),
      'brand': serializer.toJson<String>(brand),
      'model': serializer.toJson<String>(model),
      'serialNumber': serializer.toJson<String>(serialNumber),
      'installedOn': serializer.toJson<String?>(installedOn),
      'warrantyEndsOn': serializer.toJson<String?>(warrantyEndsOn),
      'contractContractorId': serializer.toJson<String?>(contractContractorId),
      'contractNumber': serializer.toJson<String>(contractNumber),
      'contractUrl': serializer.toJson<String>(contractUrl),
      'links': serializer.toJson<String>(links),
      'notes': serializer.toJson<String>(notes),
    };
  }

  ItemRow copyWith({
    String? id,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    String? homeId,
    String? roomId,
    String? name,
    String? kind,
    String? brand,
    String? model,
    String? serialNumber,
    Value<String?> installedOn = const Value.absent(),
    Value<String?> warrantyEndsOn = const Value.absent(),
    Value<String?> contractContractorId = const Value.absent(),
    String? contractNumber,
    String? contractUrl,
    String? links,
    String? notes,
  }) => ItemRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    homeId: homeId ?? this.homeId,
    roomId: roomId ?? this.roomId,
    name: name ?? this.name,
    kind: kind ?? this.kind,
    brand: brand ?? this.brand,
    model: model ?? this.model,
    serialNumber: serialNumber ?? this.serialNumber,
    installedOn: installedOn.present ? installedOn.value : this.installedOn,
    warrantyEndsOn: warrantyEndsOn.present
        ? warrantyEndsOn.value
        : this.warrantyEndsOn,
    contractContractorId: contractContractorId.present
        ? contractContractorId.value
        : this.contractContractorId,
    contractNumber: contractNumber ?? this.contractNumber,
    contractUrl: contractUrl ?? this.contractUrl,
    links: links ?? this.links,
    notes: notes ?? this.notes,
  );
  ItemRow copyWithCompanion(ItemsCompanion data) {
    return ItemRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      homeId: data.homeId.present ? data.homeId.value : this.homeId,
      roomId: data.roomId.present ? data.roomId.value : this.roomId,
      name: data.name.present ? data.name.value : this.name,
      kind: data.kind.present ? data.kind.value : this.kind,
      brand: data.brand.present ? data.brand.value : this.brand,
      model: data.model.present ? data.model.value : this.model,
      serialNumber: data.serialNumber.present
          ? data.serialNumber.value
          : this.serialNumber,
      installedOn: data.installedOn.present
          ? data.installedOn.value
          : this.installedOn,
      warrantyEndsOn: data.warrantyEndsOn.present
          ? data.warrantyEndsOn.value
          : this.warrantyEndsOn,
      contractContractorId: data.contractContractorId.present
          ? data.contractContractorId.value
          : this.contractContractorId,
      contractNumber: data.contractNumber.present
          ? data.contractNumber.value
          : this.contractNumber,
      contractUrl: data.contractUrl.present
          ? data.contractUrl.value
          : this.contractUrl,
      links: data.links.present ? data.links.value : this.links,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ItemRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('homeId: $homeId, ')
          ..write('roomId: $roomId, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('brand: $brand, ')
          ..write('model: $model, ')
          ..write('serialNumber: $serialNumber, ')
          ..write('installedOn: $installedOn, ')
          ..write('warrantyEndsOn: $warrantyEndsOn, ')
          ..write('contractContractorId: $contractContractorId, ')
          ..write('contractNumber: $contractNumber, ')
          ..write('contractUrl: $contractUrl, ')
          ..write('links: $links, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    homeId,
    roomId,
    name,
    kind,
    brand,
    model,
    serialNumber,
    installedOn,
    warrantyEndsOn,
    contractContractorId,
    contractNumber,
    contractUrl,
    links,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ItemRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.homeId == this.homeId &&
          other.roomId == this.roomId &&
          other.name == this.name &&
          other.kind == this.kind &&
          other.brand == this.brand &&
          other.model == this.model &&
          other.serialNumber == this.serialNumber &&
          other.installedOn == this.installedOn &&
          other.warrantyEndsOn == this.warrantyEndsOn &&
          other.contractContractorId == this.contractContractorId &&
          other.contractNumber == this.contractNumber &&
          other.contractUrl == this.contractUrl &&
          other.links == this.links &&
          other.notes == this.notes);
}

class ItemsCompanion extends UpdateCompanion<ItemRow> {
  final Value<String> id;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<String> homeId;
  final Value<String> roomId;
  final Value<String> name;
  final Value<String> kind;
  final Value<String> brand;
  final Value<String> model;
  final Value<String> serialNumber;
  final Value<String?> installedOn;
  final Value<String?> warrantyEndsOn;
  final Value<String?> contractContractorId;
  final Value<String> contractNumber;
  final Value<String> contractUrl;
  final Value<String> links;
  final Value<String> notes;
  final Value<int> rowid;
  const ItemsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.homeId = const Value.absent(),
    this.roomId = const Value.absent(),
    this.name = const Value.absent(),
    this.kind = const Value.absent(),
    this.brand = const Value.absent(),
    this.model = const Value.absent(),
    this.serialNumber = const Value.absent(),
    this.installedOn = const Value.absent(),
    this.warrantyEndsOn = const Value.absent(),
    this.contractContractorId = const Value.absent(),
    this.contractNumber = const Value.absent(),
    this.contractUrl = const Value.absent(),
    this.links = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ItemsCompanion.insert({
    required String id,
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    required String homeId,
    required String roomId,
    required String name,
    this.kind = const Value.absent(),
    this.brand = const Value.absent(),
    this.model = const Value.absent(),
    this.serialNumber = const Value.absent(),
    this.installedOn = const Value.absent(),
    this.warrantyEndsOn = const Value.absent(),
    this.contractContractorId = const Value.absent(),
    this.contractNumber = const Value.absent(),
    this.contractUrl = const Value.absent(),
    this.links = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       homeId = Value(homeId),
       roomId = Value(roomId),
       name = Value(name);
  static Insertable<ItemRow> custom({
    Expression<Uint8List>? id,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<Uint8List>? homeId,
    Expression<Uint8List>? roomId,
    Expression<String>? name,
    Expression<String>? kind,
    Expression<String>? brand,
    Expression<String>? model,
    Expression<String>? serialNumber,
    Expression<String>? installedOn,
    Expression<String>? warrantyEndsOn,
    Expression<Uint8List>? contractContractorId,
    Expression<String>? contractNumber,
    Expression<String>? contractUrl,
    Expression<String>? links,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (homeId != null) 'home_id': homeId,
      if (roomId != null) 'room_id': roomId,
      if (name != null) 'name': name,
      if (kind != null) 'kind': kind,
      if (brand != null) 'brand': brand,
      if (model != null) 'model': model,
      if (serialNumber != null) 'serial_number': serialNumber,
      if (installedOn != null) 'installed_on': installedOn,
      if (warrantyEndsOn != null) 'warranty_ends_on': warrantyEndsOn,
      if (contractContractorId != null)
        'contract_contractor_id': contractContractorId,
      if (contractNumber != null) 'contract_number': contractNumber,
      if (contractUrl != null) 'contract_url': contractUrl,
      if (links != null) 'links': links,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ItemsCompanion copyWith({
    Value<String>? id,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<String>? homeId,
    Value<String>? roomId,
    Value<String>? name,
    Value<String>? kind,
    Value<String>? brand,
    Value<String>? model,
    Value<String>? serialNumber,
    Value<String?>? installedOn,
    Value<String?>? warrantyEndsOn,
    Value<String?>? contractContractorId,
    Value<String>? contractNumber,
    Value<String>? contractUrl,
    Value<String>? links,
    Value<String>? notes,
    Value<int>? rowid,
  }) {
    return ItemsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      homeId: homeId ?? this.homeId,
      roomId: roomId ?? this.roomId,
      name: name ?? this.name,
      kind: kind ?? this.kind,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      serialNumber: serialNumber ?? this.serialNumber,
      installedOn: installedOn ?? this.installedOn,
      warrantyEndsOn: warrantyEndsOn ?? this.warrantyEndsOn,
      contractContractorId: contractContractorId ?? this.contractContractorId,
      contractNumber: contractNumber ?? this.contractNumber,
      contractUrl: contractUrl ?? this.contractUrl,
      links: links ?? this.links,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<Uint8List>($ItemsTable.$converterid.toSql(id.value));
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (homeId.present) {
      map['home_id'] = Variable<Uint8List>(
        $ItemsTable.$converterhomeId.toSql(homeId.value),
      );
    }
    if (roomId.present) {
      map['room_id'] = Variable<Uint8List>(
        $ItemsTable.$converterroomId.toSql(roomId.value),
      );
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (brand.present) {
      map['brand'] = Variable<String>(brand.value);
    }
    if (model.present) {
      map['model'] = Variable<String>(model.value);
    }
    if (serialNumber.present) {
      map['serial_number'] = Variable<String>(serialNumber.value);
    }
    if (installedOn.present) {
      map['installed_on'] = Variable<String>(installedOn.value);
    }
    if (warrantyEndsOn.present) {
      map['warranty_ends_on'] = Variable<String>(warrantyEndsOn.value);
    }
    if (contractContractorId.present) {
      map['contract_contractor_id'] = Variable<Uint8List>(
        $ItemsTable.$convertercontractContractorIdn.toSql(
          contractContractorId.value,
        ),
      );
    }
    if (contractNumber.present) {
      map['contract_number'] = Variable<String>(contractNumber.value);
    }
    if (contractUrl.present) {
      map['contract_url'] = Variable<String>(contractUrl.value);
    }
    if (links.present) {
      map['links'] = Variable<String>(links.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ItemsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('homeId: $homeId, ')
          ..write('roomId: $roomId, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('brand: $brand, ')
          ..write('model: $model, ')
          ..write('serialNumber: $serialNumber, ')
          ..write('installedOn: $installedOn, ')
          ..write('warrantyEndsOn: $warrantyEndsOn, ')
          ..write('contractContractorId: $contractContractorId, ')
          ..write('contractNumber: $contractNumber, ')
          ..write('contractUrl: $contractUrl, ')
          ..write('links: $links, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PhotosTable extends Photos with TableInfo<$PhotosTable, PhotoRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PhotosTable(this.attachedDatabase, [this._alias]);
  @override
  late final GeneratedColumnWithTypeConverter<String, Uint8List> id =
      GeneratedColumn<Uint8List>(
        'id',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      ).withConverter<String>($PhotosTable.$converterid);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<String, Uint8List> homeId =
      GeneratedColumn<Uint8List>(
        'home_id',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      ).withConverter<String>($PhotosTable.$converterhomeId);
  @override
  late final GeneratedColumnWithTypeConverter<String?, Uint8List> roomId =
      GeneratedColumn<Uint8List>(
        'room_id',
        aliasedName,
        true,
        type: DriftSqlType.blob,
        requiredDuringInsert: false,
      ).withConverter<String?>($PhotosTable.$converterroomIdn);
  @override
  late final GeneratedColumnWithTypeConverter<String?, Uint8List> itemId =
      GeneratedColumn<Uint8List>(
        'item_id',
        aliasedName,
        true,
        type: DriftSqlType.blob,
        requiredDuringInsert: false,
      ).withConverter<String?>($PhotosTable.$converteritemIdn);
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('general'),
  );
  static const VerificationMeta _captionMeta = const VerificationMeta(
    'caption',
  );
  @override
  late final GeneratedColumn<String> caption = GeneratedColumn<String>(
    'caption',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _imageMeta = const VerificationMeta('image');
  @override
  late final GeneratedColumn<String> image = GeneratedColumn<String>(
    'image',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    homeId,
    roomId,
    itemId,
    category,
    caption,
    image,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'photos';
  @override
  VerificationContext validateIntegrity(
    Insertable<PhotoRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('caption')) {
      context.handle(
        _captionMeta,
        caption.isAcceptableOrUnknown(data['caption']!, _captionMeta),
      );
    }
    if (data.containsKey('image')) {
      context.handle(
        _imageMeta,
        image.isAcceptableOrUnknown(data['image']!, _imageMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PhotoRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PhotoRow(
      id: $PhotosTable.$converterid.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}id'],
        )!,
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      homeId: $PhotosTable.$converterhomeId.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}home_id'],
        )!,
      ),
      roomId: $PhotosTable.$converterroomIdn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}room_id'],
        ),
      ),
      itemId: $PhotosTable.$converteritemIdn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}item_id'],
        ),
      ),
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      caption: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}caption'],
      )!,
      image: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image'],
      ),
    );
  }

  @override
  $PhotosTable createAlias(String alias) {
    return $PhotosTable(attachedDatabase, alias);
  }

  static TypeConverter<String, Uint8List> $converterid = const UuidConverter();
  static TypeConverter<String, Uint8List> $converterhomeId =
      const UuidConverter();
  static TypeConverter<String, Uint8List> $converterroomId =
      const UuidConverter();
  static TypeConverter<String?, Uint8List?> $converterroomIdn =
      NullAwareTypeConverter.wrap($converterroomId);
  static TypeConverter<String, Uint8List> $converteritemId =
      const UuidConverter();
  static TypeConverter<String?, Uint8List?> $converteritemIdn =
      NullAwareTypeConverter.wrap($converteritemId);
}

class PhotoRow extends DataClass implements Insertable<PhotoRow> {
  final String id;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;
  final String homeId;
  final String? roomId;
  final String? itemId;
  final String category;
  final String caption;
  final String? image;
  const PhotoRow({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.homeId,
    this.roomId,
    this.itemId,
    required this.category,
    required this.caption,
    this.image,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    {
      map['id'] = Variable<Uint8List>($PhotosTable.$converterid.toSql(id));
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    {
      map['home_id'] = Variable<Uint8List>(
        $PhotosTable.$converterhomeId.toSql(homeId),
      );
    }
    if (!nullToAbsent || roomId != null) {
      map['room_id'] = Variable<Uint8List>(
        $PhotosTable.$converterroomIdn.toSql(roomId),
      );
    }
    if (!nullToAbsent || itemId != null) {
      map['item_id'] = Variable<Uint8List>(
        $PhotosTable.$converteritemIdn.toSql(itemId),
      );
    }
    map['category'] = Variable<String>(category);
    map['caption'] = Variable<String>(caption);
    if (!nullToAbsent || image != null) {
      map['image'] = Variable<String>(image);
    }
    return map;
  }

  PhotosCompanion toCompanion(bool nullToAbsent) {
    return PhotosCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      homeId: Value(homeId),
      roomId: roomId == null && nullToAbsent
          ? const Value.absent()
          : Value(roomId),
      itemId: itemId == null && nullToAbsent
          ? const Value.absent()
          : Value(itemId),
      category: Value(category),
      caption: Value(caption),
      image: image == null && nullToAbsent
          ? const Value.absent()
          : Value(image),
    );
  }

  factory PhotoRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PhotoRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      homeId: serializer.fromJson<String>(json['homeId']),
      roomId: serializer.fromJson<String?>(json['roomId']),
      itemId: serializer.fromJson<String?>(json['itemId']),
      category: serializer.fromJson<String>(json['category']),
      caption: serializer.fromJson<String>(json['caption']),
      image: serializer.fromJson<String?>(json['image']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'homeId': serializer.toJson<String>(homeId),
      'roomId': serializer.toJson<String?>(roomId),
      'itemId': serializer.toJson<String?>(itemId),
      'category': serializer.toJson<String>(category),
      'caption': serializer.toJson<String>(caption),
      'image': serializer.toJson<String?>(image),
    };
  }

  PhotoRow copyWith({
    String? id,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    String? homeId,
    Value<String?> roomId = const Value.absent(),
    Value<String?> itemId = const Value.absent(),
    String? category,
    String? caption,
    Value<String?> image = const Value.absent(),
  }) => PhotoRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    homeId: homeId ?? this.homeId,
    roomId: roomId.present ? roomId.value : this.roomId,
    itemId: itemId.present ? itemId.value : this.itemId,
    category: category ?? this.category,
    caption: caption ?? this.caption,
    image: image.present ? image.value : this.image,
  );
  PhotoRow copyWithCompanion(PhotosCompanion data) {
    return PhotoRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      homeId: data.homeId.present ? data.homeId.value : this.homeId,
      roomId: data.roomId.present ? data.roomId.value : this.roomId,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      category: data.category.present ? data.category.value : this.category,
      caption: data.caption.present ? data.caption.value : this.caption,
      image: data.image.present ? data.image.value : this.image,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PhotoRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('homeId: $homeId, ')
          ..write('roomId: $roomId, ')
          ..write('itemId: $itemId, ')
          ..write('category: $category, ')
          ..write('caption: $caption, ')
          ..write('image: $image')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    homeId,
    roomId,
    itemId,
    category,
    caption,
    image,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PhotoRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.homeId == this.homeId &&
          other.roomId == this.roomId &&
          other.itemId == this.itemId &&
          other.category == this.category &&
          other.caption == this.caption &&
          other.image == this.image);
}

class PhotosCompanion extends UpdateCompanion<PhotoRow> {
  final Value<String> id;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<String> homeId;
  final Value<String?> roomId;
  final Value<String?> itemId;
  final Value<String> category;
  final Value<String> caption;
  final Value<String?> image;
  final Value<int> rowid;
  const PhotosCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.homeId = const Value.absent(),
    this.roomId = const Value.absent(),
    this.itemId = const Value.absent(),
    this.category = const Value.absent(),
    this.caption = const Value.absent(),
    this.image = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PhotosCompanion.insert({
    required String id,
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    required String homeId,
    this.roomId = const Value.absent(),
    this.itemId = const Value.absent(),
    this.category = const Value.absent(),
    this.caption = const Value.absent(),
    this.image = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       homeId = Value(homeId);
  static Insertable<PhotoRow> custom({
    Expression<Uint8List>? id,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<Uint8List>? homeId,
    Expression<Uint8List>? roomId,
    Expression<Uint8List>? itemId,
    Expression<String>? category,
    Expression<String>? caption,
    Expression<String>? image,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (homeId != null) 'home_id': homeId,
      if (roomId != null) 'room_id': roomId,
      if (itemId != null) 'item_id': itemId,
      if (category != null) 'category': category,
      if (caption != null) 'caption': caption,
      if (image != null) 'image': image,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PhotosCompanion copyWith({
    Value<String>? id,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<String>? homeId,
    Value<String?>? roomId,
    Value<String?>? itemId,
    Value<String>? category,
    Value<String>? caption,
    Value<String?>? image,
    Value<int>? rowid,
  }) {
    return PhotosCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      homeId: homeId ?? this.homeId,
      roomId: roomId ?? this.roomId,
      itemId: itemId ?? this.itemId,
      category: category ?? this.category,
      caption: caption ?? this.caption,
      image: image ?? this.image,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<Uint8List>(
        $PhotosTable.$converterid.toSql(id.value),
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (homeId.present) {
      map['home_id'] = Variable<Uint8List>(
        $PhotosTable.$converterhomeId.toSql(homeId.value),
      );
    }
    if (roomId.present) {
      map['room_id'] = Variable<Uint8List>(
        $PhotosTable.$converterroomIdn.toSql(roomId.value),
      );
    }
    if (itemId.present) {
      map['item_id'] = Variable<Uint8List>(
        $PhotosTable.$converteritemIdn.toSql(itemId.value),
      );
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (caption.present) {
      map['caption'] = Variable<String>(caption.value);
    }
    if (image.present) {
      map['image'] = Variable<String>(image.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PhotosCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('homeId: $homeId, ')
          ..write('roomId: $roomId, ')
          ..write('itemId: $itemId, ')
          ..write('category: $category, ')
          ..write('caption: $caption, ')
          ..write('image: $image, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ContractorsTable extends Contractors
    with TableInfo<$ContractorsTable, ContractorRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ContractorsTable(this.attachedDatabase, [this._alias]);
  @override
  late final GeneratedColumnWithTypeConverter<String, Uint8List> id =
      GeneratedColumn<Uint8List>(
        'id',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      ).withConverter<String>($ContractorsTable.$converterid);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<String, Uint8List> homeId =
      GeneratedColumn<Uint8List>(
        'home_id',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      ).withConverter<String>($ContractorsTable.$converterhomeId);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tradeMeta = const VerificationMeta('trade');
  @override
  late final GeneratedColumn<String> trade = GeneratedColumn<String>(
    'trade',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _tradeOtherMeta = const VerificationMeta(
    'tradeOther',
  );
  @override
  late final GeneratedColumn<String> tradeOther = GeneratedColumn<String>(
    'trade_other',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    homeId,
    name,
    trade,
    tradeOther,
    phone,
    email,
    address,
    note,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'contractors';
  @override
  VerificationContext validateIntegrity(
    Insertable<ContractorRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('trade')) {
      context.handle(
        _tradeMeta,
        trade.isAcceptableOrUnknown(data['trade']!, _tradeMeta),
      );
    }
    if (data.containsKey('trade_other')) {
      context.handle(
        _tradeOtherMeta,
        tradeOther.isAcceptableOrUnknown(data['trade_other']!, _tradeOtherMeta),
      );
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ContractorRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ContractorRow(
      id: $ContractorsTable.$converterid.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}id'],
        )!,
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      homeId: $ContractorsTable.$converterhomeId.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}home_id'],
        )!,
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      trade: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trade'],
      )!,
      tradeOther: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trade_other'],
      )!,
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      )!,
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      )!,
    );
  }

  @override
  $ContractorsTable createAlias(String alias) {
    return $ContractorsTable(attachedDatabase, alias);
  }

  static TypeConverter<String, Uint8List> $converterid = const UuidConverter();
  static TypeConverter<String, Uint8List> $converterhomeId =
      const UuidConverter();
}

class ContractorRow extends DataClass implements Insertable<ContractorRow> {
  final String id;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;
  final String homeId;
  final String name;
  final String trade;
  final String tradeOther;
  final String phone;
  final String email;
  final String address;
  final String note;
  const ContractorRow({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.homeId,
    required this.name,
    required this.trade,
    required this.tradeOther,
    required this.phone,
    required this.email,
    required this.address,
    required this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    {
      map['id'] = Variable<Uint8List>($ContractorsTable.$converterid.toSql(id));
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    {
      map['home_id'] = Variable<Uint8List>(
        $ContractorsTable.$converterhomeId.toSql(homeId),
      );
    }
    map['name'] = Variable<String>(name);
    map['trade'] = Variable<String>(trade);
    map['trade_other'] = Variable<String>(tradeOther);
    map['phone'] = Variable<String>(phone);
    map['email'] = Variable<String>(email);
    map['address'] = Variable<String>(address);
    map['note'] = Variable<String>(note);
    return map;
  }

  ContractorsCompanion toCompanion(bool nullToAbsent) {
    return ContractorsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      homeId: Value(homeId),
      name: Value(name),
      trade: Value(trade),
      tradeOther: Value(tradeOther),
      phone: Value(phone),
      email: Value(email),
      address: Value(address),
      note: Value(note),
    );
  }

  factory ContractorRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ContractorRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      homeId: serializer.fromJson<String>(json['homeId']),
      name: serializer.fromJson<String>(json['name']),
      trade: serializer.fromJson<String>(json['trade']),
      tradeOther: serializer.fromJson<String>(json['tradeOther']),
      phone: serializer.fromJson<String>(json['phone']),
      email: serializer.fromJson<String>(json['email']),
      address: serializer.fromJson<String>(json['address']),
      note: serializer.fromJson<String>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'homeId': serializer.toJson<String>(homeId),
      'name': serializer.toJson<String>(name),
      'trade': serializer.toJson<String>(trade),
      'tradeOther': serializer.toJson<String>(tradeOther),
      'phone': serializer.toJson<String>(phone),
      'email': serializer.toJson<String>(email),
      'address': serializer.toJson<String>(address),
      'note': serializer.toJson<String>(note),
    };
  }

  ContractorRow copyWith({
    String? id,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    String? homeId,
    String? name,
    String? trade,
    String? tradeOther,
    String? phone,
    String? email,
    String? address,
    String? note,
  }) => ContractorRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    homeId: homeId ?? this.homeId,
    name: name ?? this.name,
    trade: trade ?? this.trade,
    tradeOther: tradeOther ?? this.tradeOther,
    phone: phone ?? this.phone,
    email: email ?? this.email,
    address: address ?? this.address,
    note: note ?? this.note,
  );
  ContractorRow copyWithCompanion(ContractorsCompanion data) {
    return ContractorRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      homeId: data.homeId.present ? data.homeId.value : this.homeId,
      name: data.name.present ? data.name.value : this.name,
      trade: data.trade.present ? data.trade.value : this.trade,
      tradeOther: data.tradeOther.present
          ? data.tradeOther.value
          : this.tradeOther,
      phone: data.phone.present ? data.phone.value : this.phone,
      email: data.email.present ? data.email.value : this.email,
      address: data.address.present ? data.address.value : this.address,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ContractorRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('homeId: $homeId, ')
          ..write('name: $name, ')
          ..write('trade: $trade, ')
          ..write('tradeOther: $tradeOther, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('address: $address, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    homeId,
    name,
    trade,
    tradeOther,
    phone,
    email,
    address,
    note,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ContractorRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.homeId == this.homeId &&
          other.name == this.name &&
          other.trade == this.trade &&
          other.tradeOther == this.tradeOther &&
          other.phone == this.phone &&
          other.email == this.email &&
          other.address == this.address &&
          other.note == this.note);
}

class ContractorsCompanion extends UpdateCompanion<ContractorRow> {
  final Value<String> id;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<String> homeId;
  final Value<String> name;
  final Value<String> trade;
  final Value<String> tradeOther;
  final Value<String> phone;
  final Value<String> email;
  final Value<String> address;
  final Value<String> note;
  final Value<int> rowid;
  const ContractorsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.homeId = const Value.absent(),
    this.name = const Value.absent(),
    this.trade = const Value.absent(),
    this.tradeOther = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.address = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ContractorsCompanion.insert({
    required String id,
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    required String homeId,
    required String name,
    this.trade = const Value.absent(),
    this.tradeOther = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.address = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       homeId = Value(homeId),
       name = Value(name);
  static Insertable<ContractorRow> custom({
    Expression<Uint8List>? id,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<Uint8List>? homeId,
    Expression<String>? name,
    Expression<String>? trade,
    Expression<String>? tradeOther,
    Expression<String>? phone,
    Expression<String>? email,
    Expression<String>? address,
    Expression<String>? note,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (homeId != null) 'home_id': homeId,
      if (name != null) 'name': name,
      if (trade != null) 'trade': trade,
      if (tradeOther != null) 'trade_other': tradeOther,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (address != null) 'address': address,
      if (note != null) 'note': note,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ContractorsCompanion copyWith({
    Value<String>? id,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<String>? homeId,
    Value<String>? name,
    Value<String>? trade,
    Value<String>? tradeOther,
    Value<String>? phone,
    Value<String>? email,
    Value<String>? address,
    Value<String>? note,
    Value<int>? rowid,
  }) {
    return ContractorsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      homeId: homeId ?? this.homeId,
      name: name ?? this.name,
      trade: trade ?? this.trade,
      tradeOther: tradeOther ?? this.tradeOther,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      note: note ?? this.note,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<Uint8List>(
        $ContractorsTable.$converterid.toSql(id.value),
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (homeId.present) {
      map['home_id'] = Variable<Uint8List>(
        $ContractorsTable.$converterhomeId.toSql(homeId.value),
      );
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (trade.present) {
      map['trade'] = Variable<String>(trade.value);
    }
    if (tradeOther.present) {
      map['trade_other'] = Variable<String>(tradeOther.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ContractorsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('homeId: $homeId, ')
          ..write('name: $name, ')
          ..write('trade: $trade, ')
          ..write('tradeOther: $tradeOther, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('address: $address, ')
          ..write('note: $note, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TasksTable extends Tasks with TableInfo<$TasksTable, TaskRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TasksTable(this.attachedDatabase, [this._alias]);
  @override
  late final GeneratedColumnWithTypeConverter<String, Uint8List> id =
      GeneratedColumn<Uint8List>(
        'id',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      ).withConverter<String>($TasksTable.$converterid);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<String, Uint8List> homeId =
      GeneratedColumn<Uint8List>(
        'home_id',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      ).withConverter<String>($TasksTable.$converterhomeId);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<String?, Uint8List> roomId =
      GeneratedColumn<Uint8List>(
        'room_id',
        aliasedName,
        true,
        type: DriftSqlType.blob,
        requiredDuringInsert: false,
      ).withConverter<String?>($TasksTable.$converterroomIdn);
  @override
  late final GeneratedColumnWithTypeConverter<String?, Uint8List> itemId =
      GeneratedColumn<Uint8List>(
        'item_id',
        aliasedName,
        true,
        type: DriftSqlType.blob,
        requiredDuringInsert: false,
      ).withConverter<String?>($TasksTable.$converteritemIdn);
  static const VerificationMeta _priorityMeta = const VerificationMeta(
    'priority',
  );
  @override
  late final GeneratedColumn<String> priority = GeneratedColumn<String>(
    'priority',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('normal'),
  );
  static const VerificationMeta _estimatedMinutesMeta = const VerificationMeta(
    'estimatedMinutes',
  );
  @override
  late final GeneratedColumn<int> estimatedMinutes = GeneratedColumn<int>(
    'estimated_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _procedureMeta = const VerificationMeta(
    'procedure',
  );
  @override
  late final GeneratedColumn<String> procedure = GeneratedColumn<String>(
    'procedure',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  late final GeneratedColumnWithTypeConverter<String?, Uint8List> contractorId =
      GeneratedColumn<Uint8List>(
        'contractor_id',
        aliasedName,
        true,
        type: DriftSqlType.blob,
        requiredDuringInsert: false,
      ).withConverter<String?>($TasksTable.$convertercontractorIdn);
  static const VerificationMeta _repeatModeMeta = const VerificationMeta(
    'repeatMode',
  );
  @override
  late final GeneratedColumn<String> repeatMode = GeneratedColumn<String>(
    'repeat_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('once'),
  );
  static const VerificationMeta _repeatUnitMeta = const VerificationMeta(
    'repeatUnit',
  );
  @override
  late final GeneratedColumn<String> repeatUnit = GeneratedColumn<String>(
    'repeat_unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('month'),
  );
  static const VerificationMeta _repeatIntervalMeta = const VerificationMeta(
    'repeatInterval',
  );
  @override
  late final GeneratedColumn<int> repeatInterval = GeneratedColumn<int>(
    'repeat_interval',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _seasonMeta = const VerificationMeta('season');
  @override
  late final GeneratedColumn<String> season = GeneratedColumn<String>(
    'season',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _seasonStartMonthMeta = const VerificationMeta(
    'seasonStartMonth',
  );
  @override
  late final GeneratedColumn<int> seasonStartMonth = GeneratedColumn<int>(
    'season_start_month',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _seasonEndMonthMeta = const VerificationMeta(
    'seasonEndMonth',
  );
  @override
  late final GeneratedColumn<int> seasonEndMonth = GeneratedColumn<int>(
    'season_end_month',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hideDaysBeforeMeta = const VerificationMeta(
    'hideDaysBefore',
  );
  @override
  late final GeneratedColumn<int> hideDaysBefore = GeneratedColumn<int>(
    'hide_days_before',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _seriesStartMeta = const VerificationMeta(
    'seriesStart',
  );
  @override
  late final GeneratedColumn<String> seriesStart = GeneratedColumn<String>(
    'series_start',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    homeId,
    title,
    roomId,
    itemId,
    priority,
    estimatedMinutes,
    notes,
    procedure,
    contractorId,
    repeatMode,
    repeatUnit,
    repeatInterval,
    season,
    seasonStartMonth,
    seasonEndMonth,
    hideDaysBefore,
    seriesStart,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tasks';
  @override
  VerificationContext validateIntegrity(
    Insertable<TaskRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('priority')) {
      context.handle(
        _priorityMeta,
        priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta),
      );
    }
    if (data.containsKey('estimated_minutes')) {
      context.handle(
        _estimatedMinutesMeta,
        estimatedMinutes.isAcceptableOrUnknown(
          data['estimated_minutes']!,
          _estimatedMinutesMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('procedure')) {
      context.handle(
        _procedureMeta,
        procedure.isAcceptableOrUnknown(data['procedure']!, _procedureMeta),
      );
    }
    if (data.containsKey('repeat_mode')) {
      context.handle(
        _repeatModeMeta,
        repeatMode.isAcceptableOrUnknown(data['repeat_mode']!, _repeatModeMeta),
      );
    }
    if (data.containsKey('repeat_unit')) {
      context.handle(
        _repeatUnitMeta,
        repeatUnit.isAcceptableOrUnknown(data['repeat_unit']!, _repeatUnitMeta),
      );
    }
    if (data.containsKey('repeat_interval')) {
      context.handle(
        _repeatIntervalMeta,
        repeatInterval.isAcceptableOrUnknown(
          data['repeat_interval']!,
          _repeatIntervalMeta,
        ),
      );
    }
    if (data.containsKey('season')) {
      context.handle(
        _seasonMeta,
        season.isAcceptableOrUnknown(data['season']!, _seasonMeta),
      );
    }
    if (data.containsKey('season_start_month')) {
      context.handle(
        _seasonStartMonthMeta,
        seasonStartMonth.isAcceptableOrUnknown(
          data['season_start_month']!,
          _seasonStartMonthMeta,
        ),
      );
    }
    if (data.containsKey('season_end_month')) {
      context.handle(
        _seasonEndMonthMeta,
        seasonEndMonth.isAcceptableOrUnknown(
          data['season_end_month']!,
          _seasonEndMonthMeta,
        ),
      );
    }
    if (data.containsKey('hide_days_before')) {
      context.handle(
        _hideDaysBeforeMeta,
        hideDaysBefore.isAcceptableOrUnknown(
          data['hide_days_before']!,
          _hideDaysBeforeMeta,
        ),
      );
    }
    if (data.containsKey('series_start')) {
      context.handle(
        _seriesStartMeta,
        seriesStart.isAcceptableOrUnknown(
          data['series_start']!,
          _seriesStartMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TaskRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaskRow(
      id: $TasksTable.$converterid.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}id'],
        )!,
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      homeId: $TasksTable.$converterhomeId.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}home_id'],
        )!,
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      roomId: $TasksTable.$converterroomIdn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}room_id'],
        ),
      ),
      itemId: $TasksTable.$converteritemIdn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}item_id'],
        ),
      ),
      priority: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}priority'],
      )!,
      estimatedMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}estimated_minutes'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
      procedure: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}procedure'],
      )!,
      contractorId: $TasksTable.$convertercontractorIdn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}contractor_id'],
        ),
      ),
      repeatMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}repeat_mode'],
      )!,
      repeatUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}repeat_unit'],
      )!,
      repeatInterval: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}repeat_interval'],
      )!,
      season: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}season'],
      )!,
      seasonStartMonth: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}season_start_month'],
      ),
      seasonEndMonth: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}season_end_month'],
      ),
      hideDaysBefore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hide_days_before'],
      )!,
      seriesStart: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}series_start'],
      ),
    );
  }

  @override
  $TasksTable createAlias(String alias) {
    return $TasksTable(attachedDatabase, alias);
  }

  static TypeConverter<String, Uint8List> $converterid = const UuidConverter();
  static TypeConverter<String, Uint8List> $converterhomeId =
      const UuidConverter();
  static TypeConverter<String, Uint8List> $converterroomId =
      const UuidConverter();
  static TypeConverter<String?, Uint8List?> $converterroomIdn =
      NullAwareTypeConverter.wrap($converterroomId);
  static TypeConverter<String, Uint8List> $converteritemId =
      const UuidConverter();
  static TypeConverter<String?, Uint8List?> $converteritemIdn =
      NullAwareTypeConverter.wrap($converteritemId);
  static TypeConverter<String, Uint8List> $convertercontractorId =
      const UuidConverter();
  static TypeConverter<String?, Uint8List?> $convertercontractorIdn =
      NullAwareTypeConverter.wrap($convertercontractorId);
}

class TaskRow extends DataClass implements Insertable<TaskRow> {
  final String id;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;
  final String homeId;
  final String title;
  final String? roomId;
  final String? itemId;
  final String priority;
  final int? estimatedMinutes;
  final String notes;
  final String procedure;
  final String? contractorId;
  final String repeatMode;
  final String repeatUnit;
  final int repeatInterval;
  final String season;
  final int? seasonStartMonth;
  final int? seasonEndMonth;
  final int hideDaysBefore;

  /// First due date of a fixed series: it carries the day of the month.
  final String? seriesStart;
  const TaskRow({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.homeId,
    required this.title,
    this.roomId,
    this.itemId,
    required this.priority,
    this.estimatedMinutes,
    required this.notes,
    required this.procedure,
    this.contractorId,
    required this.repeatMode,
    required this.repeatUnit,
    required this.repeatInterval,
    required this.season,
    this.seasonStartMonth,
    this.seasonEndMonth,
    required this.hideDaysBefore,
    this.seriesStart,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    {
      map['id'] = Variable<Uint8List>($TasksTable.$converterid.toSql(id));
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    {
      map['home_id'] = Variable<Uint8List>(
        $TasksTable.$converterhomeId.toSql(homeId),
      );
    }
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || roomId != null) {
      map['room_id'] = Variable<Uint8List>(
        $TasksTable.$converterroomIdn.toSql(roomId),
      );
    }
    if (!nullToAbsent || itemId != null) {
      map['item_id'] = Variable<Uint8List>(
        $TasksTable.$converteritemIdn.toSql(itemId),
      );
    }
    map['priority'] = Variable<String>(priority);
    if (!nullToAbsent || estimatedMinutes != null) {
      map['estimated_minutes'] = Variable<int>(estimatedMinutes);
    }
    map['notes'] = Variable<String>(notes);
    map['procedure'] = Variable<String>(procedure);
    if (!nullToAbsent || contractorId != null) {
      map['contractor_id'] = Variable<Uint8List>(
        $TasksTable.$convertercontractorIdn.toSql(contractorId),
      );
    }
    map['repeat_mode'] = Variable<String>(repeatMode);
    map['repeat_unit'] = Variable<String>(repeatUnit);
    map['repeat_interval'] = Variable<int>(repeatInterval);
    map['season'] = Variable<String>(season);
    if (!nullToAbsent || seasonStartMonth != null) {
      map['season_start_month'] = Variable<int>(seasonStartMonth);
    }
    if (!nullToAbsent || seasonEndMonth != null) {
      map['season_end_month'] = Variable<int>(seasonEndMonth);
    }
    map['hide_days_before'] = Variable<int>(hideDaysBefore);
    if (!nullToAbsent || seriesStart != null) {
      map['series_start'] = Variable<String>(seriesStart);
    }
    return map;
  }

  TasksCompanion toCompanion(bool nullToAbsent) {
    return TasksCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      homeId: Value(homeId),
      title: Value(title),
      roomId: roomId == null && nullToAbsent
          ? const Value.absent()
          : Value(roomId),
      itemId: itemId == null && nullToAbsent
          ? const Value.absent()
          : Value(itemId),
      priority: Value(priority),
      estimatedMinutes: estimatedMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(estimatedMinutes),
      notes: Value(notes),
      procedure: Value(procedure),
      contractorId: contractorId == null && nullToAbsent
          ? const Value.absent()
          : Value(contractorId),
      repeatMode: Value(repeatMode),
      repeatUnit: Value(repeatUnit),
      repeatInterval: Value(repeatInterval),
      season: Value(season),
      seasonStartMonth: seasonStartMonth == null && nullToAbsent
          ? const Value.absent()
          : Value(seasonStartMonth),
      seasonEndMonth: seasonEndMonth == null && nullToAbsent
          ? const Value.absent()
          : Value(seasonEndMonth),
      hideDaysBefore: Value(hideDaysBefore),
      seriesStart: seriesStart == null && nullToAbsent
          ? const Value.absent()
          : Value(seriesStart),
    );
  }

  factory TaskRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaskRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      homeId: serializer.fromJson<String>(json['homeId']),
      title: serializer.fromJson<String>(json['title']),
      roomId: serializer.fromJson<String?>(json['roomId']),
      itemId: serializer.fromJson<String?>(json['itemId']),
      priority: serializer.fromJson<String>(json['priority']),
      estimatedMinutes: serializer.fromJson<int?>(json['estimatedMinutes']),
      notes: serializer.fromJson<String>(json['notes']),
      procedure: serializer.fromJson<String>(json['procedure']),
      contractorId: serializer.fromJson<String?>(json['contractorId']),
      repeatMode: serializer.fromJson<String>(json['repeatMode']),
      repeatUnit: serializer.fromJson<String>(json['repeatUnit']),
      repeatInterval: serializer.fromJson<int>(json['repeatInterval']),
      season: serializer.fromJson<String>(json['season']),
      seasonStartMonth: serializer.fromJson<int?>(json['seasonStartMonth']),
      seasonEndMonth: serializer.fromJson<int?>(json['seasonEndMonth']),
      hideDaysBefore: serializer.fromJson<int>(json['hideDaysBefore']),
      seriesStart: serializer.fromJson<String?>(json['seriesStart']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'homeId': serializer.toJson<String>(homeId),
      'title': serializer.toJson<String>(title),
      'roomId': serializer.toJson<String?>(roomId),
      'itemId': serializer.toJson<String?>(itemId),
      'priority': serializer.toJson<String>(priority),
      'estimatedMinutes': serializer.toJson<int?>(estimatedMinutes),
      'notes': serializer.toJson<String>(notes),
      'procedure': serializer.toJson<String>(procedure),
      'contractorId': serializer.toJson<String?>(contractorId),
      'repeatMode': serializer.toJson<String>(repeatMode),
      'repeatUnit': serializer.toJson<String>(repeatUnit),
      'repeatInterval': serializer.toJson<int>(repeatInterval),
      'season': serializer.toJson<String>(season),
      'seasonStartMonth': serializer.toJson<int?>(seasonStartMonth),
      'seasonEndMonth': serializer.toJson<int?>(seasonEndMonth),
      'hideDaysBefore': serializer.toJson<int>(hideDaysBefore),
      'seriesStart': serializer.toJson<String?>(seriesStart),
    };
  }

  TaskRow copyWith({
    String? id,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    String? homeId,
    String? title,
    Value<String?> roomId = const Value.absent(),
    Value<String?> itemId = const Value.absent(),
    String? priority,
    Value<int?> estimatedMinutes = const Value.absent(),
    String? notes,
    String? procedure,
    Value<String?> contractorId = const Value.absent(),
    String? repeatMode,
    String? repeatUnit,
    int? repeatInterval,
    String? season,
    Value<int?> seasonStartMonth = const Value.absent(),
    Value<int?> seasonEndMonth = const Value.absent(),
    int? hideDaysBefore,
    Value<String?> seriesStart = const Value.absent(),
  }) => TaskRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    homeId: homeId ?? this.homeId,
    title: title ?? this.title,
    roomId: roomId.present ? roomId.value : this.roomId,
    itemId: itemId.present ? itemId.value : this.itemId,
    priority: priority ?? this.priority,
    estimatedMinutes: estimatedMinutes.present
        ? estimatedMinutes.value
        : this.estimatedMinutes,
    notes: notes ?? this.notes,
    procedure: procedure ?? this.procedure,
    contractorId: contractorId.present ? contractorId.value : this.contractorId,
    repeatMode: repeatMode ?? this.repeatMode,
    repeatUnit: repeatUnit ?? this.repeatUnit,
    repeatInterval: repeatInterval ?? this.repeatInterval,
    season: season ?? this.season,
    seasonStartMonth: seasonStartMonth.present
        ? seasonStartMonth.value
        : this.seasonStartMonth,
    seasonEndMonth: seasonEndMonth.present
        ? seasonEndMonth.value
        : this.seasonEndMonth,
    hideDaysBefore: hideDaysBefore ?? this.hideDaysBefore,
    seriesStart: seriesStart.present ? seriesStart.value : this.seriesStart,
  );
  TaskRow copyWithCompanion(TasksCompanion data) {
    return TaskRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      homeId: data.homeId.present ? data.homeId.value : this.homeId,
      title: data.title.present ? data.title.value : this.title,
      roomId: data.roomId.present ? data.roomId.value : this.roomId,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      priority: data.priority.present ? data.priority.value : this.priority,
      estimatedMinutes: data.estimatedMinutes.present
          ? data.estimatedMinutes.value
          : this.estimatedMinutes,
      notes: data.notes.present ? data.notes.value : this.notes,
      procedure: data.procedure.present ? data.procedure.value : this.procedure,
      contractorId: data.contractorId.present
          ? data.contractorId.value
          : this.contractorId,
      repeatMode: data.repeatMode.present
          ? data.repeatMode.value
          : this.repeatMode,
      repeatUnit: data.repeatUnit.present
          ? data.repeatUnit.value
          : this.repeatUnit,
      repeatInterval: data.repeatInterval.present
          ? data.repeatInterval.value
          : this.repeatInterval,
      season: data.season.present ? data.season.value : this.season,
      seasonStartMonth: data.seasonStartMonth.present
          ? data.seasonStartMonth.value
          : this.seasonStartMonth,
      seasonEndMonth: data.seasonEndMonth.present
          ? data.seasonEndMonth.value
          : this.seasonEndMonth,
      hideDaysBefore: data.hideDaysBefore.present
          ? data.hideDaysBefore.value
          : this.hideDaysBefore,
      seriesStart: data.seriesStart.present
          ? data.seriesStart.value
          : this.seriesStart,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaskRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('homeId: $homeId, ')
          ..write('title: $title, ')
          ..write('roomId: $roomId, ')
          ..write('itemId: $itemId, ')
          ..write('priority: $priority, ')
          ..write('estimatedMinutes: $estimatedMinutes, ')
          ..write('notes: $notes, ')
          ..write('procedure: $procedure, ')
          ..write('contractorId: $contractorId, ')
          ..write('repeatMode: $repeatMode, ')
          ..write('repeatUnit: $repeatUnit, ')
          ..write('repeatInterval: $repeatInterval, ')
          ..write('season: $season, ')
          ..write('seasonStartMonth: $seasonStartMonth, ')
          ..write('seasonEndMonth: $seasonEndMonth, ')
          ..write('hideDaysBefore: $hideDaysBefore, ')
          ..write('seriesStart: $seriesStart')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    createdAt,
    updatedAt,
    deletedAt,
    homeId,
    title,
    roomId,
    itemId,
    priority,
    estimatedMinutes,
    notes,
    procedure,
    contractorId,
    repeatMode,
    repeatUnit,
    repeatInterval,
    season,
    seasonStartMonth,
    seasonEndMonth,
    hideDaysBefore,
    seriesStart,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaskRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.homeId == this.homeId &&
          other.title == this.title &&
          other.roomId == this.roomId &&
          other.itemId == this.itemId &&
          other.priority == this.priority &&
          other.estimatedMinutes == this.estimatedMinutes &&
          other.notes == this.notes &&
          other.procedure == this.procedure &&
          other.contractorId == this.contractorId &&
          other.repeatMode == this.repeatMode &&
          other.repeatUnit == this.repeatUnit &&
          other.repeatInterval == this.repeatInterval &&
          other.season == this.season &&
          other.seasonStartMonth == this.seasonStartMonth &&
          other.seasonEndMonth == this.seasonEndMonth &&
          other.hideDaysBefore == this.hideDaysBefore &&
          other.seriesStart == this.seriesStart);
}

class TasksCompanion extends UpdateCompanion<TaskRow> {
  final Value<String> id;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<String> homeId;
  final Value<String> title;
  final Value<String?> roomId;
  final Value<String?> itemId;
  final Value<String> priority;
  final Value<int?> estimatedMinutes;
  final Value<String> notes;
  final Value<String> procedure;
  final Value<String?> contractorId;
  final Value<String> repeatMode;
  final Value<String> repeatUnit;
  final Value<int> repeatInterval;
  final Value<String> season;
  final Value<int?> seasonStartMonth;
  final Value<int?> seasonEndMonth;
  final Value<int> hideDaysBefore;
  final Value<String?> seriesStart;
  final Value<int> rowid;
  const TasksCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.homeId = const Value.absent(),
    this.title = const Value.absent(),
    this.roomId = const Value.absent(),
    this.itemId = const Value.absent(),
    this.priority = const Value.absent(),
    this.estimatedMinutes = const Value.absent(),
    this.notes = const Value.absent(),
    this.procedure = const Value.absent(),
    this.contractorId = const Value.absent(),
    this.repeatMode = const Value.absent(),
    this.repeatUnit = const Value.absent(),
    this.repeatInterval = const Value.absent(),
    this.season = const Value.absent(),
    this.seasonStartMonth = const Value.absent(),
    this.seasonEndMonth = const Value.absent(),
    this.hideDaysBefore = const Value.absent(),
    this.seriesStart = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TasksCompanion.insert({
    required String id,
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    required String homeId,
    required String title,
    this.roomId = const Value.absent(),
    this.itemId = const Value.absent(),
    this.priority = const Value.absent(),
    this.estimatedMinutes = const Value.absent(),
    this.notes = const Value.absent(),
    this.procedure = const Value.absent(),
    this.contractorId = const Value.absent(),
    this.repeatMode = const Value.absent(),
    this.repeatUnit = const Value.absent(),
    this.repeatInterval = const Value.absent(),
    this.season = const Value.absent(),
    this.seasonStartMonth = const Value.absent(),
    this.seasonEndMonth = const Value.absent(),
    this.hideDaysBefore = const Value.absent(),
    this.seriesStart = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       homeId = Value(homeId),
       title = Value(title);
  static Insertable<TaskRow> custom({
    Expression<Uint8List>? id,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<Uint8List>? homeId,
    Expression<String>? title,
    Expression<Uint8List>? roomId,
    Expression<Uint8List>? itemId,
    Expression<String>? priority,
    Expression<int>? estimatedMinutes,
    Expression<String>? notes,
    Expression<String>? procedure,
    Expression<Uint8List>? contractorId,
    Expression<String>? repeatMode,
    Expression<String>? repeatUnit,
    Expression<int>? repeatInterval,
    Expression<String>? season,
    Expression<int>? seasonStartMonth,
    Expression<int>? seasonEndMonth,
    Expression<int>? hideDaysBefore,
    Expression<String>? seriesStart,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (homeId != null) 'home_id': homeId,
      if (title != null) 'title': title,
      if (roomId != null) 'room_id': roomId,
      if (itemId != null) 'item_id': itemId,
      if (priority != null) 'priority': priority,
      if (estimatedMinutes != null) 'estimated_minutes': estimatedMinutes,
      if (notes != null) 'notes': notes,
      if (procedure != null) 'procedure': procedure,
      if (contractorId != null) 'contractor_id': contractorId,
      if (repeatMode != null) 'repeat_mode': repeatMode,
      if (repeatUnit != null) 'repeat_unit': repeatUnit,
      if (repeatInterval != null) 'repeat_interval': repeatInterval,
      if (season != null) 'season': season,
      if (seasonStartMonth != null) 'season_start_month': seasonStartMonth,
      if (seasonEndMonth != null) 'season_end_month': seasonEndMonth,
      if (hideDaysBefore != null) 'hide_days_before': hideDaysBefore,
      if (seriesStart != null) 'series_start': seriesStart,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TasksCompanion copyWith({
    Value<String>? id,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<String>? homeId,
    Value<String>? title,
    Value<String?>? roomId,
    Value<String?>? itemId,
    Value<String>? priority,
    Value<int?>? estimatedMinutes,
    Value<String>? notes,
    Value<String>? procedure,
    Value<String?>? contractorId,
    Value<String>? repeatMode,
    Value<String>? repeatUnit,
    Value<int>? repeatInterval,
    Value<String>? season,
    Value<int?>? seasonStartMonth,
    Value<int?>? seasonEndMonth,
    Value<int>? hideDaysBefore,
    Value<String?>? seriesStart,
    Value<int>? rowid,
  }) {
    return TasksCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      homeId: homeId ?? this.homeId,
      title: title ?? this.title,
      roomId: roomId ?? this.roomId,
      itemId: itemId ?? this.itemId,
      priority: priority ?? this.priority,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      notes: notes ?? this.notes,
      procedure: procedure ?? this.procedure,
      contractorId: contractorId ?? this.contractorId,
      repeatMode: repeatMode ?? this.repeatMode,
      repeatUnit: repeatUnit ?? this.repeatUnit,
      repeatInterval: repeatInterval ?? this.repeatInterval,
      season: season ?? this.season,
      seasonStartMonth: seasonStartMonth ?? this.seasonStartMonth,
      seasonEndMonth: seasonEndMonth ?? this.seasonEndMonth,
      hideDaysBefore: hideDaysBefore ?? this.hideDaysBefore,
      seriesStart: seriesStart ?? this.seriesStart,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<Uint8List>($TasksTable.$converterid.toSql(id.value));
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (homeId.present) {
      map['home_id'] = Variable<Uint8List>(
        $TasksTable.$converterhomeId.toSql(homeId.value),
      );
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (roomId.present) {
      map['room_id'] = Variable<Uint8List>(
        $TasksTable.$converterroomIdn.toSql(roomId.value),
      );
    }
    if (itemId.present) {
      map['item_id'] = Variable<Uint8List>(
        $TasksTable.$converteritemIdn.toSql(itemId.value),
      );
    }
    if (priority.present) {
      map['priority'] = Variable<String>(priority.value);
    }
    if (estimatedMinutes.present) {
      map['estimated_minutes'] = Variable<int>(estimatedMinutes.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (procedure.present) {
      map['procedure'] = Variable<String>(procedure.value);
    }
    if (contractorId.present) {
      map['contractor_id'] = Variable<Uint8List>(
        $TasksTable.$convertercontractorIdn.toSql(contractorId.value),
      );
    }
    if (repeatMode.present) {
      map['repeat_mode'] = Variable<String>(repeatMode.value);
    }
    if (repeatUnit.present) {
      map['repeat_unit'] = Variable<String>(repeatUnit.value);
    }
    if (repeatInterval.present) {
      map['repeat_interval'] = Variable<int>(repeatInterval.value);
    }
    if (season.present) {
      map['season'] = Variable<String>(season.value);
    }
    if (seasonStartMonth.present) {
      map['season_start_month'] = Variable<int>(seasonStartMonth.value);
    }
    if (seasonEndMonth.present) {
      map['season_end_month'] = Variable<int>(seasonEndMonth.value);
    }
    if (hideDaysBefore.present) {
      map['hide_days_before'] = Variable<int>(hideDaysBefore.value);
    }
    if (seriesStart.present) {
      map['series_start'] = Variable<String>(seriesStart.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TasksCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('homeId: $homeId, ')
          ..write('title: $title, ')
          ..write('roomId: $roomId, ')
          ..write('itemId: $itemId, ')
          ..write('priority: $priority, ')
          ..write('estimatedMinutes: $estimatedMinutes, ')
          ..write('notes: $notes, ')
          ..write('procedure: $procedure, ')
          ..write('contractorId: $contractorId, ')
          ..write('repeatMode: $repeatMode, ')
          ..write('repeatUnit: $repeatUnit, ')
          ..write('repeatInterval: $repeatInterval, ')
          ..write('season: $season, ')
          ..write('seasonStartMonth: $seasonStartMonth, ')
          ..write('seasonEndMonth: $seasonEndMonth, ')
          ..write('hideDaysBefore: $hideDaysBefore, ')
          ..write('seriesStart: $seriesStart, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OccurrencesTable extends Occurrences
    with TableInfo<$OccurrencesTable, OccurrenceRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OccurrencesTable(this.attachedDatabase, [this._alias]);
  @override
  late final GeneratedColumnWithTypeConverter<String, Uint8List> id =
      GeneratedColumn<Uint8List>(
        'id',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      ).withConverter<String>($OccurrencesTable.$converterid);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<String, Uint8List> homeId =
      GeneratedColumn<Uint8List>(
        'home_id',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      ).withConverter<String>($OccurrencesTable.$converterhomeId);
  @override
  late final GeneratedColumnWithTypeConverter<String, Uint8List> taskId =
      GeneratedColumn<Uint8List>(
        'task_id',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      ).withConverter<String>($OccurrencesTable.$convertertaskId);
  static const VerificationMeta _dueOnMeta = const VerificationMeta('dueOn');
  @override
  late final GeneratedColumn<String> dueOn = GeneratedColumn<String>(
    'due_on',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _visibleFromMeta = const VerificationMeta(
    'visibleFrom',
  );
  @override
  late final GeneratedColumn<String> visibleFrom = GeneratedColumn<String>(
    'visible_from',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('planned'),
  );
  static const VerificationMeta _statusBeforeMeta = const VerificationMeta(
    'statusBefore',
  );
  @override
  late final GeneratedColumn<String> statusBefore = GeneratedColumn<String>(
    'status_before',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _postponedFromMeta = const VerificationMeta(
    'postponedFrom',
  );
  @override
  late final GeneratedColumn<String> postponedFrom = GeneratedColumn<String>(
    'postponed_from',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _completedOnMeta = const VerificationMeta(
    'completedOn',
  );
  @override
  late final GeneratedColumn<String> completedOn = GeneratedColumn<String>(
    'completed_on',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _completionNoteMeta = const VerificationMeta(
    'completionNote',
  );
  @override
  late final GeneratedColumn<String> completionNote = GeneratedColumn<String>(
    'completion_note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  late final GeneratedColumnWithTypeConverter<String?, Uint8List> follows =
      GeneratedColumn<Uint8List>(
        'follows',
        aliasedName,
        true,
        type: DriftSqlType.blob,
        requiredDuringInsert: false,
      ).withConverter<String?>($OccurrencesTable.$converterfollowsn);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    homeId,
    taskId,
    dueOn,
    visibleFrom,
    status,
    statusBefore,
    postponedFrom,
    completedOn,
    completionNote,
    follows,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'occurrences';
  @override
  VerificationContext validateIntegrity(
    Insertable<OccurrenceRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('due_on')) {
      context.handle(
        _dueOnMeta,
        dueOn.isAcceptableOrUnknown(data['due_on']!, _dueOnMeta),
      );
    }
    if (data.containsKey('visible_from')) {
      context.handle(
        _visibleFromMeta,
        visibleFrom.isAcceptableOrUnknown(
          data['visible_from']!,
          _visibleFromMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('status_before')) {
      context.handle(
        _statusBeforeMeta,
        statusBefore.isAcceptableOrUnknown(
          data['status_before']!,
          _statusBeforeMeta,
        ),
      );
    }
    if (data.containsKey('postponed_from')) {
      context.handle(
        _postponedFromMeta,
        postponedFrom.isAcceptableOrUnknown(
          data['postponed_from']!,
          _postponedFromMeta,
        ),
      );
    }
    if (data.containsKey('completed_on')) {
      context.handle(
        _completedOnMeta,
        completedOn.isAcceptableOrUnknown(
          data['completed_on']!,
          _completedOnMeta,
        ),
      );
    }
    if (data.containsKey('completion_note')) {
      context.handle(
        _completionNoteMeta,
        completionNote.isAcceptableOrUnknown(
          data['completion_note']!,
          _completionNoteMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OccurrenceRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OccurrenceRow(
      id: $OccurrencesTable.$converterid.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}id'],
        )!,
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      homeId: $OccurrencesTable.$converterhomeId.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}home_id'],
        )!,
      ),
      taskId: $OccurrencesTable.$convertertaskId.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}task_id'],
        )!,
      ),
      dueOn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}due_on'],
      ),
      visibleFrom: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}visible_from'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      statusBefore: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status_before'],
      )!,
      postponedFrom: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}postponed_from'],
      ),
      completedOn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}completed_on'],
      ),
      completionNote: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}completion_note'],
      )!,
      follows: $OccurrencesTable.$converterfollowsn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}follows'],
        ),
      ),
    );
  }

  @override
  $OccurrencesTable createAlias(String alias) {
    return $OccurrencesTable(attachedDatabase, alias);
  }

  static TypeConverter<String, Uint8List> $converterid = const UuidConverter();
  static TypeConverter<String, Uint8List> $converterhomeId =
      const UuidConverter();
  static TypeConverter<String, Uint8List> $convertertaskId =
      const UuidConverter();
  static TypeConverter<String, Uint8List> $converterfollows =
      const UuidConverter();
  static TypeConverter<String?, Uint8List?> $converterfollowsn =
      NullAwareTypeConverter.wrap($converterfollows);
}

class OccurrenceRow extends DataClass implements Insertable<OccurrenceRow> {
  final String id;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;
  final String homeId;
  final String taskId;
  final String? dueOn;
  final String? visibleFrom;
  final String status;
  final String statusBefore;
  final String? postponedFrom;
  final String? completedOn;
  final String completionNote;

  /// The occurrence whose closing created this one.
  final String? follows;
  const OccurrenceRow({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.homeId,
    required this.taskId,
    this.dueOn,
    this.visibleFrom,
    required this.status,
    required this.statusBefore,
    this.postponedFrom,
    this.completedOn,
    required this.completionNote,
    this.follows,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    {
      map['id'] = Variable<Uint8List>($OccurrencesTable.$converterid.toSql(id));
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    {
      map['home_id'] = Variable<Uint8List>(
        $OccurrencesTable.$converterhomeId.toSql(homeId),
      );
    }
    {
      map['task_id'] = Variable<Uint8List>(
        $OccurrencesTable.$convertertaskId.toSql(taskId),
      );
    }
    if (!nullToAbsent || dueOn != null) {
      map['due_on'] = Variable<String>(dueOn);
    }
    if (!nullToAbsent || visibleFrom != null) {
      map['visible_from'] = Variable<String>(visibleFrom);
    }
    map['status'] = Variable<String>(status);
    map['status_before'] = Variable<String>(statusBefore);
    if (!nullToAbsent || postponedFrom != null) {
      map['postponed_from'] = Variable<String>(postponedFrom);
    }
    if (!nullToAbsent || completedOn != null) {
      map['completed_on'] = Variable<String>(completedOn);
    }
    map['completion_note'] = Variable<String>(completionNote);
    if (!nullToAbsent || follows != null) {
      map['follows'] = Variable<Uint8List>(
        $OccurrencesTable.$converterfollowsn.toSql(follows),
      );
    }
    return map;
  }

  OccurrencesCompanion toCompanion(bool nullToAbsent) {
    return OccurrencesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      homeId: Value(homeId),
      taskId: Value(taskId),
      dueOn: dueOn == null && nullToAbsent
          ? const Value.absent()
          : Value(dueOn),
      visibleFrom: visibleFrom == null && nullToAbsent
          ? const Value.absent()
          : Value(visibleFrom),
      status: Value(status),
      statusBefore: Value(statusBefore),
      postponedFrom: postponedFrom == null && nullToAbsent
          ? const Value.absent()
          : Value(postponedFrom),
      completedOn: completedOn == null && nullToAbsent
          ? const Value.absent()
          : Value(completedOn),
      completionNote: Value(completionNote),
      follows: follows == null && nullToAbsent
          ? const Value.absent()
          : Value(follows),
    );
  }

  factory OccurrenceRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OccurrenceRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      homeId: serializer.fromJson<String>(json['homeId']),
      taskId: serializer.fromJson<String>(json['taskId']),
      dueOn: serializer.fromJson<String?>(json['dueOn']),
      visibleFrom: serializer.fromJson<String?>(json['visibleFrom']),
      status: serializer.fromJson<String>(json['status']),
      statusBefore: serializer.fromJson<String>(json['statusBefore']),
      postponedFrom: serializer.fromJson<String?>(json['postponedFrom']),
      completedOn: serializer.fromJson<String?>(json['completedOn']),
      completionNote: serializer.fromJson<String>(json['completionNote']),
      follows: serializer.fromJson<String?>(json['follows']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'homeId': serializer.toJson<String>(homeId),
      'taskId': serializer.toJson<String>(taskId),
      'dueOn': serializer.toJson<String?>(dueOn),
      'visibleFrom': serializer.toJson<String?>(visibleFrom),
      'status': serializer.toJson<String>(status),
      'statusBefore': serializer.toJson<String>(statusBefore),
      'postponedFrom': serializer.toJson<String?>(postponedFrom),
      'completedOn': serializer.toJson<String?>(completedOn),
      'completionNote': serializer.toJson<String>(completionNote),
      'follows': serializer.toJson<String?>(follows),
    };
  }

  OccurrenceRow copyWith({
    String? id,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    String? homeId,
    String? taskId,
    Value<String?> dueOn = const Value.absent(),
    Value<String?> visibleFrom = const Value.absent(),
    String? status,
    String? statusBefore,
    Value<String?> postponedFrom = const Value.absent(),
    Value<String?> completedOn = const Value.absent(),
    String? completionNote,
    Value<String?> follows = const Value.absent(),
  }) => OccurrenceRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    homeId: homeId ?? this.homeId,
    taskId: taskId ?? this.taskId,
    dueOn: dueOn.present ? dueOn.value : this.dueOn,
    visibleFrom: visibleFrom.present ? visibleFrom.value : this.visibleFrom,
    status: status ?? this.status,
    statusBefore: statusBefore ?? this.statusBefore,
    postponedFrom: postponedFrom.present
        ? postponedFrom.value
        : this.postponedFrom,
    completedOn: completedOn.present ? completedOn.value : this.completedOn,
    completionNote: completionNote ?? this.completionNote,
    follows: follows.present ? follows.value : this.follows,
  );
  OccurrenceRow copyWithCompanion(OccurrencesCompanion data) {
    return OccurrenceRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      homeId: data.homeId.present ? data.homeId.value : this.homeId,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      dueOn: data.dueOn.present ? data.dueOn.value : this.dueOn,
      visibleFrom: data.visibleFrom.present
          ? data.visibleFrom.value
          : this.visibleFrom,
      status: data.status.present ? data.status.value : this.status,
      statusBefore: data.statusBefore.present
          ? data.statusBefore.value
          : this.statusBefore,
      postponedFrom: data.postponedFrom.present
          ? data.postponedFrom.value
          : this.postponedFrom,
      completedOn: data.completedOn.present
          ? data.completedOn.value
          : this.completedOn,
      completionNote: data.completionNote.present
          ? data.completionNote.value
          : this.completionNote,
      follows: data.follows.present ? data.follows.value : this.follows,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OccurrenceRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('homeId: $homeId, ')
          ..write('taskId: $taskId, ')
          ..write('dueOn: $dueOn, ')
          ..write('visibleFrom: $visibleFrom, ')
          ..write('status: $status, ')
          ..write('statusBefore: $statusBefore, ')
          ..write('postponedFrom: $postponedFrom, ')
          ..write('completedOn: $completedOn, ')
          ..write('completionNote: $completionNote, ')
          ..write('follows: $follows')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    homeId,
    taskId,
    dueOn,
    visibleFrom,
    status,
    statusBefore,
    postponedFrom,
    completedOn,
    completionNote,
    follows,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OccurrenceRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.homeId == this.homeId &&
          other.taskId == this.taskId &&
          other.dueOn == this.dueOn &&
          other.visibleFrom == this.visibleFrom &&
          other.status == this.status &&
          other.statusBefore == this.statusBefore &&
          other.postponedFrom == this.postponedFrom &&
          other.completedOn == this.completedOn &&
          other.completionNote == this.completionNote &&
          other.follows == this.follows);
}

class OccurrencesCompanion extends UpdateCompanion<OccurrenceRow> {
  final Value<String> id;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<String> homeId;
  final Value<String> taskId;
  final Value<String?> dueOn;
  final Value<String?> visibleFrom;
  final Value<String> status;
  final Value<String> statusBefore;
  final Value<String?> postponedFrom;
  final Value<String?> completedOn;
  final Value<String> completionNote;
  final Value<String?> follows;
  final Value<int> rowid;
  const OccurrencesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.homeId = const Value.absent(),
    this.taskId = const Value.absent(),
    this.dueOn = const Value.absent(),
    this.visibleFrom = const Value.absent(),
    this.status = const Value.absent(),
    this.statusBefore = const Value.absent(),
    this.postponedFrom = const Value.absent(),
    this.completedOn = const Value.absent(),
    this.completionNote = const Value.absent(),
    this.follows = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OccurrencesCompanion.insert({
    required String id,
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    required String homeId,
    required String taskId,
    this.dueOn = const Value.absent(),
    this.visibleFrom = const Value.absent(),
    this.status = const Value.absent(),
    this.statusBefore = const Value.absent(),
    this.postponedFrom = const Value.absent(),
    this.completedOn = const Value.absent(),
    this.completionNote = const Value.absent(),
    this.follows = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       homeId = Value(homeId),
       taskId = Value(taskId);
  static Insertable<OccurrenceRow> custom({
    Expression<Uint8List>? id,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<Uint8List>? homeId,
    Expression<Uint8List>? taskId,
    Expression<String>? dueOn,
    Expression<String>? visibleFrom,
    Expression<String>? status,
    Expression<String>? statusBefore,
    Expression<String>? postponedFrom,
    Expression<String>? completedOn,
    Expression<String>? completionNote,
    Expression<Uint8List>? follows,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (homeId != null) 'home_id': homeId,
      if (taskId != null) 'task_id': taskId,
      if (dueOn != null) 'due_on': dueOn,
      if (visibleFrom != null) 'visible_from': visibleFrom,
      if (status != null) 'status': status,
      if (statusBefore != null) 'status_before': statusBefore,
      if (postponedFrom != null) 'postponed_from': postponedFrom,
      if (completedOn != null) 'completed_on': completedOn,
      if (completionNote != null) 'completion_note': completionNote,
      if (follows != null) 'follows': follows,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OccurrencesCompanion copyWith({
    Value<String>? id,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<String>? homeId,
    Value<String>? taskId,
    Value<String?>? dueOn,
    Value<String?>? visibleFrom,
    Value<String>? status,
    Value<String>? statusBefore,
    Value<String?>? postponedFrom,
    Value<String?>? completedOn,
    Value<String>? completionNote,
    Value<String?>? follows,
    Value<int>? rowid,
  }) {
    return OccurrencesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      homeId: homeId ?? this.homeId,
      taskId: taskId ?? this.taskId,
      dueOn: dueOn ?? this.dueOn,
      visibleFrom: visibleFrom ?? this.visibleFrom,
      status: status ?? this.status,
      statusBefore: statusBefore ?? this.statusBefore,
      postponedFrom: postponedFrom ?? this.postponedFrom,
      completedOn: completedOn ?? this.completedOn,
      completionNote: completionNote ?? this.completionNote,
      follows: follows ?? this.follows,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<Uint8List>(
        $OccurrencesTable.$converterid.toSql(id.value),
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (homeId.present) {
      map['home_id'] = Variable<Uint8List>(
        $OccurrencesTable.$converterhomeId.toSql(homeId.value),
      );
    }
    if (taskId.present) {
      map['task_id'] = Variable<Uint8List>(
        $OccurrencesTable.$convertertaskId.toSql(taskId.value),
      );
    }
    if (dueOn.present) {
      map['due_on'] = Variable<String>(dueOn.value);
    }
    if (visibleFrom.present) {
      map['visible_from'] = Variable<String>(visibleFrom.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (statusBefore.present) {
      map['status_before'] = Variable<String>(statusBefore.value);
    }
    if (postponedFrom.present) {
      map['postponed_from'] = Variable<String>(postponedFrom.value);
    }
    if (completedOn.present) {
      map['completed_on'] = Variable<String>(completedOn.value);
    }
    if (completionNote.present) {
      map['completion_note'] = Variable<String>(completionNote.value);
    }
    if (follows.present) {
      map['follows'] = Variable<Uint8List>(
        $OccurrencesTable.$converterfollowsn.toSql(follows.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OccurrencesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('homeId: $homeId, ')
          ..write('taskId: $taskId, ')
          ..write('dueOn: $dueOn, ')
          ..write('visibleFrom: $visibleFrom, ')
          ..write('status: $status, ')
          ..write('statusBefore: $statusBefore, ')
          ..write('postponedFrom: $postponedFrom, ')
          ..write('completedOn: $completedOn, ')
          ..write('completionNote: $completionNote, ')
          ..write('follows: $follows, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FieldClockTable extends FieldClock
    with TableInfo<$FieldClockTable, FieldClockRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FieldClockTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _entityMeta = const VerificationMeta('entity');
  @override
  late final GeneratedColumn<String> entity = GeneratedColumn<String>(
    'entity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<String, Uint8List> rowId =
      GeneratedColumn<Uint8List>(
        'row_id',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      ).withConverter<String>($FieldClockTable.$converterrowId);
  static const VerificationMeta _fieldMeta = const VerificationMeta('field');
  @override
  late final GeneratedColumn<String> field = GeneratedColumn<String>(
    'field',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hlcMeta = const VerificationMeta('hlc');
  @override
  late final GeneratedColumn<String> hlc = GeneratedColumn<String>(
    'hlc',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceMeta = const VerificationMeta('device');
  @override
  late final GeneratedColumn<Uint8List> device = GeneratedColumn<Uint8List>(
    'device',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [entity, rowId, field, hlc, device];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'field_clock';
  @override
  VerificationContext validateIntegrity(
    Insertable<FieldClockRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('entity')) {
      context.handle(
        _entityMeta,
        entity.isAcceptableOrUnknown(data['entity']!, _entityMeta),
      );
    } else if (isInserting) {
      context.missing(_entityMeta);
    }
    if (data.containsKey('field')) {
      context.handle(
        _fieldMeta,
        field.isAcceptableOrUnknown(data['field']!, _fieldMeta),
      );
    } else if (isInserting) {
      context.missing(_fieldMeta);
    }
    if (data.containsKey('hlc')) {
      context.handle(
        _hlcMeta,
        hlc.isAcceptableOrUnknown(data['hlc']!, _hlcMeta),
      );
    } else if (isInserting) {
      context.missing(_hlcMeta);
    }
    if (data.containsKey('device')) {
      context.handle(
        _deviceMeta,
        device.isAcceptableOrUnknown(data['device']!, _deviceMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {entity, rowId, field};
  @override
  FieldClockRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FieldClockRow(
      entity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity'],
      )!,
      rowId: $FieldClockTable.$converterrowId.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}row_id'],
        )!,
      ),
      field: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}field'],
      )!,
      hlc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hlc'],
      )!,
      device: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}device'],
      )!,
    );
  }

  @override
  $FieldClockTable createAlias(String alias) {
    return $FieldClockTable(attachedDatabase, alias);
  }

  static TypeConverter<String, Uint8List> $converterrowId =
      const UuidConverter();
}

class FieldClockRow extends DataClass implements Insertable<FieldClockRow> {
  final String entity;
  final String rowId;
  final String field;
  final String hlc;
  final Uint8List device;
  const FieldClockRow({
    required this.entity,
    required this.rowId,
    required this.field,
    required this.hlc,
    required this.device,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['entity'] = Variable<String>(entity);
    {
      map['row_id'] = Variable<Uint8List>(
        $FieldClockTable.$converterrowId.toSql(rowId),
      );
    }
    map['field'] = Variable<String>(field);
    map['hlc'] = Variable<String>(hlc);
    map['device'] = Variable<Uint8List>(device);
    return map;
  }

  FieldClockCompanion toCompanion(bool nullToAbsent) {
    return FieldClockCompanion(
      entity: Value(entity),
      rowId: Value(rowId),
      field: Value(field),
      hlc: Value(hlc),
      device: Value(device),
    );
  }

  factory FieldClockRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FieldClockRow(
      entity: serializer.fromJson<String>(json['entity']),
      rowId: serializer.fromJson<String>(json['rowId']),
      field: serializer.fromJson<String>(json['field']),
      hlc: serializer.fromJson<String>(json['hlc']),
      device: serializer.fromJson<Uint8List>(json['device']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'entity': serializer.toJson<String>(entity),
      'rowId': serializer.toJson<String>(rowId),
      'field': serializer.toJson<String>(field),
      'hlc': serializer.toJson<String>(hlc),
      'device': serializer.toJson<Uint8List>(device),
    };
  }

  FieldClockRow copyWith({
    String? entity,
    String? rowId,
    String? field,
    String? hlc,
    Uint8List? device,
  }) => FieldClockRow(
    entity: entity ?? this.entity,
    rowId: rowId ?? this.rowId,
    field: field ?? this.field,
    hlc: hlc ?? this.hlc,
    device: device ?? this.device,
  );
  FieldClockRow copyWithCompanion(FieldClockCompanion data) {
    return FieldClockRow(
      entity: data.entity.present ? data.entity.value : this.entity,
      rowId: data.rowId.present ? data.rowId.value : this.rowId,
      field: data.field.present ? data.field.value : this.field,
      hlc: data.hlc.present ? data.hlc.value : this.hlc,
      device: data.device.present ? data.device.value : this.device,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FieldClockRow(')
          ..write('entity: $entity, ')
          ..write('rowId: $rowId, ')
          ..write('field: $field, ')
          ..write('hlc: $hlc, ')
          ..write('device: $device')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(entity, rowId, field, hlc, $driftBlobEquality.hash(device));
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FieldClockRow &&
          other.entity == this.entity &&
          other.rowId == this.rowId &&
          other.field == this.field &&
          other.hlc == this.hlc &&
          $driftBlobEquality.equals(other.device, this.device));
}

class FieldClockCompanion extends UpdateCompanion<FieldClockRow> {
  final Value<String> entity;
  final Value<String> rowId;
  final Value<String> field;
  final Value<String> hlc;
  final Value<Uint8List> device;
  final Value<int> rowid;
  const FieldClockCompanion({
    this.entity = const Value.absent(),
    this.rowId = const Value.absent(),
    this.field = const Value.absent(),
    this.hlc = const Value.absent(),
    this.device = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FieldClockCompanion.insert({
    required String entity,
    required String rowId,
    required String field,
    required String hlc,
    required Uint8List device,
    this.rowid = const Value.absent(),
  }) : entity = Value(entity),
       rowId = Value(rowId),
       field = Value(field),
       hlc = Value(hlc),
       device = Value(device);
  static Insertable<FieldClockRow> custom({
    Expression<String>? entity,
    Expression<Uint8List>? rowId,
    Expression<String>? field,
    Expression<String>? hlc,
    Expression<Uint8List>? device,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (entity != null) 'entity': entity,
      if (rowId != null) 'row_id': rowId,
      if (field != null) 'field': field,
      if (hlc != null) 'hlc': hlc,
      if (device != null) 'device': device,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FieldClockCompanion copyWith({
    Value<String>? entity,
    Value<String>? rowId,
    Value<String>? field,
    Value<String>? hlc,
    Value<Uint8List>? device,
    Value<int>? rowid,
  }) {
    return FieldClockCompanion(
      entity: entity ?? this.entity,
      rowId: rowId ?? this.rowId,
      field: field ?? this.field,
      hlc: hlc ?? this.hlc,
      device: device ?? this.device,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (entity.present) {
      map['entity'] = Variable<String>(entity.value);
    }
    if (rowId.present) {
      map['row_id'] = Variable<Uint8List>(
        $FieldClockTable.$converterrowId.toSql(rowId.value),
      );
    }
    if (field.present) {
      map['field'] = Variable<String>(field.value);
    }
    if (hlc.present) {
      map['hlc'] = Variable<String>(hlc.value);
    }
    if (device.present) {
      map['device'] = Variable<Uint8List>(device.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FieldClockCompanion(')
          ..write('entity: $entity, ')
          ..write('rowId: $rowId, ')
          ..write('field: $field, ')
          ..write('hlc: $hlc, ')
          ..write('device: $device, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalSettingsTable extends LocalSettings
    with TableInfo<$LocalSettingsTable, LocalSettingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalSettingRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  LocalSettingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalSettingRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $LocalSettingsTable createAlias(String alias) {
    return $LocalSettingsTable(attachedDatabase, alias);
  }
}

class LocalSettingRow extends DataClass implements Insertable<LocalSettingRow> {
  final String key;
  final String value;
  const LocalSettingRow({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  LocalSettingsCompanion toCompanion(bool nullToAbsent) {
    return LocalSettingsCompanion(key: Value(key), value: Value(value));
  }

  factory LocalSettingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalSettingRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  LocalSettingRow copyWith({String? key, String? value}) =>
      LocalSettingRow(key: key ?? this.key, value: value ?? this.value);
  LocalSettingRow copyWithCompanion(LocalSettingsCompanion data) {
    return LocalSettingRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalSettingRow(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalSettingRow &&
          other.key == this.key &&
          other.value == this.value);
}

class LocalSettingsCompanion extends UpdateCompanion<LocalSettingRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const LocalSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalSettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<LocalSettingRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalSettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return LocalSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $HomesTable homes = $HomesTable(this);
  late final $RoomsTable rooms = $RoomsTable(this);
  late final $ItemsTable items = $ItemsTable(this);
  late final $PhotosTable photos = $PhotosTable(this);
  late final $ContractorsTable contractors = $ContractorsTable(this);
  late final $TasksTable tasks = $TasksTable(this);
  late final $OccurrencesTable occurrences = $OccurrencesTable(this);
  late final $FieldClockTable fieldClock = $FieldClockTable(this);
  late final $LocalSettingsTable localSettings = $LocalSettingsTable(this);
  late final Index roomHomePosition = Index(
    'room_home_position',
    'CREATE INDEX room_home_position ON rooms (home_id, position)',
  );
  late final Index taskHomeCreated = Index(
    'task_home_created',
    'CREATE INDEX task_home_created ON tasks (home_id, created_at)',
  );
  late final Index occHomeStatusDue = Index(
    'occ_home_status_due',
    'CREATE INDEX occ_home_status_due ON occurrences (home_id, status, due_on)',
  );
  late final Index occTaskStatus = Index(
    'occ_task_status',
    'CREATE INDEX occ_task_status ON occurrences (task_id, status)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    homes,
    rooms,
    items,
    photos,
    contractors,
    tasks,
    occurrences,
    fieldClock,
    localSettings,
    roomHomePosition,
    taskHomeCreated,
    occHomeStatusDue,
    occTaskStatus,
  ];
}

typedef $$HomesTableCreateCompanionBuilder = HomesCompanion Function({
  required String id,
  required int createdAt,
  required int updatedAt,
  Value<int?> deletedAt,
  required String name,
  Value<String> currency,
  Value<String> hemisphere,
  Value<int?> archivedAt,
  Value<int> rowid,
});
typedef $$HomesTableUpdateCompanionBuilder = HomesCompanion Function({
  Value<String> id,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int?> deletedAt,
  Value<String> name,
  Value<String> currency,
  Value<String> hemisphere,
  Value<int?> archivedAt,
  Value<int> rowid,
});

class $$HomesTableFilterComposer extends Composer<_$AppDatabase, $HomesTable> {
  $$HomesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnWithTypeConverterFilters<String, String, Uint8List> get id =>
      $composableBuilder(
        column: $table.id,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hemisphere => $composableBuilder(
    column: $table.hemisphere,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HomesTableOrderingComposer
    extends Composer<_$AppDatabase, $HomesTable> {
  $$HomesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<Uint8List> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hemisphere => $composableBuilder(
    column: $table.hemisphere,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HomesTableAnnotationComposer
    extends Composer<_$AppDatabase, $HomesTable> {
  $$HomesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumnWithTypeConverter<String, Uint8List> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<String> get hemisphere => $composableBuilder(
    column: $table.hemisphere,
    builder: (column) => column,
  );

  GeneratedColumn<int> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => column,
  );
}

class $$HomesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HomesTable,
          HomeRow,
          $$HomesTableFilterComposer,
          $$HomesTableOrderingComposer,
          $$HomesTableAnnotationComposer,
          $$HomesTableCreateCompanionBuilder,
          $$HomesTableUpdateCompanionBuilder,
          (HomeRow, BaseReferences<_$AppDatabase, $HomesTable, HomeRow>),
          HomeRow,
          PrefetchHooks Function()
        > {
  $$HomesTableTableManager(_$AppDatabase db, $HomesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HomesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HomesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HomesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<String> hemisphere = const Value.absent(),
                Value<int?> archivedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HomesCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                name: name,
                currency: currency,
                hemisphere: hemisphere,
                archivedAt: archivedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                required String name,
                Value<String> currency = const Value.absent(),
                Value<String> hemisphere = const Value.absent(),
                Value<int?> archivedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HomesCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                name: name,
                currency: currency,
                hemisphere: hemisphere,
                archivedAt: archivedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$HomesTable, HomeRow>(table),
                  BaseReferences<_$AppDatabase, $HomesTable, HomeRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HomesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HomesTable,
      HomeRow,
      $$HomesTableFilterComposer,
      $$HomesTableOrderingComposer,
      $$HomesTableAnnotationComposer,
      $$HomesTableCreateCompanionBuilder,
      $$HomesTableUpdateCompanionBuilder,
      (HomeRow, BaseReferences<_$AppDatabase, $HomesTable, HomeRow>),
      HomeRow,
      PrefetchHooks Function()
    >;
typedef $$RoomsTableCreateCompanionBuilder = RoomsCompanion Function({
  required String id,
  required int createdAt,
  required int updatedAt,
  Value<int?> deletedAt,
  required String homeId,
  required String name,
  Value<String> kind,
  Value<int> position,
  Value<String> notes,
  Value<String> paintColour,
  Value<String> paintBrand,
  Value<String> paintReference,
  Value<String> paintBatch,
  Value<String> floorCovering,
  Value<String> wallCovering,
  Value<String> memoryNotes,
  Value<int> rowid,
});
typedef $$RoomsTableUpdateCompanionBuilder = RoomsCompanion Function({
  Value<String> id,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int?> deletedAt,
  Value<String> homeId,
  Value<String> name,
  Value<String> kind,
  Value<int> position,
  Value<String> notes,
  Value<String> paintColour,
  Value<String> paintBrand,
  Value<String> paintReference,
  Value<String> paintBatch,
  Value<String> floorCovering,
  Value<String> wallCovering,
  Value<String> memoryNotes,
  Value<int> rowid,
});

class $$RoomsTableFilterComposer extends Composer<_$AppDatabase, $RoomsTable> {
  $$RoomsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnWithTypeConverterFilters<String, String, Uint8List> get id =>
      $composableBuilder(
        column: $table.id,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<String, String, Uint8List> get homeId =>
      $composableBuilder(
        column: $table.homeId,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paintColour => $composableBuilder(
    column: $table.paintColour,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paintBrand => $composableBuilder(
    column: $table.paintBrand,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paintReference => $composableBuilder(
    column: $table.paintReference,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paintBatch => $composableBuilder(
    column: $table.paintBatch,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get floorCovering => $composableBuilder(
    column: $table.floorCovering,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get wallCovering => $composableBuilder(
    column: $table.wallCovering,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get memoryNotes => $composableBuilder(
    column: $table.memoryNotes,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RoomsTableOrderingComposer
    extends Composer<_$AppDatabase, $RoomsTable> {
  $$RoomsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<Uint8List> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get homeId => $composableBuilder(
    column: $table.homeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paintColour => $composableBuilder(
    column: $table.paintColour,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paintBrand => $composableBuilder(
    column: $table.paintBrand,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paintReference => $composableBuilder(
    column: $table.paintReference,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paintBatch => $composableBuilder(
    column: $table.paintBatch,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get floorCovering => $composableBuilder(
    column: $table.floorCovering,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get wallCovering => $composableBuilder(
    column: $table.wallCovering,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get memoryNotes => $composableBuilder(
    column: $table.memoryNotes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RoomsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RoomsTable> {
  $$RoomsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumnWithTypeConverter<String, Uint8List> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<String, Uint8List> get homeId =>
      $composableBuilder(column: $table.homeId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get paintColour => $composableBuilder(
    column: $table.paintColour,
    builder: (column) => column,
  );

  GeneratedColumn<String> get paintBrand => $composableBuilder(
    column: $table.paintBrand,
    builder: (column) => column,
  );

  GeneratedColumn<String> get paintReference => $composableBuilder(
    column: $table.paintReference,
    builder: (column) => column,
  );

  GeneratedColumn<String> get paintBatch => $composableBuilder(
    column: $table.paintBatch,
    builder: (column) => column,
  );

  GeneratedColumn<String> get floorCovering => $composableBuilder(
    column: $table.floorCovering,
    builder: (column) => column,
  );

  GeneratedColumn<String> get wallCovering => $composableBuilder(
    column: $table.wallCovering,
    builder: (column) => column,
  );

  GeneratedColumn<String> get memoryNotes => $composableBuilder(
    column: $table.memoryNotes,
    builder: (column) => column,
  );
}

class $$RoomsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RoomsTable,
          RoomRow,
          $$RoomsTableFilterComposer,
          $$RoomsTableOrderingComposer,
          $$RoomsTableAnnotationComposer,
          $$RoomsTableCreateCompanionBuilder,
          $$RoomsTableUpdateCompanionBuilder,
          (RoomRow, BaseReferences<_$AppDatabase, $RoomsTable, RoomRow>),
          RoomRow,
          PrefetchHooks Function()
        > {
  $$RoomsTableTableManager(_$AppDatabase db, $RoomsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RoomsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RoomsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RoomsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<String> homeId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<String> paintColour = const Value.absent(),
                Value<String> paintBrand = const Value.absent(),
                Value<String> paintReference = const Value.absent(),
                Value<String> paintBatch = const Value.absent(),
                Value<String> floorCovering = const Value.absent(),
                Value<String> wallCovering = const Value.absent(),
                Value<String> memoryNotes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RoomsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                homeId: homeId,
                name: name,
                kind: kind,
                position: position,
                notes: notes,
                paintColour: paintColour,
                paintBrand: paintBrand,
                paintReference: paintReference,
                paintBatch: paintBatch,
                floorCovering: floorCovering,
                wallCovering: wallCovering,
                memoryNotes: memoryNotes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                required String homeId,
                required String name,
                Value<String> kind = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<String> paintColour = const Value.absent(),
                Value<String> paintBrand = const Value.absent(),
                Value<String> paintReference = const Value.absent(),
                Value<String> paintBatch = const Value.absent(),
                Value<String> floorCovering = const Value.absent(),
                Value<String> wallCovering = const Value.absent(),
                Value<String> memoryNotes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RoomsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                homeId: homeId,
                name: name,
                kind: kind,
                position: position,
                notes: notes,
                paintColour: paintColour,
                paintBrand: paintBrand,
                paintReference: paintReference,
                paintBatch: paintBatch,
                floorCovering: floorCovering,
                wallCovering: wallCovering,
                memoryNotes: memoryNotes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RoomsTable, RoomRow>(table),
                  BaseReferences<_$AppDatabase, $RoomsTable, RoomRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RoomsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RoomsTable,
      RoomRow,
      $$RoomsTableFilterComposer,
      $$RoomsTableOrderingComposer,
      $$RoomsTableAnnotationComposer,
      $$RoomsTableCreateCompanionBuilder,
      $$RoomsTableUpdateCompanionBuilder,
      (RoomRow, BaseReferences<_$AppDatabase, $RoomsTable, RoomRow>),
      RoomRow,
      PrefetchHooks Function()
    >;
typedef $$ItemsTableCreateCompanionBuilder = ItemsCompanion Function({
  required String id,
  required int createdAt,
  required int updatedAt,
  Value<int?> deletedAt,
  required String homeId,
  required String roomId,
  required String name,
  Value<String> kind,
  Value<String> brand,
  Value<String> model,
  Value<String> serialNumber,
  Value<String?> installedOn,
  Value<String?> warrantyEndsOn,
  Value<String?> contractContractorId,
  Value<String> contractNumber,
  Value<String> contractUrl,
  Value<String> links,
  Value<String> notes,
  Value<int> rowid,
});
typedef $$ItemsTableUpdateCompanionBuilder = ItemsCompanion Function({
  Value<String> id,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int?> deletedAt,
  Value<String> homeId,
  Value<String> roomId,
  Value<String> name,
  Value<String> kind,
  Value<String> brand,
  Value<String> model,
  Value<String> serialNumber,
  Value<String?> installedOn,
  Value<String?> warrantyEndsOn,
  Value<String?> contractContractorId,
  Value<String> contractNumber,
  Value<String> contractUrl,
  Value<String> links,
  Value<String> notes,
  Value<int> rowid,
});

class $$ItemsTableFilterComposer extends Composer<_$AppDatabase, $ItemsTable> {
  $$ItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnWithTypeConverterFilters<String, String, Uint8List> get id =>
      $composableBuilder(
        column: $table.id,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<String, String, Uint8List> get homeId =>
      $composableBuilder(
        column: $table.homeId,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<String, String, Uint8List> get roomId =>
      $composableBuilder(
        column: $table.roomId,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serialNumber => $composableBuilder(
    column: $table.serialNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get installedOn => $composableBuilder(
    column: $table.installedOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get warrantyEndsOn => $composableBuilder(
    column: $table.warrantyEndsOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<String?, String, Uint8List>
  get contractContractorId => $composableBuilder(
    column: $table.contractContractorId,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get contractNumber => $composableBuilder(
    column: $table.contractNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contractUrl => $composableBuilder(
    column: $table.contractUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get links => $composableBuilder(
    column: $table.links,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $ItemsTable> {
  $$ItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<Uint8List> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get homeId => $composableBuilder(
    column: $table.homeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get roomId => $composableBuilder(
    column: $table.roomId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serialNumber => $composableBuilder(
    column: $table.serialNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get installedOn => $composableBuilder(
    column: $table.installedOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get warrantyEndsOn => $composableBuilder(
    column: $table.warrantyEndsOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get contractContractorId => $composableBuilder(
    column: $table.contractContractorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contractNumber => $composableBuilder(
    column: $table.contractNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contractUrl => $composableBuilder(
    column: $table.contractUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get links => $composableBuilder(
    column: $table.links,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ItemsTable> {
  $$ItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumnWithTypeConverter<String, Uint8List> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<String, Uint8List> get homeId =>
      $composableBuilder(column: $table.homeId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<String, Uint8List> get roomId =>
      $composableBuilder(column: $table.roomId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get brand =>
      $composableBuilder(column: $table.brand, builder: (column) => column);

  GeneratedColumn<String> get model =>
      $composableBuilder(column: $table.model, builder: (column) => column);

  GeneratedColumn<String> get serialNumber => $composableBuilder(
    column: $table.serialNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get installedOn => $composableBuilder(
    column: $table.installedOn,
    builder: (column) => column,
  );

  GeneratedColumn<String> get warrantyEndsOn => $composableBuilder(
    column: $table.warrantyEndsOn,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<String?, Uint8List>
  get contractContractorId => $composableBuilder(
    column: $table.contractContractorId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get contractNumber => $composableBuilder(
    column: $table.contractNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get contractUrl => $composableBuilder(
    column: $table.contractUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get links =>
      $composableBuilder(column: $table.links, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);
}

class $$ItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ItemsTable,
          ItemRow,
          $$ItemsTableFilterComposer,
          $$ItemsTableOrderingComposer,
          $$ItemsTableAnnotationComposer,
          $$ItemsTableCreateCompanionBuilder,
          $$ItemsTableUpdateCompanionBuilder,
          (ItemRow, BaseReferences<_$AppDatabase, $ItemsTable, ItemRow>),
          ItemRow,
          PrefetchHooks Function()
        > {
  $$ItemsTableTableManager(_$AppDatabase db, $ItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<String> homeId = const Value.absent(),
                Value<String> roomId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> brand = const Value.absent(),
                Value<String> model = const Value.absent(),
                Value<String> serialNumber = const Value.absent(),
                Value<String?> installedOn = const Value.absent(),
                Value<String?> warrantyEndsOn = const Value.absent(),
                Value<String?> contractContractorId = const Value.absent(),
                Value<String> contractNumber = const Value.absent(),
                Value<String> contractUrl = const Value.absent(),
                Value<String> links = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ItemsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                homeId: homeId,
                roomId: roomId,
                name: name,
                kind: kind,
                brand: brand,
                model: model,
                serialNumber: serialNumber,
                installedOn: installedOn,
                warrantyEndsOn: warrantyEndsOn,
                contractContractorId: contractContractorId,
                contractNumber: contractNumber,
                contractUrl: contractUrl,
                links: links,
                notes: notes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                required String homeId,
                required String roomId,
                required String name,
                Value<String> kind = const Value.absent(),
                Value<String> brand = const Value.absent(),
                Value<String> model = const Value.absent(),
                Value<String> serialNumber = const Value.absent(),
                Value<String?> installedOn = const Value.absent(),
                Value<String?> warrantyEndsOn = const Value.absent(),
                Value<String?> contractContractorId = const Value.absent(),
                Value<String> contractNumber = const Value.absent(),
                Value<String> contractUrl = const Value.absent(),
                Value<String> links = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ItemsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                homeId: homeId,
                roomId: roomId,
                name: name,
                kind: kind,
                brand: brand,
                model: model,
                serialNumber: serialNumber,
                installedOn: installedOn,
                warrantyEndsOn: warrantyEndsOn,
                contractContractorId: contractContractorId,
                contractNumber: contractNumber,
                contractUrl: contractUrl,
                links: links,
                notes: notes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ItemsTable, ItemRow>(table),
                  BaseReferences<_$AppDatabase, $ItemsTable, ItemRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ItemsTable,
      ItemRow,
      $$ItemsTableFilterComposer,
      $$ItemsTableOrderingComposer,
      $$ItemsTableAnnotationComposer,
      $$ItemsTableCreateCompanionBuilder,
      $$ItemsTableUpdateCompanionBuilder,
      (ItemRow, BaseReferences<_$AppDatabase, $ItemsTable, ItemRow>),
      ItemRow,
      PrefetchHooks Function()
    >;
typedef $$PhotosTableCreateCompanionBuilder = PhotosCompanion Function({
  required String id,
  required int createdAt,
  required int updatedAt,
  Value<int?> deletedAt,
  required String homeId,
  Value<String?> roomId,
  Value<String?> itemId,
  Value<String> category,
  Value<String> caption,
  Value<String?> image,
  Value<int> rowid,
});
typedef $$PhotosTableUpdateCompanionBuilder = PhotosCompanion Function({
  Value<String> id,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int?> deletedAt,
  Value<String> homeId,
  Value<String?> roomId,
  Value<String?> itemId,
  Value<String> category,
  Value<String> caption,
  Value<String?> image,
  Value<int> rowid,
});

class $$PhotosTableFilterComposer
    extends Composer<_$AppDatabase, $PhotosTable> {
  $$PhotosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnWithTypeConverterFilters<String, String, Uint8List> get id =>
      $composableBuilder(
        column: $table.id,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<String, String, Uint8List> get homeId =>
      $composableBuilder(
        column: $table.homeId,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<String?, String, Uint8List> get roomId =>
      $composableBuilder(
        column: $table.roomId,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<String?, String, Uint8List> get itemId =>
      $composableBuilder(
        column: $table.itemId,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get caption => $composableBuilder(
    column: $table.caption,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get image => $composableBuilder(
    column: $table.image,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PhotosTableOrderingComposer
    extends Composer<_$AppDatabase, $PhotosTable> {
  $$PhotosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<Uint8List> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get homeId => $composableBuilder(
    column: $table.homeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get roomId => $composableBuilder(
    column: $table.roomId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get caption => $composableBuilder(
    column: $table.caption,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get image => $composableBuilder(
    column: $table.image,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PhotosTableAnnotationComposer
    extends Composer<_$AppDatabase, $PhotosTable> {
  $$PhotosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumnWithTypeConverter<String, Uint8List> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<String, Uint8List> get homeId =>
      $composableBuilder(column: $table.homeId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<String?, Uint8List> get roomId =>
      $composableBuilder(column: $table.roomId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<String?, Uint8List> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get caption =>
      $composableBuilder(column: $table.caption, builder: (column) => column);

  GeneratedColumn<String> get image =>
      $composableBuilder(column: $table.image, builder: (column) => column);
}

class $$PhotosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PhotosTable,
          PhotoRow,
          $$PhotosTableFilterComposer,
          $$PhotosTableOrderingComposer,
          $$PhotosTableAnnotationComposer,
          $$PhotosTableCreateCompanionBuilder,
          $$PhotosTableUpdateCompanionBuilder,
          (PhotoRow, BaseReferences<_$AppDatabase, $PhotosTable, PhotoRow>),
          PhotoRow,
          PrefetchHooks Function()
        > {
  $$PhotosTableTableManager(_$AppDatabase db, $PhotosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PhotosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PhotosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PhotosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<String> homeId = const Value.absent(),
                Value<String?> roomId = const Value.absent(),
                Value<String?> itemId = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> caption = const Value.absent(),
                Value<String?> image = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PhotosCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                homeId: homeId,
                roomId: roomId,
                itemId: itemId,
                category: category,
                caption: caption,
                image: image,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                required String homeId,
                Value<String?> roomId = const Value.absent(),
                Value<String?> itemId = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> caption = const Value.absent(),
                Value<String?> image = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PhotosCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                homeId: homeId,
                roomId: roomId,
                itemId: itemId,
                category: category,
                caption: caption,
                image: image,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PhotosTable, PhotoRow>(table),
                  BaseReferences<_$AppDatabase, $PhotosTable, PhotoRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PhotosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PhotosTable,
      PhotoRow,
      $$PhotosTableFilterComposer,
      $$PhotosTableOrderingComposer,
      $$PhotosTableAnnotationComposer,
      $$PhotosTableCreateCompanionBuilder,
      $$PhotosTableUpdateCompanionBuilder,
      (PhotoRow, BaseReferences<_$AppDatabase, $PhotosTable, PhotoRow>),
      PhotoRow,
      PrefetchHooks Function()
    >;
typedef $$ContractorsTableCreateCompanionBuilder =
    ContractorsCompanion Function({
      required String id,
      required int createdAt,
      required int updatedAt,
      Value<int?> deletedAt,
      required String homeId,
      required String name,
      Value<String> trade,
      Value<String> tradeOther,
      Value<String> phone,
      Value<String> email,
      Value<String> address,
      Value<String> note,
      Value<int> rowid,
    });
typedef $$ContractorsTableUpdateCompanionBuilder =
    ContractorsCompanion Function({
      Value<String> id,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int?> deletedAt,
      Value<String> homeId,
      Value<String> name,
      Value<String> trade,
      Value<String> tradeOther,
      Value<String> phone,
      Value<String> email,
      Value<String> address,
      Value<String> note,
      Value<int> rowid,
    });

class $$ContractorsTableFilterComposer
    extends Composer<_$AppDatabase, $ContractorsTable> {
  $$ContractorsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnWithTypeConverterFilters<String, String, Uint8List> get id =>
      $composableBuilder(
        column: $table.id,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<String, String, Uint8List> get homeId =>
      $composableBuilder(
        column: $table.homeId,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get trade => $composableBuilder(
    column: $table.trade,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tradeOther => $composableBuilder(
    column: $table.tradeOther,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ContractorsTableOrderingComposer
    extends Composer<_$AppDatabase, $ContractorsTable> {
  $$ContractorsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<Uint8List> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get homeId => $composableBuilder(
    column: $table.homeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get trade => $composableBuilder(
    column: $table.trade,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tradeOther => $composableBuilder(
    column: $table.tradeOther,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ContractorsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ContractorsTable> {
  $$ContractorsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumnWithTypeConverter<String, Uint8List> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<String, Uint8List> get homeId =>
      $composableBuilder(column: $table.homeId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get trade =>
      $composableBuilder(column: $table.trade, builder: (column) => column);

  GeneratedColumn<String> get tradeOther => $composableBuilder(
    column: $table.tradeOther,
    builder: (column) => column,
  );

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);
}

class $$ContractorsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ContractorsTable,
          ContractorRow,
          $$ContractorsTableFilterComposer,
          $$ContractorsTableOrderingComposer,
          $$ContractorsTableAnnotationComposer,
          $$ContractorsTableCreateCompanionBuilder,
          $$ContractorsTableUpdateCompanionBuilder,
          (
            ContractorRow,
            BaseReferences<_$AppDatabase, $ContractorsTable, ContractorRow>,
          ),
          ContractorRow,
          PrefetchHooks Function()
        > {
  $$ContractorsTableTableManager(_$AppDatabase db, $ContractorsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ContractorsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ContractorsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ContractorsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<String> homeId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> trade = const Value.absent(),
                Value<String> tradeOther = const Value.absent(),
                Value<String> phone = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<String> address = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ContractorsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                homeId: homeId,
                name: name,
                trade: trade,
                tradeOther: tradeOther,
                phone: phone,
                email: email,
                address: address,
                note: note,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                required String homeId,
                required String name,
                Value<String> trade = const Value.absent(),
                Value<String> tradeOther = const Value.absent(),
                Value<String> phone = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<String> address = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ContractorsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                homeId: homeId,
                name: name,
                trade: trade,
                tradeOther: tradeOther,
                phone: phone,
                email: email,
                address: address,
                note: note,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ContractorsTable, ContractorRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $ContractorsTable,
                    ContractorRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ContractorsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ContractorsTable,
      ContractorRow,
      $$ContractorsTableFilterComposer,
      $$ContractorsTableOrderingComposer,
      $$ContractorsTableAnnotationComposer,
      $$ContractorsTableCreateCompanionBuilder,
      $$ContractorsTableUpdateCompanionBuilder,
      (
        ContractorRow,
        BaseReferences<_$AppDatabase, $ContractorsTable, ContractorRow>,
      ),
      ContractorRow,
      PrefetchHooks Function()
    >;
typedef $$TasksTableCreateCompanionBuilder = TasksCompanion Function({
  required String id,
  required int createdAt,
  required int updatedAt,
  Value<int?> deletedAt,
  required String homeId,
  required String title,
  Value<String?> roomId,
  Value<String?> itemId,
  Value<String> priority,
  Value<int?> estimatedMinutes,
  Value<String> notes,
  Value<String> procedure,
  Value<String?> contractorId,
  Value<String> repeatMode,
  Value<String> repeatUnit,
  Value<int> repeatInterval,
  Value<String> season,
  Value<int?> seasonStartMonth,
  Value<int?> seasonEndMonth,
  Value<int> hideDaysBefore,
  Value<String?> seriesStart,
  Value<int> rowid,
});
typedef $$TasksTableUpdateCompanionBuilder = TasksCompanion Function({
  Value<String> id,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int?> deletedAt,
  Value<String> homeId,
  Value<String> title,
  Value<String?> roomId,
  Value<String?> itemId,
  Value<String> priority,
  Value<int?> estimatedMinutes,
  Value<String> notes,
  Value<String> procedure,
  Value<String?> contractorId,
  Value<String> repeatMode,
  Value<String> repeatUnit,
  Value<int> repeatInterval,
  Value<String> season,
  Value<int?> seasonStartMonth,
  Value<int?> seasonEndMonth,
  Value<int> hideDaysBefore,
  Value<String?> seriesStart,
  Value<int> rowid,
});

class $$TasksTableFilterComposer extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnWithTypeConverterFilters<String, String, Uint8List> get id =>
      $composableBuilder(
        column: $table.id,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<String, String, Uint8List> get homeId =>
      $composableBuilder(
        column: $table.homeId,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<String?, String, Uint8List> get roomId =>
      $composableBuilder(
        column: $table.roomId,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<String?, String, Uint8List> get itemId =>
      $composableBuilder(
        column: $table.itemId,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get estimatedMinutes => $composableBuilder(
    column: $table.estimatedMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get procedure => $composableBuilder(
    column: $table.procedure,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<String?, String, Uint8List> get contractorId =>
      $composableBuilder(
        column: $table.contractorId,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get repeatMode => $composableBuilder(
    column: $table.repeatMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get repeatUnit => $composableBuilder(
    column: $table.repeatUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get repeatInterval => $composableBuilder(
    column: $table.repeatInterval,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get season => $composableBuilder(
    column: $table.season,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get seasonStartMonth => $composableBuilder(
    column: $table.seasonStartMonth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get seasonEndMonth => $composableBuilder(
    column: $table.seasonEndMonth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hideDaysBefore => $composableBuilder(
    column: $table.hideDaysBefore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get seriesStart => $composableBuilder(
    column: $table.seriesStart,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TasksTableOrderingComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<Uint8List> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get homeId => $composableBuilder(
    column: $table.homeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get roomId => $composableBuilder(
    column: $table.roomId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get estimatedMinutes => $composableBuilder(
    column: $table.estimatedMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get procedure => $composableBuilder(
    column: $table.procedure,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get contractorId => $composableBuilder(
    column: $table.contractorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get repeatMode => $composableBuilder(
    column: $table.repeatMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get repeatUnit => $composableBuilder(
    column: $table.repeatUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get repeatInterval => $composableBuilder(
    column: $table.repeatInterval,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get season => $composableBuilder(
    column: $table.season,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get seasonStartMonth => $composableBuilder(
    column: $table.seasonStartMonth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get seasonEndMonth => $composableBuilder(
    column: $table.seasonEndMonth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hideDaysBefore => $composableBuilder(
    column: $table.hideDaysBefore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get seriesStart => $composableBuilder(
    column: $table.seriesStart,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumnWithTypeConverter<String, Uint8List> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<String, Uint8List> get homeId =>
      $composableBuilder(column: $table.homeId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumnWithTypeConverter<String?, Uint8List> get roomId =>
      $composableBuilder(column: $table.roomId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<String?, Uint8List> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<String> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<int> get estimatedMinutes => $composableBuilder(
    column: $table.estimatedMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get procedure =>
      $composableBuilder(column: $table.procedure, builder: (column) => column);

  GeneratedColumnWithTypeConverter<String?, Uint8List> get contractorId =>
      $composableBuilder(
        column: $table.contractorId,
        builder: (column) => column,
      );

  GeneratedColumn<String> get repeatMode => $composableBuilder(
    column: $table.repeatMode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get repeatUnit => $composableBuilder(
    column: $table.repeatUnit,
    builder: (column) => column,
  );

  GeneratedColumn<int> get repeatInterval => $composableBuilder(
    column: $table.repeatInterval,
    builder: (column) => column,
  );

  GeneratedColumn<String> get season =>
      $composableBuilder(column: $table.season, builder: (column) => column);

  GeneratedColumn<int> get seasonStartMonth => $composableBuilder(
    column: $table.seasonStartMonth,
    builder: (column) => column,
  );

  GeneratedColumn<int> get seasonEndMonth => $composableBuilder(
    column: $table.seasonEndMonth,
    builder: (column) => column,
  );

  GeneratedColumn<int> get hideDaysBefore => $composableBuilder(
    column: $table.hideDaysBefore,
    builder: (column) => column,
  );

  GeneratedColumn<String> get seriesStart => $composableBuilder(
    column: $table.seriesStart,
    builder: (column) => column,
  );
}

class $$TasksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TasksTable,
          TaskRow,
          $$TasksTableFilterComposer,
          $$TasksTableOrderingComposer,
          $$TasksTableAnnotationComposer,
          $$TasksTableCreateCompanionBuilder,
          $$TasksTableUpdateCompanionBuilder,
          (TaskRow, BaseReferences<_$AppDatabase, $TasksTable, TaskRow>),
          TaskRow,
          PrefetchHooks Function()
        > {
  $$TasksTableTableManager(_$AppDatabase db, $TasksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<String> homeId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> roomId = const Value.absent(),
                Value<String?> itemId = const Value.absent(),
                Value<String> priority = const Value.absent(),
                Value<int?> estimatedMinutes = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<String> procedure = const Value.absent(),
                Value<String?> contractorId = const Value.absent(),
                Value<String> repeatMode = const Value.absent(),
                Value<String> repeatUnit = const Value.absent(),
                Value<int> repeatInterval = const Value.absent(),
                Value<String> season = const Value.absent(),
                Value<int?> seasonStartMonth = const Value.absent(),
                Value<int?> seasonEndMonth = const Value.absent(),
                Value<int> hideDaysBefore = const Value.absent(),
                Value<String?> seriesStart = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TasksCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                homeId: homeId,
                title: title,
                roomId: roomId,
                itemId: itemId,
                priority: priority,
                estimatedMinutes: estimatedMinutes,
                notes: notes,
                procedure: procedure,
                contractorId: contractorId,
                repeatMode: repeatMode,
                repeatUnit: repeatUnit,
                repeatInterval: repeatInterval,
                season: season,
                seasonStartMonth: seasonStartMonth,
                seasonEndMonth: seasonEndMonth,
                hideDaysBefore: hideDaysBefore,
                seriesStart: seriesStart,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                required String homeId,
                required String title,
                Value<String?> roomId = const Value.absent(),
                Value<String?> itemId = const Value.absent(),
                Value<String> priority = const Value.absent(),
                Value<int?> estimatedMinutes = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<String> procedure = const Value.absent(),
                Value<String?> contractorId = const Value.absent(),
                Value<String> repeatMode = const Value.absent(),
                Value<String> repeatUnit = const Value.absent(),
                Value<int> repeatInterval = const Value.absent(),
                Value<String> season = const Value.absent(),
                Value<int?> seasonStartMonth = const Value.absent(),
                Value<int?> seasonEndMonth = const Value.absent(),
                Value<int> hideDaysBefore = const Value.absent(),
                Value<String?> seriesStart = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TasksCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                homeId: homeId,
                title: title,
                roomId: roomId,
                itemId: itemId,
                priority: priority,
                estimatedMinutes: estimatedMinutes,
                notes: notes,
                procedure: procedure,
                contractorId: contractorId,
                repeatMode: repeatMode,
                repeatUnit: repeatUnit,
                repeatInterval: repeatInterval,
                season: season,
                seasonStartMonth: seasonStartMonth,
                seasonEndMonth: seasonEndMonth,
                hideDaysBefore: hideDaysBefore,
                seriesStart: seriesStart,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TasksTable, TaskRow>(table),
                  BaseReferences<_$AppDatabase, $TasksTable, TaskRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TasksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TasksTable,
      TaskRow,
      $$TasksTableFilterComposer,
      $$TasksTableOrderingComposer,
      $$TasksTableAnnotationComposer,
      $$TasksTableCreateCompanionBuilder,
      $$TasksTableUpdateCompanionBuilder,
      (TaskRow, BaseReferences<_$AppDatabase, $TasksTable, TaskRow>),
      TaskRow,
      PrefetchHooks Function()
    >;
typedef $$OccurrencesTableCreateCompanionBuilder =
    OccurrencesCompanion Function({
      required String id,
      required int createdAt,
      required int updatedAt,
      Value<int?> deletedAt,
      required String homeId,
      required String taskId,
      Value<String?> dueOn,
      Value<String?> visibleFrom,
      Value<String> status,
      Value<String> statusBefore,
      Value<String?> postponedFrom,
      Value<String?> completedOn,
      Value<String> completionNote,
      Value<String?> follows,
      Value<int> rowid,
    });
typedef $$OccurrencesTableUpdateCompanionBuilder =
    OccurrencesCompanion Function({
      Value<String> id,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int?> deletedAt,
      Value<String> homeId,
      Value<String> taskId,
      Value<String?> dueOn,
      Value<String?> visibleFrom,
      Value<String> status,
      Value<String> statusBefore,
      Value<String?> postponedFrom,
      Value<String?> completedOn,
      Value<String> completionNote,
      Value<String?> follows,
      Value<int> rowid,
    });

class $$OccurrencesTableFilterComposer
    extends Composer<_$AppDatabase, $OccurrencesTable> {
  $$OccurrencesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnWithTypeConverterFilters<String, String, Uint8List> get id =>
      $composableBuilder(
        column: $table.id,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<String, String, Uint8List> get homeId =>
      $composableBuilder(
        column: $table.homeId,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<String, String, Uint8List> get taskId =>
      $composableBuilder(
        column: $table.taskId,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get dueOn => $composableBuilder(
    column: $table.dueOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get visibleFrom => $composableBuilder(
    column: $table.visibleFrom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get statusBefore => $composableBuilder(
    column: $table.statusBefore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get postponedFrom => $composableBuilder(
    column: $table.postponedFrom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get completedOn => $composableBuilder(
    column: $table.completedOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get completionNote => $composableBuilder(
    column: $table.completionNote,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<String?, String, Uint8List> get follows =>
      $composableBuilder(
        column: $table.follows,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );
}

class $$OccurrencesTableOrderingComposer
    extends Composer<_$AppDatabase, $OccurrencesTable> {
  $$OccurrencesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<Uint8List> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get homeId => $composableBuilder(
    column: $table.homeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dueOn => $composableBuilder(
    column: $table.dueOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get visibleFrom => $composableBuilder(
    column: $table.visibleFrom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get statusBefore => $composableBuilder(
    column: $table.statusBefore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get postponedFrom => $composableBuilder(
    column: $table.postponedFrom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get completedOn => $composableBuilder(
    column: $table.completedOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get completionNote => $composableBuilder(
    column: $table.completionNote,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get follows => $composableBuilder(
    column: $table.follows,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OccurrencesTableAnnotationComposer
    extends Composer<_$AppDatabase, $OccurrencesTable> {
  $$OccurrencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumnWithTypeConverter<String, Uint8List> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<String, Uint8List> get homeId =>
      $composableBuilder(column: $table.homeId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<String, Uint8List> get taskId =>
      $composableBuilder(column: $table.taskId, builder: (column) => column);

  GeneratedColumn<String> get dueOn =>
      $composableBuilder(column: $table.dueOn, builder: (column) => column);

  GeneratedColumn<String> get visibleFrom => $composableBuilder(
    column: $table.visibleFrom,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get statusBefore => $composableBuilder(
    column: $table.statusBefore,
    builder: (column) => column,
  );

  GeneratedColumn<String> get postponedFrom => $composableBuilder(
    column: $table.postponedFrom,
    builder: (column) => column,
  );

  GeneratedColumn<String> get completedOn => $composableBuilder(
    column: $table.completedOn,
    builder: (column) => column,
  );

  GeneratedColumn<String> get completionNote => $composableBuilder(
    column: $table.completionNote,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<String?, Uint8List> get follows =>
      $composableBuilder(column: $table.follows, builder: (column) => column);
}

class $$OccurrencesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OccurrencesTable,
          OccurrenceRow,
          $$OccurrencesTableFilterComposer,
          $$OccurrencesTableOrderingComposer,
          $$OccurrencesTableAnnotationComposer,
          $$OccurrencesTableCreateCompanionBuilder,
          $$OccurrencesTableUpdateCompanionBuilder,
          (
            OccurrenceRow,
            BaseReferences<_$AppDatabase, $OccurrencesTable, OccurrenceRow>,
          ),
          OccurrenceRow,
          PrefetchHooks Function()
        > {
  $$OccurrencesTableTableManager(_$AppDatabase db, $OccurrencesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OccurrencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OccurrencesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OccurrencesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<String> homeId = const Value.absent(),
                Value<String> taskId = const Value.absent(),
                Value<String?> dueOn = const Value.absent(),
                Value<String?> visibleFrom = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> statusBefore = const Value.absent(),
                Value<String?> postponedFrom = const Value.absent(),
                Value<String?> completedOn = const Value.absent(),
                Value<String> completionNote = const Value.absent(),
                Value<String?> follows = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OccurrencesCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                homeId: homeId,
                taskId: taskId,
                dueOn: dueOn,
                visibleFrom: visibleFrom,
                status: status,
                statusBefore: statusBefore,
                postponedFrom: postponedFrom,
                completedOn: completedOn,
                completionNote: completionNote,
                follows: follows,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                required String homeId,
                required String taskId,
                Value<String?> dueOn = const Value.absent(),
                Value<String?> visibleFrom = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> statusBefore = const Value.absent(),
                Value<String?> postponedFrom = const Value.absent(),
                Value<String?> completedOn = const Value.absent(),
                Value<String> completionNote = const Value.absent(),
                Value<String?> follows = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OccurrencesCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                homeId: homeId,
                taskId: taskId,
                dueOn: dueOn,
                visibleFrom: visibleFrom,
                status: status,
                statusBefore: statusBefore,
                postponedFrom: postponedFrom,
                completedOn: completedOn,
                completionNote: completionNote,
                follows: follows,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$OccurrencesTable, OccurrenceRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $OccurrencesTable,
                    OccurrenceRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OccurrencesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OccurrencesTable,
      OccurrenceRow,
      $$OccurrencesTableFilterComposer,
      $$OccurrencesTableOrderingComposer,
      $$OccurrencesTableAnnotationComposer,
      $$OccurrencesTableCreateCompanionBuilder,
      $$OccurrencesTableUpdateCompanionBuilder,
      (
        OccurrenceRow,
        BaseReferences<_$AppDatabase, $OccurrencesTable, OccurrenceRow>,
      ),
      OccurrenceRow,
      PrefetchHooks Function()
    >;
typedef $$FieldClockTableCreateCompanionBuilder = FieldClockCompanion Function({
  required String entity,
  required String rowId,
  required String field,
  required String hlc,
  required Uint8List device,
  Value<int> rowid,
});
typedef $$FieldClockTableUpdateCompanionBuilder = FieldClockCompanion Function({
  Value<String> entity,
  Value<String> rowId,
  Value<String> field,
  Value<String> hlc,
  Value<Uint8List> device,
  Value<int> rowid,
});

class $$FieldClockTableFilterComposer
    extends Composer<_$AppDatabase, $FieldClockTable> {
  $$FieldClockTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<String, String, Uint8List> get rowId =>
      $composableBuilder(
        column: $table.rowId,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get field => $composableBuilder(
    column: $table.field,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get device => $composableBuilder(
    column: $table.device,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FieldClockTableOrderingComposer
    extends Composer<_$AppDatabase, $FieldClockTable> {
  $$FieldClockTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get rowId => $composableBuilder(
    column: $table.rowId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get field => $composableBuilder(
    column: $table.field,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get device => $composableBuilder(
    column: $table.device,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FieldClockTableAnnotationComposer
    extends Composer<_$AppDatabase, $FieldClockTable> {
  $$FieldClockTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get entity =>
      $composableBuilder(column: $table.entity, builder: (column) => column);

  GeneratedColumnWithTypeConverter<String, Uint8List> get rowId =>
      $composableBuilder(column: $table.rowId, builder: (column) => column);

  GeneratedColumn<String> get field =>
      $composableBuilder(column: $table.field, builder: (column) => column);

  GeneratedColumn<String> get hlc =>
      $composableBuilder(column: $table.hlc, builder: (column) => column);

  GeneratedColumn<Uint8List> get device =>
      $composableBuilder(column: $table.device, builder: (column) => column);
}

class $$FieldClockTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FieldClockTable,
          FieldClockRow,
          $$FieldClockTableFilterComposer,
          $$FieldClockTableOrderingComposer,
          $$FieldClockTableAnnotationComposer,
          $$FieldClockTableCreateCompanionBuilder,
          $$FieldClockTableUpdateCompanionBuilder,
          (
            FieldClockRow,
            BaseReferences<_$AppDatabase, $FieldClockTable, FieldClockRow>,
          ),
          FieldClockRow,
          PrefetchHooks Function()
        > {
  $$FieldClockTableTableManager(_$AppDatabase db, $FieldClockTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FieldClockTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FieldClockTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FieldClockTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> entity = const Value.absent(),
                Value<String> rowId = const Value.absent(),
                Value<String> field = const Value.absent(),
                Value<String> hlc = const Value.absent(),
                Value<Uint8List> device = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FieldClockCompanion(
                entity: entity,
                rowId: rowId,
                field: field,
                hlc: hlc,
                device: device,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String entity,
                required String rowId,
                required String field,
                required String hlc,
                required Uint8List device,
                Value<int> rowid = const Value.absent(),
              }) => FieldClockCompanion.insert(
                entity: entity,
                rowId: rowId,
                field: field,
                hlc: hlc,
                device: device,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FieldClockTable, FieldClockRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $FieldClockTable,
                    FieldClockRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FieldClockTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FieldClockTable,
      FieldClockRow,
      $$FieldClockTableFilterComposer,
      $$FieldClockTableOrderingComposer,
      $$FieldClockTableAnnotationComposer,
      $$FieldClockTableCreateCompanionBuilder,
      $$FieldClockTableUpdateCompanionBuilder,
      (
        FieldClockRow,
        BaseReferences<_$AppDatabase, $FieldClockTable, FieldClockRow>,
      ),
      FieldClockRow,
      PrefetchHooks Function()
    >;
typedef $$LocalSettingsTableCreateCompanionBuilder =
    LocalSettingsCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$LocalSettingsTableUpdateCompanionBuilder =
    LocalSettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$LocalSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalSettingsTable> {
  $$LocalSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalSettingsTable> {
  $$LocalSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalSettingsTable> {
  $$LocalSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$LocalSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalSettingsTable,
          LocalSettingRow,
          $$LocalSettingsTableFilterComposer,
          $$LocalSettingsTableOrderingComposer,
          $$LocalSettingsTableAnnotationComposer,
          $$LocalSettingsTableCreateCompanionBuilder,
          $$LocalSettingsTableUpdateCompanionBuilder,
          (
            LocalSettingRow,
            BaseReferences<_$AppDatabase, $LocalSettingsTable, LocalSettingRow>,
          ),
          LocalSettingRow,
          PrefetchHooks Function()
        > {
  $$LocalSettingsTableTableManager(_$AppDatabase db, $LocalSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => LocalSettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => LocalSettingsCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LocalSettingsTable, LocalSettingRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $LocalSettingsTable,
                    LocalSettingRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalSettingsTable,
      LocalSettingRow,
      $$LocalSettingsTableFilterComposer,
      $$LocalSettingsTableOrderingComposer,
      $$LocalSettingsTableAnnotationComposer,
      $$LocalSettingsTableCreateCompanionBuilder,
      $$LocalSettingsTableUpdateCompanionBuilder,
      (
        LocalSettingRow,
        BaseReferences<_$AppDatabase, $LocalSettingsTable, LocalSettingRow>,
      ),
      LocalSettingRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$HomesTableTableManager get homes =>
      $$HomesTableTableManager(_db, _db.homes);
  $$RoomsTableTableManager get rooms =>
      $$RoomsTableTableManager(_db, _db.rooms);
  $$ItemsTableTableManager get items =>
      $$ItemsTableTableManager(_db, _db.items);
  $$PhotosTableTableManager get photos =>
      $$PhotosTableTableManager(_db, _db.photos);
  $$ContractorsTableTableManager get contractors =>
      $$ContractorsTableTableManager(_db, _db.contractors);
  $$TasksTableTableManager get tasks =>
      $$TasksTableTableManager(_db, _db.tasks);
  $$OccurrencesTableTableManager get occurrences =>
      $$OccurrencesTableTableManager(_db, _db.occurrences);
  $$FieldClockTableTableManager get fieldClock =>
      $$FieldClockTableTableManager(_db, _db.fieldClock);
  $$LocalSettingsTableTableManager get localSettings =>
      $$LocalSettingsTableTableManager(_db, _db.localSettings);
}
