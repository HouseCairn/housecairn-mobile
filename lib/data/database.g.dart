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
  late final GeneratedColumnWithTypeConverter<String?, Uint8List>
  paintArticleId = GeneratedColumn<Uint8List>(
    'paint_article_id',
    aliasedName,
    true,
    type: DriftSqlType.blob,
    requiredDuringInsert: false,
  ).withConverter<String?>($RoomsTable.$converterpaintArticleIdn);
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
    paintArticleId,
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
      paintArticleId: $RoomsTable.$converterpaintArticleIdn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}paint_article_id'],
        ),
      ),
    );
  }

  @override
  $RoomsTable createAlias(String alias) {
    return $RoomsTable(attachedDatabase, alias);
  }

  static TypeConverter<String, Uint8List> $converterid = const UuidConverter();
  static TypeConverter<String, Uint8List> $converterhomeId =
      const UuidConverter();
  static TypeConverter<String, Uint8List> $converterpaintArticleId =
      const UuidConverter();
  static TypeConverter<String?, Uint8List?> $converterpaintArticleIdn =
      NullAwareTypeConverter.wrap($converterpaintArticleId);
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
  final String? paintArticleId;
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
    this.paintArticleId,
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
    if (!nullToAbsent || paintArticleId != null) {
      map['paint_article_id'] = Variable<Uint8List>(
        $RoomsTable.$converterpaintArticleIdn.toSql(paintArticleId),
      );
    }
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
      paintArticleId: paintArticleId == null && nullToAbsent
          ? const Value.absent()
          : Value(paintArticleId),
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
      paintArticleId: serializer.fromJson<String?>(json['paintArticleId']),
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
      'paintArticleId': serializer.toJson<String?>(paintArticleId),
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
    Value<String?> paintArticleId = const Value.absent(),
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
    paintArticleId: paintArticleId.present
        ? paintArticleId.value
        : this.paintArticleId,
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
      paintArticleId: data.paintArticleId.present
          ? data.paintArticleId.value
          : this.paintArticleId,
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
          ..write('memoryNotes: $memoryNotes, ')
          ..write('paintArticleId: $paintArticleId')
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
    paintArticleId,
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
          other.memoryNotes == this.memoryNotes &&
          other.paintArticleId == this.paintArticleId);
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
  final Value<String?> paintArticleId;
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
    this.paintArticleId = const Value.absent(),
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
    this.paintArticleId = const Value.absent(),
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
    Expression<Uint8List>? paintArticleId,
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
      if (paintArticleId != null) 'paint_article_id': paintArticleId,
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
    Value<String?>? paintArticleId,
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
      paintArticleId: paintArticleId ?? this.paintArticleId,
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
    if (paintArticleId.present) {
      map['paint_article_id'] = Variable<Uint8List>(
        $RoomsTable.$converterpaintArticleIdn.toSql(paintArticleId.value),
      );
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
          ..write('paintArticleId: $paintArticleId, ')
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
  static const VerificationMeta _purchasedOnMeta = const VerificationMeta(
    'purchasedOn',
  );
  @override
  late final GeneratedColumn<String> purchasedOn = GeneratedColumn<String>(
    'purchased_on',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _warrantyDurationMeta = const VerificationMeta(
    'warrantyDuration',
  );
  @override
  late final GeneratedColumn<int> warrantyDuration = GeneratedColumn<int>(
    'warranty_duration',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _warrantyDurationUnitMeta =
      const VerificationMeta('warrantyDurationUnit');
  @override
  late final GeneratedColumn<String> warrantyDurationUnit =
      GeneratedColumn<String>(
        'warranty_duration_unit',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('year'),
      );
  static const VerificationMeta _warrantyProviderMeta = const VerificationMeta(
    'warrantyProvider',
  );
  @override
  late final GeneratedColumn<String> warrantyProvider = GeneratedColumn<String>(
    'warranty_provider',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _warrantyProviderNameMeta =
      const VerificationMeta('warrantyProviderName');
  @override
  late final GeneratedColumn<String> warrantyProviderName =
      GeneratedColumn<String>(
        'warranty_provider_name',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant(''),
      );
  static const VerificationMeta _warrantyStartsOnMeta = const VerificationMeta(
    'warrantyStartsOn',
  );
  @override
  late final GeneratedColumn<String> warrantyStartsOn = GeneratedColumn<String>(
    'warranty_starts_on',
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
    purchasedOn,
    warrantyDuration,
    warrantyDurationUnit,
    warrantyProvider,
    warrantyProviderName,
    warrantyStartsOn,
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
    if (data.containsKey('purchased_on')) {
      context.handle(
        _purchasedOnMeta,
        purchasedOn.isAcceptableOrUnknown(
          data['purchased_on']!,
          _purchasedOnMeta,
        ),
      );
    }
    if (data.containsKey('warranty_duration')) {
      context.handle(
        _warrantyDurationMeta,
        warrantyDuration.isAcceptableOrUnknown(
          data['warranty_duration']!,
          _warrantyDurationMeta,
        ),
      );
    }
    if (data.containsKey('warranty_duration_unit')) {
      context.handle(
        _warrantyDurationUnitMeta,
        warrantyDurationUnit.isAcceptableOrUnknown(
          data['warranty_duration_unit']!,
          _warrantyDurationUnitMeta,
        ),
      );
    }
    if (data.containsKey('warranty_provider')) {
      context.handle(
        _warrantyProviderMeta,
        warrantyProvider.isAcceptableOrUnknown(
          data['warranty_provider']!,
          _warrantyProviderMeta,
        ),
      );
    }
    if (data.containsKey('warranty_provider_name')) {
      context.handle(
        _warrantyProviderNameMeta,
        warrantyProviderName.isAcceptableOrUnknown(
          data['warranty_provider_name']!,
          _warrantyProviderNameMeta,
        ),
      );
    }
    if (data.containsKey('warranty_starts_on')) {
      context.handle(
        _warrantyStartsOnMeta,
        warrantyStartsOn.isAcceptableOrUnknown(
          data['warranty_starts_on']!,
          _warrantyStartsOnMeta,
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
      purchasedOn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}purchased_on'],
      ),
      warrantyDuration: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}warranty_duration'],
      ),
      warrantyDurationUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}warranty_duration_unit'],
      )!,
      warrantyProvider: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}warranty_provider'],
      )!,
      warrantyProviderName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}warranty_provider_name'],
      )!,
      warrantyStartsOn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}warranty_starts_on'],
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
  final String? purchasedOn;
  final int? warrantyDuration;
  final String warrantyDurationUnit;
  final String warrantyProvider;
  final String warrantyProviderName;
  final String? warrantyStartsOn;
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
    this.purchasedOn,
    this.warrantyDuration,
    required this.warrantyDurationUnit,
    required this.warrantyProvider,
    required this.warrantyProviderName,
    this.warrantyStartsOn,
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
    if (!nullToAbsent || purchasedOn != null) {
      map['purchased_on'] = Variable<String>(purchasedOn);
    }
    if (!nullToAbsent || warrantyDuration != null) {
      map['warranty_duration'] = Variable<int>(warrantyDuration);
    }
    map['warranty_duration_unit'] = Variable<String>(warrantyDurationUnit);
    map['warranty_provider'] = Variable<String>(warrantyProvider);
    map['warranty_provider_name'] = Variable<String>(warrantyProviderName);
    if (!nullToAbsent || warrantyStartsOn != null) {
      map['warranty_starts_on'] = Variable<String>(warrantyStartsOn);
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
      purchasedOn: purchasedOn == null && nullToAbsent
          ? const Value.absent()
          : Value(purchasedOn),
      warrantyDuration: warrantyDuration == null && nullToAbsent
          ? const Value.absent()
          : Value(warrantyDuration),
      warrantyDurationUnit: Value(warrantyDurationUnit),
      warrantyProvider: Value(warrantyProvider),
      warrantyProviderName: Value(warrantyProviderName),
      warrantyStartsOn: warrantyStartsOn == null && nullToAbsent
          ? const Value.absent()
          : Value(warrantyStartsOn),
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
      purchasedOn: serializer.fromJson<String?>(json['purchasedOn']),
      warrantyDuration: serializer.fromJson<int?>(json['warrantyDuration']),
      warrantyDurationUnit: serializer.fromJson<String>(
        json['warrantyDurationUnit'],
      ),
      warrantyProvider: serializer.fromJson<String>(json['warrantyProvider']),
      warrantyProviderName: serializer.fromJson<String>(
        json['warrantyProviderName'],
      ),
      warrantyStartsOn: serializer.fromJson<String?>(json['warrantyStartsOn']),
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
      'purchasedOn': serializer.toJson<String?>(purchasedOn),
      'warrantyDuration': serializer.toJson<int?>(warrantyDuration),
      'warrantyDurationUnit': serializer.toJson<String>(warrantyDurationUnit),
      'warrantyProvider': serializer.toJson<String>(warrantyProvider),
      'warrantyProviderName': serializer.toJson<String>(warrantyProviderName),
      'warrantyStartsOn': serializer.toJson<String?>(warrantyStartsOn),
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
    Value<String?> purchasedOn = const Value.absent(),
    Value<int?> warrantyDuration = const Value.absent(),
    String? warrantyDurationUnit,
    String? warrantyProvider,
    String? warrantyProviderName,
    Value<String?> warrantyStartsOn = const Value.absent(),
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
    purchasedOn: purchasedOn.present ? purchasedOn.value : this.purchasedOn,
    warrantyDuration: warrantyDuration.present
        ? warrantyDuration.value
        : this.warrantyDuration,
    warrantyDurationUnit: warrantyDurationUnit ?? this.warrantyDurationUnit,
    warrantyProvider: warrantyProvider ?? this.warrantyProvider,
    warrantyProviderName: warrantyProviderName ?? this.warrantyProviderName,
    warrantyStartsOn: warrantyStartsOn.present
        ? warrantyStartsOn.value
        : this.warrantyStartsOn,
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
      purchasedOn: data.purchasedOn.present
          ? data.purchasedOn.value
          : this.purchasedOn,
      warrantyDuration: data.warrantyDuration.present
          ? data.warrantyDuration.value
          : this.warrantyDuration,
      warrantyDurationUnit: data.warrantyDurationUnit.present
          ? data.warrantyDurationUnit.value
          : this.warrantyDurationUnit,
      warrantyProvider: data.warrantyProvider.present
          ? data.warrantyProvider.value
          : this.warrantyProvider,
      warrantyProviderName: data.warrantyProviderName.present
          ? data.warrantyProviderName.value
          : this.warrantyProviderName,
      warrantyStartsOn: data.warrantyStartsOn.present
          ? data.warrantyStartsOn.value
          : this.warrantyStartsOn,
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
          ..write('purchasedOn: $purchasedOn, ')
          ..write('warrantyDuration: $warrantyDuration, ')
          ..write('warrantyDurationUnit: $warrantyDurationUnit, ')
          ..write('warrantyProvider: $warrantyProvider, ')
          ..write('warrantyProviderName: $warrantyProviderName, ')
          ..write('warrantyStartsOn: $warrantyStartsOn, ')
          ..write('contractContractorId: $contractContractorId, ')
          ..write('contractNumber: $contractNumber, ')
          ..write('contractUrl: $contractUrl, ')
          ..write('links: $links, ')
          ..write('notes: $notes')
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
    roomId,
    name,
    kind,
    brand,
    model,
    serialNumber,
    installedOn,
    warrantyEndsOn,
    purchasedOn,
    warrantyDuration,
    warrantyDurationUnit,
    warrantyProvider,
    warrantyProviderName,
    warrantyStartsOn,
    contractContractorId,
    contractNumber,
    contractUrl,
    links,
    notes,
  ]);
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
          other.purchasedOn == this.purchasedOn &&
          other.warrantyDuration == this.warrantyDuration &&
          other.warrantyDurationUnit == this.warrantyDurationUnit &&
          other.warrantyProvider == this.warrantyProvider &&
          other.warrantyProviderName == this.warrantyProviderName &&
          other.warrantyStartsOn == this.warrantyStartsOn &&
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
  final Value<String?> purchasedOn;
  final Value<int?> warrantyDuration;
  final Value<String> warrantyDurationUnit;
  final Value<String> warrantyProvider;
  final Value<String> warrantyProviderName;
  final Value<String?> warrantyStartsOn;
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
    this.purchasedOn = const Value.absent(),
    this.warrantyDuration = const Value.absent(),
    this.warrantyDurationUnit = const Value.absent(),
    this.warrantyProvider = const Value.absent(),
    this.warrantyProviderName = const Value.absent(),
    this.warrantyStartsOn = const Value.absent(),
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
    this.purchasedOn = const Value.absent(),
    this.warrantyDuration = const Value.absent(),
    this.warrantyDurationUnit = const Value.absent(),
    this.warrantyProvider = const Value.absent(),
    this.warrantyProviderName = const Value.absent(),
    this.warrantyStartsOn = const Value.absent(),
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
    Expression<String>? purchasedOn,
    Expression<int>? warrantyDuration,
    Expression<String>? warrantyDurationUnit,
    Expression<String>? warrantyProvider,
    Expression<String>? warrantyProviderName,
    Expression<String>? warrantyStartsOn,
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
      if (purchasedOn != null) 'purchased_on': purchasedOn,
      if (warrantyDuration != null) 'warranty_duration': warrantyDuration,
      if (warrantyDurationUnit != null)
        'warranty_duration_unit': warrantyDurationUnit,
      if (warrantyProvider != null) 'warranty_provider': warrantyProvider,
      if (warrantyProviderName != null)
        'warranty_provider_name': warrantyProviderName,
      if (warrantyStartsOn != null) 'warranty_starts_on': warrantyStartsOn,
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
    Value<String?>? purchasedOn,
    Value<int?>? warrantyDuration,
    Value<String>? warrantyDurationUnit,
    Value<String>? warrantyProvider,
    Value<String>? warrantyProviderName,
    Value<String?>? warrantyStartsOn,
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
      purchasedOn: purchasedOn ?? this.purchasedOn,
      warrantyDuration: warrantyDuration ?? this.warrantyDuration,
      warrantyDurationUnit: warrantyDurationUnit ?? this.warrantyDurationUnit,
      warrantyProvider: warrantyProvider ?? this.warrantyProvider,
      warrantyProviderName: warrantyProviderName ?? this.warrantyProviderName,
      warrantyStartsOn: warrantyStartsOn ?? this.warrantyStartsOn,
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
    if (purchasedOn.present) {
      map['purchased_on'] = Variable<String>(purchasedOn.value);
    }
    if (warrantyDuration.present) {
      map['warranty_duration'] = Variable<int>(warrantyDuration.value);
    }
    if (warrantyDurationUnit.present) {
      map['warranty_duration_unit'] = Variable<String>(
        warrantyDurationUnit.value,
      );
    }
    if (warrantyProvider.present) {
      map['warranty_provider'] = Variable<String>(warrantyProvider.value);
    }
    if (warrantyProviderName.present) {
      map['warranty_provider_name'] = Variable<String>(
        warrantyProviderName.value,
      );
    }
    if (warrantyStartsOn.present) {
      map['warranty_starts_on'] = Variable<String>(warrantyStartsOn.value);
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
          ..write('purchasedOn: $purchasedOn, ')
          ..write('warrantyDuration: $warrantyDuration, ')
          ..write('warrantyDurationUnit: $warrantyDurationUnit, ')
          ..write('warrantyProvider: $warrantyProvider, ')
          ..write('warrantyProviderName: $warrantyProviderName, ')
          ..write('warrantyStartsOn: $warrantyStartsOn, ')
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
  static const VerificationMeta _materialBudgetMeta = const VerificationMeta(
    'materialBudget',
  );
  @override
  late final GeneratedColumn<String> materialBudget = GeneratedColumn<String>(
    'material_budget',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _labourBudgetMeta = const VerificationMeta(
    'labourBudget',
  );
  @override
  late final GeneratedColumn<String> labourBudget = GeneratedColumn<String>(
    'labour_budget',
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
    materialBudget,
    labourBudget,
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
    if (data.containsKey('material_budget')) {
      context.handle(
        _materialBudgetMeta,
        materialBudget.isAcceptableOrUnknown(
          data['material_budget']!,
          _materialBudgetMeta,
        ),
      );
    }
    if (data.containsKey('labour_budget')) {
      context.handle(
        _labourBudgetMeta,
        labourBudget.isAcceptableOrUnknown(
          data['labour_budget']!,
          _labourBudgetMeta,
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
      materialBudget: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}material_budget'],
      ),
      labourBudget: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}labour_budget'],
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

  /// What one time of the task is planned to cost, in materials and in
  /// labour (`tasks/models.py` `material_budget`, `labour_budget`).
  final String? materialBudget;
  final String? labourBudget;
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
    this.materialBudget,
    this.labourBudget,
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
    if (!nullToAbsent || materialBudget != null) {
      map['material_budget'] = Variable<String>(materialBudget);
    }
    if (!nullToAbsent || labourBudget != null) {
      map['labour_budget'] = Variable<String>(labourBudget);
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
      materialBudget: materialBudget == null && nullToAbsent
          ? const Value.absent()
          : Value(materialBudget),
      labourBudget: labourBudget == null && nullToAbsent
          ? const Value.absent()
          : Value(labourBudget),
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
      materialBudget: serializer.fromJson<String?>(json['materialBudget']),
      labourBudget: serializer.fromJson<String?>(json['labourBudget']),
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
      'materialBudget': serializer.toJson<String?>(materialBudget),
      'labourBudget': serializer.toJson<String?>(labourBudget),
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
    Value<String?> materialBudget = const Value.absent(),
    Value<String?> labourBudget = const Value.absent(),
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
    materialBudget: materialBudget.present
        ? materialBudget.value
        : this.materialBudget,
    labourBudget: labourBudget.present ? labourBudget.value : this.labourBudget,
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
      materialBudget: data.materialBudget.present
          ? data.materialBudget.value
          : this.materialBudget,
      labourBudget: data.labourBudget.present
          ? data.labourBudget.value
          : this.labourBudget,
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
          ..write('seriesStart: $seriesStart, ')
          ..write('materialBudget: $materialBudget, ')
          ..write('labourBudget: $labourBudget')
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
    materialBudget,
    labourBudget,
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
          other.seriesStart == this.seriesStart &&
          other.materialBudget == this.materialBudget &&
          other.labourBudget == this.labourBudget);
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
  final Value<String?> materialBudget;
  final Value<String?> labourBudget;
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
    this.materialBudget = const Value.absent(),
    this.labourBudget = const Value.absent(),
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
    this.materialBudget = const Value.absent(),
    this.labourBudget = const Value.absent(),
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
    Expression<String>? materialBudget,
    Expression<String>? labourBudget,
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
      if (materialBudget != null) 'material_budget': materialBudget,
      if (labourBudget != null) 'labour_budget': labourBudget,
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
    Value<String?>? materialBudget,
    Value<String?>? labourBudget,
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
      materialBudget: materialBudget ?? this.materialBudget,
      labourBudget: labourBudget ?? this.labourBudget,
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
    if (materialBudget.present) {
      map['material_budget'] = Variable<String>(materialBudget.value);
    }
    if (labourBudget.present) {
      map['labour_budget'] = Variable<String>(labourBudget.value);
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
          ..write('materialBudget: $materialBudget, ')
          ..write('labourBudget: $labourBudget, ')
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
  static const VerificationMeta _actualCostMeta = const VerificationMeta(
    'actualCost',
  );
  @override
  late final GeneratedColumn<String> actualCost = GeneratedColumn<String>(
    'actual_cost',
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
    taskId,
    dueOn,
    visibleFrom,
    status,
    statusBefore,
    postponedFrom,
    completedOn,
    completionNote,
    follows,
    actualCost,
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
    if (data.containsKey('actual_cost')) {
      context.handle(
        _actualCostMeta,
        actualCost.isAcceptableOrUnknown(data['actual_cost']!, _actualCostMeta),
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
      actualCost: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}actual_cost'],
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
  final String? actualCost;
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
    this.actualCost,
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
    if (!nullToAbsent || actualCost != null) {
      map['actual_cost'] = Variable<String>(actualCost);
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
      actualCost: actualCost == null && nullToAbsent
          ? const Value.absent()
          : Value(actualCost),
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
      actualCost: serializer.fromJson<String?>(json['actualCost']),
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
      'actualCost': serializer.toJson<String?>(actualCost),
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
    Value<String?> actualCost = const Value.absent(),
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
    actualCost: actualCost.present ? actualCost.value : this.actualCost,
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
      actualCost: data.actualCost.present
          ? data.actualCost.value
          : this.actualCost,
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
          ..write('follows: $follows, ')
          ..write('actualCost: $actualCost')
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
    actualCost,
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
          other.follows == this.follows &&
          other.actualCost == this.actualCost);
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
  final Value<String?> actualCost;
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
    this.actualCost = const Value.absent(),
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
    this.actualCost = const Value.absent(),
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
    Expression<String>? actualCost,
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
      if (actualCost != null) 'actual_cost': actualCost,
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
    Value<String?>? actualCost,
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
      actualCost: actualCost ?? this.actualCost,
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
    if (actualCost.present) {
      map['actual_cost'] = Variable<String>(actualCost.value);
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
          ..write('actualCost: $actualCost, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ArticlesTable extends Articles
    with TableInfo<$ArticlesTable, ArticleRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ArticlesTable(this.attachedDatabase, [this._alias]);
  @override
  late final GeneratedColumnWithTypeConverter<String, Uint8List> id =
      GeneratedColumn<Uint8List>(
        'id',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      ).withConverter<String>($ArticlesTable.$converterid);
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
      ).withConverter<String>($ArticlesTable.$converterhomeId);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _manufacturerReferenceMeta =
      const VerificationMeta('manufacturerReference');
  @override
  late final GeneratedColumn<String> manufacturerReference =
      GeneratedColumn<String>(
        'manufacturer_reference',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant(''),
      );
  static const VerificationMeta _dimensionsMeta = const VerificationMeta(
    'dimensions',
  );
  @override
  late final GeneratedColumn<String> dimensions = GeneratedColumn<String>(
    'dimensions',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _storageLocationMeta = const VerificationMeta(
    'storageLocation',
  );
  @override
  late final GeneratedColumn<String> storageLocation = GeneratedColumn<String>(
    'storage_location',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _unitOtherMeta = const VerificationMeta(
    'unitOther',
  );
  @override
  late final GeneratedColumn<String> unitOther = GeneratedColumn<String>(
    'unit_other',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _thresholdMeta = const VerificationMeta(
    'threshold',
  );
  @override
  late final GeneratedColumn<String> threshold = GeneratedColumn<String>(
    'threshold',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _unitPriceMeta = const VerificationMeta(
    'unitPrice',
  );
  @override
  late final GeneratedColumn<String> unitPrice = GeneratedColumn<String>(
    'unit_price',
    aliasedName,
    true,
    type: DriftSqlType.string,
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
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
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
    name,
    manufacturerReference,
    dimensions,
    storageLocation,
    unit,
    unitOther,
    threshold,
    unitPrice,
    notes,
    label,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'articles';
  @override
  VerificationContext validateIntegrity(
    Insertable<ArticleRow> instance, {
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
    if (data.containsKey('manufacturer_reference')) {
      context.handle(
        _manufacturerReferenceMeta,
        manufacturerReference.isAcceptableOrUnknown(
          data['manufacturer_reference']!,
          _manufacturerReferenceMeta,
        ),
      );
    }
    if (data.containsKey('dimensions')) {
      context.handle(
        _dimensionsMeta,
        dimensions.isAcceptableOrUnknown(data['dimensions']!, _dimensionsMeta),
      );
    }
    if (data.containsKey('storage_location')) {
      context.handle(
        _storageLocationMeta,
        storageLocation.isAcceptableOrUnknown(
          data['storage_location']!,
          _storageLocationMeta,
        ),
      );
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    }
    if (data.containsKey('unit_other')) {
      context.handle(
        _unitOtherMeta,
        unitOther.isAcceptableOrUnknown(data['unit_other']!, _unitOtherMeta),
      );
    }
    if (data.containsKey('threshold')) {
      context.handle(
        _thresholdMeta,
        threshold.isAcceptableOrUnknown(data['threshold']!, _thresholdMeta),
      );
    }
    if (data.containsKey('unit_price')) {
      context.handle(
        _unitPriceMeta,
        unitPrice.isAcceptableOrUnknown(data['unit_price']!, _unitPriceMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ArticleRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ArticleRow(
      id: $ArticlesTable.$converterid.fromSql(
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
      homeId: $ArticlesTable.$converterhomeId.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}home_id'],
        )!,
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      manufacturerReference: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}manufacturer_reference'],
      )!,
      dimensions: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dimensions'],
      )!,
      storageLocation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}storage_location'],
      )!,
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      )!,
      unitOther: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit_other'],
      )!,
      threshold: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}threshold'],
      ),
      unitPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit_price'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      ),
    );
  }

  @override
  $ArticlesTable createAlias(String alias) {
    return $ArticlesTable(attachedDatabase, alias);
  }

  static TypeConverter<String, Uint8List> $converterid = const UuidConverter();
  static TypeConverter<String, Uint8List> $converterhomeId =
      const UuidConverter();
}

class ArticleRow extends DataClass implements Insertable<ArticleRow> {
  final String id;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;
  final String homeId;
  final String name;
  final String manufacturerReference;
  final String dimensions;
  final String storageLocation;
  final String unit;
  final String unitOther;
  final String? threshold;
  final String? unitPrice;
  final String notes;
  final String? label;
  const ArticleRow({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.homeId,
    required this.name,
    required this.manufacturerReference,
    required this.dimensions,
    required this.storageLocation,
    required this.unit,
    required this.unitOther,
    this.threshold,
    this.unitPrice,
    required this.notes,
    this.label,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    {
      map['id'] = Variable<Uint8List>($ArticlesTable.$converterid.toSql(id));
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    {
      map['home_id'] = Variable<Uint8List>(
        $ArticlesTable.$converterhomeId.toSql(homeId),
      );
    }
    map['name'] = Variable<String>(name);
    map['manufacturer_reference'] = Variable<String>(manufacturerReference);
    map['dimensions'] = Variable<String>(dimensions);
    map['storage_location'] = Variable<String>(storageLocation);
    map['unit'] = Variable<String>(unit);
    map['unit_other'] = Variable<String>(unitOther);
    if (!nullToAbsent || threshold != null) {
      map['threshold'] = Variable<String>(threshold);
    }
    if (!nullToAbsent || unitPrice != null) {
      map['unit_price'] = Variable<String>(unitPrice);
    }
    map['notes'] = Variable<String>(notes);
    if (!nullToAbsent || label != null) {
      map['label'] = Variable<String>(label);
    }
    return map;
  }

  ArticlesCompanion toCompanion(bool nullToAbsent) {
    return ArticlesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      homeId: Value(homeId),
      name: Value(name),
      manufacturerReference: Value(manufacturerReference),
      dimensions: Value(dimensions),
      storageLocation: Value(storageLocation),
      unit: Value(unit),
      unitOther: Value(unitOther),
      threshold: threshold == null && nullToAbsent
          ? const Value.absent()
          : Value(threshold),
      unitPrice: unitPrice == null && nullToAbsent
          ? const Value.absent()
          : Value(unitPrice),
      notes: Value(notes),
      label: label == null && nullToAbsent
          ? const Value.absent()
          : Value(label),
    );
  }

  factory ArticleRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ArticleRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      homeId: serializer.fromJson<String>(json['homeId']),
      name: serializer.fromJson<String>(json['name']),
      manufacturerReference: serializer.fromJson<String>(
        json['manufacturerReference'],
      ),
      dimensions: serializer.fromJson<String>(json['dimensions']),
      storageLocation: serializer.fromJson<String>(json['storageLocation']),
      unit: serializer.fromJson<String>(json['unit']),
      unitOther: serializer.fromJson<String>(json['unitOther']),
      threshold: serializer.fromJson<String?>(json['threshold']),
      unitPrice: serializer.fromJson<String?>(json['unitPrice']),
      notes: serializer.fromJson<String>(json['notes']),
      label: serializer.fromJson<String?>(json['label']),
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
      'manufacturerReference': serializer.toJson<String>(manufacturerReference),
      'dimensions': serializer.toJson<String>(dimensions),
      'storageLocation': serializer.toJson<String>(storageLocation),
      'unit': serializer.toJson<String>(unit),
      'unitOther': serializer.toJson<String>(unitOther),
      'threshold': serializer.toJson<String?>(threshold),
      'unitPrice': serializer.toJson<String?>(unitPrice),
      'notes': serializer.toJson<String>(notes),
      'label': serializer.toJson<String?>(label),
    };
  }

  ArticleRow copyWith({
    String? id,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    String? homeId,
    String? name,
    String? manufacturerReference,
    String? dimensions,
    String? storageLocation,
    String? unit,
    String? unitOther,
    Value<String?> threshold = const Value.absent(),
    Value<String?> unitPrice = const Value.absent(),
    String? notes,
    Value<String?> label = const Value.absent(),
  }) => ArticleRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    homeId: homeId ?? this.homeId,
    name: name ?? this.name,
    manufacturerReference: manufacturerReference ?? this.manufacturerReference,
    dimensions: dimensions ?? this.dimensions,
    storageLocation: storageLocation ?? this.storageLocation,
    unit: unit ?? this.unit,
    unitOther: unitOther ?? this.unitOther,
    threshold: threshold.present ? threshold.value : this.threshold,
    unitPrice: unitPrice.present ? unitPrice.value : this.unitPrice,
    notes: notes ?? this.notes,
    label: label.present ? label.value : this.label,
  );
  ArticleRow copyWithCompanion(ArticlesCompanion data) {
    return ArticleRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      homeId: data.homeId.present ? data.homeId.value : this.homeId,
      name: data.name.present ? data.name.value : this.name,
      manufacturerReference: data.manufacturerReference.present
          ? data.manufacturerReference.value
          : this.manufacturerReference,
      dimensions: data.dimensions.present
          ? data.dimensions.value
          : this.dimensions,
      storageLocation: data.storageLocation.present
          ? data.storageLocation.value
          : this.storageLocation,
      unit: data.unit.present ? data.unit.value : this.unit,
      unitOther: data.unitOther.present ? data.unitOther.value : this.unitOther,
      threshold: data.threshold.present ? data.threshold.value : this.threshold,
      unitPrice: data.unitPrice.present ? data.unitPrice.value : this.unitPrice,
      notes: data.notes.present ? data.notes.value : this.notes,
      label: data.label.present ? data.label.value : this.label,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ArticleRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('homeId: $homeId, ')
          ..write('name: $name, ')
          ..write('manufacturerReference: $manufacturerReference, ')
          ..write('dimensions: $dimensions, ')
          ..write('storageLocation: $storageLocation, ')
          ..write('unit: $unit, ')
          ..write('unitOther: $unitOther, ')
          ..write('threshold: $threshold, ')
          ..write('unitPrice: $unitPrice, ')
          ..write('notes: $notes, ')
          ..write('label: $label')
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
    manufacturerReference,
    dimensions,
    storageLocation,
    unit,
    unitOther,
    threshold,
    unitPrice,
    notes,
    label,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ArticleRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.homeId == this.homeId &&
          other.name == this.name &&
          other.manufacturerReference == this.manufacturerReference &&
          other.dimensions == this.dimensions &&
          other.storageLocation == this.storageLocation &&
          other.unit == this.unit &&
          other.unitOther == this.unitOther &&
          other.threshold == this.threshold &&
          other.unitPrice == this.unitPrice &&
          other.notes == this.notes &&
          other.label == this.label);
}

class ArticlesCompanion extends UpdateCompanion<ArticleRow> {
  final Value<String> id;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<String> homeId;
  final Value<String> name;
  final Value<String> manufacturerReference;
  final Value<String> dimensions;
  final Value<String> storageLocation;
  final Value<String> unit;
  final Value<String> unitOther;
  final Value<String?> threshold;
  final Value<String?> unitPrice;
  final Value<String> notes;
  final Value<String?> label;
  final Value<int> rowid;
  const ArticlesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.homeId = const Value.absent(),
    this.name = const Value.absent(),
    this.manufacturerReference = const Value.absent(),
    this.dimensions = const Value.absent(),
    this.storageLocation = const Value.absent(),
    this.unit = const Value.absent(),
    this.unitOther = const Value.absent(),
    this.threshold = const Value.absent(),
    this.unitPrice = const Value.absent(),
    this.notes = const Value.absent(),
    this.label = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ArticlesCompanion.insert({
    required String id,
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    required String homeId,
    required String name,
    this.manufacturerReference = const Value.absent(),
    this.dimensions = const Value.absent(),
    this.storageLocation = const Value.absent(),
    this.unit = const Value.absent(),
    this.unitOther = const Value.absent(),
    this.threshold = const Value.absent(),
    this.unitPrice = const Value.absent(),
    this.notes = const Value.absent(),
    this.label = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       homeId = Value(homeId),
       name = Value(name);
  static Insertable<ArticleRow> custom({
    Expression<Uint8List>? id,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<Uint8List>? homeId,
    Expression<String>? name,
    Expression<String>? manufacturerReference,
    Expression<String>? dimensions,
    Expression<String>? storageLocation,
    Expression<String>? unit,
    Expression<String>? unitOther,
    Expression<String>? threshold,
    Expression<String>? unitPrice,
    Expression<String>? notes,
    Expression<String>? label,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (homeId != null) 'home_id': homeId,
      if (name != null) 'name': name,
      if (manufacturerReference != null)
        'manufacturer_reference': manufacturerReference,
      if (dimensions != null) 'dimensions': dimensions,
      if (storageLocation != null) 'storage_location': storageLocation,
      if (unit != null) 'unit': unit,
      if (unitOther != null) 'unit_other': unitOther,
      if (threshold != null) 'threshold': threshold,
      if (unitPrice != null) 'unit_price': unitPrice,
      if (notes != null) 'notes': notes,
      if (label != null) 'label': label,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ArticlesCompanion copyWith({
    Value<String>? id,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<String>? homeId,
    Value<String>? name,
    Value<String>? manufacturerReference,
    Value<String>? dimensions,
    Value<String>? storageLocation,
    Value<String>? unit,
    Value<String>? unitOther,
    Value<String?>? threshold,
    Value<String?>? unitPrice,
    Value<String>? notes,
    Value<String?>? label,
    Value<int>? rowid,
  }) {
    return ArticlesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      homeId: homeId ?? this.homeId,
      name: name ?? this.name,
      manufacturerReference:
          manufacturerReference ?? this.manufacturerReference,
      dimensions: dimensions ?? this.dimensions,
      storageLocation: storageLocation ?? this.storageLocation,
      unit: unit ?? this.unit,
      unitOther: unitOther ?? this.unitOther,
      threshold: threshold ?? this.threshold,
      unitPrice: unitPrice ?? this.unitPrice,
      notes: notes ?? this.notes,
      label: label ?? this.label,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<Uint8List>(
        $ArticlesTable.$converterid.toSql(id.value),
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
        $ArticlesTable.$converterhomeId.toSql(homeId.value),
      );
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (manufacturerReference.present) {
      map['manufacturer_reference'] = Variable<String>(
        manufacturerReference.value,
      );
    }
    if (dimensions.present) {
      map['dimensions'] = Variable<String>(dimensions.value);
    }
    if (storageLocation.present) {
      map['storage_location'] = Variable<String>(storageLocation.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (unitOther.present) {
      map['unit_other'] = Variable<String>(unitOther.value);
    }
    if (threshold.present) {
      map['threshold'] = Variable<String>(threshold.value);
    }
    if (unitPrice.present) {
      map['unit_price'] = Variable<String>(unitPrice.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ArticlesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('homeId: $homeId, ')
          ..write('name: $name, ')
          ..write('manufacturerReference: $manufacturerReference, ')
          ..write('dimensions: $dimensions, ')
          ..write('storageLocation: $storageLocation, ')
          ..write('unit: $unit, ')
          ..write('unitOther: $unitOther, ')
          ..write('threshold: $threshold, ')
          ..write('unitPrice: $unitPrice, ')
          ..write('notes: $notes, ')
          ..write('label: $label, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ArticleRoomsTable extends ArticleRooms
    with TableInfo<$ArticleRoomsTable, ArticleRoomRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ArticleRoomsTable(this.attachedDatabase, [this._alias]);
  @override
  late final GeneratedColumnWithTypeConverter<String, Uint8List> id =
      GeneratedColumn<Uint8List>(
        'id',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      ).withConverter<String>($ArticleRoomsTable.$converterid);
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
      ).withConverter<String>($ArticleRoomsTable.$converterhomeId);
  @override
  late final GeneratedColumnWithTypeConverter<String, Uint8List> articleId =
      GeneratedColumn<Uint8List>(
        'article_id',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      ).withConverter<String>($ArticleRoomsTable.$converterarticleId);
  @override
  late final GeneratedColumnWithTypeConverter<String, Uint8List> roomId =
      GeneratedColumn<Uint8List>(
        'room_id',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      ).withConverter<String>($ArticleRoomsTable.$converterroomId);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    homeId,
    articleId,
    roomId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'article_rooms';
  @override
  VerificationContext validateIntegrity(
    Insertable<ArticleRoomRow> instance, {
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ArticleRoomRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ArticleRoomRow(
      id: $ArticleRoomsTable.$converterid.fromSql(
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
      homeId: $ArticleRoomsTable.$converterhomeId.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}home_id'],
        )!,
      ),
      articleId: $ArticleRoomsTable.$converterarticleId.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}article_id'],
        )!,
      ),
      roomId: $ArticleRoomsTable.$converterroomId.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}room_id'],
        )!,
      ),
    );
  }

  @override
  $ArticleRoomsTable createAlias(String alias) {
    return $ArticleRoomsTable(attachedDatabase, alias);
  }

  static TypeConverter<String, Uint8List> $converterid = const UuidConverter();
  static TypeConverter<String, Uint8List> $converterhomeId =
      const UuidConverter();
  static TypeConverter<String, Uint8List> $converterarticleId =
      const UuidConverter();
  static TypeConverter<String, Uint8List> $converterroomId =
      const UuidConverter();
}

class ArticleRoomRow extends DataClass implements Insertable<ArticleRoomRow> {
  final String id;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;
  final String homeId;
  final String articleId;
  final String roomId;
  const ArticleRoomRow({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.homeId,
    required this.articleId,
    required this.roomId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    {
      map['id'] = Variable<Uint8List>(
        $ArticleRoomsTable.$converterid.toSql(id),
      );
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    {
      map['home_id'] = Variable<Uint8List>(
        $ArticleRoomsTable.$converterhomeId.toSql(homeId),
      );
    }
    {
      map['article_id'] = Variable<Uint8List>(
        $ArticleRoomsTable.$converterarticleId.toSql(articleId),
      );
    }
    {
      map['room_id'] = Variable<Uint8List>(
        $ArticleRoomsTable.$converterroomId.toSql(roomId),
      );
    }
    return map;
  }

  ArticleRoomsCompanion toCompanion(bool nullToAbsent) {
    return ArticleRoomsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      homeId: Value(homeId),
      articleId: Value(articleId),
      roomId: Value(roomId),
    );
  }

  factory ArticleRoomRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ArticleRoomRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      homeId: serializer.fromJson<String>(json['homeId']),
      articleId: serializer.fromJson<String>(json['articleId']),
      roomId: serializer.fromJson<String>(json['roomId']),
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
      'articleId': serializer.toJson<String>(articleId),
      'roomId': serializer.toJson<String>(roomId),
    };
  }

  ArticleRoomRow copyWith({
    String? id,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    String? homeId,
    String? articleId,
    String? roomId,
  }) => ArticleRoomRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    homeId: homeId ?? this.homeId,
    articleId: articleId ?? this.articleId,
    roomId: roomId ?? this.roomId,
  );
  ArticleRoomRow copyWithCompanion(ArticleRoomsCompanion data) {
    return ArticleRoomRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      homeId: data.homeId.present ? data.homeId.value : this.homeId,
      articleId: data.articleId.present ? data.articleId.value : this.articleId,
      roomId: data.roomId.present ? data.roomId.value : this.roomId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ArticleRoomRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('homeId: $homeId, ')
          ..write('articleId: $articleId, ')
          ..write('roomId: $roomId')
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
    articleId,
    roomId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ArticleRoomRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.homeId == this.homeId &&
          other.articleId == this.articleId &&
          other.roomId == this.roomId);
}

class ArticleRoomsCompanion extends UpdateCompanion<ArticleRoomRow> {
  final Value<String> id;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<String> homeId;
  final Value<String> articleId;
  final Value<String> roomId;
  final Value<int> rowid;
  const ArticleRoomsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.homeId = const Value.absent(),
    this.articleId = const Value.absent(),
    this.roomId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ArticleRoomsCompanion.insert({
    required String id,
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    required String homeId,
    required String articleId,
    required String roomId,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       homeId = Value(homeId),
       articleId = Value(articleId),
       roomId = Value(roomId);
  static Insertable<ArticleRoomRow> custom({
    Expression<Uint8List>? id,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<Uint8List>? homeId,
    Expression<Uint8List>? articleId,
    Expression<Uint8List>? roomId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (homeId != null) 'home_id': homeId,
      if (articleId != null) 'article_id': articleId,
      if (roomId != null) 'room_id': roomId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ArticleRoomsCompanion copyWith({
    Value<String>? id,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<String>? homeId,
    Value<String>? articleId,
    Value<String>? roomId,
    Value<int>? rowid,
  }) {
    return ArticleRoomsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      homeId: homeId ?? this.homeId,
      articleId: articleId ?? this.articleId,
      roomId: roomId ?? this.roomId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<Uint8List>(
        $ArticleRoomsTable.$converterid.toSql(id.value),
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
        $ArticleRoomsTable.$converterhomeId.toSql(homeId.value),
      );
    }
    if (articleId.present) {
      map['article_id'] = Variable<Uint8List>(
        $ArticleRoomsTable.$converterarticleId.toSql(articleId.value),
      );
    }
    if (roomId.present) {
      map['room_id'] = Variable<Uint8List>(
        $ArticleRoomsTable.$converterroomId.toSql(roomId.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ArticleRoomsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('homeId: $homeId, ')
          ..write('articleId: $articleId, ')
          ..write('roomId: $roomId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ArticleItemsTable extends ArticleItems
    with TableInfo<$ArticleItemsTable, ArticleItemRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ArticleItemsTable(this.attachedDatabase, [this._alias]);
  @override
  late final GeneratedColumnWithTypeConverter<String, Uint8List> id =
      GeneratedColumn<Uint8List>(
        'id',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      ).withConverter<String>($ArticleItemsTable.$converterid);
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
      ).withConverter<String>($ArticleItemsTable.$converterhomeId);
  @override
  late final GeneratedColumnWithTypeConverter<String, Uint8List> articleId =
      GeneratedColumn<Uint8List>(
        'article_id',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      ).withConverter<String>($ArticleItemsTable.$converterarticleId);
  @override
  late final GeneratedColumnWithTypeConverter<String, Uint8List> itemId =
      GeneratedColumn<Uint8List>(
        'item_id',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      ).withConverter<String>($ArticleItemsTable.$converteritemId);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    homeId,
    articleId,
    itemId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'article_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<ArticleItemRow> instance, {
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ArticleItemRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ArticleItemRow(
      id: $ArticleItemsTable.$converterid.fromSql(
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
      homeId: $ArticleItemsTable.$converterhomeId.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}home_id'],
        )!,
      ),
      articleId: $ArticleItemsTable.$converterarticleId.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}article_id'],
        )!,
      ),
      itemId: $ArticleItemsTable.$converteritemId.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}item_id'],
        )!,
      ),
    );
  }

  @override
  $ArticleItemsTable createAlias(String alias) {
    return $ArticleItemsTable(attachedDatabase, alias);
  }

  static TypeConverter<String, Uint8List> $converterid = const UuidConverter();
  static TypeConverter<String, Uint8List> $converterhomeId =
      const UuidConverter();
  static TypeConverter<String, Uint8List> $converterarticleId =
      const UuidConverter();
  static TypeConverter<String, Uint8List> $converteritemId =
      const UuidConverter();
}

class ArticleItemRow extends DataClass implements Insertable<ArticleItemRow> {
  final String id;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;
  final String homeId;
  final String articleId;
  final String itemId;
  const ArticleItemRow({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.homeId,
    required this.articleId,
    required this.itemId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    {
      map['id'] = Variable<Uint8List>(
        $ArticleItemsTable.$converterid.toSql(id),
      );
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    {
      map['home_id'] = Variable<Uint8List>(
        $ArticleItemsTable.$converterhomeId.toSql(homeId),
      );
    }
    {
      map['article_id'] = Variable<Uint8List>(
        $ArticleItemsTable.$converterarticleId.toSql(articleId),
      );
    }
    {
      map['item_id'] = Variable<Uint8List>(
        $ArticleItemsTable.$converteritemId.toSql(itemId),
      );
    }
    return map;
  }

  ArticleItemsCompanion toCompanion(bool nullToAbsent) {
    return ArticleItemsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      homeId: Value(homeId),
      articleId: Value(articleId),
      itemId: Value(itemId),
    );
  }

  factory ArticleItemRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ArticleItemRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      homeId: serializer.fromJson<String>(json['homeId']),
      articleId: serializer.fromJson<String>(json['articleId']),
      itemId: serializer.fromJson<String>(json['itemId']),
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
      'articleId': serializer.toJson<String>(articleId),
      'itemId': serializer.toJson<String>(itemId),
    };
  }

  ArticleItemRow copyWith({
    String? id,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    String? homeId,
    String? articleId,
    String? itemId,
  }) => ArticleItemRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    homeId: homeId ?? this.homeId,
    articleId: articleId ?? this.articleId,
    itemId: itemId ?? this.itemId,
  );
  ArticleItemRow copyWithCompanion(ArticleItemsCompanion data) {
    return ArticleItemRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      homeId: data.homeId.present ? data.homeId.value : this.homeId,
      articleId: data.articleId.present ? data.articleId.value : this.articleId,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ArticleItemRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('homeId: $homeId, ')
          ..write('articleId: $articleId, ')
          ..write('itemId: $itemId')
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
    articleId,
    itemId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ArticleItemRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.homeId == this.homeId &&
          other.articleId == this.articleId &&
          other.itemId == this.itemId);
}

class ArticleItemsCompanion extends UpdateCompanion<ArticleItemRow> {
  final Value<String> id;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<String> homeId;
  final Value<String> articleId;
  final Value<String> itemId;
  final Value<int> rowid;
  const ArticleItemsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.homeId = const Value.absent(),
    this.articleId = const Value.absent(),
    this.itemId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ArticleItemsCompanion.insert({
    required String id,
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    required String homeId,
    required String articleId,
    required String itemId,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       homeId = Value(homeId),
       articleId = Value(articleId),
       itemId = Value(itemId);
  static Insertable<ArticleItemRow> custom({
    Expression<Uint8List>? id,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<Uint8List>? homeId,
    Expression<Uint8List>? articleId,
    Expression<Uint8List>? itemId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (homeId != null) 'home_id': homeId,
      if (articleId != null) 'article_id': articleId,
      if (itemId != null) 'item_id': itemId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ArticleItemsCompanion copyWith({
    Value<String>? id,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<String>? homeId,
    Value<String>? articleId,
    Value<String>? itemId,
    Value<int>? rowid,
  }) {
    return ArticleItemsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      homeId: homeId ?? this.homeId,
      articleId: articleId ?? this.articleId,
      itemId: itemId ?? this.itemId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<Uint8List>(
        $ArticleItemsTable.$converterid.toSql(id.value),
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
        $ArticleItemsTable.$converterhomeId.toSql(homeId.value),
      );
    }
    if (articleId.present) {
      map['article_id'] = Variable<Uint8List>(
        $ArticleItemsTable.$converterarticleId.toSql(articleId.value),
      );
    }
    if (itemId.present) {
      map['item_id'] = Variable<Uint8List>(
        $ArticleItemsTable.$converteritemId.toSql(itemId.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ArticleItemsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('homeId: $homeId, ')
          ..write('articleId: $articleId, ')
          ..write('itemId: $itemId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SuppliersTable extends Suppliers
    with TableInfo<$SuppliersTable, SupplierRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SuppliersTable(this.attachedDatabase, [this._alias]);
  @override
  late final GeneratedColumnWithTypeConverter<String, Uint8List> id =
      GeneratedColumn<Uint8List>(
        'id',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      ).withConverter<String>($SuppliersTable.$converterid);
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
      ).withConverter<String>($SuppliersTable.$converterhomeId);
  @override
  late final GeneratedColumnWithTypeConverter<String, Uint8List> articleId =
      GeneratedColumn<Uint8List>(
        'article_id',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      ).withConverter<String>($SuppliersTable.$converterarticleId);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _referenceMeta = const VerificationMeta(
    'reference',
  );
  @override
  late final GeneratedColumn<String> reference = GeneratedColumn<String>(
    'reference',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _lastPriceMeta = const VerificationMeta(
    'lastPrice',
  );
  @override
  late final GeneratedColumn<String> lastPrice = GeneratedColumn<String>(
    'last_price',
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
    articleId,
    name,
    reference,
    url,
    lastPrice,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'suppliers';
  @override
  VerificationContext validateIntegrity(
    Insertable<SupplierRow> instance, {
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
    if (data.containsKey('reference')) {
      context.handle(
        _referenceMeta,
        reference.isAcceptableOrUnknown(data['reference']!, _referenceMeta),
      );
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    }
    if (data.containsKey('last_price')) {
      context.handle(
        _lastPriceMeta,
        lastPrice.isAcceptableOrUnknown(data['last_price']!, _lastPriceMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SupplierRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SupplierRow(
      id: $SuppliersTable.$converterid.fromSql(
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
      homeId: $SuppliersTable.$converterhomeId.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}home_id'],
        )!,
      ),
      articleId: $SuppliersTable.$converterarticleId.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}article_id'],
        )!,
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      reference: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reference'],
      )!,
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      )!,
      lastPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_price'],
      ),
    );
  }

  @override
  $SuppliersTable createAlias(String alias) {
    return $SuppliersTable(attachedDatabase, alias);
  }

  static TypeConverter<String, Uint8List> $converterid = const UuidConverter();
  static TypeConverter<String, Uint8List> $converterhomeId =
      const UuidConverter();
  static TypeConverter<String, Uint8List> $converterarticleId =
      const UuidConverter();
}

class SupplierRow extends DataClass implements Insertable<SupplierRow> {
  final String id;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;
  final String homeId;
  final String articleId;
  final String name;
  final String reference;
  final String url;
  final String? lastPrice;
  const SupplierRow({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.homeId,
    required this.articleId,
    required this.name,
    required this.reference,
    required this.url,
    this.lastPrice,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    {
      map['id'] = Variable<Uint8List>($SuppliersTable.$converterid.toSql(id));
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    {
      map['home_id'] = Variable<Uint8List>(
        $SuppliersTable.$converterhomeId.toSql(homeId),
      );
    }
    {
      map['article_id'] = Variable<Uint8List>(
        $SuppliersTable.$converterarticleId.toSql(articleId),
      );
    }
    map['name'] = Variable<String>(name);
    map['reference'] = Variable<String>(reference);
    map['url'] = Variable<String>(url);
    if (!nullToAbsent || lastPrice != null) {
      map['last_price'] = Variable<String>(lastPrice);
    }
    return map;
  }

  SuppliersCompanion toCompanion(bool nullToAbsent) {
    return SuppliersCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      homeId: Value(homeId),
      articleId: Value(articleId),
      name: Value(name),
      reference: Value(reference),
      url: Value(url),
      lastPrice: lastPrice == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPrice),
    );
  }

  factory SupplierRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SupplierRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      homeId: serializer.fromJson<String>(json['homeId']),
      articleId: serializer.fromJson<String>(json['articleId']),
      name: serializer.fromJson<String>(json['name']),
      reference: serializer.fromJson<String>(json['reference']),
      url: serializer.fromJson<String>(json['url']),
      lastPrice: serializer.fromJson<String?>(json['lastPrice']),
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
      'articleId': serializer.toJson<String>(articleId),
      'name': serializer.toJson<String>(name),
      'reference': serializer.toJson<String>(reference),
      'url': serializer.toJson<String>(url),
      'lastPrice': serializer.toJson<String?>(lastPrice),
    };
  }

  SupplierRow copyWith({
    String? id,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    String? homeId,
    String? articleId,
    String? name,
    String? reference,
    String? url,
    Value<String?> lastPrice = const Value.absent(),
  }) => SupplierRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    homeId: homeId ?? this.homeId,
    articleId: articleId ?? this.articleId,
    name: name ?? this.name,
    reference: reference ?? this.reference,
    url: url ?? this.url,
    lastPrice: lastPrice.present ? lastPrice.value : this.lastPrice,
  );
  SupplierRow copyWithCompanion(SuppliersCompanion data) {
    return SupplierRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      homeId: data.homeId.present ? data.homeId.value : this.homeId,
      articleId: data.articleId.present ? data.articleId.value : this.articleId,
      name: data.name.present ? data.name.value : this.name,
      reference: data.reference.present ? data.reference.value : this.reference,
      url: data.url.present ? data.url.value : this.url,
      lastPrice: data.lastPrice.present ? data.lastPrice.value : this.lastPrice,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SupplierRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('homeId: $homeId, ')
          ..write('articleId: $articleId, ')
          ..write('name: $name, ')
          ..write('reference: $reference, ')
          ..write('url: $url, ')
          ..write('lastPrice: $lastPrice')
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
    articleId,
    name,
    reference,
    url,
    lastPrice,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SupplierRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.homeId == this.homeId &&
          other.articleId == this.articleId &&
          other.name == this.name &&
          other.reference == this.reference &&
          other.url == this.url &&
          other.lastPrice == this.lastPrice);
}

class SuppliersCompanion extends UpdateCompanion<SupplierRow> {
  final Value<String> id;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<String> homeId;
  final Value<String> articleId;
  final Value<String> name;
  final Value<String> reference;
  final Value<String> url;
  final Value<String?> lastPrice;
  final Value<int> rowid;
  const SuppliersCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.homeId = const Value.absent(),
    this.articleId = const Value.absent(),
    this.name = const Value.absent(),
    this.reference = const Value.absent(),
    this.url = const Value.absent(),
    this.lastPrice = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SuppliersCompanion.insert({
    required String id,
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    required String homeId,
    required String articleId,
    required String name,
    this.reference = const Value.absent(),
    this.url = const Value.absent(),
    this.lastPrice = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       homeId = Value(homeId),
       articleId = Value(articleId),
       name = Value(name);
  static Insertable<SupplierRow> custom({
    Expression<Uint8List>? id,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<Uint8List>? homeId,
    Expression<Uint8List>? articleId,
    Expression<String>? name,
    Expression<String>? reference,
    Expression<String>? url,
    Expression<String>? lastPrice,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (homeId != null) 'home_id': homeId,
      if (articleId != null) 'article_id': articleId,
      if (name != null) 'name': name,
      if (reference != null) 'reference': reference,
      if (url != null) 'url': url,
      if (lastPrice != null) 'last_price': lastPrice,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SuppliersCompanion copyWith({
    Value<String>? id,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<String>? homeId,
    Value<String>? articleId,
    Value<String>? name,
    Value<String>? reference,
    Value<String>? url,
    Value<String?>? lastPrice,
    Value<int>? rowid,
  }) {
    return SuppliersCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      homeId: homeId ?? this.homeId,
      articleId: articleId ?? this.articleId,
      name: name ?? this.name,
      reference: reference ?? this.reference,
      url: url ?? this.url,
      lastPrice: lastPrice ?? this.lastPrice,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<Uint8List>(
        $SuppliersTable.$converterid.toSql(id.value),
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
        $SuppliersTable.$converterhomeId.toSql(homeId.value),
      );
    }
    if (articleId.present) {
      map['article_id'] = Variable<Uint8List>(
        $SuppliersTable.$converterarticleId.toSql(articleId.value),
      );
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (reference.present) {
      map['reference'] = Variable<String>(reference.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (lastPrice.present) {
      map['last_price'] = Variable<String>(lastPrice.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SuppliersCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('homeId: $homeId, ')
          ..write('articleId: $articleId, ')
          ..write('name: $name, ')
          ..write('reference: $reference, ')
          ..write('url: $url, ')
          ..write('lastPrice: $lastPrice, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MovementsTable extends Movements
    with TableInfo<$MovementsTable, MovementRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MovementsTable(this.attachedDatabase, [this._alias]);
  @override
  late final GeneratedColumnWithTypeConverter<String, Uint8List> id =
      GeneratedColumn<Uint8List>(
        'id',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      ).withConverter<String>($MovementsTable.$converterid);
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
      ).withConverter<String>($MovementsTable.$converterhomeId);
  @override
  late final GeneratedColumnWithTypeConverter<String, Uint8List> articleId =
      GeneratedColumn<Uint8List>(
        'article_id',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      ).withConverter<String>($MovementsTable.$converterarticleId);
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<String> quantity = GeneratedColumn<String>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _occurredOnMeta = const VerificationMeta(
    'occurredOn',
  );
  @override
  late final GeneratedColumn<String> occurredOn = GeneratedColumn<String>(
    'occurred_on',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  late final GeneratedColumnWithTypeConverter<String?, Uint8List> occurrenceId =
      GeneratedColumn<Uint8List>(
        'occurrence_id',
        aliasedName,
        true,
        type: DriftSqlType.blob,
        requiredDuringInsert: false,
      ).withConverter<String?>($MovementsTable.$converteroccurrenceIdn);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    homeId,
    articleId,
    kind,
    quantity,
    occurredOn,
    note,
    occurrenceId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'movements';
  @override
  VerificationContext validateIntegrity(
    Insertable<MovementRow> instance, {
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
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('occurred_on')) {
      context.handle(
        _occurredOnMeta,
        occurredOn.isAcceptableOrUnknown(data['occurred_on']!, _occurredOnMeta),
      );
    } else if (isInserting) {
      context.missing(_occurredOnMeta);
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
  MovementRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MovementRow(
      id: $MovementsTable.$converterid.fromSql(
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
      homeId: $MovementsTable.$converterhomeId.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}home_id'],
        )!,
      ),
      articleId: $MovementsTable.$converterarticleId.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}article_id'],
        )!,
      ),
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quantity'],
      )!,
      occurredOn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}occurred_on'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      )!,
      occurrenceId: $MovementsTable.$converteroccurrenceIdn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}occurrence_id'],
        ),
      ),
    );
  }

  @override
  $MovementsTable createAlias(String alias) {
    return $MovementsTable(attachedDatabase, alias);
  }

  static TypeConverter<String, Uint8List> $converterid = const UuidConverter();
  static TypeConverter<String, Uint8List> $converterhomeId =
      const UuidConverter();
  static TypeConverter<String, Uint8List> $converterarticleId =
      const UuidConverter();
  static TypeConverter<String, Uint8List> $converteroccurrenceId =
      const UuidConverter();
  static TypeConverter<String?, Uint8List?> $converteroccurrenceIdn =
      NullAwareTypeConverter.wrap($converteroccurrenceId);
}

class MovementRow extends DataClass implements Insertable<MovementRow> {
  final String id;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;
  final String homeId;
  final String articleId;
  final String kind;
  final String quantity;
  final String occurredOn;
  final String note;

  /// The occurrence whose closing, or its undoing, wrote this line.
  final String? occurrenceId;
  const MovementRow({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.homeId,
    required this.articleId,
    required this.kind,
    required this.quantity,
    required this.occurredOn,
    required this.note,
    this.occurrenceId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    {
      map['id'] = Variable<Uint8List>($MovementsTable.$converterid.toSql(id));
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    {
      map['home_id'] = Variable<Uint8List>(
        $MovementsTable.$converterhomeId.toSql(homeId),
      );
    }
    {
      map['article_id'] = Variable<Uint8List>(
        $MovementsTable.$converterarticleId.toSql(articleId),
      );
    }
    map['kind'] = Variable<String>(kind);
    map['quantity'] = Variable<String>(quantity);
    map['occurred_on'] = Variable<String>(occurredOn);
    map['note'] = Variable<String>(note);
    if (!nullToAbsent || occurrenceId != null) {
      map['occurrence_id'] = Variable<Uint8List>(
        $MovementsTable.$converteroccurrenceIdn.toSql(occurrenceId),
      );
    }
    return map;
  }

  MovementsCompanion toCompanion(bool nullToAbsent) {
    return MovementsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      homeId: Value(homeId),
      articleId: Value(articleId),
      kind: Value(kind),
      quantity: Value(quantity),
      occurredOn: Value(occurredOn),
      note: Value(note),
      occurrenceId: occurrenceId == null && nullToAbsent
          ? const Value.absent()
          : Value(occurrenceId),
    );
  }

  factory MovementRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MovementRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      homeId: serializer.fromJson<String>(json['homeId']),
      articleId: serializer.fromJson<String>(json['articleId']),
      kind: serializer.fromJson<String>(json['kind']),
      quantity: serializer.fromJson<String>(json['quantity']),
      occurredOn: serializer.fromJson<String>(json['occurredOn']),
      note: serializer.fromJson<String>(json['note']),
      occurrenceId: serializer.fromJson<String?>(json['occurrenceId']),
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
      'articleId': serializer.toJson<String>(articleId),
      'kind': serializer.toJson<String>(kind),
      'quantity': serializer.toJson<String>(quantity),
      'occurredOn': serializer.toJson<String>(occurredOn),
      'note': serializer.toJson<String>(note),
      'occurrenceId': serializer.toJson<String?>(occurrenceId),
    };
  }

  MovementRow copyWith({
    String? id,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    String? homeId,
    String? articleId,
    String? kind,
    String? quantity,
    String? occurredOn,
    String? note,
    Value<String?> occurrenceId = const Value.absent(),
  }) => MovementRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    homeId: homeId ?? this.homeId,
    articleId: articleId ?? this.articleId,
    kind: kind ?? this.kind,
    quantity: quantity ?? this.quantity,
    occurredOn: occurredOn ?? this.occurredOn,
    note: note ?? this.note,
    occurrenceId: occurrenceId.present ? occurrenceId.value : this.occurrenceId,
  );
  MovementRow copyWithCompanion(MovementsCompanion data) {
    return MovementRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      homeId: data.homeId.present ? data.homeId.value : this.homeId,
      articleId: data.articleId.present ? data.articleId.value : this.articleId,
      kind: data.kind.present ? data.kind.value : this.kind,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      occurredOn: data.occurredOn.present
          ? data.occurredOn.value
          : this.occurredOn,
      note: data.note.present ? data.note.value : this.note,
      occurrenceId: data.occurrenceId.present
          ? data.occurrenceId.value
          : this.occurrenceId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MovementRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('homeId: $homeId, ')
          ..write('articleId: $articleId, ')
          ..write('kind: $kind, ')
          ..write('quantity: $quantity, ')
          ..write('occurredOn: $occurredOn, ')
          ..write('note: $note, ')
          ..write('occurrenceId: $occurrenceId')
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
    articleId,
    kind,
    quantity,
    occurredOn,
    note,
    occurrenceId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MovementRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.homeId == this.homeId &&
          other.articleId == this.articleId &&
          other.kind == this.kind &&
          other.quantity == this.quantity &&
          other.occurredOn == this.occurredOn &&
          other.note == this.note &&
          other.occurrenceId == this.occurrenceId);
}

class MovementsCompanion extends UpdateCompanion<MovementRow> {
  final Value<String> id;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<String> homeId;
  final Value<String> articleId;
  final Value<String> kind;
  final Value<String> quantity;
  final Value<String> occurredOn;
  final Value<String> note;
  final Value<String?> occurrenceId;
  final Value<int> rowid;
  const MovementsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.homeId = const Value.absent(),
    this.articleId = const Value.absent(),
    this.kind = const Value.absent(),
    this.quantity = const Value.absent(),
    this.occurredOn = const Value.absent(),
    this.note = const Value.absent(),
    this.occurrenceId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MovementsCompanion.insert({
    required String id,
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    required String homeId,
    required String articleId,
    required String kind,
    required String quantity,
    required String occurredOn,
    this.note = const Value.absent(),
    this.occurrenceId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       homeId = Value(homeId),
       articleId = Value(articleId),
       kind = Value(kind),
       quantity = Value(quantity),
       occurredOn = Value(occurredOn);
  static Insertable<MovementRow> custom({
    Expression<Uint8List>? id,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<Uint8List>? homeId,
    Expression<Uint8List>? articleId,
    Expression<String>? kind,
    Expression<String>? quantity,
    Expression<String>? occurredOn,
    Expression<String>? note,
    Expression<Uint8List>? occurrenceId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (homeId != null) 'home_id': homeId,
      if (articleId != null) 'article_id': articleId,
      if (kind != null) 'kind': kind,
      if (quantity != null) 'quantity': quantity,
      if (occurredOn != null) 'occurred_on': occurredOn,
      if (note != null) 'note': note,
      if (occurrenceId != null) 'occurrence_id': occurrenceId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MovementsCompanion copyWith({
    Value<String>? id,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<String>? homeId,
    Value<String>? articleId,
    Value<String>? kind,
    Value<String>? quantity,
    Value<String>? occurredOn,
    Value<String>? note,
    Value<String?>? occurrenceId,
    Value<int>? rowid,
  }) {
    return MovementsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      homeId: homeId ?? this.homeId,
      articleId: articleId ?? this.articleId,
      kind: kind ?? this.kind,
      quantity: quantity ?? this.quantity,
      occurredOn: occurredOn ?? this.occurredOn,
      note: note ?? this.note,
      occurrenceId: occurrenceId ?? this.occurrenceId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<Uint8List>(
        $MovementsTable.$converterid.toSql(id.value),
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
        $MovementsTable.$converterhomeId.toSql(homeId.value),
      );
    }
    if (articleId.present) {
      map['article_id'] = Variable<Uint8List>(
        $MovementsTable.$converterarticleId.toSql(articleId.value),
      );
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<String>(quantity.value);
    }
    if (occurredOn.present) {
      map['occurred_on'] = Variable<String>(occurredOn.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (occurrenceId.present) {
      map['occurrence_id'] = Variable<Uint8List>(
        $MovementsTable.$converteroccurrenceIdn.toSql(occurrenceId.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MovementsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('homeId: $homeId, ')
          ..write('articleId: $articleId, ')
          ..write('kind: $kind, ')
          ..write('quantity: $quantity, ')
          ..write('occurredOn: $occurredOn, ')
          ..write('note: $note, ')
          ..write('occurrenceId: $occurrenceId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TaskMaterialsTable extends TaskMaterials
    with TableInfo<$TaskMaterialsTable, TaskMaterialRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TaskMaterialsTable(this.attachedDatabase, [this._alias]);
  @override
  late final GeneratedColumnWithTypeConverter<String, Uint8List> id =
      GeneratedColumn<Uint8List>(
        'id',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      ).withConverter<String>($TaskMaterialsTable.$converterid);
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
      ).withConverter<String>($TaskMaterialsTable.$converterhomeId);
  @override
  late final GeneratedColumnWithTypeConverter<String, Uint8List> taskId =
      GeneratedColumn<Uint8List>(
        'task_id',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      ).withConverter<String>($TaskMaterialsTable.$convertertaskId);
  @override
  late final GeneratedColumnWithTypeConverter<String, Uint8List> articleId =
      GeneratedColumn<Uint8List>(
        'article_id',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      ).withConverter<String>($TaskMaterialsTable.$converterarticleId);
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<String> quantity = GeneratedColumn<String>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    homeId,
    taskId,
    articleId,
    quantity,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'task_materials';
  @override
  VerificationContext validateIntegrity(
    Insertable<TaskMaterialRow> instance, {
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
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TaskMaterialRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaskMaterialRow(
      id: $TaskMaterialsTable.$converterid.fromSql(
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
      homeId: $TaskMaterialsTable.$converterhomeId.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}home_id'],
        )!,
      ),
      taskId: $TaskMaterialsTable.$convertertaskId.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}task_id'],
        )!,
      ),
      articleId: $TaskMaterialsTable.$converterarticleId.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}article_id'],
        )!,
      ),
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quantity'],
      )!,
    );
  }

  @override
  $TaskMaterialsTable createAlias(String alias) {
    return $TaskMaterialsTable(attachedDatabase, alias);
  }

  static TypeConverter<String, Uint8List> $converterid = const UuidConverter();
  static TypeConverter<String, Uint8List> $converterhomeId =
      const UuidConverter();
  static TypeConverter<String, Uint8List> $convertertaskId =
      const UuidConverter();
  static TypeConverter<String, Uint8List> $converterarticleId =
      const UuidConverter();
}

class TaskMaterialRow extends DataClass implements Insertable<TaskMaterialRow> {
  final String id;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;
  final String homeId;
  final String taskId;
  final String articleId;
  final String quantity;
  const TaskMaterialRow({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.homeId,
    required this.taskId,
    required this.articleId,
    required this.quantity,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    {
      map['id'] = Variable<Uint8List>(
        $TaskMaterialsTable.$converterid.toSql(id),
      );
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    {
      map['home_id'] = Variable<Uint8List>(
        $TaskMaterialsTable.$converterhomeId.toSql(homeId),
      );
    }
    {
      map['task_id'] = Variable<Uint8List>(
        $TaskMaterialsTable.$convertertaskId.toSql(taskId),
      );
    }
    {
      map['article_id'] = Variable<Uint8List>(
        $TaskMaterialsTable.$converterarticleId.toSql(articleId),
      );
    }
    map['quantity'] = Variable<String>(quantity);
    return map;
  }

  TaskMaterialsCompanion toCompanion(bool nullToAbsent) {
    return TaskMaterialsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      homeId: Value(homeId),
      taskId: Value(taskId),
      articleId: Value(articleId),
      quantity: Value(quantity),
    );
  }

  factory TaskMaterialRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaskMaterialRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      homeId: serializer.fromJson<String>(json['homeId']),
      taskId: serializer.fromJson<String>(json['taskId']),
      articleId: serializer.fromJson<String>(json['articleId']),
      quantity: serializer.fromJson<String>(json['quantity']),
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
      'articleId': serializer.toJson<String>(articleId),
      'quantity': serializer.toJson<String>(quantity),
    };
  }

  TaskMaterialRow copyWith({
    String? id,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    String? homeId,
    String? taskId,
    String? articleId,
    String? quantity,
  }) => TaskMaterialRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    homeId: homeId ?? this.homeId,
    taskId: taskId ?? this.taskId,
    articleId: articleId ?? this.articleId,
    quantity: quantity ?? this.quantity,
  );
  TaskMaterialRow copyWithCompanion(TaskMaterialsCompanion data) {
    return TaskMaterialRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      homeId: data.homeId.present ? data.homeId.value : this.homeId,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      articleId: data.articleId.present ? data.articleId.value : this.articleId,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaskMaterialRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('homeId: $homeId, ')
          ..write('taskId: $taskId, ')
          ..write('articleId: $articleId, ')
          ..write('quantity: $quantity')
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
    articleId,
    quantity,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaskMaterialRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.homeId == this.homeId &&
          other.taskId == this.taskId &&
          other.articleId == this.articleId &&
          other.quantity == this.quantity);
}

class TaskMaterialsCompanion extends UpdateCompanion<TaskMaterialRow> {
  final Value<String> id;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<String> homeId;
  final Value<String> taskId;
  final Value<String> articleId;
  final Value<String> quantity;
  final Value<int> rowid;
  const TaskMaterialsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.homeId = const Value.absent(),
    this.taskId = const Value.absent(),
    this.articleId = const Value.absent(),
    this.quantity = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TaskMaterialsCompanion.insert({
    required String id,
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    required String homeId,
    required String taskId,
    required String articleId,
    required String quantity,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       homeId = Value(homeId),
       taskId = Value(taskId),
       articleId = Value(articleId),
       quantity = Value(quantity);
  static Insertable<TaskMaterialRow> custom({
    Expression<Uint8List>? id,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<Uint8List>? homeId,
    Expression<Uint8List>? taskId,
    Expression<Uint8List>? articleId,
    Expression<String>? quantity,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (homeId != null) 'home_id': homeId,
      if (taskId != null) 'task_id': taskId,
      if (articleId != null) 'article_id': articleId,
      if (quantity != null) 'quantity': quantity,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TaskMaterialsCompanion copyWith({
    Value<String>? id,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<String>? homeId,
    Value<String>? taskId,
    Value<String>? articleId,
    Value<String>? quantity,
    Value<int>? rowid,
  }) {
    return TaskMaterialsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      homeId: homeId ?? this.homeId,
      taskId: taskId ?? this.taskId,
      articleId: articleId ?? this.articleId,
      quantity: quantity ?? this.quantity,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<Uint8List>(
        $TaskMaterialsTable.$converterid.toSql(id.value),
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
        $TaskMaterialsTable.$converterhomeId.toSql(homeId.value),
      );
    }
    if (taskId.present) {
      map['task_id'] = Variable<Uint8List>(
        $TaskMaterialsTable.$convertertaskId.toSql(taskId.value),
      );
    }
    if (articleId.present) {
      map['article_id'] = Variable<Uint8List>(
        $TaskMaterialsTable.$converterarticleId.toSql(articleId.value),
      );
    }
    if (quantity.present) {
      map['quantity'] = Variable<String>(quantity.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TaskMaterialsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('homeId: $homeId, ')
          ..write('taskId: $taskId, ')
          ..write('articleId: $articleId, ')
          ..write('quantity: $quantity, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MaterialDrawsTable extends MaterialDraws
    with TableInfo<$MaterialDrawsTable, MaterialDrawRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MaterialDrawsTable(this.attachedDatabase, [this._alias]);
  @override
  late final GeneratedColumnWithTypeConverter<String, Uint8List> id =
      GeneratedColumn<Uint8List>(
        'id',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      ).withConverter<String>($MaterialDrawsTable.$converterid);
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
      ).withConverter<String>($MaterialDrawsTable.$converterhomeId);
  @override
  late final GeneratedColumnWithTypeConverter<String, Uint8List> occurrenceId =
      GeneratedColumn<Uint8List>(
        'occurrence_id',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      ).withConverter<String>($MaterialDrawsTable.$converteroccurrenceId);
  @override
  late final GeneratedColumnWithTypeConverter<String, Uint8List> articleId =
      GeneratedColumn<Uint8List>(
        'article_id',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      ).withConverter<String>($MaterialDrawsTable.$converterarticleId);
  static const VerificationMeta _wantedMeta = const VerificationMeta('wanted');
  @override
  late final GeneratedColumn<String> wanted = GeneratedColumn<String>(
    'wanted',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _drawnMeta = const VerificationMeta('drawn');
  @override
  late final GeneratedColumn<String> drawn = GeneratedColumn<String>(
    'drawn',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    homeId,
    occurrenceId,
    articleId,
    wanted,
    drawn,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'material_draws';
  @override
  VerificationContext validateIntegrity(
    Insertable<MaterialDrawRow> instance, {
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
    if (data.containsKey('wanted')) {
      context.handle(
        _wantedMeta,
        wanted.isAcceptableOrUnknown(data['wanted']!, _wantedMeta),
      );
    } else if (isInserting) {
      context.missing(_wantedMeta);
    }
    if (data.containsKey('drawn')) {
      context.handle(
        _drawnMeta,
        drawn.isAcceptableOrUnknown(data['drawn']!, _drawnMeta),
      );
    } else if (isInserting) {
      context.missing(_drawnMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MaterialDrawRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MaterialDrawRow(
      id: $MaterialDrawsTable.$converterid.fromSql(
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
      homeId: $MaterialDrawsTable.$converterhomeId.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}home_id'],
        )!,
      ),
      occurrenceId: $MaterialDrawsTable.$converteroccurrenceId.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}occurrence_id'],
        )!,
      ),
      articleId: $MaterialDrawsTable.$converterarticleId.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}article_id'],
        )!,
      ),
      wanted: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}wanted'],
      )!,
      drawn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}drawn'],
      )!,
    );
  }

  @override
  $MaterialDrawsTable createAlias(String alias) {
    return $MaterialDrawsTable(attachedDatabase, alias);
  }

  static TypeConverter<String, Uint8List> $converterid = const UuidConverter();
  static TypeConverter<String, Uint8List> $converterhomeId =
      const UuidConverter();
  static TypeConverter<String, Uint8List> $converteroccurrenceId =
      const UuidConverter();
  static TypeConverter<String, Uint8List> $converterarticleId =
      const UuidConverter();
}

class MaterialDrawRow extends DataClass implements Insertable<MaterialDrawRow> {
  final String id;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;
  final String homeId;
  final String occurrenceId;
  final String articleId;
  final String wanted;
  final String drawn;
  const MaterialDrawRow({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.homeId,
    required this.occurrenceId,
    required this.articleId,
    required this.wanted,
    required this.drawn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    {
      map['id'] = Variable<Uint8List>(
        $MaterialDrawsTable.$converterid.toSql(id),
      );
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    {
      map['home_id'] = Variable<Uint8List>(
        $MaterialDrawsTable.$converterhomeId.toSql(homeId),
      );
    }
    {
      map['occurrence_id'] = Variable<Uint8List>(
        $MaterialDrawsTable.$converteroccurrenceId.toSql(occurrenceId),
      );
    }
    {
      map['article_id'] = Variable<Uint8List>(
        $MaterialDrawsTable.$converterarticleId.toSql(articleId),
      );
    }
    map['wanted'] = Variable<String>(wanted);
    map['drawn'] = Variable<String>(drawn);
    return map;
  }

  MaterialDrawsCompanion toCompanion(bool nullToAbsent) {
    return MaterialDrawsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      homeId: Value(homeId),
      occurrenceId: Value(occurrenceId),
      articleId: Value(articleId),
      wanted: Value(wanted),
      drawn: Value(drawn),
    );
  }

  factory MaterialDrawRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MaterialDrawRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      homeId: serializer.fromJson<String>(json['homeId']),
      occurrenceId: serializer.fromJson<String>(json['occurrenceId']),
      articleId: serializer.fromJson<String>(json['articleId']),
      wanted: serializer.fromJson<String>(json['wanted']),
      drawn: serializer.fromJson<String>(json['drawn']),
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
      'occurrenceId': serializer.toJson<String>(occurrenceId),
      'articleId': serializer.toJson<String>(articleId),
      'wanted': serializer.toJson<String>(wanted),
      'drawn': serializer.toJson<String>(drawn),
    };
  }

  MaterialDrawRow copyWith({
    String? id,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    String? homeId,
    String? occurrenceId,
    String? articleId,
    String? wanted,
    String? drawn,
  }) => MaterialDrawRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    homeId: homeId ?? this.homeId,
    occurrenceId: occurrenceId ?? this.occurrenceId,
    articleId: articleId ?? this.articleId,
    wanted: wanted ?? this.wanted,
    drawn: drawn ?? this.drawn,
  );
  MaterialDrawRow copyWithCompanion(MaterialDrawsCompanion data) {
    return MaterialDrawRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      homeId: data.homeId.present ? data.homeId.value : this.homeId,
      occurrenceId: data.occurrenceId.present
          ? data.occurrenceId.value
          : this.occurrenceId,
      articleId: data.articleId.present ? data.articleId.value : this.articleId,
      wanted: data.wanted.present ? data.wanted.value : this.wanted,
      drawn: data.drawn.present ? data.drawn.value : this.drawn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MaterialDrawRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('homeId: $homeId, ')
          ..write('occurrenceId: $occurrenceId, ')
          ..write('articleId: $articleId, ')
          ..write('wanted: $wanted, ')
          ..write('drawn: $drawn')
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
    occurrenceId,
    articleId,
    wanted,
    drawn,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MaterialDrawRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.homeId == this.homeId &&
          other.occurrenceId == this.occurrenceId &&
          other.articleId == this.articleId &&
          other.wanted == this.wanted &&
          other.drawn == this.drawn);
}

class MaterialDrawsCompanion extends UpdateCompanion<MaterialDrawRow> {
  final Value<String> id;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<String> homeId;
  final Value<String> occurrenceId;
  final Value<String> articleId;
  final Value<String> wanted;
  final Value<String> drawn;
  final Value<int> rowid;
  const MaterialDrawsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.homeId = const Value.absent(),
    this.occurrenceId = const Value.absent(),
    this.articleId = const Value.absent(),
    this.wanted = const Value.absent(),
    this.drawn = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MaterialDrawsCompanion.insert({
    required String id,
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    required String homeId,
    required String occurrenceId,
    required String articleId,
    required String wanted,
    required String drawn,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       homeId = Value(homeId),
       occurrenceId = Value(occurrenceId),
       articleId = Value(articleId),
       wanted = Value(wanted),
       drawn = Value(drawn);
  static Insertable<MaterialDrawRow> custom({
    Expression<Uint8List>? id,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<Uint8List>? homeId,
    Expression<Uint8List>? occurrenceId,
    Expression<Uint8List>? articleId,
    Expression<String>? wanted,
    Expression<String>? drawn,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (homeId != null) 'home_id': homeId,
      if (occurrenceId != null) 'occurrence_id': occurrenceId,
      if (articleId != null) 'article_id': articleId,
      if (wanted != null) 'wanted': wanted,
      if (drawn != null) 'drawn': drawn,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MaterialDrawsCompanion copyWith({
    Value<String>? id,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<String>? homeId,
    Value<String>? occurrenceId,
    Value<String>? articleId,
    Value<String>? wanted,
    Value<String>? drawn,
    Value<int>? rowid,
  }) {
    return MaterialDrawsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      homeId: homeId ?? this.homeId,
      occurrenceId: occurrenceId ?? this.occurrenceId,
      articleId: articleId ?? this.articleId,
      wanted: wanted ?? this.wanted,
      drawn: drawn ?? this.drawn,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<Uint8List>(
        $MaterialDrawsTable.$converterid.toSql(id.value),
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
        $MaterialDrawsTable.$converterhomeId.toSql(homeId.value),
      );
    }
    if (occurrenceId.present) {
      map['occurrence_id'] = Variable<Uint8List>(
        $MaterialDrawsTable.$converteroccurrenceId.toSql(occurrenceId.value),
      );
    }
    if (articleId.present) {
      map['article_id'] = Variable<Uint8List>(
        $MaterialDrawsTable.$converterarticleId.toSql(articleId.value),
      );
    }
    if (wanted.present) {
      map['wanted'] = Variable<String>(wanted.value);
    }
    if (drawn.present) {
      map['drawn'] = Variable<String>(drawn.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MaterialDrawsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('homeId: $homeId, ')
          ..write('occurrenceId: $occurrenceId, ')
          ..write('articleId: $articleId, ')
          ..write('wanted: $wanted, ')
          ..write('drawn: $drawn, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProjectsTable extends Projects
    with TableInfo<$ProjectsTable, ProjectRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProjectsTable(this.attachedDatabase, [this._alias]);
  @override
  late final GeneratedColumnWithTypeConverter<String, Uint8List> id =
      GeneratedColumn<Uint8List>(
        'id',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      ).withConverter<String>($ProjectsTable.$converterid);
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
      ).withConverter<String>($ProjectsTable.$converterhomeId);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _goalMeta = const VerificationMeta('goal');
  @override
  late final GeneratedColumn<String> goal = GeneratedColumn<String>(
    'goal',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('idea'),
  );
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    homeId,
    title,
    goal,
    status,
    priority,
    estimatedMinutes,
    season,
    seasonStartMonth,
    seasonEndMonth,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'projects';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProjectRow> instance, {
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
    if (data.containsKey('goal')) {
      context.handle(
        _goalMeta,
        goal.isAcceptableOrUnknown(data['goal']!, _goalMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProjectRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProjectRow(
      id: $ProjectsTable.$converterid.fromSql(
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
      homeId: $ProjectsTable.$converterhomeId.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}home_id'],
        )!,
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      goal: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}goal'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      priority: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}priority'],
      )!,
      estimatedMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}estimated_minutes'],
      ),
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
    );
  }

  @override
  $ProjectsTable createAlias(String alias) {
    return $ProjectsTable(attachedDatabase, alias);
  }

  static TypeConverter<String, Uint8List> $converterid = const UuidConverter();
  static TypeConverter<String, Uint8List> $converterhomeId =
      const UuidConverter();
}

class ProjectRow extends DataClass implements Insertable<ProjectRow> {
  final String id;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;
  final String homeId;
  final String title;
  final String goal;
  final String status;
  final String priority;
  final int? estimatedMinutes;
  final String season;
  final int? seasonStartMonth;
  final int? seasonEndMonth;
  const ProjectRow({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.homeId,
    required this.title,
    required this.goal,
    required this.status,
    required this.priority,
    this.estimatedMinutes,
    required this.season,
    this.seasonStartMonth,
    this.seasonEndMonth,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    {
      map['id'] = Variable<Uint8List>($ProjectsTable.$converterid.toSql(id));
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    {
      map['home_id'] = Variable<Uint8List>(
        $ProjectsTable.$converterhomeId.toSql(homeId),
      );
    }
    map['title'] = Variable<String>(title);
    map['goal'] = Variable<String>(goal);
    map['status'] = Variable<String>(status);
    map['priority'] = Variable<String>(priority);
    if (!nullToAbsent || estimatedMinutes != null) {
      map['estimated_minutes'] = Variable<int>(estimatedMinutes);
    }
    map['season'] = Variable<String>(season);
    if (!nullToAbsent || seasonStartMonth != null) {
      map['season_start_month'] = Variable<int>(seasonStartMonth);
    }
    if (!nullToAbsent || seasonEndMonth != null) {
      map['season_end_month'] = Variable<int>(seasonEndMonth);
    }
    return map;
  }

  ProjectsCompanion toCompanion(bool nullToAbsent) {
    return ProjectsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      homeId: Value(homeId),
      title: Value(title),
      goal: Value(goal),
      status: Value(status),
      priority: Value(priority),
      estimatedMinutes: estimatedMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(estimatedMinutes),
      season: Value(season),
      seasonStartMonth: seasonStartMonth == null && nullToAbsent
          ? const Value.absent()
          : Value(seasonStartMonth),
      seasonEndMonth: seasonEndMonth == null && nullToAbsent
          ? const Value.absent()
          : Value(seasonEndMonth),
    );
  }

  factory ProjectRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProjectRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      homeId: serializer.fromJson<String>(json['homeId']),
      title: serializer.fromJson<String>(json['title']),
      goal: serializer.fromJson<String>(json['goal']),
      status: serializer.fromJson<String>(json['status']),
      priority: serializer.fromJson<String>(json['priority']),
      estimatedMinutes: serializer.fromJson<int?>(json['estimatedMinutes']),
      season: serializer.fromJson<String>(json['season']),
      seasonStartMonth: serializer.fromJson<int?>(json['seasonStartMonth']),
      seasonEndMonth: serializer.fromJson<int?>(json['seasonEndMonth']),
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
      'goal': serializer.toJson<String>(goal),
      'status': serializer.toJson<String>(status),
      'priority': serializer.toJson<String>(priority),
      'estimatedMinutes': serializer.toJson<int?>(estimatedMinutes),
      'season': serializer.toJson<String>(season),
      'seasonStartMonth': serializer.toJson<int?>(seasonStartMonth),
      'seasonEndMonth': serializer.toJson<int?>(seasonEndMonth),
    };
  }

  ProjectRow copyWith({
    String? id,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    String? homeId,
    String? title,
    String? goal,
    String? status,
    String? priority,
    Value<int?> estimatedMinutes = const Value.absent(),
    String? season,
    Value<int?> seasonStartMonth = const Value.absent(),
    Value<int?> seasonEndMonth = const Value.absent(),
  }) => ProjectRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    homeId: homeId ?? this.homeId,
    title: title ?? this.title,
    goal: goal ?? this.goal,
    status: status ?? this.status,
    priority: priority ?? this.priority,
    estimatedMinutes: estimatedMinutes.present
        ? estimatedMinutes.value
        : this.estimatedMinutes,
    season: season ?? this.season,
    seasonStartMonth: seasonStartMonth.present
        ? seasonStartMonth.value
        : this.seasonStartMonth,
    seasonEndMonth: seasonEndMonth.present
        ? seasonEndMonth.value
        : this.seasonEndMonth,
  );
  ProjectRow copyWithCompanion(ProjectsCompanion data) {
    return ProjectRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      homeId: data.homeId.present ? data.homeId.value : this.homeId,
      title: data.title.present ? data.title.value : this.title,
      goal: data.goal.present ? data.goal.value : this.goal,
      status: data.status.present ? data.status.value : this.status,
      priority: data.priority.present ? data.priority.value : this.priority,
      estimatedMinutes: data.estimatedMinutes.present
          ? data.estimatedMinutes.value
          : this.estimatedMinutes,
      season: data.season.present ? data.season.value : this.season,
      seasonStartMonth: data.seasonStartMonth.present
          ? data.seasonStartMonth.value
          : this.seasonStartMonth,
      seasonEndMonth: data.seasonEndMonth.present
          ? data.seasonEndMonth.value
          : this.seasonEndMonth,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProjectRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('homeId: $homeId, ')
          ..write('title: $title, ')
          ..write('goal: $goal, ')
          ..write('status: $status, ')
          ..write('priority: $priority, ')
          ..write('estimatedMinutes: $estimatedMinutes, ')
          ..write('season: $season, ')
          ..write('seasonStartMonth: $seasonStartMonth, ')
          ..write('seasonEndMonth: $seasonEndMonth')
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
    title,
    goal,
    status,
    priority,
    estimatedMinutes,
    season,
    seasonStartMonth,
    seasonEndMonth,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProjectRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.homeId == this.homeId &&
          other.title == this.title &&
          other.goal == this.goal &&
          other.status == this.status &&
          other.priority == this.priority &&
          other.estimatedMinutes == this.estimatedMinutes &&
          other.season == this.season &&
          other.seasonStartMonth == this.seasonStartMonth &&
          other.seasonEndMonth == this.seasonEndMonth);
}

class ProjectsCompanion extends UpdateCompanion<ProjectRow> {
  final Value<String> id;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<String> homeId;
  final Value<String> title;
  final Value<String> goal;
  final Value<String> status;
  final Value<String> priority;
  final Value<int?> estimatedMinutes;
  final Value<String> season;
  final Value<int?> seasonStartMonth;
  final Value<int?> seasonEndMonth;
  final Value<int> rowid;
  const ProjectsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.homeId = const Value.absent(),
    this.title = const Value.absent(),
    this.goal = const Value.absent(),
    this.status = const Value.absent(),
    this.priority = const Value.absent(),
    this.estimatedMinutes = const Value.absent(),
    this.season = const Value.absent(),
    this.seasonStartMonth = const Value.absent(),
    this.seasonEndMonth = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProjectsCompanion.insert({
    required String id,
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    required String homeId,
    required String title,
    this.goal = const Value.absent(),
    this.status = const Value.absent(),
    this.priority = const Value.absent(),
    this.estimatedMinutes = const Value.absent(),
    this.season = const Value.absent(),
    this.seasonStartMonth = const Value.absent(),
    this.seasonEndMonth = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       homeId = Value(homeId),
       title = Value(title);
  static Insertable<ProjectRow> custom({
    Expression<Uint8List>? id,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<Uint8List>? homeId,
    Expression<String>? title,
    Expression<String>? goal,
    Expression<String>? status,
    Expression<String>? priority,
    Expression<int>? estimatedMinutes,
    Expression<String>? season,
    Expression<int>? seasonStartMonth,
    Expression<int>? seasonEndMonth,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (homeId != null) 'home_id': homeId,
      if (title != null) 'title': title,
      if (goal != null) 'goal': goal,
      if (status != null) 'status': status,
      if (priority != null) 'priority': priority,
      if (estimatedMinutes != null) 'estimated_minutes': estimatedMinutes,
      if (season != null) 'season': season,
      if (seasonStartMonth != null) 'season_start_month': seasonStartMonth,
      if (seasonEndMonth != null) 'season_end_month': seasonEndMonth,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProjectsCompanion copyWith({
    Value<String>? id,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<String>? homeId,
    Value<String>? title,
    Value<String>? goal,
    Value<String>? status,
    Value<String>? priority,
    Value<int?>? estimatedMinutes,
    Value<String>? season,
    Value<int?>? seasonStartMonth,
    Value<int?>? seasonEndMonth,
    Value<int>? rowid,
  }) {
    return ProjectsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      homeId: homeId ?? this.homeId,
      title: title ?? this.title,
      goal: goal ?? this.goal,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      season: season ?? this.season,
      seasonStartMonth: seasonStartMonth ?? this.seasonStartMonth,
      seasonEndMonth: seasonEndMonth ?? this.seasonEndMonth,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<Uint8List>(
        $ProjectsTable.$converterid.toSql(id.value),
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
        $ProjectsTable.$converterhomeId.toSql(homeId.value),
      );
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (goal.present) {
      map['goal'] = Variable<String>(goal.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (priority.present) {
      map['priority'] = Variable<String>(priority.value);
    }
    if (estimatedMinutes.present) {
      map['estimated_minutes'] = Variable<int>(estimatedMinutes.value);
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
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProjectsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('homeId: $homeId, ')
          ..write('title: $title, ')
          ..write('goal: $goal, ')
          ..write('status: $status, ')
          ..write('priority: $priority, ')
          ..write('estimatedMinutes: $estimatedMinutes, ')
          ..write('season: $season, ')
          ..write('seasonStartMonth: $seasonStartMonth, ')
          ..write('seasonEndMonth: $seasonEndMonth, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProjectRoomsTable extends ProjectRooms
    with TableInfo<$ProjectRoomsTable, ProjectRoomRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProjectRoomsTable(this.attachedDatabase, [this._alias]);
  @override
  late final GeneratedColumnWithTypeConverter<String, Uint8List> id =
      GeneratedColumn<Uint8List>(
        'id',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      ).withConverter<String>($ProjectRoomsTable.$converterid);
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
      ).withConverter<String>($ProjectRoomsTable.$converterhomeId);
  @override
  late final GeneratedColumnWithTypeConverter<String, Uint8List> projectId =
      GeneratedColumn<Uint8List>(
        'project_id',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      ).withConverter<String>($ProjectRoomsTable.$converterprojectId);
  @override
  late final GeneratedColumnWithTypeConverter<String, Uint8List> roomId =
      GeneratedColumn<Uint8List>(
        'room_id',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      ).withConverter<String>($ProjectRoomsTable.$converterroomId);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    homeId,
    projectId,
    roomId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'project_rooms';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProjectRoomRow> instance, {
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProjectRoomRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProjectRoomRow(
      id: $ProjectRoomsTable.$converterid.fromSql(
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
      homeId: $ProjectRoomsTable.$converterhomeId.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}home_id'],
        )!,
      ),
      projectId: $ProjectRoomsTable.$converterprojectId.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}project_id'],
        )!,
      ),
      roomId: $ProjectRoomsTable.$converterroomId.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}room_id'],
        )!,
      ),
    );
  }

  @override
  $ProjectRoomsTable createAlias(String alias) {
    return $ProjectRoomsTable(attachedDatabase, alias);
  }

  static TypeConverter<String, Uint8List> $converterid = const UuidConverter();
  static TypeConverter<String, Uint8List> $converterhomeId =
      const UuidConverter();
  static TypeConverter<String, Uint8List> $converterprojectId =
      const UuidConverter();
  static TypeConverter<String, Uint8List> $converterroomId =
      const UuidConverter();
}

class ProjectRoomRow extends DataClass implements Insertable<ProjectRoomRow> {
  final String id;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;
  final String homeId;
  final String projectId;
  final String roomId;
  const ProjectRoomRow({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.homeId,
    required this.projectId,
    required this.roomId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    {
      map['id'] = Variable<Uint8List>(
        $ProjectRoomsTable.$converterid.toSql(id),
      );
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    {
      map['home_id'] = Variable<Uint8List>(
        $ProjectRoomsTable.$converterhomeId.toSql(homeId),
      );
    }
    {
      map['project_id'] = Variable<Uint8List>(
        $ProjectRoomsTable.$converterprojectId.toSql(projectId),
      );
    }
    {
      map['room_id'] = Variable<Uint8List>(
        $ProjectRoomsTable.$converterroomId.toSql(roomId),
      );
    }
    return map;
  }

  ProjectRoomsCompanion toCompanion(bool nullToAbsent) {
    return ProjectRoomsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      homeId: Value(homeId),
      projectId: Value(projectId),
      roomId: Value(roomId),
    );
  }

  factory ProjectRoomRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProjectRoomRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      homeId: serializer.fromJson<String>(json['homeId']),
      projectId: serializer.fromJson<String>(json['projectId']),
      roomId: serializer.fromJson<String>(json['roomId']),
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
      'projectId': serializer.toJson<String>(projectId),
      'roomId': serializer.toJson<String>(roomId),
    };
  }

  ProjectRoomRow copyWith({
    String? id,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    String? homeId,
    String? projectId,
    String? roomId,
  }) => ProjectRoomRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    homeId: homeId ?? this.homeId,
    projectId: projectId ?? this.projectId,
    roomId: roomId ?? this.roomId,
  );
  ProjectRoomRow copyWithCompanion(ProjectRoomsCompanion data) {
    return ProjectRoomRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      homeId: data.homeId.present ? data.homeId.value : this.homeId,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      roomId: data.roomId.present ? data.roomId.value : this.roomId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProjectRoomRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('homeId: $homeId, ')
          ..write('projectId: $projectId, ')
          ..write('roomId: $roomId')
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
    projectId,
    roomId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProjectRoomRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.homeId == this.homeId &&
          other.projectId == this.projectId &&
          other.roomId == this.roomId);
}

class ProjectRoomsCompanion extends UpdateCompanion<ProjectRoomRow> {
  final Value<String> id;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<String> homeId;
  final Value<String> projectId;
  final Value<String> roomId;
  final Value<int> rowid;
  const ProjectRoomsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.homeId = const Value.absent(),
    this.projectId = const Value.absent(),
    this.roomId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProjectRoomsCompanion.insert({
    required String id,
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    required String homeId,
    required String projectId,
    required String roomId,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       homeId = Value(homeId),
       projectId = Value(projectId),
       roomId = Value(roomId);
  static Insertable<ProjectRoomRow> custom({
    Expression<Uint8List>? id,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<Uint8List>? homeId,
    Expression<Uint8List>? projectId,
    Expression<Uint8List>? roomId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (homeId != null) 'home_id': homeId,
      if (projectId != null) 'project_id': projectId,
      if (roomId != null) 'room_id': roomId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProjectRoomsCompanion copyWith({
    Value<String>? id,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<String>? homeId,
    Value<String>? projectId,
    Value<String>? roomId,
    Value<int>? rowid,
  }) {
    return ProjectRoomsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      homeId: homeId ?? this.homeId,
      projectId: projectId ?? this.projectId,
      roomId: roomId ?? this.roomId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<Uint8List>(
        $ProjectRoomsTable.$converterid.toSql(id.value),
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
        $ProjectRoomsTable.$converterhomeId.toSql(homeId.value),
      );
    }
    if (projectId.present) {
      map['project_id'] = Variable<Uint8List>(
        $ProjectRoomsTable.$converterprojectId.toSql(projectId.value),
      );
    }
    if (roomId.present) {
      map['room_id'] = Variable<Uint8List>(
        $ProjectRoomsTable.$converterroomId.toSql(roomId.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProjectRoomsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('homeId: $homeId, ')
          ..write('projectId: $projectId, ')
          ..write('roomId: $roomId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BudgetLinesTable extends BudgetLines
    with TableInfo<$BudgetLinesTable, BudgetLineRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BudgetLinesTable(this.attachedDatabase, [this._alias]);
  @override
  late final GeneratedColumnWithTypeConverter<String, Uint8List> id =
      GeneratedColumn<Uint8List>(
        'id',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      ).withConverter<String>($BudgetLinesTable.$converterid);
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
      ).withConverter<String>($BudgetLinesTable.$converterhomeId);
  @override
  late final GeneratedColumnWithTypeConverter<String, Uint8List> projectId =
      GeneratedColumn<Uint8List>(
        'project_id',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      ).withConverter<String>($BudgetLinesTable.$converterprojectId);
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _natureMeta = const VerificationMeta('nature');
  @override
  late final GeneratedColumn<String> nature = GeneratedColumn<String>(
    'nature',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('other'),
  );
  static const VerificationMeta _plannedMeta = const VerificationMeta(
    'planned',
  );
  @override
  late final GeneratedColumn<String> planned = GeneratedColumn<String>(
    'planned',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('0.00'),
  );
  static const VerificationMeta _paidMeta = const VerificationMeta('paid');
  @override
  late final GeneratedColumn<String> paid = GeneratedColumn<String>(
    'paid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('0.00'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    homeId,
    projectId,
    label,
    nature,
    planned,
    paid,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'budget_lines';
  @override
  VerificationContext validateIntegrity(
    Insertable<BudgetLineRow> instance, {
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
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('nature')) {
      context.handle(
        _natureMeta,
        nature.isAcceptableOrUnknown(data['nature']!, _natureMeta),
      );
    }
    if (data.containsKey('planned')) {
      context.handle(
        _plannedMeta,
        planned.isAcceptableOrUnknown(data['planned']!, _plannedMeta),
      );
    }
    if (data.containsKey('paid')) {
      context.handle(
        _paidMeta,
        paid.isAcceptableOrUnknown(data['paid']!, _paidMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BudgetLineRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BudgetLineRow(
      id: $BudgetLinesTable.$converterid.fromSql(
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
      homeId: $BudgetLinesTable.$converterhomeId.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}home_id'],
        )!,
      ),
      projectId: $BudgetLinesTable.$converterprojectId.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}project_id'],
        )!,
      ),
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      nature: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nature'],
      )!,
      planned: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}planned'],
      )!,
      paid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}paid'],
      )!,
    );
  }

  @override
  $BudgetLinesTable createAlias(String alias) {
    return $BudgetLinesTable(attachedDatabase, alias);
  }

  static TypeConverter<String, Uint8List> $converterid = const UuidConverter();
  static TypeConverter<String, Uint8List> $converterhomeId =
      const UuidConverter();
  static TypeConverter<String, Uint8List> $converterprojectId =
      const UuidConverter();
}

class BudgetLineRow extends DataClass implements Insertable<BudgetLineRow> {
  final String id;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;
  final String homeId;
  final String projectId;
  final String label;
  final String nature;
  final String planned;
  final String paid;
  const BudgetLineRow({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.homeId,
    required this.projectId,
    required this.label,
    required this.nature,
    required this.planned,
    required this.paid,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    {
      map['id'] = Variable<Uint8List>($BudgetLinesTable.$converterid.toSql(id));
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    {
      map['home_id'] = Variable<Uint8List>(
        $BudgetLinesTable.$converterhomeId.toSql(homeId),
      );
    }
    {
      map['project_id'] = Variable<Uint8List>(
        $BudgetLinesTable.$converterprojectId.toSql(projectId),
      );
    }
    map['label'] = Variable<String>(label);
    map['nature'] = Variable<String>(nature);
    map['planned'] = Variable<String>(planned);
    map['paid'] = Variable<String>(paid);
    return map;
  }

  BudgetLinesCompanion toCompanion(bool nullToAbsent) {
    return BudgetLinesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      homeId: Value(homeId),
      projectId: Value(projectId),
      label: Value(label),
      nature: Value(nature),
      planned: Value(planned),
      paid: Value(paid),
    );
  }

  factory BudgetLineRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BudgetLineRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      homeId: serializer.fromJson<String>(json['homeId']),
      projectId: serializer.fromJson<String>(json['projectId']),
      label: serializer.fromJson<String>(json['label']),
      nature: serializer.fromJson<String>(json['nature']),
      planned: serializer.fromJson<String>(json['planned']),
      paid: serializer.fromJson<String>(json['paid']),
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
      'projectId': serializer.toJson<String>(projectId),
      'label': serializer.toJson<String>(label),
      'nature': serializer.toJson<String>(nature),
      'planned': serializer.toJson<String>(planned),
      'paid': serializer.toJson<String>(paid),
    };
  }

  BudgetLineRow copyWith({
    String? id,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    String? homeId,
    String? projectId,
    String? label,
    String? nature,
    String? planned,
    String? paid,
  }) => BudgetLineRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    homeId: homeId ?? this.homeId,
    projectId: projectId ?? this.projectId,
    label: label ?? this.label,
    nature: nature ?? this.nature,
    planned: planned ?? this.planned,
    paid: paid ?? this.paid,
  );
  BudgetLineRow copyWithCompanion(BudgetLinesCompanion data) {
    return BudgetLineRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      homeId: data.homeId.present ? data.homeId.value : this.homeId,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      label: data.label.present ? data.label.value : this.label,
      nature: data.nature.present ? data.nature.value : this.nature,
      planned: data.planned.present ? data.planned.value : this.planned,
      paid: data.paid.present ? data.paid.value : this.paid,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BudgetLineRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('homeId: $homeId, ')
          ..write('projectId: $projectId, ')
          ..write('label: $label, ')
          ..write('nature: $nature, ')
          ..write('planned: $planned, ')
          ..write('paid: $paid')
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
    projectId,
    label,
    nature,
    planned,
    paid,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BudgetLineRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.homeId == this.homeId &&
          other.projectId == this.projectId &&
          other.label == this.label &&
          other.nature == this.nature &&
          other.planned == this.planned &&
          other.paid == this.paid);
}

class BudgetLinesCompanion extends UpdateCompanion<BudgetLineRow> {
  final Value<String> id;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<String> homeId;
  final Value<String> projectId;
  final Value<String> label;
  final Value<String> nature;
  final Value<String> planned;
  final Value<String> paid;
  final Value<int> rowid;
  const BudgetLinesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.homeId = const Value.absent(),
    this.projectId = const Value.absent(),
    this.label = const Value.absent(),
    this.nature = const Value.absent(),
    this.planned = const Value.absent(),
    this.paid = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BudgetLinesCompanion.insert({
    required String id,
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    required String homeId,
    required String projectId,
    required String label,
    this.nature = const Value.absent(),
    this.planned = const Value.absent(),
    this.paid = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       homeId = Value(homeId),
       projectId = Value(projectId),
       label = Value(label);
  static Insertable<BudgetLineRow> custom({
    Expression<Uint8List>? id,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<Uint8List>? homeId,
    Expression<Uint8List>? projectId,
    Expression<String>? label,
    Expression<String>? nature,
    Expression<String>? planned,
    Expression<String>? paid,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (homeId != null) 'home_id': homeId,
      if (projectId != null) 'project_id': projectId,
      if (label != null) 'label': label,
      if (nature != null) 'nature': nature,
      if (planned != null) 'planned': planned,
      if (paid != null) 'paid': paid,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BudgetLinesCompanion copyWith({
    Value<String>? id,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<String>? homeId,
    Value<String>? projectId,
    Value<String>? label,
    Value<String>? nature,
    Value<String>? planned,
    Value<String>? paid,
    Value<int>? rowid,
  }) {
    return BudgetLinesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      homeId: homeId ?? this.homeId,
      projectId: projectId ?? this.projectId,
      label: label ?? this.label,
      nature: nature ?? this.nature,
      planned: planned ?? this.planned,
      paid: paid ?? this.paid,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<Uint8List>(
        $BudgetLinesTable.$converterid.toSql(id.value),
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
        $BudgetLinesTable.$converterhomeId.toSql(homeId.value),
      );
    }
    if (projectId.present) {
      map['project_id'] = Variable<Uint8List>(
        $BudgetLinesTable.$converterprojectId.toSql(projectId.value),
      );
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (nature.present) {
      map['nature'] = Variable<String>(nature.value);
    }
    if (planned.present) {
      map['planned'] = Variable<String>(planned.value);
    }
    if (paid.present) {
      map['paid'] = Variable<String>(paid.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BudgetLinesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('homeId: $homeId, ')
          ..write('projectId: $projectId, ')
          ..write('label: $label, ')
          ..write('nature: $nature, ')
          ..write('planned: $planned, ')
          ..write('paid: $paid, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $QuotesTable extends Quotes with TableInfo<$QuotesTable, QuoteRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QuotesTable(this.attachedDatabase, [this._alias]);
  @override
  late final GeneratedColumnWithTypeConverter<String, Uint8List> id =
      GeneratedColumn<Uint8List>(
        'id',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      ).withConverter<String>($QuotesTable.$converterid);
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
      ).withConverter<String>($QuotesTable.$converterhomeId);
  @override
  late final GeneratedColumnWithTypeConverter<String, Uint8List> projectId =
      GeneratedColumn<Uint8List>(
        'project_id',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      ).withConverter<String>($QuotesTable.$converterprojectId);
  @override
  late final GeneratedColumnWithTypeConverter<String?, Uint8List> contractorId =
      GeneratedColumn<Uint8List>(
        'contractor_id',
        aliasedName,
        true,
        type: DriftSqlType.blob,
        requiredDuringInsert: false,
      ).withConverter<String?>($QuotesTable.$convertercontractorIdn);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<String> amount = GeneratedColumn<String>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('0.00'),
  );
  static const VerificationMeta _issuedOnMeta = const VerificationMeta(
    'issuedOn',
  );
  @override
  late final GeneratedColumn<String> issuedOn = GeneratedColumn<String>(
    'issued_on',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _validUntilMeta = const VerificationMeta(
    'validUntil',
  );
  @override
  late final GeneratedColumn<String> validUntil = GeneratedColumn<String>(
    'valid_until',
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
    defaultValue: const Constant('requested'),
  );
  @override
  late final GeneratedColumnWithTypeConverter<String?, Uint8List> budgetLineId =
      GeneratedColumn<Uint8List>(
        'budget_line_id',
        aliasedName,
        true,
        type: DriftSqlType.blob,
        requiredDuringInsert: false,
      ).withConverter<String?>($QuotesTable.$converterbudgetLineIdn);
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
    projectId,
    contractorId,
    amount,
    issuedOn,
    validUntil,
    status,
    budgetLineId,
    note,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'quotes';
  @override
  VerificationContext validateIntegrity(
    Insertable<QuoteRow> instance, {
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
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    }
    if (data.containsKey('issued_on')) {
      context.handle(
        _issuedOnMeta,
        issuedOn.isAcceptableOrUnknown(data['issued_on']!, _issuedOnMeta),
      );
    }
    if (data.containsKey('valid_until')) {
      context.handle(
        _validUntilMeta,
        validUntil.isAcceptableOrUnknown(data['valid_until']!, _validUntilMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
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
  QuoteRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QuoteRow(
      id: $QuotesTable.$converterid.fromSql(
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
      homeId: $QuotesTable.$converterhomeId.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}home_id'],
        )!,
      ),
      projectId: $QuotesTable.$converterprojectId.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}project_id'],
        )!,
      ),
      contractorId: $QuotesTable.$convertercontractorIdn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}contractor_id'],
        ),
      ),
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}amount'],
      )!,
      issuedOn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}issued_on'],
      ),
      validUntil: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}valid_until'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      budgetLineId: $QuotesTable.$converterbudgetLineIdn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}budget_line_id'],
        ),
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      )!,
    );
  }

  @override
  $QuotesTable createAlias(String alias) {
    return $QuotesTable(attachedDatabase, alias);
  }

  static TypeConverter<String, Uint8List> $converterid = const UuidConverter();
  static TypeConverter<String, Uint8List> $converterhomeId =
      const UuidConverter();
  static TypeConverter<String, Uint8List> $converterprojectId =
      const UuidConverter();
  static TypeConverter<String, Uint8List> $convertercontractorId =
      const UuidConverter();
  static TypeConverter<String?, Uint8List?> $convertercontractorIdn =
      NullAwareTypeConverter.wrap($convertercontractorId);
  static TypeConverter<String, Uint8List> $converterbudgetLineId =
      const UuidConverter();
  static TypeConverter<String?, Uint8List?> $converterbudgetLineIdn =
      NullAwareTypeConverter.wrap($converterbudgetLineId);
}

class QuoteRow extends DataClass implements Insertable<QuoteRow> {
  final String id;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;
  final String homeId;
  final String projectId;
  final String? contractorId;
  final String amount;
  final String? issuedOn;
  final String? validUntil;
  final String status;
  final String? budgetLineId;
  final String note;
  const QuoteRow({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.homeId,
    required this.projectId,
    this.contractorId,
    required this.amount,
    this.issuedOn,
    this.validUntil,
    required this.status,
    this.budgetLineId,
    required this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    {
      map['id'] = Variable<Uint8List>($QuotesTable.$converterid.toSql(id));
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    {
      map['home_id'] = Variable<Uint8List>(
        $QuotesTable.$converterhomeId.toSql(homeId),
      );
    }
    {
      map['project_id'] = Variable<Uint8List>(
        $QuotesTable.$converterprojectId.toSql(projectId),
      );
    }
    if (!nullToAbsent || contractorId != null) {
      map['contractor_id'] = Variable<Uint8List>(
        $QuotesTable.$convertercontractorIdn.toSql(contractorId),
      );
    }
    map['amount'] = Variable<String>(amount);
    if (!nullToAbsent || issuedOn != null) {
      map['issued_on'] = Variable<String>(issuedOn);
    }
    if (!nullToAbsent || validUntil != null) {
      map['valid_until'] = Variable<String>(validUntil);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || budgetLineId != null) {
      map['budget_line_id'] = Variable<Uint8List>(
        $QuotesTable.$converterbudgetLineIdn.toSql(budgetLineId),
      );
    }
    map['note'] = Variable<String>(note);
    return map;
  }

  QuotesCompanion toCompanion(bool nullToAbsent) {
    return QuotesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      homeId: Value(homeId),
      projectId: Value(projectId),
      contractorId: contractorId == null && nullToAbsent
          ? const Value.absent()
          : Value(contractorId),
      amount: Value(amount),
      issuedOn: issuedOn == null && nullToAbsent
          ? const Value.absent()
          : Value(issuedOn),
      validUntil: validUntil == null && nullToAbsent
          ? const Value.absent()
          : Value(validUntil),
      status: Value(status),
      budgetLineId: budgetLineId == null && nullToAbsent
          ? const Value.absent()
          : Value(budgetLineId),
      note: Value(note),
    );
  }

  factory QuoteRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QuoteRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      homeId: serializer.fromJson<String>(json['homeId']),
      projectId: serializer.fromJson<String>(json['projectId']),
      contractorId: serializer.fromJson<String?>(json['contractorId']),
      amount: serializer.fromJson<String>(json['amount']),
      issuedOn: serializer.fromJson<String?>(json['issuedOn']),
      validUntil: serializer.fromJson<String?>(json['validUntil']),
      status: serializer.fromJson<String>(json['status']),
      budgetLineId: serializer.fromJson<String?>(json['budgetLineId']),
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
      'projectId': serializer.toJson<String>(projectId),
      'contractorId': serializer.toJson<String?>(contractorId),
      'amount': serializer.toJson<String>(amount),
      'issuedOn': serializer.toJson<String?>(issuedOn),
      'validUntil': serializer.toJson<String?>(validUntil),
      'status': serializer.toJson<String>(status),
      'budgetLineId': serializer.toJson<String?>(budgetLineId),
      'note': serializer.toJson<String>(note),
    };
  }

  QuoteRow copyWith({
    String? id,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    String? homeId,
    String? projectId,
    Value<String?> contractorId = const Value.absent(),
    String? amount,
    Value<String?> issuedOn = const Value.absent(),
    Value<String?> validUntil = const Value.absent(),
    String? status,
    Value<String?> budgetLineId = const Value.absent(),
    String? note,
  }) => QuoteRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    homeId: homeId ?? this.homeId,
    projectId: projectId ?? this.projectId,
    contractorId: contractorId.present ? contractorId.value : this.contractorId,
    amount: amount ?? this.amount,
    issuedOn: issuedOn.present ? issuedOn.value : this.issuedOn,
    validUntil: validUntil.present ? validUntil.value : this.validUntil,
    status: status ?? this.status,
    budgetLineId: budgetLineId.present ? budgetLineId.value : this.budgetLineId,
    note: note ?? this.note,
  );
  QuoteRow copyWithCompanion(QuotesCompanion data) {
    return QuoteRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      homeId: data.homeId.present ? data.homeId.value : this.homeId,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      contractorId: data.contractorId.present
          ? data.contractorId.value
          : this.contractorId,
      amount: data.amount.present ? data.amount.value : this.amount,
      issuedOn: data.issuedOn.present ? data.issuedOn.value : this.issuedOn,
      validUntil: data.validUntil.present
          ? data.validUntil.value
          : this.validUntil,
      status: data.status.present ? data.status.value : this.status,
      budgetLineId: data.budgetLineId.present
          ? data.budgetLineId.value
          : this.budgetLineId,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QuoteRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('homeId: $homeId, ')
          ..write('projectId: $projectId, ')
          ..write('contractorId: $contractorId, ')
          ..write('amount: $amount, ')
          ..write('issuedOn: $issuedOn, ')
          ..write('validUntil: $validUntil, ')
          ..write('status: $status, ')
          ..write('budgetLineId: $budgetLineId, ')
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
    projectId,
    contractorId,
    amount,
    issuedOn,
    validUntil,
    status,
    budgetLineId,
    note,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QuoteRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.homeId == this.homeId &&
          other.projectId == this.projectId &&
          other.contractorId == this.contractorId &&
          other.amount == this.amount &&
          other.issuedOn == this.issuedOn &&
          other.validUntil == this.validUntil &&
          other.status == this.status &&
          other.budgetLineId == this.budgetLineId &&
          other.note == this.note);
}

class QuotesCompanion extends UpdateCompanion<QuoteRow> {
  final Value<String> id;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<String> homeId;
  final Value<String> projectId;
  final Value<String?> contractorId;
  final Value<String> amount;
  final Value<String?> issuedOn;
  final Value<String?> validUntil;
  final Value<String> status;
  final Value<String?> budgetLineId;
  final Value<String> note;
  final Value<int> rowid;
  const QuotesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.homeId = const Value.absent(),
    this.projectId = const Value.absent(),
    this.contractorId = const Value.absent(),
    this.amount = const Value.absent(),
    this.issuedOn = const Value.absent(),
    this.validUntil = const Value.absent(),
    this.status = const Value.absent(),
    this.budgetLineId = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  QuotesCompanion.insert({
    required String id,
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    required String homeId,
    required String projectId,
    this.contractorId = const Value.absent(),
    this.amount = const Value.absent(),
    this.issuedOn = const Value.absent(),
    this.validUntil = const Value.absent(),
    this.status = const Value.absent(),
    this.budgetLineId = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       homeId = Value(homeId),
       projectId = Value(projectId);
  static Insertable<QuoteRow> custom({
    Expression<Uint8List>? id,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<Uint8List>? homeId,
    Expression<Uint8List>? projectId,
    Expression<Uint8List>? contractorId,
    Expression<String>? amount,
    Expression<String>? issuedOn,
    Expression<String>? validUntil,
    Expression<String>? status,
    Expression<Uint8List>? budgetLineId,
    Expression<String>? note,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (homeId != null) 'home_id': homeId,
      if (projectId != null) 'project_id': projectId,
      if (contractorId != null) 'contractor_id': contractorId,
      if (amount != null) 'amount': amount,
      if (issuedOn != null) 'issued_on': issuedOn,
      if (validUntil != null) 'valid_until': validUntil,
      if (status != null) 'status': status,
      if (budgetLineId != null) 'budget_line_id': budgetLineId,
      if (note != null) 'note': note,
      if (rowid != null) 'rowid': rowid,
    });
  }

  QuotesCompanion copyWith({
    Value<String>? id,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<String>? homeId,
    Value<String>? projectId,
    Value<String?>? contractorId,
    Value<String>? amount,
    Value<String?>? issuedOn,
    Value<String?>? validUntil,
    Value<String>? status,
    Value<String?>? budgetLineId,
    Value<String>? note,
    Value<int>? rowid,
  }) {
    return QuotesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      homeId: homeId ?? this.homeId,
      projectId: projectId ?? this.projectId,
      contractorId: contractorId ?? this.contractorId,
      amount: amount ?? this.amount,
      issuedOn: issuedOn ?? this.issuedOn,
      validUntil: validUntil ?? this.validUntil,
      status: status ?? this.status,
      budgetLineId: budgetLineId ?? this.budgetLineId,
      note: note ?? this.note,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<Uint8List>(
        $QuotesTable.$converterid.toSql(id.value),
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
        $QuotesTable.$converterhomeId.toSql(homeId.value),
      );
    }
    if (projectId.present) {
      map['project_id'] = Variable<Uint8List>(
        $QuotesTable.$converterprojectId.toSql(projectId.value),
      );
    }
    if (contractorId.present) {
      map['contractor_id'] = Variable<Uint8List>(
        $QuotesTable.$convertercontractorIdn.toSql(contractorId.value),
      );
    }
    if (amount.present) {
      map['amount'] = Variable<String>(amount.value);
    }
    if (issuedOn.present) {
      map['issued_on'] = Variable<String>(issuedOn.value);
    }
    if (validUntil.present) {
      map['valid_until'] = Variable<String>(validUntil.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (budgetLineId.present) {
      map['budget_line_id'] = Variable<Uint8List>(
        $QuotesTable.$converterbudgetLineIdn.toSql(budgetLineId.value),
      );
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
    return (StringBuffer('QuotesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('homeId: $homeId, ')
          ..write('projectId: $projectId, ')
          ..write('contractorId: $contractorId, ')
          ..write('amount: $amount, ')
          ..write('issuedOn: $issuedOn, ')
          ..write('validUntil: $validUntil, ')
          ..write('status: $status, ')
          ..write('budgetLineId: $budgetLineId, ')
          ..write('note: $note, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProjectFilesTable extends ProjectFiles
    with TableInfo<$ProjectFilesTable, ProjectFileRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProjectFilesTable(this.attachedDatabase, [this._alias]);
  @override
  late final GeneratedColumnWithTypeConverter<String, Uint8List> id =
      GeneratedColumn<Uint8List>(
        'id',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      ).withConverter<String>($ProjectFilesTable.$converterid);
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
      ).withConverter<String>($ProjectFilesTable.$converterhomeId);
  @override
  late final GeneratedColumnWithTypeConverter<String, Uint8List> projectId =
      GeneratedColumn<Uint8List>(
        'project_id',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      ).withConverter<String>($ProjectFilesTable.$converterprojectId);
  @override
  late final GeneratedColumnWithTypeConverter<String?, Uint8List> quoteId =
      GeneratedColumn<Uint8List>(
        'quote_id',
        aliasedName,
        true,
        type: DriftSqlType.blob,
        requiredDuringInsert: false,
      ).withConverter<String?>($ProjectFilesTable.$converterquoteIdn);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fileMeta = const VerificationMeta('file');
  @override
  late final GeneratedColumn<String> file = GeneratedColumn<String>(
    'file',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _contentTypeMeta = const VerificationMeta(
    'contentType',
  );
  @override
  late final GeneratedColumn<String> contentType = GeneratedColumn<String>(
    'content_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _isImageMeta = const VerificationMeta(
    'isImage',
  );
  @override
  late final GeneratedColumn<bool> isImage = GeneratedColumn<bool>(
    'is_image',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_image" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _sizeBytesMeta = const VerificationMeta(
    'sizeBytes',
  );
  @override
  late final GeneratedColumn<int> sizeBytes = GeneratedColumn<int>(
    'size_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    homeId,
    projectId,
    quoteId,
    name,
    file,
    contentType,
    isImage,
    sizeBytes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'project_files';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProjectFileRow> instance, {
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
    if (data.containsKey('file')) {
      context.handle(
        _fileMeta,
        file.isAcceptableOrUnknown(data['file']!, _fileMeta),
      );
    }
    if (data.containsKey('content_type')) {
      context.handle(
        _contentTypeMeta,
        contentType.isAcceptableOrUnknown(
          data['content_type']!,
          _contentTypeMeta,
        ),
      );
    }
    if (data.containsKey('is_image')) {
      context.handle(
        _isImageMeta,
        isImage.isAcceptableOrUnknown(data['is_image']!, _isImageMeta),
      );
    }
    if (data.containsKey('size_bytes')) {
      context.handle(
        _sizeBytesMeta,
        sizeBytes.isAcceptableOrUnknown(data['size_bytes']!, _sizeBytesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProjectFileRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProjectFileRow(
      id: $ProjectFilesTable.$converterid.fromSql(
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
      homeId: $ProjectFilesTable.$converterhomeId.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}home_id'],
        )!,
      ),
      projectId: $ProjectFilesTable.$converterprojectId.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}project_id'],
        )!,
      ),
      quoteId: $ProjectFilesTable.$converterquoteIdn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}quote_id'],
        ),
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      file: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file'],
      ),
      contentType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_type'],
      )!,
      isImage: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_image'],
      )!,
      sizeBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size_bytes'],
      )!,
    );
  }

  @override
  $ProjectFilesTable createAlias(String alias) {
    return $ProjectFilesTable(attachedDatabase, alias);
  }

  static TypeConverter<String, Uint8List> $converterid = const UuidConverter();
  static TypeConverter<String, Uint8List> $converterhomeId =
      const UuidConverter();
  static TypeConverter<String, Uint8List> $converterprojectId =
      const UuidConverter();
  static TypeConverter<String, Uint8List> $converterquoteId =
      const UuidConverter();
  static TypeConverter<String?, Uint8List?> $converterquoteIdn =
      NullAwareTypeConverter.wrap($converterquoteId);
}

class ProjectFileRow extends DataClass implements Insertable<ProjectFileRow> {
  final String id;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;
  final String homeId;
  final String projectId;
  final String? quoteId;
  final String name;
  final String? file;
  final String contentType;
  final bool isImage;
  final int sizeBytes;
  const ProjectFileRow({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.homeId,
    required this.projectId,
    this.quoteId,
    required this.name,
    this.file,
    required this.contentType,
    required this.isImage,
    required this.sizeBytes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    {
      map['id'] = Variable<Uint8List>(
        $ProjectFilesTable.$converterid.toSql(id),
      );
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    {
      map['home_id'] = Variable<Uint8List>(
        $ProjectFilesTable.$converterhomeId.toSql(homeId),
      );
    }
    {
      map['project_id'] = Variable<Uint8List>(
        $ProjectFilesTable.$converterprojectId.toSql(projectId),
      );
    }
    if (!nullToAbsent || quoteId != null) {
      map['quote_id'] = Variable<Uint8List>(
        $ProjectFilesTable.$converterquoteIdn.toSql(quoteId),
      );
    }
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || file != null) {
      map['file'] = Variable<String>(file);
    }
    map['content_type'] = Variable<String>(contentType);
    map['is_image'] = Variable<bool>(isImage);
    map['size_bytes'] = Variable<int>(sizeBytes);
    return map;
  }

  ProjectFilesCompanion toCompanion(bool nullToAbsent) {
    return ProjectFilesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      homeId: Value(homeId),
      projectId: Value(projectId),
      quoteId: quoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(quoteId),
      name: Value(name),
      file: file == null && nullToAbsent ? const Value.absent() : Value(file),
      contentType: Value(contentType),
      isImage: Value(isImage),
      sizeBytes: Value(sizeBytes),
    );
  }

  factory ProjectFileRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProjectFileRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      homeId: serializer.fromJson<String>(json['homeId']),
      projectId: serializer.fromJson<String>(json['projectId']),
      quoteId: serializer.fromJson<String?>(json['quoteId']),
      name: serializer.fromJson<String>(json['name']),
      file: serializer.fromJson<String?>(json['file']),
      contentType: serializer.fromJson<String>(json['contentType']),
      isImage: serializer.fromJson<bool>(json['isImage']),
      sizeBytes: serializer.fromJson<int>(json['sizeBytes']),
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
      'projectId': serializer.toJson<String>(projectId),
      'quoteId': serializer.toJson<String?>(quoteId),
      'name': serializer.toJson<String>(name),
      'file': serializer.toJson<String?>(file),
      'contentType': serializer.toJson<String>(contentType),
      'isImage': serializer.toJson<bool>(isImage),
      'sizeBytes': serializer.toJson<int>(sizeBytes),
    };
  }

  ProjectFileRow copyWith({
    String? id,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    String? homeId,
    String? projectId,
    Value<String?> quoteId = const Value.absent(),
    String? name,
    Value<String?> file = const Value.absent(),
    String? contentType,
    bool? isImage,
    int? sizeBytes,
  }) => ProjectFileRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    homeId: homeId ?? this.homeId,
    projectId: projectId ?? this.projectId,
    quoteId: quoteId.present ? quoteId.value : this.quoteId,
    name: name ?? this.name,
    file: file.present ? file.value : this.file,
    contentType: contentType ?? this.contentType,
    isImage: isImage ?? this.isImage,
    sizeBytes: sizeBytes ?? this.sizeBytes,
  );
  ProjectFileRow copyWithCompanion(ProjectFilesCompanion data) {
    return ProjectFileRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      homeId: data.homeId.present ? data.homeId.value : this.homeId,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      quoteId: data.quoteId.present ? data.quoteId.value : this.quoteId,
      name: data.name.present ? data.name.value : this.name,
      file: data.file.present ? data.file.value : this.file,
      contentType: data.contentType.present
          ? data.contentType.value
          : this.contentType,
      isImage: data.isImage.present ? data.isImage.value : this.isImage,
      sizeBytes: data.sizeBytes.present ? data.sizeBytes.value : this.sizeBytes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProjectFileRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('homeId: $homeId, ')
          ..write('projectId: $projectId, ')
          ..write('quoteId: $quoteId, ')
          ..write('name: $name, ')
          ..write('file: $file, ')
          ..write('contentType: $contentType, ')
          ..write('isImage: $isImage, ')
          ..write('sizeBytes: $sizeBytes')
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
    projectId,
    quoteId,
    name,
    file,
    contentType,
    isImage,
    sizeBytes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProjectFileRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.homeId == this.homeId &&
          other.projectId == this.projectId &&
          other.quoteId == this.quoteId &&
          other.name == this.name &&
          other.file == this.file &&
          other.contentType == this.contentType &&
          other.isImage == this.isImage &&
          other.sizeBytes == this.sizeBytes);
}

class ProjectFilesCompanion extends UpdateCompanion<ProjectFileRow> {
  final Value<String> id;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<String> homeId;
  final Value<String> projectId;
  final Value<String?> quoteId;
  final Value<String> name;
  final Value<String?> file;
  final Value<String> contentType;
  final Value<bool> isImage;
  final Value<int> sizeBytes;
  final Value<int> rowid;
  const ProjectFilesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.homeId = const Value.absent(),
    this.projectId = const Value.absent(),
    this.quoteId = const Value.absent(),
    this.name = const Value.absent(),
    this.file = const Value.absent(),
    this.contentType = const Value.absent(),
    this.isImage = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProjectFilesCompanion.insert({
    required String id,
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    required String homeId,
    required String projectId,
    this.quoteId = const Value.absent(),
    required String name,
    this.file = const Value.absent(),
    this.contentType = const Value.absent(),
    this.isImage = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       homeId = Value(homeId),
       projectId = Value(projectId),
       name = Value(name);
  static Insertable<ProjectFileRow> custom({
    Expression<Uint8List>? id,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<Uint8List>? homeId,
    Expression<Uint8List>? projectId,
    Expression<Uint8List>? quoteId,
    Expression<String>? name,
    Expression<String>? file,
    Expression<String>? contentType,
    Expression<bool>? isImage,
    Expression<int>? sizeBytes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (homeId != null) 'home_id': homeId,
      if (projectId != null) 'project_id': projectId,
      if (quoteId != null) 'quote_id': quoteId,
      if (name != null) 'name': name,
      if (file != null) 'file': file,
      if (contentType != null) 'content_type': contentType,
      if (isImage != null) 'is_image': isImage,
      if (sizeBytes != null) 'size_bytes': sizeBytes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProjectFilesCompanion copyWith({
    Value<String>? id,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<String>? homeId,
    Value<String>? projectId,
    Value<String?>? quoteId,
    Value<String>? name,
    Value<String?>? file,
    Value<String>? contentType,
    Value<bool>? isImage,
    Value<int>? sizeBytes,
    Value<int>? rowid,
  }) {
    return ProjectFilesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      homeId: homeId ?? this.homeId,
      projectId: projectId ?? this.projectId,
      quoteId: quoteId ?? this.quoteId,
      name: name ?? this.name,
      file: file ?? this.file,
      contentType: contentType ?? this.contentType,
      isImage: isImage ?? this.isImage,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<Uint8List>(
        $ProjectFilesTable.$converterid.toSql(id.value),
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
        $ProjectFilesTable.$converterhomeId.toSql(homeId.value),
      );
    }
    if (projectId.present) {
      map['project_id'] = Variable<Uint8List>(
        $ProjectFilesTable.$converterprojectId.toSql(projectId.value),
      );
    }
    if (quoteId.present) {
      map['quote_id'] = Variable<Uint8List>(
        $ProjectFilesTable.$converterquoteIdn.toSql(quoteId.value),
      );
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (file.present) {
      map['file'] = Variable<String>(file.value);
    }
    if (contentType.present) {
      map['content_type'] = Variable<String>(contentType.value);
    }
    if (isImage.present) {
      map['is_image'] = Variable<bool>(isImage.value);
    }
    if (sizeBytes.present) {
      map['size_bytes'] = Variable<int>(sizeBytes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProjectFilesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('homeId: $homeId, ')
          ..write('projectId: $projectId, ')
          ..write('quoteId: $quoteId, ')
          ..write('name: $name, ')
          ..write('file: $file, ')
          ..write('contentType: $contentType, ')
          ..write('isImage: $isImage, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProjectLinksTable extends ProjectLinks
    with TableInfo<$ProjectLinksTable, ProjectLinkRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProjectLinksTable(this.attachedDatabase, [this._alias]);
  @override
  late final GeneratedColumnWithTypeConverter<String, Uint8List> id =
      GeneratedColumn<Uint8List>(
        'id',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      ).withConverter<String>($ProjectLinksTable.$converterid);
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
      ).withConverter<String>($ProjectLinksTable.$converterhomeId);
  @override
  late final GeneratedColumnWithTypeConverter<String, Uint8List> projectId =
      GeneratedColumn<Uint8List>(
        'project_id',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      ).withConverter<String>($ProjectLinksTable.$converterprojectId);
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
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
    projectId,
    url,
    title,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'project_links';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProjectLinkRow> instance, {
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
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProjectLinkRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProjectLinkRow(
      id: $ProjectLinksTable.$converterid.fromSql(
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
      homeId: $ProjectLinksTable.$converterhomeId.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}home_id'],
        )!,
      ),
      projectId: $ProjectLinksTable.$converterprojectId.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}project_id'],
        )!,
      ),
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
    );
  }

  @override
  $ProjectLinksTable createAlias(String alias) {
    return $ProjectLinksTable(attachedDatabase, alias);
  }

  static TypeConverter<String, Uint8List> $converterid = const UuidConverter();
  static TypeConverter<String, Uint8List> $converterhomeId =
      const UuidConverter();
  static TypeConverter<String, Uint8List> $converterprojectId =
      const UuidConverter();
}

class ProjectLinkRow extends DataClass implements Insertable<ProjectLinkRow> {
  final String id;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;
  final String homeId;
  final String projectId;
  final String url;
  final String title;
  const ProjectLinkRow({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.homeId,
    required this.projectId,
    required this.url,
    required this.title,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    {
      map['id'] = Variable<Uint8List>(
        $ProjectLinksTable.$converterid.toSql(id),
      );
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    {
      map['home_id'] = Variable<Uint8List>(
        $ProjectLinksTable.$converterhomeId.toSql(homeId),
      );
    }
    {
      map['project_id'] = Variable<Uint8List>(
        $ProjectLinksTable.$converterprojectId.toSql(projectId),
      );
    }
    map['url'] = Variable<String>(url);
    map['title'] = Variable<String>(title);
    return map;
  }

  ProjectLinksCompanion toCompanion(bool nullToAbsent) {
    return ProjectLinksCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      homeId: Value(homeId),
      projectId: Value(projectId),
      url: Value(url),
      title: Value(title),
    );
  }

  factory ProjectLinkRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProjectLinkRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      homeId: serializer.fromJson<String>(json['homeId']),
      projectId: serializer.fromJson<String>(json['projectId']),
      url: serializer.fromJson<String>(json['url']),
      title: serializer.fromJson<String>(json['title']),
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
      'projectId': serializer.toJson<String>(projectId),
      'url': serializer.toJson<String>(url),
      'title': serializer.toJson<String>(title),
    };
  }

  ProjectLinkRow copyWith({
    String? id,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    String? homeId,
    String? projectId,
    String? url,
    String? title,
  }) => ProjectLinkRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    homeId: homeId ?? this.homeId,
    projectId: projectId ?? this.projectId,
    url: url ?? this.url,
    title: title ?? this.title,
  );
  ProjectLinkRow copyWithCompanion(ProjectLinksCompanion data) {
    return ProjectLinkRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      homeId: data.homeId.present ? data.homeId.value : this.homeId,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      url: data.url.present ? data.url.value : this.url,
      title: data.title.present ? data.title.value : this.title,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProjectLinkRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('homeId: $homeId, ')
          ..write('projectId: $projectId, ')
          ..write('url: $url, ')
          ..write('title: $title')
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
    projectId,
    url,
    title,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProjectLinkRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.homeId == this.homeId &&
          other.projectId == this.projectId &&
          other.url == this.url &&
          other.title == this.title);
}

class ProjectLinksCompanion extends UpdateCompanion<ProjectLinkRow> {
  final Value<String> id;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<String> homeId;
  final Value<String> projectId;
  final Value<String> url;
  final Value<String> title;
  final Value<int> rowid;
  const ProjectLinksCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.homeId = const Value.absent(),
    this.projectId = const Value.absent(),
    this.url = const Value.absent(),
    this.title = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProjectLinksCompanion.insert({
    required String id,
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    required String homeId,
    required String projectId,
    required String url,
    this.title = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       homeId = Value(homeId),
       projectId = Value(projectId),
       url = Value(url);
  static Insertable<ProjectLinkRow> custom({
    Expression<Uint8List>? id,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<Uint8List>? homeId,
    Expression<Uint8List>? projectId,
    Expression<String>? url,
    Expression<String>? title,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (homeId != null) 'home_id': homeId,
      if (projectId != null) 'project_id': projectId,
      if (url != null) 'url': url,
      if (title != null) 'title': title,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProjectLinksCompanion copyWith({
    Value<String>? id,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<String>? homeId,
    Value<String>? projectId,
    Value<String>? url,
    Value<String>? title,
    Value<int>? rowid,
  }) {
    return ProjectLinksCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      homeId: homeId ?? this.homeId,
      projectId: projectId ?? this.projectId,
      url: url ?? this.url,
      title: title ?? this.title,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<Uint8List>(
        $ProjectLinksTable.$converterid.toSql(id.value),
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
        $ProjectLinksTable.$converterhomeId.toSql(homeId.value),
      );
    }
    if (projectId.present) {
      map['project_id'] = Variable<Uint8List>(
        $ProjectLinksTable.$converterprojectId.toSql(projectId.value),
      );
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProjectLinksCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('homeId: $homeId, ')
          ..write('projectId: $projectId, ')
          ..write('url: $url, ')
          ..write('title: $title, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProjectTasksTable extends ProjectTasks
    with TableInfo<$ProjectTasksTable, ProjectTaskRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProjectTasksTable(this.attachedDatabase, [this._alias]);
  @override
  late final GeneratedColumnWithTypeConverter<String, Uint8List> id =
      GeneratedColumn<Uint8List>(
        'id',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      ).withConverter<String>($ProjectTasksTable.$converterid);
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
      ).withConverter<String>($ProjectTasksTable.$converterhomeId);
  @override
  late final GeneratedColumnWithTypeConverter<String, Uint8List> projectId =
      GeneratedColumn<Uint8List>(
        'project_id',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      ).withConverter<String>($ProjectTasksTable.$converterprojectId);
  @override
  late final GeneratedColumnWithTypeConverter<String, Uint8List> taskId =
      GeneratedColumn<Uint8List>(
        'task_id',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      ).withConverter<String>($ProjectTasksTable.$convertertaskId);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    homeId,
    projectId,
    taskId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'project_tasks';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProjectTaskRow> instance, {
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProjectTaskRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProjectTaskRow(
      id: $ProjectTasksTable.$converterid.fromSql(
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
      homeId: $ProjectTasksTable.$converterhomeId.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}home_id'],
        )!,
      ),
      projectId: $ProjectTasksTable.$converterprojectId.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}project_id'],
        )!,
      ),
      taskId: $ProjectTasksTable.$convertertaskId.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}task_id'],
        )!,
      ),
    );
  }

  @override
  $ProjectTasksTable createAlias(String alias) {
    return $ProjectTasksTable(attachedDatabase, alias);
  }

  static TypeConverter<String, Uint8List> $converterid = const UuidConverter();
  static TypeConverter<String, Uint8List> $converterhomeId =
      const UuidConverter();
  static TypeConverter<String, Uint8List> $converterprojectId =
      const UuidConverter();
  static TypeConverter<String, Uint8List> $convertertaskId =
      const UuidConverter();
}

class ProjectTaskRow extends DataClass implements Insertable<ProjectTaskRow> {
  final String id;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;
  final String homeId;
  final String projectId;
  final String taskId;
  const ProjectTaskRow({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.homeId,
    required this.projectId,
    required this.taskId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    {
      map['id'] = Variable<Uint8List>(
        $ProjectTasksTable.$converterid.toSql(id),
      );
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    {
      map['home_id'] = Variable<Uint8List>(
        $ProjectTasksTable.$converterhomeId.toSql(homeId),
      );
    }
    {
      map['project_id'] = Variable<Uint8List>(
        $ProjectTasksTable.$converterprojectId.toSql(projectId),
      );
    }
    {
      map['task_id'] = Variable<Uint8List>(
        $ProjectTasksTable.$convertertaskId.toSql(taskId),
      );
    }
    return map;
  }

  ProjectTasksCompanion toCompanion(bool nullToAbsent) {
    return ProjectTasksCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      homeId: Value(homeId),
      projectId: Value(projectId),
      taskId: Value(taskId),
    );
  }

  factory ProjectTaskRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProjectTaskRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      homeId: serializer.fromJson<String>(json['homeId']),
      projectId: serializer.fromJson<String>(json['projectId']),
      taskId: serializer.fromJson<String>(json['taskId']),
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
      'projectId': serializer.toJson<String>(projectId),
      'taskId': serializer.toJson<String>(taskId),
    };
  }

  ProjectTaskRow copyWith({
    String? id,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    String? homeId,
    String? projectId,
    String? taskId,
  }) => ProjectTaskRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    homeId: homeId ?? this.homeId,
    projectId: projectId ?? this.projectId,
    taskId: taskId ?? this.taskId,
  );
  ProjectTaskRow copyWithCompanion(ProjectTasksCompanion data) {
    return ProjectTaskRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      homeId: data.homeId.present ? data.homeId.value : this.homeId,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProjectTaskRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('homeId: $homeId, ')
          ..write('projectId: $projectId, ')
          ..write('taskId: $taskId')
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
    projectId,
    taskId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProjectTaskRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.homeId == this.homeId &&
          other.projectId == this.projectId &&
          other.taskId == this.taskId);
}

class ProjectTasksCompanion extends UpdateCompanion<ProjectTaskRow> {
  final Value<String> id;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<String> homeId;
  final Value<String> projectId;
  final Value<String> taskId;
  final Value<int> rowid;
  const ProjectTasksCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.homeId = const Value.absent(),
    this.projectId = const Value.absent(),
    this.taskId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProjectTasksCompanion.insert({
    required String id,
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    required String homeId,
    required String projectId,
    required String taskId,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       homeId = Value(homeId),
       projectId = Value(projectId),
       taskId = Value(taskId);
  static Insertable<ProjectTaskRow> custom({
    Expression<Uint8List>? id,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<Uint8List>? homeId,
    Expression<Uint8List>? projectId,
    Expression<Uint8List>? taskId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (homeId != null) 'home_id': homeId,
      if (projectId != null) 'project_id': projectId,
      if (taskId != null) 'task_id': taskId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProjectTasksCompanion copyWith({
    Value<String>? id,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<String>? homeId,
    Value<String>? projectId,
    Value<String>? taskId,
    Value<int>? rowid,
  }) {
    return ProjectTasksCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      homeId: homeId ?? this.homeId,
      projectId: projectId ?? this.projectId,
      taskId: taskId ?? this.taskId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<Uint8List>(
        $ProjectTasksTable.$converterid.toSql(id.value),
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
        $ProjectTasksTable.$converterhomeId.toSql(homeId.value),
      );
    }
    if (projectId.present) {
      map['project_id'] = Variable<Uint8List>(
        $ProjectTasksTable.$converterprojectId.toSql(projectId.value),
      );
    }
    if (taskId.present) {
      map['task_id'] = Variable<Uint8List>(
        $ProjectTasksTable.$convertertaskId.toSql(taskId.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProjectTasksCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('homeId: $homeId, ')
          ..write('projectId: $projectId, ')
          ..write('taskId: $taskId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AnnualEnvelopesTable extends AnnualEnvelopes
    with TableInfo<$AnnualEnvelopesTable, EnvelopeRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AnnualEnvelopesTable(this.attachedDatabase, [this._alias]);
  @override
  late final GeneratedColumnWithTypeConverter<String, Uint8List> id =
      GeneratedColumn<Uint8List>(
        'id',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      ).withConverter<String>($AnnualEnvelopesTable.$converterid);
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
      ).withConverter<String>($AnnualEnvelopesTable.$converterhomeId);
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<int> year = GeneratedColumn<int>(
    'year',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<String> amount = GeneratedColumn<String>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    homeId,
    year,
    amount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'annual_envelopes';
  @override
  VerificationContext validateIntegrity(
    Insertable<EnvelopeRow> instance, {
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
    if (data.containsKey('year')) {
      context.handle(
        _yearMeta,
        year.isAcceptableOrUnknown(data['year']!, _yearMeta),
      );
    } else if (isInserting) {
      context.missing(_yearMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EnvelopeRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EnvelopeRow(
      id: $AnnualEnvelopesTable.$converterid.fromSql(
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
      homeId: $AnnualEnvelopesTable.$converterhomeId.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}home_id'],
        )!,
      ),
      year: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}amount'],
      )!,
    );
  }

  @override
  $AnnualEnvelopesTable createAlias(String alias) {
    return $AnnualEnvelopesTable(attachedDatabase, alias);
  }

  static TypeConverter<String, Uint8List> $converterid = const UuidConverter();
  static TypeConverter<String, Uint8List> $converterhomeId =
      const UuidConverter();
}

class EnvelopeRow extends DataClass implements Insertable<EnvelopeRow> {
  final String id;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;
  final String homeId;
  final int year;
  final String amount;
  const EnvelopeRow({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.homeId,
    required this.year,
    required this.amount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    {
      map['id'] = Variable<Uint8List>(
        $AnnualEnvelopesTable.$converterid.toSql(id),
      );
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    {
      map['home_id'] = Variable<Uint8List>(
        $AnnualEnvelopesTable.$converterhomeId.toSql(homeId),
      );
    }
    map['year'] = Variable<int>(year);
    map['amount'] = Variable<String>(amount);
    return map;
  }

  AnnualEnvelopesCompanion toCompanion(bool nullToAbsent) {
    return AnnualEnvelopesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      homeId: Value(homeId),
      year: Value(year),
      amount: Value(amount),
    );
  }

  factory EnvelopeRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EnvelopeRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      homeId: serializer.fromJson<String>(json['homeId']),
      year: serializer.fromJson<int>(json['year']),
      amount: serializer.fromJson<String>(json['amount']),
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
      'year': serializer.toJson<int>(year),
      'amount': serializer.toJson<String>(amount),
    };
  }

  EnvelopeRow copyWith({
    String? id,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    String? homeId,
    int? year,
    String? amount,
  }) => EnvelopeRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    homeId: homeId ?? this.homeId,
    year: year ?? this.year,
    amount: amount ?? this.amount,
  );
  EnvelopeRow copyWithCompanion(AnnualEnvelopesCompanion data) {
    return EnvelopeRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      homeId: data.homeId.present ? data.homeId.value : this.homeId,
      year: data.year.present ? data.year.value : this.year,
      amount: data.amount.present ? data.amount.value : this.amount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EnvelopeRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('homeId: $homeId, ')
          ..write('year: $year, ')
          ..write('amount: $amount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, createdAt, updatedAt, deletedAt, homeId, year, amount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EnvelopeRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.homeId == this.homeId &&
          other.year == this.year &&
          other.amount == this.amount);
}

class AnnualEnvelopesCompanion extends UpdateCompanion<EnvelopeRow> {
  final Value<String> id;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<String> homeId;
  final Value<int> year;
  final Value<String> amount;
  final Value<int> rowid;
  const AnnualEnvelopesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.homeId = const Value.absent(),
    this.year = const Value.absent(),
    this.amount = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AnnualEnvelopesCompanion.insert({
    required String id,
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    required String homeId,
    required int year,
    required String amount,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       homeId = Value(homeId),
       year = Value(year),
       amount = Value(amount);
  static Insertable<EnvelopeRow> custom({
    Expression<Uint8List>? id,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<Uint8List>? homeId,
    Expression<int>? year,
    Expression<String>? amount,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (homeId != null) 'home_id': homeId,
      if (year != null) 'year': year,
      if (amount != null) 'amount': amount,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AnnualEnvelopesCompanion copyWith({
    Value<String>? id,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<String>? homeId,
    Value<int>? year,
    Value<String>? amount,
    Value<int>? rowid,
  }) {
    return AnnualEnvelopesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      homeId: homeId ?? this.homeId,
      year: year ?? this.year,
      amount: amount ?? this.amount,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<Uint8List>(
        $AnnualEnvelopesTable.$converterid.toSql(id.value),
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
        $AnnualEnvelopesTable.$converterhomeId.toSql(homeId.value),
      );
    }
    if (year.present) {
      map['year'] = Variable<int>(year.value);
    }
    if (amount.present) {
      map['amount'] = Variable<String>(amount.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AnnualEnvelopesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('homeId: $homeId, ')
          ..write('year: $year, ')
          ..write('amount: $amount, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReportsTable extends Reports with TableInfo<$ReportsTable, ReportRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReportsTable(this.attachedDatabase, [this._alias]);
  @override
  late final GeneratedColumnWithTypeConverter<String, Uint8List> id =
      GeneratedColumn<Uint8List>(
        'id',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      ).withConverter<String>($ReportsTable.$converterid);
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
      ).withConverter<String>($ReportsTable.$converterhomeId);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('open'),
  );
  @override
  late final GeneratedColumnWithTypeConverter<String?, Uint8List> roomId =
      GeneratedColumn<Uint8List>(
        'room_id',
        aliasedName,
        true,
        type: DriftSqlType.blob,
        requiredDuringInsert: false,
      ).withConverter<String?>($ReportsTable.$converterroomIdn);
  @override
  late final GeneratedColumnWithTypeConverter<String?, Uint8List> itemId =
      GeneratedColumn<Uint8List>(
        'item_id',
        aliasedName,
        true,
        type: DriftSqlType.blob,
        requiredDuringInsert: false,
      ).withConverter<String?>($ReportsTable.$converteritemIdn);
  @override
  late final GeneratedColumnWithTypeConverter<String?, Uint8List> articleId =
      GeneratedColumn<Uint8List>(
        'article_id',
        aliasedName,
        true,
        type: DriftSqlType.blob,
        requiredDuringInsert: false,
      ).withConverter<String?>($ReportsTable.$converterarticleIdn);
  static const VerificationMeta _placeMeta = const VerificationMeta('place');
  @override
  late final GeneratedColumn<String> place = GeneratedColumn<String>(
    'place',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  late final GeneratedColumnWithTypeConverter<String?, Uint8List> taskId =
      GeneratedColumn<Uint8List>(
        'task_id',
        aliasedName,
        true,
        type: DriftSqlType.blob,
        requiredDuringInsert: false,
      ).withConverter<String?>($ReportsTable.$convertertaskIdn);
  static const VerificationMeta _closedAtMeta = const VerificationMeta(
    'closedAt',
  );
  @override
  late final GeneratedColumn<int> closedAt = GeneratedColumn<int>(
    'closed_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _photoMeta = const VerificationMeta('photo');
  @override
  late final GeneratedColumn<String> photo = GeneratedColumn<String>(
    'photo',
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
    status,
    roomId,
    itemId,
    articleId,
    place,
    taskId,
    closedAt,
    photo,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reports';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReportRow> instance, {
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
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('place')) {
      context.handle(
        _placeMeta,
        place.isAcceptableOrUnknown(data['place']!, _placeMeta),
      );
    }
    if (data.containsKey('closed_at')) {
      context.handle(
        _closedAtMeta,
        closedAt.isAcceptableOrUnknown(data['closed_at']!, _closedAtMeta),
      );
    }
    if (data.containsKey('photo')) {
      context.handle(
        _photoMeta,
        photo.isAcceptableOrUnknown(data['photo']!, _photoMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReportRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReportRow(
      id: $ReportsTable.$converterid.fromSql(
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
      homeId: $ReportsTable.$converterhomeId.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}home_id'],
        )!,
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      roomId: $ReportsTable.$converterroomIdn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}room_id'],
        ),
      ),
      itemId: $ReportsTable.$converteritemIdn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}item_id'],
        ),
      ),
      articleId: $ReportsTable.$converterarticleIdn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}article_id'],
        ),
      ),
      place: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}place'],
      )!,
      taskId: $ReportsTable.$convertertaskIdn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}task_id'],
        ),
      ),
      closedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}closed_at'],
      ),
      photo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo'],
      ),
    );
  }

  @override
  $ReportsTable createAlias(String alias) {
    return $ReportsTable(attachedDatabase, alias);
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
  static TypeConverter<String, Uint8List> $converterarticleId =
      const UuidConverter();
  static TypeConverter<String?, Uint8List?> $converterarticleIdn =
      NullAwareTypeConverter.wrap($converterarticleId);
  static TypeConverter<String, Uint8List> $convertertaskId =
      const UuidConverter();
  static TypeConverter<String?, Uint8List?> $convertertaskIdn =
      NullAwareTypeConverter.wrap($convertertaskId);
}

class ReportRow extends DataClass implements Insertable<ReportRow> {
  final String id;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;
  final String homeId;
  final String title;
  final String status;
  final String? roomId;
  final String? itemId;
  final String? articleId;
  final String place;
  final String? taskId;
  final int? closedAt;
  final String? photo;
  const ReportRow({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.homeId,
    required this.title,
    required this.status,
    this.roomId,
    this.itemId,
    this.articleId,
    required this.place,
    this.taskId,
    this.closedAt,
    this.photo,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    {
      map['id'] = Variable<Uint8List>($ReportsTable.$converterid.toSql(id));
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    {
      map['home_id'] = Variable<Uint8List>(
        $ReportsTable.$converterhomeId.toSql(homeId),
      );
    }
    map['title'] = Variable<String>(title);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || roomId != null) {
      map['room_id'] = Variable<Uint8List>(
        $ReportsTable.$converterroomIdn.toSql(roomId),
      );
    }
    if (!nullToAbsent || itemId != null) {
      map['item_id'] = Variable<Uint8List>(
        $ReportsTable.$converteritemIdn.toSql(itemId),
      );
    }
    if (!nullToAbsent || articleId != null) {
      map['article_id'] = Variable<Uint8List>(
        $ReportsTable.$converterarticleIdn.toSql(articleId),
      );
    }
    map['place'] = Variable<String>(place);
    if (!nullToAbsent || taskId != null) {
      map['task_id'] = Variable<Uint8List>(
        $ReportsTable.$convertertaskIdn.toSql(taskId),
      );
    }
    if (!nullToAbsent || closedAt != null) {
      map['closed_at'] = Variable<int>(closedAt);
    }
    if (!nullToAbsent || photo != null) {
      map['photo'] = Variable<String>(photo);
    }
    return map;
  }

  ReportsCompanion toCompanion(bool nullToAbsent) {
    return ReportsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      homeId: Value(homeId),
      title: Value(title),
      status: Value(status),
      roomId: roomId == null && nullToAbsent
          ? const Value.absent()
          : Value(roomId),
      itemId: itemId == null && nullToAbsent
          ? const Value.absent()
          : Value(itemId),
      articleId: articleId == null && nullToAbsent
          ? const Value.absent()
          : Value(articleId),
      place: Value(place),
      taskId: taskId == null && nullToAbsent
          ? const Value.absent()
          : Value(taskId),
      closedAt: closedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(closedAt),
      photo: photo == null && nullToAbsent
          ? const Value.absent()
          : Value(photo),
    );
  }

  factory ReportRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReportRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      homeId: serializer.fromJson<String>(json['homeId']),
      title: serializer.fromJson<String>(json['title']),
      status: serializer.fromJson<String>(json['status']),
      roomId: serializer.fromJson<String?>(json['roomId']),
      itemId: serializer.fromJson<String?>(json['itemId']),
      articleId: serializer.fromJson<String?>(json['articleId']),
      place: serializer.fromJson<String>(json['place']),
      taskId: serializer.fromJson<String?>(json['taskId']),
      closedAt: serializer.fromJson<int?>(json['closedAt']),
      photo: serializer.fromJson<String?>(json['photo']),
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
      'status': serializer.toJson<String>(status),
      'roomId': serializer.toJson<String?>(roomId),
      'itemId': serializer.toJson<String?>(itemId),
      'articleId': serializer.toJson<String?>(articleId),
      'place': serializer.toJson<String>(place),
      'taskId': serializer.toJson<String?>(taskId),
      'closedAt': serializer.toJson<int?>(closedAt),
      'photo': serializer.toJson<String?>(photo),
    };
  }

  ReportRow copyWith({
    String? id,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    String? homeId,
    String? title,
    String? status,
    Value<String?> roomId = const Value.absent(),
    Value<String?> itemId = const Value.absent(),
    Value<String?> articleId = const Value.absent(),
    String? place,
    Value<String?> taskId = const Value.absent(),
    Value<int?> closedAt = const Value.absent(),
    Value<String?> photo = const Value.absent(),
  }) => ReportRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    homeId: homeId ?? this.homeId,
    title: title ?? this.title,
    status: status ?? this.status,
    roomId: roomId.present ? roomId.value : this.roomId,
    itemId: itemId.present ? itemId.value : this.itemId,
    articleId: articleId.present ? articleId.value : this.articleId,
    place: place ?? this.place,
    taskId: taskId.present ? taskId.value : this.taskId,
    closedAt: closedAt.present ? closedAt.value : this.closedAt,
    photo: photo.present ? photo.value : this.photo,
  );
  ReportRow copyWithCompanion(ReportsCompanion data) {
    return ReportRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      homeId: data.homeId.present ? data.homeId.value : this.homeId,
      title: data.title.present ? data.title.value : this.title,
      status: data.status.present ? data.status.value : this.status,
      roomId: data.roomId.present ? data.roomId.value : this.roomId,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      articleId: data.articleId.present ? data.articleId.value : this.articleId,
      place: data.place.present ? data.place.value : this.place,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      closedAt: data.closedAt.present ? data.closedAt.value : this.closedAt,
      photo: data.photo.present ? data.photo.value : this.photo,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReportRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('homeId: $homeId, ')
          ..write('title: $title, ')
          ..write('status: $status, ')
          ..write('roomId: $roomId, ')
          ..write('itemId: $itemId, ')
          ..write('articleId: $articleId, ')
          ..write('place: $place, ')
          ..write('taskId: $taskId, ')
          ..write('closedAt: $closedAt, ')
          ..write('photo: $photo')
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
    title,
    status,
    roomId,
    itemId,
    articleId,
    place,
    taskId,
    closedAt,
    photo,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReportRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.homeId == this.homeId &&
          other.title == this.title &&
          other.status == this.status &&
          other.roomId == this.roomId &&
          other.itemId == this.itemId &&
          other.articleId == this.articleId &&
          other.place == this.place &&
          other.taskId == this.taskId &&
          other.closedAt == this.closedAt &&
          other.photo == this.photo);
}

class ReportsCompanion extends UpdateCompanion<ReportRow> {
  final Value<String> id;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<String> homeId;
  final Value<String> title;
  final Value<String> status;
  final Value<String?> roomId;
  final Value<String?> itemId;
  final Value<String?> articleId;
  final Value<String> place;
  final Value<String?> taskId;
  final Value<int?> closedAt;
  final Value<String?> photo;
  final Value<int> rowid;
  const ReportsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.homeId = const Value.absent(),
    this.title = const Value.absent(),
    this.status = const Value.absent(),
    this.roomId = const Value.absent(),
    this.itemId = const Value.absent(),
    this.articleId = const Value.absent(),
    this.place = const Value.absent(),
    this.taskId = const Value.absent(),
    this.closedAt = const Value.absent(),
    this.photo = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReportsCompanion.insert({
    required String id,
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    required String homeId,
    required String title,
    this.status = const Value.absent(),
    this.roomId = const Value.absent(),
    this.itemId = const Value.absent(),
    this.articleId = const Value.absent(),
    this.place = const Value.absent(),
    this.taskId = const Value.absent(),
    this.closedAt = const Value.absent(),
    this.photo = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       homeId = Value(homeId),
       title = Value(title);
  static Insertable<ReportRow> custom({
    Expression<Uint8List>? id,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<Uint8List>? homeId,
    Expression<String>? title,
    Expression<String>? status,
    Expression<Uint8List>? roomId,
    Expression<Uint8List>? itemId,
    Expression<Uint8List>? articleId,
    Expression<String>? place,
    Expression<Uint8List>? taskId,
    Expression<int>? closedAt,
    Expression<String>? photo,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (homeId != null) 'home_id': homeId,
      if (title != null) 'title': title,
      if (status != null) 'status': status,
      if (roomId != null) 'room_id': roomId,
      if (itemId != null) 'item_id': itemId,
      if (articleId != null) 'article_id': articleId,
      if (place != null) 'place': place,
      if (taskId != null) 'task_id': taskId,
      if (closedAt != null) 'closed_at': closedAt,
      if (photo != null) 'photo': photo,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReportsCompanion copyWith({
    Value<String>? id,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<String>? homeId,
    Value<String>? title,
    Value<String>? status,
    Value<String?>? roomId,
    Value<String?>? itemId,
    Value<String?>? articleId,
    Value<String>? place,
    Value<String?>? taskId,
    Value<int?>? closedAt,
    Value<String?>? photo,
    Value<int>? rowid,
  }) {
    return ReportsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      homeId: homeId ?? this.homeId,
      title: title ?? this.title,
      status: status ?? this.status,
      roomId: roomId ?? this.roomId,
      itemId: itemId ?? this.itemId,
      articleId: articleId ?? this.articleId,
      place: place ?? this.place,
      taskId: taskId ?? this.taskId,
      closedAt: closedAt ?? this.closedAt,
      photo: photo ?? this.photo,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<Uint8List>(
        $ReportsTable.$converterid.toSql(id.value),
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
        $ReportsTable.$converterhomeId.toSql(homeId.value),
      );
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (roomId.present) {
      map['room_id'] = Variable<Uint8List>(
        $ReportsTable.$converterroomIdn.toSql(roomId.value),
      );
    }
    if (itemId.present) {
      map['item_id'] = Variable<Uint8List>(
        $ReportsTable.$converteritemIdn.toSql(itemId.value),
      );
    }
    if (articleId.present) {
      map['article_id'] = Variable<Uint8List>(
        $ReportsTable.$converterarticleIdn.toSql(articleId.value),
      );
    }
    if (place.present) {
      map['place'] = Variable<String>(place.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<Uint8List>(
        $ReportsTable.$convertertaskIdn.toSql(taskId.value),
      );
    }
    if (closedAt.present) {
      map['closed_at'] = Variable<int>(closedAt.value);
    }
    if (photo.present) {
      map['photo'] = Variable<String>(photo.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReportsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('homeId: $homeId, ')
          ..write('title: $title, ')
          ..write('status: $status, ')
          ..write('roomId: $roomId, ')
          ..write('itemId: $itemId, ')
          ..write('articleId: $articleId, ')
          ..write('place: $place, ')
          ..write('taskId: $taskId, ')
          ..write('closedAt: $closedAt, ')
          ..write('photo: $photo, ')
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

class $OpLogTable extends OpLog with TableInfo<$OpLogTable, OpLogRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OpLogTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _seqMeta = const VerificationMeta('seq');
  @override
  late final GeneratedColumn<int> seq = GeneratedColumn<int>(
    'seq',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
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
  static const VerificationMeta _hlcMeta = const VerificationMeta('hlc');
  @override
  late final GeneratedColumn<String> hlc = GeneratedColumn<String>(
    'hlc',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<String?, Uint8List> homeId =
      GeneratedColumn<Uint8List>(
        'home_id',
        aliasedName,
        true,
        type: DriftSqlType.blob,
        requiredDuringInsert: false,
      ).withConverter<String?>($OpLogTable.$converterhomeIdn);
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [seq, device, hlc, homeId, body];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'op_log';
  @override
  VerificationContext validateIntegrity(
    Insertable<OpLogRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('seq')) {
      context.handle(
        _seqMeta,
        seq.isAcceptableOrUnknown(data['seq']!, _seqMeta),
      );
    }
    if (data.containsKey('device')) {
      context.handle(
        _deviceMeta,
        device.isAcceptableOrUnknown(data['device']!, _deviceMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceMeta);
    }
    if (data.containsKey('hlc')) {
      context.handle(
        _hlcMeta,
        hlc.isAcceptableOrUnknown(data['hlc']!, _hlcMeta),
      );
    } else if (isInserting) {
      context.missing(_hlcMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {seq};
  @override
  OpLogRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OpLogRow(
      seq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seq'],
      )!,
      device: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}device'],
      )!,
      hlc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hlc'],
      )!,
      homeId: $OpLogTable.$converterhomeIdn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}home_id'],
        ),
      ),
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
    );
  }

  @override
  $OpLogTable createAlias(String alias) {
    return $OpLogTable(attachedDatabase, alias);
  }

  static TypeConverter<String, Uint8List> $converterhomeId =
      const UuidConverter();
  static TypeConverter<String?, Uint8List?> $converterhomeIdn =
      NullAwareTypeConverter.wrap($converterhomeId);
}

class OpLogRow extends DataClass implements Insertable<OpLogRow> {
  final int seq;
  final Uint8List device;
  final String hlc;
  final String? homeId;
  final String body;
  const OpLogRow({
    required this.seq,
    required this.device,
    required this.hlc,
    this.homeId,
    required this.body,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['seq'] = Variable<int>(seq);
    map['device'] = Variable<Uint8List>(device);
    map['hlc'] = Variable<String>(hlc);
    if (!nullToAbsent || homeId != null) {
      map['home_id'] = Variable<Uint8List>(
        $OpLogTable.$converterhomeIdn.toSql(homeId),
      );
    }
    map['body'] = Variable<String>(body);
    return map;
  }

  OpLogCompanion toCompanion(bool nullToAbsent) {
    return OpLogCompanion(
      seq: Value(seq),
      device: Value(device),
      hlc: Value(hlc),
      homeId: homeId == null && nullToAbsent
          ? const Value.absent()
          : Value(homeId),
      body: Value(body),
    );
  }

  factory OpLogRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OpLogRow(
      seq: serializer.fromJson<int>(json['seq']),
      device: serializer.fromJson<Uint8List>(json['device']),
      hlc: serializer.fromJson<String>(json['hlc']),
      homeId: serializer.fromJson<String?>(json['homeId']),
      body: serializer.fromJson<String>(json['body']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'seq': serializer.toJson<int>(seq),
      'device': serializer.toJson<Uint8List>(device),
      'hlc': serializer.toJson<String>(hlc),
      'homeId': serializer.toJson<String?>(homeId),
      'body': serializer.toJson<String>(body),
    };
  }

  OpLogRow copyWith({
    int? seq,
    Uint8List? device,
    String? hlc,
    Value<String?> homeId = const Value.absent(),
    String? body,
  }) => OpLogRow(
    seq: seq ?? this.seq,
    device: device ?? this.device,
    hlc: hlc ?? this.hlc,
    homeId: homeId.present ? homeId.value : this.homeId,
    body: body ?? this.body,
  );
  OpLogRow copyWithCompanion(OpLogCompanion data) {
    return OpLogRow(
      seq: data.seq.present ? data.seq.value : this.seq,
      device: data.device.present ? data.device.value : this.device,
      hlc: data.hlc.present ? data.hlc.value : this.hlc,
      homeId: data.homeId.present ? data.homeId.value : this.homeId,
      body: data.body.present ? data.body.value : this.body,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OpLogRow(')
          ..write('seq: $seq, ')
          ..write('device: $device, ')
          ..write('hlc: $hlc, ')
          ..write('homeId: $homeId, ')
          ..write('body: $body')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(seq, $driftBlobEquality.hash(device), hlc, homeId, body);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OpLogRow &&
          other.seq == this.seq &&
          $driftBlobEquality.equals(other.device, this.device) &&
          other.hlc == this.hlc &&
          other.homeId == this.homeId &&
          other.body == this.body);
}

class OpLogCompanion extends UpdateCompanion<OpLogRow> {
  final Value<int> seq;
  final Value<Uint8List> device;
  final Value<String> hlc;
  final Value<String?> homeId;
  final Value<String> body;
  const OpLogCompanion({
    this.seq = const Value.absent(),
    this.device = const Value.absent(),
    this.hlc = const Value.absent(),
    this.homeId = const Value.absent(),
    this.body = const Value.absent(),
  });
  OpLogCompanion.insert({
    this.seq = const Value.absent(),
    required Uint8List device,
    required String hlc,
    this.homeId = const Value.absent(),
    required String body,
  }) : device = Value(device),
       hlc = Value(hlc),
       body = Value(body);
  static Insertable<OpLogRow> custom({
    Expression<int>? seq,
    Expression<Uint8List>? device,
    Expression<String>? hlc,
    Expression<Uint8List>? homeId,
    Expression<String>? body,
  }) {
    return RawValuesInsertable({
      if (seq != null) 'seq': seq,
      if (device != null) 'device': device,
      if (hlc != null) 'hlc': hlc,
      if (homeId != null) 'home_id': homeId,
      if (body != null) 'body': body,
    });
  }

  OpLogCompanion copyWith({
    Value<int>? seq,
    Value<Uint8List>? device,
    Value<String>? hlc,
    Value<String?>? homeId,
    Value<String>? body,
  }) {
    return OpLogCompanion(
      seq: seq ?? this.seq,
      device: device ?? this.device,
      hlc: hlc ?? this.hlc,
      homeId: homeId ?? this.homeId,
      body: body ?? this.body,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (seq.present) {
      map['seq'] = Variable<int>(seq.value);
    }
    if (device.present) {
      map['device'] = Variable<Uint8List>(device.value);
    }
    if (hlc.present) {
      map['hlc'] = Variable<String>(hlc.value);
    }
    if (homeId.present) {
      map['home_id'] = Variable<Uint8List>(
        $OpLogTable.$converterhomeIdn.toSql(homeId.value),
      );
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OpLogCompanion(')
          ..write('seq: $seq, ')
          ..write('device: $device, ')
          ..write('hlc: $hlc, ')
          ..write('homeId: $homeId, ')
          ..write('body: $body')
          ..write(')'))
        .toString();
  }
}

class $ExtraTable extends Extra with TableInfo<$ExtraTable, ExtraRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExtraTable(this.attachedDatabase, [this._alias]);
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
      ).withConverter<String>($ExtraTable.$converterrowId);
  @override
  late final GeneratedColumnWithTypeConverter<String?, Uint8List> homeId =
      GeneratedColumn<Uint8List>(
        'home_id',
        aliasedName,
        true,
        type: DriftSqlType.blob,
        requiredDuringInsert: false,
      ).withConverter<String?>($ExtraTable.$converterhomeIdn);
  static const VerificationMeta _jsonMeta = const VerificationMeta('json');
  @override
  late final GeneratedColumn<String> json = GeneratedColumn<String>(
    'json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [entity, rowId, homeId, json];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'extra';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExtraRow> instance, {
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
    if (data.containsKey('json')) {
      context.handle(
        _jsonMeta,
        json.isAcceptableOrUnknown(data['json']!, _jsonMeta),
      );
    } else if (isInserting) {
      context.missing(_jsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {entity, rowId};
  @override
  ExtraRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExtraRow(
      entity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity'],
      )!,
      rowId: $ExtraTable.$converterrowId.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}row_id'],
        )!,
      ),
      homeId: $ExtraTable.$converterhomeIdn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}home_id'],
        ),
      ),
      json: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}json'],
      )!,
    );
  }

  @override
  $ExtraTable createAlias(String alias) {
    return $ExtraTable(attachedDatabase, alias);
  }

  static TypeConverter<String, Uint8List> $converterrowId =
      const UuidConverter();
  static TypeConverter<String, Uint8List> $converterhomeId =
      const UuidConverter();
  static TypeConverter<String?, Uint8List?> $converterhomeIdn =
      NullAwareTypeConverter.wrap($converterhomeId);
}

class ExtraRow extends DataClass implements Insertable<ExtraRow> {
  final String entity;
  final String rowId;
  final String? homeId;
  final String json;
  const ExtraRow({
    required this.entity,
    required this.rowId,
    this.homeId,
    required this.json,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['entity'] = Variable<String>(entity);
    {
      map['row_id'] = Variable<Uint8List>(
        $ExtraTable.$converterrowId.toSql(rowId),
      );
    }
    if (!nullToAbsent || homeId != null) {
      map['home_id'] = Variable<Uint8List>(
        $ExtraTable.$converterhomeIdn.toSql(homeId),
      );
    }
    map['json'] = Variable<String>(json);
    return map;
  }

  ExtraCompanion toCompanion(bool nullToAbsent) {
    return ExtraCompanion(
      entity: Value(entity),
      rowId: Value(rowId),
      homeId: homeId == null && nullToAbsent
          ? const Value.absent()
          : Value(homeId),
      json: Value(json),
    );
  }

  factory ExtraRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExtraRow(
      entity: serializer.fromJson<String>(json['entity']),
      rowId: serializer.fromJson<String>(json['rowId']),
      homeId: serializer.fromJson<String?>(json['homeId']),
      json: serializer.fromJson<String>(json['json']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'entity': serializer.toJson<String>(entity),
      'rowId': serializer.toJson<String>(rowId),
      'homeId': serializer.toJson<String?>(homeId),
      'json': serializer.toJson<String>(json),
    };
  }

  ExtraRow copyWith({
    String? entity,
    String? rowId,
    Value<String?> homeId = const Value.absent(),
    String? json,
  }) => ExtraRow(
    entity: entity ?? this.entity,
    rowId: rowId ?? this.rowId,
    homeId: homeId.present ? homeId.value : this.homeId,
    json: json ?? this.json,
  );
  ExtraRow copyWithCompanion(ExtraCompanion data) {
    return ExtraRow(
      entity: data.entity.present ? data.entity.value : this.entity,
      rowId: data.rowId.present ? data.rowId.value : this.rowId,
      homeId: data.homeId.present ? data.homeId.value : this.homeId,
      json: data.json.present ? data.json.value : this.json,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExtraRow(')
          ..write('entity: $entity, ')
          ..write('rowId: $rowId, ')
          ..write('homeId: $homeId, ')
          ..write('json: $json')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(entity, rowId, homeId, json);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExtraRow &&
          other.entity == this.entity &&
          other.rowId == this.rowId &&
          other.homeId == this.homeId &&
          other.json == this.json);
}

class ExtraCompanion extends UpdateCompanion<ExtraRow> {
  final Value<String> entity;
  final Value<String> rowId;
  final Value<String?> homeId;
  final Value<String> json;
  final Value<int> rowid;
  const ExtraCompanion({
    this.entity = const Value.absent(),
    this.rowId = const Value.absent(),
    this.homeId = const Value.absent(),
    this.json = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExtraCompanion.insert({
    required String entity,
    required String rowId,
    this.homeId = const Value.absent(),
    required String json,
    this.rowid = const Value.absent(),
  }) : entity = Value(entity),
       rowId = Value(rowId),
       json = Value(json);
  static Insertable<ExtraRow> custom({
    Expression<String>? entity,
    Expression<Uint8List>? rowId,
    Expression<Uint8List>? homeId,
    Expression<String>? json,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (entity != null) 'entity': entity,
      if (rowId != null) 'row_id': rowId,
      if (homeId != null) 'home_id': homeId,
      if (json != null) 'json': json,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExtraCompanion copyWith({
    Value<String>? entity,
    Value<String>? rowId,
    Value<String?>? homeId,
    Value<String>? json,
    Value<int>? rowid,
  }) {
    return ExtraCompanion(
      entity: entity ?? this.entity,
      rowId: rowId ?? this.rowId,
      homeId: homeId ?? this.homeId,
      json: json ?? this.json,
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
        $ExtraTable.$converterrowId.toSql(rowId.value),
      );
    }
    if (homeId.present) {
      map['home_id'] = Variable<Uint8List>(
        $ExtraTable.$converterhomeIdn.toSql(homeId.value),
      );
    }
    if (json.present) {
      map['json'] = Variable<String>(json.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExtraCompanion(')
          ..write('entity: $entity, ')
          ..write('rowId: $rowId, ')
          ..write('homeId: $homeId, ')
          ..write('json: $json, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PendingTable extends Pending with TableInfo<$PendingTable, PendingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PendingTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
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
  late final GeneratedColumnWithTypeConverter<String?, Uint8List> homeId =
      GeneratedColumn<Uint8List>(
        'home_id',
        aliasedName,
        true,
        type: DriftSqlType.blob,
        requiredDuringInsert: false,
      ).withConverter<String?>($PendingTable.$converterhomeIdn);
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, entity, homeId, body];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pending';
  @override
  VerificationContext validateIntegrity(
    Insertable<PendingRow> instance, {
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
    if (data.containsKey('entity')) {
      context.handle(
        _entityMeta,
        entity.isAcceptableOrUnknown(data['entity']!, _entityMeta),
      );
    } else if (isInserting) {
      context.missing(_entityMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  PendingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PendingRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      entity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity'],
      )!,
      homeId: $PendingTable.$converterhomeIdn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}home_id'],
        ),
      ),
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
    );
  }

  @override
  $PendingTable createAlias(String alias) {
    return $PendingTable(attachedDatabase, alias);
  }

  static TypeConverter<String, Uint8List> $converterhomeId =
      const UuidConverter();
  static TypeConverter<String?, Uint8List?> $converterhomeIdn =
      NullAwareTypeConverter.wrap($converterhomeId);
}

class PendingRow extends DataClass implements Insertable<PendingRow> {
  final String key;
  final String entity;
  final String? homeId;
  final String body;
  const PendingRow({
    required this.key,
    required this.entity,
    this.homeId,
    required this.body,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['entity'] = Variable<String>(entity);
    if (!nullToAbsent || homeId != null) {
      map['home_id'] = Variable<Uint8List>(
        $PendingTable.$converterhomeIdn.toSql(homeId),
      );
    }
    map['body'] = Variable<String>(body);
    return map;
  }

  PendingCompanion toCompanion(bool nullToAbsent) {
    return PendingCompanion(
      key: Value(key),
      entity: Value(entity),
      homeId: homeId == null && nullToAbsent
          ? const Value.absent()
          : Value(homeId),
      body: Value(body),
    );
  }

  factory PendingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PendingRow(
      key: serializer.fromJson<String>(json['key']),
      entity: serializer.fromJson<String>(json['entity']),
      homeId: serializer.fromJson<String?>(json['homeId']),
      body: serializer.fromJson<String>(json['body']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'entity': serializer.toJson<String>(entity),
      'homeId': serializer.toJson<String?>(homeId),
      'body': serializer.toJson<String>(body),
    };
  }

  PendingRow copyWith({
    String? key,
    String? entity,
    Value<String?> homeId = const Value.absent(),
    String? body,
  }) => PendingRow(
    key: key ?? this.key,
    entity: entity ?? this.entity,
    homeId: homeId.present ? homeId.value : this.homeId,
    body: body ?? this.body,
  );
  PendingRow copyWithCompanion(PendingCompanion data) {
    return PendingRow(
      key: data.key.present ? data.key.value : this.key,
      entity: data.entity.present ? data.entity.value : this.entity,
      homeId: data.homeId.present ? data.homeId.value : this.homeId,
      body: data.body.present ? data.body.value : this.body,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PendingRow(')
          ..write('key: $key, ')
          ..write('entity: $entity, ')
          ..write('homeId: $homeId, ')
          ..write('body: $body')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, entity, homeId, body);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PendingRow &&
          other.key == this.key &&
          other.entity == this.entity &&
          other.homeId == this.homeId &&
          other.body == this.body);
}

class PendingCompanion extends UpdateCompanion<PendingRow> {
  final Value<String> key;
  final Value<String> entity;
  final Value<String?> homeId;
  final Value<String> body;
  final Value<int> rowid;
  const PendingCompanion({
    this.key = const Value.absent(),
    this.entity = const Value.absent(),
    this.homeId = const Value.absent(),
    this.body = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PendingCompanion.insert({
    required String key,
    required String entity,
    this.homeId = const Value.absent(),
    required String body,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       entity = Value(entity),
       body = Value(body);
  static Insertable<PendingRow> custom({
    Expression<String>? key,
    Expression<String>? entity,
    Expression<Uint8List>? homeId,
    Expression<String>? body,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (entity != null) 'entity': entity,
      if (homeId != null) 'home_id': homeId,
      if (body != null) 'body': body,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PendingCompanion copyWith({
    Value<String>? key,
    Value<String>? entity,
    Value<String?>? homeId,
    Value<String>? body,
    Value<int>? rowid,
  }) {
    return PendingCompanion(
      key: key ?? this.key,
      entity: entity ?? this.entity,
      homeId: homeId ?? this.homeId,
      body: body ?? this.body,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (entity.present) {
      map['entity'] = Variable<String>(entity.value);
    }
    if (homeId.present) {
      map['home_id'] = Variable<Uint8List>(
        $PendingTable.$converterhomeIdn.toSql(homeId.value),
      );
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PendingCompanion(')
          ..write('key: $key, ')
          ..write('entity: $entity, ')
          ..write('homeId: $homeId, ')
          ..write('body: $body, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PurgedHomesTable extends PurgedHomes
    with TableInfo<$PurgedHomesTable, PurgedHomeRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PurgedHomesTable(this.attachedDatabase, [this._alias]);
  @override
  late final GeneratedColumnWithTypeConverter<String, Uint8List> homeId =
      GeneratedColumn<Uint8List>(
        'home_id',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      ).withConverter<String>($PurgedHomesTable.$converterhomeId);
  @override
  List<GeneratedColumn> get $columns => [homeId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'purged_homes';
  @override
  Set<GeneratedColumn> get $primaryKey => {homeId};
  @override
  PurgedHomeRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PurgedHomeRow(
      homeId: $PurgedHomesTable.$converterhomeId.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}home_id'],
        )!,
      ),
    );
  }

  @override
  $PurgedHomesTable createAlias(String alias) {
    return $PurgedHomesTable(attachedDatabase, alias);
  }

  static TypeConverter<String, Uint8List> $converterhomeId =
      const UuidConverter();
}

class PurgedHomeRow extends DataClass implements Insertable<PurgedHomeRow> {
  final String homeId;
  const PurgedHomeRow({required this.homeId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    {
      map['home_id'] = Variable<Uint8List>(
        $PurgedHomesTable.$converterhomeId.toSql(homeId),
      );
    }
    return map;
  }

  PurgedHomesCompanion toCompanion(bool nullToAbsent) {
    return PurgedHomesCompanion(homeId: Value(homeId));
  }

  factory PurgedHomeRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PurgedHomeRow(homeId: serializer.fromJson<String>(json['homeId']));
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{'homeId': serializer.toJson<String>(homeId)};
  }

  PurgedHomeRow copyWith({String? homeId}) =>
      PurgedHomeRow(homeId: homeId ?? this.homeId);
  PurgedHomeRow copyWithCompanion(PurgedHomesCompanion data) {
    return PurgedHomeRow(
      homeId: data.homeId.present ? data.homeId.value : this.homeId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PurgedHomeRow(')
          ..write('homeId: $homeId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => homeId.hashCode;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PurgedHomeRow && other.homeId == this.homeId);
}

class PurgedHomesCompanion extends UpdateCompanion<PurgedHomeRow> {
  final Value<String> homeId;
  final Value<int> rowid;
  const PurgedHomesCompanion({
    this.homeId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PurgedHomesCompanion.insert({
    required String homeId,
    this.rowid = const Value.absent(),
  }) : homeId = Value(homeId);
  static Insertable<PurgedHomeRow> custom({
    Expression<Uint8List>? homeId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (homeId != null) 'home_id': homeId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PurgedHomesCompanion copyWith({Value<String>? homeId, Value<int>? rowid}) {
    return PurgedHomesCompanion(
      homeId: homeId ?? this.homeId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (homeId.present) {
      map['home_id'] = Variable<Uint8List>(
        $PurgedHomesTable.$converterhomeId.toSql(homeId.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PurgedHomesCompanion(')
          ..write('homeId: $homeId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OtherVersionsTable extends OtherVersions
    with TableInfo<$OtherVersionsTable, OtherVersionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OtherVersionsTable(this.attachedDatabase, [this._alias]);
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
      ).withConverter<String>($OtherVersionsTable.$converterrowId);
  @override
  late final GeneratedColumnWithTypeConverter<String?, Uint8List> homeId =
      GeneratedColumn<Uint8List>(
        'home_id',
        aliasedName,
        true,
        type: DriftSqlType.blob,
        requiredDuringInsert: false,
      ).withConverter<String?>($OtherVersionsTable.$converterhomeIdn);
  static const VerificationMeta _fieldMeta = const VerificationMeta('field');
  @override
  late final GeneratedColumn<String> field = GeneratedColumn<String>(
    'field',
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
  static const VerificationMeta _keptUntilMeta = const VerificationMeta(
    'keptUntil',
  );
  @override
  late final GeneratedColumn<int> keptUntil = GeneratedColumn<int>(
    'kept_until',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    entity,
    rowId,
    homeId,
    field,
    value,
    hlc,
    device,
    keptUntil,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'other_versions';
  @override
  VerificationContext validateIntegrity(
    Insertable<OtherVersionRow> instance, {
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
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
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
    if (data.containsKey('kept_until')) {
      context.handle(
        _keptUntilMeta,
        keptUntil.isAcceptableOrUnknown(data['kept_until']!, _keptUntilMeta),
      );
    } else if (isInserting) {
      context.missing(_keptUntilMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {entity, rowId, field, hlc, device};
  @override
  OtherVersionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OtherVersionRow(
      entity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity'],
      )!,
      rowId: $OtherVersionsTable.$converterrowId.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}row_id'],
        )!,
      ),
      homeId: $OtherVersionsTable.$converterhomeIdn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}home_id'],
        ),
      ),
      field: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}field'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
      hlc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hlc'],
      )!,
      device: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}device'],
      )!,
      keptUntil: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}kept_until'],
      )!,
    );
  }

  @override
  $OtherVersionsTable createAlias(String alias) {
    return $OtherVersionsTable(attachedDatabase, alias);
  }

  static TypeConverter<String, Uint8List> $converterrowId =
      const UuidConverter();
  static TypeConverter<String, Uint8List> $converterhomeId =
      const UuidConverter();
  static TypeConverter<String?, Uint8List?> $converterhomeIdn =
      NullAwareTypeConverter.wrap($converterhomeId);
}

class OtherVersionRow extends DataClass implements Insertable<OtherVersionRow> {
  final String entity;
  final String rowId;
  final String? homeId;
  final String field;
  final String value;
  final String hlc;
  final Uint8List device;
  final int keptUntil;
  const OtherVersionRow({
    required this.entity,
    required this.rowId,
    this.homeId,
    required this.field,
    required this.value,
    required this.hlc,
    required this.device,
    required this.keptUntil,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['entity'] = Variable<String>(entity);
    {
      map['row_id'] = Variable<Uint8List>(
        $OtherVersionsTable.$converterrowId.toSql(rowId),
      );
    }
    if (!nullToAbsent || homeId != null) {
      map['home_id'] = Variable<Uint8List>(
        $OtherVersionsTable.$converterhomeIdn.toSql(homeId),
      );
    }
    map['field'] = Variable<String>(field);
    map['value'] = Variable<String>(value);
    map['hlc'] = Variable<String>(hlc);
    map['device'] = Variable<Uint8List>(device);
    map['kept_until'] = Variable<int>(keptUntil);
    return map;
  }

  OtherVersionsCompanion toCompanion(bool nullToAbsent) {
    return OtherVersionsCompanion(
      entity: Value(entity),
      rowId: Value(rowId),
      homeId: homeId == null && nullToAbsent
          ? const Value.absent()
          : Value(homeId),
      field: Value(field),
      value: Value(value),
      hlc: Value(hlc),
      device: Value(device),
      keptUntil: Value(keptUntil),
    );
  }

  factory OtherVersionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OtherVersionRow(
      entity: serializer.fromJson<String>(json['entity']),
      rowId: serializer.fromJson<String>(json['rowId']),
      homeId: serializer.fromJson<String?>(json['homeId']),
      field: serializer.fromJson<String>(json['field']),
      value: serializer.fromJson<String>(json['value']),
      hlc: serializer.fromJson<String>(json['hlc']),
      device: serializer.fromJson<Uint8List>(json['device']),
      keptUntil: serializer.fromJson<int>(json['keptUntil']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'entity': serializer.toJson<String>(entity),
      'rowId': serializer.toJson<String>(rowId),
      'homeId': serializer.toJson<String?>(homeId),
      'field': serializer.toJson<String>(field),
      'value': serializer.toJson<String>(value),
      'hlc': serializer.toJson<String>(hlc),
      'device': serializer.toJson<Uint8List>(device),
      'keptUntil': serializer.toJson<int>(keptUntil),
    };
  }

  OtherVersionRow copyWith({
    String? entity,
    String? rowId,
    Value<String?> homeId = const Value.absent(),
    String? field,
    String? value,
    String? hlc,
    Uint8List? device,
    int? keptUntil,
  }) => OtherVersionRow(
    entity: entity ?? this.entity,
    rowId: rowId ?? this.rowId,
    homeId: homeId.present ? homeId.value : this.homeId,
    field: field ?? this.field,
    value: value ?? this.value,
    hlc: hlc ?? this.hlc,
    device: device ?? this.device,
    keptUntil: keptUntil ?? this.keptUntil,
  );
  OtherVersionRow copyWithCompanion(OtherVersionsCompanion data) {
    return OtherVersionRow(
      entity: data.entity.present ? data.entity.value : this.entity,
      rowId: data.rowId.present ? data.rowId.value : this.rowId,
      homeId: data.homeId.present ? data.homeId.value : this.homeId,
      field: data.field.present ? data.field.value : this.field,
      value: data.value.present ? data.value.value : this.value,
      hlc: data.hlc.present ? data.hlc.value : this.hlc,
      device: data.device.present ? data.device.value : this.device,
      keptUntil: data.keptUntil.present ? data.keptUntil.value : this.keptUntil,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OtherVersionRow(')
          ..write('entity: $entity, ')
          ..write('rowId: $rowId, ')
          ..write('homeId: $homeId, ')
          ..write('field: $field, ')
          ..write('value: $value, ')
          ..write('hlc: $hlc, ')
          ..write('device: $device, ')
          ..write('keptUntil: $keptUntil')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    entity,
    rowId,
    homeId,
    field,
    value,
    hlc,
    $driftBlobEquality.hash(device),
    keptUntil,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OtherVersionRow &&
          other.entity == this.entity &&
          other.rowId == this.rowId &&
          other.homeId == this.homeId &&
          other.field == this.field &&
          other.value == this.value &&
          other.hlc == this.hlc &&
          $driftBlobEquality.equals(other.device, this.device) &&
          other.keptUntil == this.keptUntil);
}

class OtherVersionsCompanion extends UpdateCompanion<OtherVersionRow> {
  final Value<String> entity;
  final Value<String> rowId;
  final Value<String?> homeId;
  final Value<String> field;
  final Value<String> value;
  final Value<String> hlc;
  final Value<Uint8List> device;
  final Value<int> keptUntil;
  final Value<int> rowid;
  const OtherVersionsCompanion({
    this.entity = const Value.absent(),
    this.rowId = const Value.absent(),
    this.homeId = const Value.absent(),
    this.field = const Value.absent(),
    this.value = const Value.absent(),
    this.hlc = const Value.absent(),
    this.device = const Value.absent(),
    this.keptUntil = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OtherVersionsCompanion.insert({
    required String entity,
    required String rowId,
    this.homeId = const Value.absent(),
    required String field,
    required String value,
    required String hlc,
    required Uint8List device,
    required int keptUntil,
    this.rowid = const Value.absent(),
  }) : entity = Value(entity),
       rowId = Value(rowId),
       field = Value(field),
       value = Value(value),
       hlc = Value(hlc),
       device = Value(device),
       keptUntil = Value(keptUntil);
  static Insertable<OtherVersionRow> custom({
    Expression<String>? entity,
    Expression<Uint8List>? rowId,
    Expression<Uint8List>? homeId,
    Expression<String>? field,
    Expression<String>? value,
    Expression<String>? hlc,
    Expression<Uint8List>? device,
    Expression<int>? keptUntil,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (entity != null) 'entity': entity,
      if (rowId != null) 'row_id': rowId,
      if (homeId != null) 'home_id': homeId,
      if (field != null) 'field': field,
      if (value != null) 'value': value,
      if (hlc != null) 'hlc': hlc,
      if (device != null) 'device': device,
      if (keptUntil != null) 'kept_until': keptUntil,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OtherVersionsCompanion copyWith({
    Value<String>? entity,
    Value<String>? rowId,
    Value<String?>? homeId,
    Value<String>? field,
    Value<String>? value,
    Value<String>? hlc,
    Value<Uint8List>? device,
    Value<int>? keptUntil,
    Value<int>? rowid,
  }) {
    return OtherVersionsCompanion(
      entity: entity ?? this.entity,
      rowId: rowId ?? this.rowId,
      homeId: homeId ?? this.homeId,
      field: field ?? this.field,
      value: value ?? this.value,
      hlc: hlc ?? this.hlc,
      device: device ?? this.device,
      keptUntil: keptUntil ?? this.keptUntil,
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
        $OtherVersionsTable.$converterrowId.toSql(rowId.value),
      );
    }
    if (homeId.present) {
      map['home_id'] = Variable<Uint8List>(
        $OtherVersionsTable.$converterhomeIdn.toSql(homeId.value),
      );
    }
    if (field.present) {
      map['field'] = Variable<String>(field.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (hlc.present) {
      map['hlc'] = Variable<String>(hlc.value);
    }
    if (device.present) {
      map['device'] = Variable<Uint8List>(device.value);
    }
    if (keptUntil.present) {
      map['kept_until'] = Variable<int>(keptUntil.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OtherVersionsCompanion(')
          ..write('entity: $entity, ')
          ..write('rowId: $rowId, ')
          ..write('homeId: $homeId, ')
          ..write('field: $field, ')
          ..write('value: $value, ')
          ..write('hlc: $hlc, ')
          ..write('device: $device, ')
          ..write('keptUntil: $keptUntil, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ServerSeenTable extends ServerSeen
    with TableInfo<$ServerSeenTable, ServerSeenRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ServerSeenTable(this.attachedDatabase, [this._alias]);
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
      ).withConverter<String>($ServerSeenTable.$converterrowId);
  @override
  late final GeneratedColumnWithTypeConverter<String, Uint8List> homeId =
      GeneratedColumn<Uint8List>(
        'home_id',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      ).withConverter<String>($ServerSeenTable.$converterhomeId);
  @override
  List<GeneratedColumn> get $columns => [entity, rowId, homeId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'server_seen';
  @override
  VerificationContext validateIntegrity(
    Insertable<ServerSeenRow> instance, {
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {entity, rowId};
  @override
  ServerSeenRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ServerSeenRow(
      entity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity'],
      )!,
      rowId: $ServerSeenTable.$converterrowId.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}row_id'],
        )!,
      ),
      homeId: $ServerSeenTable.$converterhomeId.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}home_id'],
        )!,
      ),
    );
  }

  @override
  $ServerSeenTable createAlias(String alias) {
    return $ServerSeenTable(attachedDatabase, alias);
  }

  static TypeConverter<String, Uint8List> $converterrowId =
      const UuidConverter();
  static TypeConverter<String, Uint8List> $converterhomeId =
      const UuidConverter();
}

class ServerSeenRow extends DataClass implements Insertable<ServerSeenRow> {
  final String entity;
  final String rowId;
  final String homeId;
  const ServerSeenRow({
    required this.entity,
    required this.rowId,
    required this.homeId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['entity'] = Variable<String>(entity);
    {
      map['row_id'] = Variable<Uint8List>(
        $ServerSeenTable.$converterrowId.toSql(rowId),
      );
    }
    {
      map['home_id'] = Variable<Uint8List>(
        $ServerSeenTable.$converterhomeId.toSql(homeId),
      );
    }
    return map;
  }

  ServerSeenCompanion toCompanion(bool nullToAbsent) {
    return ServerSeenCompanion(
      entity: Value(entity),
      rowId: Value(rowId),
      homeId: Value(homeId),
    );
  }

  factory ServerSeenRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ServerSeenRow(
      entity: serializer.fromJson<String>(json['entity']),
      rowId: serializer.fromJson<String>(json['rowId']),
      homeId: serializer.fromJson<String>(json['homeId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'entity': serializer.toJson<String>(entity),
      'rowId': serializer.toJson<String>(rowId),
      'homeId': serializer.toJson<String>(homeId),
    };
  }

  ServerSeenRow copyWith({String? entity, String? rowId, String? homeId}) =>
      ServerSeenRow(
        entity: entity ?? this.entity,
        rowId: rowId ?? this.rowId,
        homeId: homeId ?? this.homeId,
      );
  ServerSeenRow copyWithCompanion(ServerSeenCompanion data) {
    return ServerSeenRow(
      entity: data.entity.present ? data.entity.value : this.entity,
      rowId: data.rowId.present ? data.rowId.value : this.rowId,
      homeId: data.homeId.present ? data.homeId.value : this.homeId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ServerSeenRow(')
          ..write('entity: $entity, ')
          ..write('rowId: $rowId, ')
          ..write('homeId: $homeId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(entity, rowId, homeId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ServerSeenRow &&
          other.entity == this.entity &&
          other.rowId == this.rowId &&
          other.homeId == this.homeId);
}

class ServerSeenCompanion extends UpdateCompanion<ServerSeenRow> {
  final Value<String> entity;
  final Value<String> rowId;
  final Value<String> homeId;
  final Value<int> rowid;
  const ServerSeenCompanion({
    this.entity = const Value.absent(),
    this.rowId = const Value.absent(),
    this.homeId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ServerSeenCompanion.insert({
    required String entity,
    required String rowId,
    required String homeId,
    this.rowid = const Value.absent(),
  }) : entity = Value(entity),
       rowId = Value(rowId),
       homeId = Value(homeId);
  static Insertable<ServerSeenRow> custom({
    Expression<String>? entity,
    Expression<Uint8List>? rowId,
    Expression<Uint8List>? homeId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (entity != null) 'entity': entity,
      if (rowId != null) 'row_id': rowId,
      if (homeId != null) 'home_id': homeId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ServerSeenCompanion copyWith({
    Value<String>? entity,
    Value<String>? rowId,
    Value<String>? homeId,
    Value<int>? rowid,
  }) {
    return ServerSeenCompanion(
      entity: entity ?? this.entity,
      rowId: rowId ?? this.rowId,
      homeId: homeId ?? this.homeId,
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
        $ServerSeenTable.$converterrowId.toSql(rowId.value),
      );
    }
    if (homeId.present) {
      map['home_id'] = Variable<Uint8List>(
        $ServerSeenTable.$converterhomeId.toSql(homeId.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ServerSeenCompanion(')
          ..write('entity: $entity, ')
          ..write('rowId: $rowId, ')
          ..write('homeId: $homeId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FileSyncTable extends FileSync
    with TableInfo<$FileSyncTable, FileSyncRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FileSyncTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _fileIdMeta = const VerificationMeta('fileId');
  @override
  late final GeneratedColumn<String> fileId = GeneratedColumn<String>(
    'file_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<String, Uint8List> homeId =
      GeneratedColumn<Uint8List>(
        'home_id',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      ).withConverter<String>($FileSyncTable.$converterhomeId);
  static const VerificationMeta _holderMeta = const VerificationMeta('holder');
  @override
  late final GeneratedColumn<String> holder = GeneratedColumn<String>(
    'holder',
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
      ).withConverter<String>($FileSyncTable.$converterrowId);
  static const VerificationMeta _directionMeta = const VerificationMeta(
    'direction',
  );
  @override
  late final GeneratedColumn<String> direction = GeneratedColumn<String>(
    'direction',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attemptsMeta = const VerificationMeta(
    'attempts',
  );
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _nextAtMeta = const VerificationMeta('nextAt');
  @override
  late final GeneratedColumn<int> nextAt = GeneratedColumn<int>(
    'next_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    fileId,
    homeId,
    holder,
    rowId,
    direction,
    state,
    attempts,
    nextAt,
    code,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'file_sync';
  @override
  VerificationContext validateIntegrity(
    Insertable<FileSyncRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('file_id')) {
      context.handle(
        _fileIdMeta,
        fileId.isAcceptableOrUnknown(data['file_id']!, _fileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_fileIdMeta);
    }
    if (data.containsKey('holder')) {
      context.handle(
        _holderMeta,
        holder.isAcceptableOrUnknown(data['holder']!, _holderMeta),
      );
    } else if (isInserting) {
      context.missing(_holderMeta);
    }
    if (data.containsKey('direction')) {
      context.handle(
        _directionMeta,
        direction.isAcceptableOrUnknown(data['direction']!, _directionMeta),
      );
    } else if (isInserting) {
      context.missing(_directionMeta);
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    } else if (isInserting) {
      context.missing(_stateMeta);
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    }
    if (data.containsKey('next_at')) {
      context.handle(
        _nextAtMeta,
        nextAt.isAcceptableOrUnknown(data['next_at']!, _nextAtMeta),
      );
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {fileId};
  @override
  FileSyncRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FileSyncRow(
      fileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_id'],
      )!,
      homeId: $FileSyncTable.$converterhomeId.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}home_id'],
        )!,
      ),
      holder: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}holder'],
      )!,
      rowId: $FileSyncTable.$converterrowId.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}row_id'],
        )!,
      ),
      direction: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}direction'],
      )!,
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
      nextAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}next_at'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      ),
    );
  }

  @override
  $FileSyncTable createAlias(String alias) {
    return $FileSyncTable(attachedDatabase, alias);
  }

  static TypeConverter<String, Uint8List> $converterhomeId =
      const UuidConverter();
  static TypeConverter<String, Uint8List> $converterrowId =
      const UuidConverter();
}

class FileSyncRow extends DataClass implements Insertable<FileSyncRow> {
  final String fileId;
  final String homeId;

  /// The table of the row that holds the file: `photos` or `project_files`.
  final String holder;
  final String rowId;
  final String direction;
  final String state;
  final int attempts;
  final int nextAt;
  final String? code;
  const FileSyncRow({
    required this.fileId,
    required this.homeId,
    required this.holder,
    required this.rowId,
    required this.direction,
    required this.state,
    required this.attempts,
    required this.nextAt,
    this.code,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['file_id'] = Variable<String>(fileId);
    {
      map['home_id'] = Variable<Uint8List>(
        $FileSyncTable.$converterhomeId.toSql(homeId),
      );
    }
    map['holder'] = Variable<String>(holder);
    {
      map['row_id'] = Variable<Uint8List>(
        $FileSyncTable.$converterrowId.toSql(rowId),
      );
    }
    map['direction'] = Variable<String>(direction);
    map['state'] = Variable<String>(state);
    map['attempts'] = Variable<int>(attempts);
    map['next_at'] = Variable<int>(nextAt);
    if (!nullToAbsent || code != null) {
      map['code'] = Variable<String>(code);
    }
    return map;
  }

  FileSyncCompanion toCompanion(bool nullToAbsent) {
    return FileSyncCompanion(
      fileId: Value(fileId),
      homeId: Value(homeId),
      holder: Value(holder),
      rowId: Value(rowId),
      direction: Value(direction),
      state: Value(state),
      attempts: Value(attempts),
      nextAt: Value(nextAt),
      code: code == null && nullToAbsent ? const Value.absent() : Value(code),
    );
  }

  factory FileSyncRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FileSyncRow(
      fileId: serializer.fromJson<String>(json['fileId']),
      homeId: serializer.fromJson<String>(json['homeId']),
      holder: serializer.fromJson<String>(json['holder']),
      rowId: serializer.fromJson<String>(json['rowId']),
      direction: serializer.fromJson<String>(json['direction']),
      state: serializer.fromJson<String>(json['state']),
      attempts: serializer.fromJson<int>(json['attempts']),
      nextAt: serializer.fromJson<int>(json['nextAt']),
      code: serializer.fromJson<String?>(json['code']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'fileId': serializer.toJson<String>(fileId),
      'homeId': serializer.toJson<String>(homeId),
      'holder': serializer.toJson<String>(holder),
      'rowId': serializer.toJson<String>(rowId),
      'direction': serializer.toJson<String>(direction),
      'state': serializer.toJson<String>(state),
      'attempts': serializer.toJson<int>(attempts),
      'nextAt': serializer.toJson<int>(nextAt),
      'code': serializer.toJson<String?>(code),
    };
  }

  FileSyncRow copyWith({
    String? fileId,
    String? homeId,
    String? holder,
    String? rowId,
    String? direction,
    String? state,
    int? attempts,
    int? nextAt,
    Value<String?> code = const Value.absent(),
  }) => FileSyncRow(
    fileId: fileId ?? this.fileId,
    homeId: homeId ?? this.homeId,
    holder: holder ?? this.holder,
    rowId: rowId ?? this.rowId,
    direction: direction ?? this.direction,
    state: state ?? this.state,
    attempts: attempts ?? this.attempts,
    nextAt: nextAt ?? this.nextAt,
    code: code.present ? code.value : this.code,
  );
  FileSyncRow copyWithCompanion(FileSyncCompanion data) {
    return FileSyncRow(
      fileId: data.fileId.present ? data.fileId.value : this.fileId,
      homeId: data.homeId.present ? data.homeId.value : this.homeId,
      holder: data.holder.present ? data.holder.value : this.holder,
      rowId: data.rowId.present ? data.rowId.value : this.rowId,
      direction: data.direction.present ? data.direction.value : this.direction,
      state: data.state.present ? data.state.value : this.state,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      nextAt: data.nextAt.present ? data.nextAt.value : this.nextAt,
      code: data.code.present ? data.code.value : this.code,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FileSyncRow(')
          ..write('fileId: $fileId, ')
          ..write('homeId: $homeId, ')
          ..write('holder: $holder, ')
          ..write('rowId: $rowId, ')
          ..write('direction: $direction, ')
          ..write('state: $state, ')
          ..write('attempts: $attempts, ')
          ..write('nextAt: $nextAt, ')
          ..write('code: $code')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    fileId,
    homeId,
    holder,
    rowId,
    direction,
    state,
    attempts,
    nextAt,
    code,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FileSyncRow &&
          other.fileId == this.fileId &&
          other.homeId == this.homeId &&
          other.holder == this.holder &&
          other.rowId == this.rowId &&
          other.direction == this.direction &&
          other.state == this.state &&
          other.attempts == this.attempts &&
          other.nextAt == this.nextAt &&
          other.code == this.code);
}

class FileSyncCompanion extends UpdateCompanion<FileSyncRow> {
  final Value<String> fileId;
  final Value<String> homeId;
  final Value<String> holder;
  final Value<String> rowId;
  final Value<String> direction;
  final Value<String> state;
  final Value<int> attempts;
  final Value<int> nextAt;
  final Value<String?> code;
  final Value<int> rowid;
  const FileSyncCompanion({
    this.fileId = const Value.absent(),
    this.homeId = const Value.absent(),
    this.holder = const Value.absent(),
    this.rowId = const Value.absent(),
    this.direction = const Value.absent(),
    this.state = const Value.absent(),
    this.attempts = const Value.absent(),
    this.nextAt = const Value.absent(),
    this.code = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FileSyncCompanion.insert({
    required String fileId,
    required String homeId,
    required String holder,
    required String rowId,
    required String direction,
    required String state,
    this.attempts = const Value.absent(),
    this.nextAt = const Value.absent(),
    this.code = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : fileId = Value(fileId),
       homeId = Value(homeId),
       holder = Value(holder),
       rowId = Value(rowId),
       direction = Value(direction),
       state = Value(state);
  static Insertable<FileSyncRow> custom({
    Expression<String>? fileId,
    Expression<Uint8List>? homeId,
    Expression<String>? holder,
    Expression<Uint8List>? rowId,
    Expression<String>? direction,
    Expression<String>? state,
    Expression<int>? attempts,
    Expression<int>? nextAt,
    Expression<String>? code,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (fileId != null) 'file_id': fileId,
      if (homeId != null) 'home_id': homeId,
      if (holder != null) 'holder': holder,
      if (rowId != null) 'row_id': rowId,
      if (direction != null) 'direction': direction,
      if (state != null) 'state': state,
      if (attempts != null) 'attempts': attempts,
      if (nextAt != null) 'next_at': nextAt,
      if (code != null) 'code': code,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FileSyncCompanion copyWith({
    Value<String>? fileId,
    Value<String>? homeId,
    Value<String>? holder,
    Value<String>? rowId,
    Value<String>? direction,
    Value<String>? state,
    Value<int>? attempts,
    Value<int>? nextAt,
    Value<String?>? code,
    Value<int>? rowid,
  }) {
    return FileSyncCompanion(
      fileId: fileId ?? this.fileId,
      homeId: homeId ?? this.homeId,
      holder: holder ?? this.holder,
      rowId: rowId ?? this.rowId,
      direction: direction ?? this.direction,
      state: state ?? this.state,
      attempts: attempts ?? this.attempts,
      nextAt: nextAt ?? this.nextAt,
      code: code ?? this.code,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (fileId.present) {
      map['file_id'] = Variable<String>(fileId.value);
    }
    if (homeId.present) {
      map['home_id'] = Variable<Uint8List>(
        $FileSyncTable.$converterhomeId.toSql(homeId.value),
      );
    }
    if (holder.present) {
      map['holder'] = Variable<String>(holder.value);
    }
    if (rowId.present) {
      map['row_id'] = Variable<Uint8List>(
        $FileSyncTable.$converterrowId.toSql(rowId.value),
      );
    }
    if (direction.present) {
      map['direction'] = Variable<String>(direction.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (nextAt.present) {
      map['next_at'] = Variable<int>(nextAt.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FileSyncCompanion(')
          ..write('fileId: $fileId, ')
          ..write('homeId: $homeId, ')
          ..write('holder: $holder, ')
          ..write('rowId: $rowId, ')
          ..write('direction: $direction, ')
          ..write('state: $state, ')
          ..write('attempts: $attempts, ')
          ..write('nextAt: $nextAt, ')
          ..write('code: $code, ')
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
  late final $ArticlesTable articles = $ArticlesTable(this);
  late final $ArticleRoomsTable articleRooms = $ArticleRoomsTable(this);
  late final $ArticleItemsTable articleItems = $ArticleItemsTable(this);
  late final $SuppliersTable suppliers = $SuppliersTable(this);
  late final $MovementsTable movements = $MovementsTable(this);
  late final $TaskMaterialsTable taskMaterials = $TaskMaterialsTable(this);
  late final $MaterialDrawsTable materialDraws = $MaterialDrawsTable(this);
  late final $ProjectsTable projects = $ProjectsTable(this);
  late final $ProjectRoomsTable projectRooms = $ProjectRoomsTable(this);
  late final $BudgetLinesTable budgetLines = $BudgetLinesTable(this);
  late final $QuotesTable quotes = $QuotesTable(this);
  late final $ProjectFilesTable projectFiles = $ProjectFilesTable(this);
  late final $ProjectLinksTable projectLinks = $ProjectLinksTable(this);
  late final $ProjectTasksTable projectTasks = $ProjectTasksTable(this);
  late final $AnnualEnvelopesTable annualEnvelopes = $AnnualEnvelopesTable(
    this,
  );
  late final $ReportsTable reports = $ReportsTable(this);
  late final $FieldClockTable fieldClock = $FieldClockTable(this);
  late final $LocalSettingsTable localSettings = $LocalSettingsTable(this);
  late final $OpLogTable opLog = $OpLogTable(this);
  late final $ExtraTable extra = $ExtraTable(this);
  late final $PendingTable pending = $PendingTable(this);
  late final $PurgedHomesTable purgedHomes = $PurgedHomesTable(this);
  late final $OtherVersionsTable otherVersions = $OtherVersionsTable(this);
  late final $ServerSeenTable serverSeen = $ServerSeenTable(this);
  late final $FileSyncTable fileSync = $FileSyncTable(this);
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
  late final Index articleHomeName = Index(
    'article_home_name',
    'CREATE INDEX article_home_name ON articles (home_id, name)',
  );
  late final Index movementArticle = Index(
    'movement_article',
    'CREATE INDEX movement_article ON movements (article_id)',
  );
  late final Index materialTask = Index(
    'material_task',
    'CREATE INDEX material_task ON task_materials (task_id)',
  );
  late final Index drawOccurrence = Index(
    'draw_occurrence',
    'CREATE INDEX draw_occurrence ON material_draws (occurrence_id)',
  );
  late final Index projectHomeStatus = Index(
    'project_home_status',
    'CREATE INDEX project_home_status ON projects (home_id, status)',
  );
  late final Index lineProject = Index(
    'line_project',
    'CREATE INDEX line_project ON budget_lines (project_id)',
  );
  late final Index quoteProject = Index(
    'quote_project',
    'CREATE INDEX quote_project ON quotes (project_id)',
  );
  late final Index reportHomeStatus = Index(
    'report_home_status',
    'CREATE INDEX report_home_status ON reports (home_id, status)',
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
    articles,
    articleRooms,
    articleItems,
    suppliers,
    movements,
    taskMaterials,
    materialDraws,
    projects,
    projectRooms,
    budgetLines,
    quotes,
    projectFiles,
    projectLinks,
    projectTasks,
    annualEnvelopes,
    reports,
    fieldClock,
    localSettings,
    opLog,
    extra,
    pending,
    purgedHomes,
    otherVersions,
    serverSeen,
    fileSync,
    roomHomePosition,
    taskHomeCreated,
    occHomeStatusDue,
    occTaskStatus,
    articleHomeName,
    movementArticle,
    materialTask,
    drawOccurrence,
    projectHomeStatus,
    lineProject,
    quoteProject,
    reportHomeStatus,
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
  Value<String?> paintArticleId,
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
  Value<String?> paintArticleId,
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

  ColumnWithTypeConverterFilters<String?, String, Uint8List>
  get paintArticleId => $composableBuilder(
    column: $table.paintArticleId,
    builder: (column) => ColumnWithTypeConverterFilters(column),
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

  ColumnOrderings<Uint8List> get paintArticleId => $composableBuilder(
    column: $table.paintArticleId,
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

  GeneratedColumnWithTypeConverter<String?, Uint8List> get paintArticleId =>
      $composableBuilder(
        column: $table.paintArticleId,
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
                Value<String?> paintArticleId = const Value.absent(),
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
                paintArticleId: paintArticleId,
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
                Value<String?> paintArticleId = const Value.absent(),
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
                paintArticleId: paintArticleId,
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
  Value<String?> purchasedOn,
  Value<int?> warrantyDuration,
  Value<String> warrantyDurationUnit,
  Value<String> warrantyProvider,
  Value<String> warrantyProviderName,
  Value<String?> warrantyStartsOn,
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
  Value<String?> purchasedOn,
  Value<int?> warrantyDuration,
  Value<String> warrantyDurationUnit,
  Value<String> warrantyProvider,
  Value<String> warrantyProviderName,
  Value<String?> warrantyStartsOn,
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

  ColumnFilters<String> get purchasedOn => $composableBuilder(
    column: $table.purchasedOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get warrantyDuration => $composableBuilder(
    column: $table.warrantyDuration,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get warrantyDurationUnit => $composableBuilder(
    column: $table.warrantyDurationUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get warrantyProvider => $composableBuilder(
    column: $table.warrantyProvider,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get warrantyProviderName => $composableBuilder(
    column: $table.warrantyProviderName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get warrantyStartsOn => $composableBuilder(
    column: $table.warrantyStartsOn,
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

  ColumnOrderings<String> get purchasedOn => $composableBuilder(
    column: $table.purchasedOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get warrantyDuration => $composableBuilder(
    column: $table.warrantyDuration,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get warrantyDurationUnit => $composableBuilder(
    column: $table.warrantyDurationUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get warrantyProvider => $composableBuilder(
    column: $table.warrantyProvider,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get warrantyProviderName => $composableBuilder(
    column: $table.warrantyProviderName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get warrantyStartsOn => $composableBuilder(
    column: $table.warrantyStartsOn,
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

  GeneratedColumn<String> get purchasedOn => $composableBuilder(
    column: $table.purchasedOn,
    builder: (column) => column,
  );

  GeneratedColumn<int> get warrantyDuration => $composableBuilder(
    column: $table.warrantyDuration,
    builder: (column) => column,
  );

  GeneratedColumn<String> get warrantyDurationUnit => $composableBuilder(
    column: $table.warrantyDurationUnit,
    builder: (column) => column,
  );

  GeneratedColumn<String> get warrantyProvider => $composableBuilder(
    column: $table.warrantyProvider,
    builder: (column) => column,
  );

  GeneratedColumn<String> get warrantyProviderName => $composableBuilder(
    column: $table.warrantyProviderName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get warrantyStartsOn => $composableBuilder(
    column: $table.warrantyStartsOn,
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
                Value<String?> purchasedOn = const Value.absent(),
                Value<int?> warrantyDuration = const Value.absent(),
                Value<String> warrantyDurationUnit = const Value.absent(),
                Value<String> warrantyProvider = const Value.absent(),
                Value<String> warrantyProviderName = const Value.absent(),
                Value<String?> warrantyStartsOn = const Value.absent(),
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
                purchasedOn: purchasedOn,
                warrantyDuration: warrantyDuration,
                warrantyDurationUnit: warrantyDurationUnit,
                warrantyProvider: warrantyProvider,
                warrantyProviderName: warrantyProviderName,
                warrantyStartsOn: warrantyStartsOn,
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
                Value<String?> purchasedOn = const Value.absent(),
                Value<int?> warrantyDuration = const Value.absent(),
                Value<String> warrantyDurationUnit = const Value.absent(),
                Value<String> warrantyProvider = const Value.absent(),
                Value<String> warrantyProviderName = const Value.absent(),
                Value<String?> warrantyStartsOn = const Value.absent(),
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
                purchasedOn: purchasedOn,
                warrantyDuration: warrantyDuration,
                warrantyDurationUnit: warrantyDurationUnit,
                warrantyProvider: warrantyProvider,
                warrantyProviderName: warrantyProviderName,
                warrantyStartsOn: warrantyStartsOn,
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
  Value<String?> materialBudget,
  Value<String?> labourBudget,
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
  Value<String?> materialBudget,
  Value<String?> labourBudget,
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

  ColumnFilters<String> get materialBudget => $composableBuilder(
    column: $table.materialBudget,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get labourBudget => $composableBuilder(
    column: $table.labourBudget,
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

  ColumnOrderings<String> get materialBudget => $composableBuilder(
    column: $table.materialBudget,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get labourBudget => $composableBuilder(
    column: $table.labourBudget,
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

  GeneratedColumn<String> get materialBudget => $composableBuilder(
    column: $table.materialBudget,
    builder: (column) => column,
  );

  GeneratedColumn<String> get labourBudget => $composableBuilder(
    column: $table.labourBudget,
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
                Value<String?> materialBudget = const Value.absent(),
                Value<String?> labourBudget = const Value.absent(),
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
                materialBudget: materialBudget,
                labourBudget: labourBudget,
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
                Value<String?> materialBudget = const Value.absent(),
                Value<String?> labourBudget = const Value.absent(),
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
                materialBudget: materialBudget,
                labourBudget: labourBudget,
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
      Value<String?> actualCost,
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
      Value<String?> actualCost,
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

  ColumnFilters<String> get actualCost => $composableBuilder(
    column: $table.actualCost,
    builder: (column) => ColumnFilters(column),
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

  ColumnOrderings<String> get actualCost => $composableBuilder(
    column: $table.actualCost,
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

  GeneratedColumn<String> get actualCost => $composableBuilder(
    column: $table.actualCost,
    builder: (column) => column,
  );
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
                Value<String?> actualCost = const Value.absent(),
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
                actualCost: actualCost,
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
                Value<String?> actualCost = const Value.absent(),
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
                actualCost: actualCost,
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
typedef $$ArticlesTableCreateCompanionBuilder = ArticlesCompanion Function({
  required String id,
  required int createdAt,
  required int updatedAt,
  Value<int?> deletedAt,
  required String homeId,
  required String name,
  Value<String> manufacturerReference,
  Value<String> dimensions,
  Value<String> storageLocation,
  Value<String> unit,
  Value<String> unitOther,
  Value<String?> threshold,
  Value<String?> unitPrice,
  Value<String> notes,
  Value<String?> label,
  Value<int> rowid,
});
typedef $$ArticlesTableUpdateCompanionBuilder = ArticlesCompanion Function({
  Value<String> id,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int?> deletedAt,
  Value<String> homeId,
  Value<String> name,
  Value<String> manufacturerReference,
  Value<String> dimensions,
  Value<String> storageLocation,
  Value<String> unit,
  Value<String> unitOther,
  Value<String?> threshold,
  Value<String?> unitPrice,
  Value<String> notes,
  Value<String?> label,
  Value<int> rowid,
});

class $$ArticlesTableFilterComposer
    extends Composer<_$AppDatabase, $ArticlesTable> {
  $$ArticlesTableFilterComposer({
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

  ColumnFilters<String> get manufacturerReference => $composableBuilder(
    column: $table.manufacturerReference,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dimensions => $composableBuilder(
    column: $table.dimensions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get storageLocation => $composableBuilder(
    column: $table.storageLocation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unitOther => $composableBuilder(
    column: $table.unitOther,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get threshold => $composableBuilder(
    column: $table.threshold,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unitPrice => $composableBuilder(
    column: $table.unitPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ArticlesTableOrderingComposer
    extends Composer<_$AppDatabase, $ArticlesTable> {
  $$ArticlesTableOrderingComposer({
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

  ColumnOrderings<String> get manufacturerReference => $composableBuilder(
    column: $table.manufacturerReference,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dimensions => $composableBuilder(
    column: $table.dimensions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get storageLocation => $composableBuilder(
    column: $table.storageLocation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unitOther => $composableBuilder(
    column: $table.unitOther,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get threshold => $composableBuilder(
    column: $table.threshold,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unitPrice => $composableBuilder(
    column: $table.unitPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ArticlesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ArticlesTable> {
  $$ArticlesTableAnnotationComposer({
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

  GeneratedColumn<String> get manufacturerReference => $composableBuilder(
    column: $table.manufacturerReference,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dimensions => $composableBuilder(
    column: $table.dimensions,
    builder: (column) => column,
  );

  GeneratedColumn<String> get storageLocation => $composableBuilder(
    column: $table.storageLocation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<String> get unitOther =>
      $composableBuilder(column: $table.unitOther, builder: (column) => column);

  GeneratedColumn<String> get threshold =>
      $composableBuilder(column: $table.threshold, builder: (column) => column);

  GeneratedColumn<String> get unitPrice =>
      $composableBuilder(column: $table.unitPrice, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);
}

class $$ArticlesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ArticlesTable,
          ArticleRow,
          $$ArticlesTableFilterComposer,
          $$ArticlesTableOrderingComposer,
          $$ArticlesTableAnnotationComposer,
          $$ArticlesTableCreateCompanionBuilder,
          $$ArticlesTableUpdateCompanionBuilder,
          (
            ArticleRow,
            BaseReferences<_$AppDatabase, $ArticlesTable, ArticleRow>,
          ),
          ArticleRow,
          PrefetchHooks Function()
        > {
  $$ArticlesTableTableManager(_$AppDatabase db, $ArticlesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ArticlesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ArticlesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ArticlesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<String> homeId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> manufacturerReference = const Value.absent(),
                Value<String> dimensions = const Value.absent(),
                Value<String> storageLocation = const Value.absent(),
                Value<String> unit = const Value.absent(),
                Value<String> unitOther = const Value.absent(),
                Value<String?> threshold = const Value.absent(),
                Value<String?> unitPrice = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<String?> label = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ArticlesCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                homeId: homeId,
                name: name,
                manufacturerReference: manufacturerReference,
                dimensions: dimensions,
                storageLocation: storageLocation,
                unit: unit,
                unitOther: unitOther,
                threshold: threshold,
                unitPrice: unitPrice,
                notes: notes,
                label: label,
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
                Value<String> manufacturerReference = const Value.absent(),
                Value<String> dimensions = const Value.absent(),
                Value<String> storageLocation = const Value.absent(),
                Value<String> unit = const Value.absent(),
                Value<String> unitOther = const Value.absent(),
                Value<String?> threshold = const Value.absent(),
                Value<String?> unitPrice = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<String?> label = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ArticlesCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                homeId: homeId,
                name: name,
                manufacturerReference: manufacturerReference,
                dimensions: dimensions,
                storageLocation: storageLocation,
                unit: unit,
                unitOther: unitOther,
                threshold: threshold,
                unitPrice: unitPrice,
                notes: notes,
                label: label,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ArticlesTable, ArticleRow>(table),
                  BaseReferences<_$AppDatabase, $ArticlesTable, ArticleRow>(
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

typedef $$ArticlesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ArticlesTable,
      ArticleRow,
      $$ArticlesTableFilterComposer,
      $$ArticlesTableOrderingComposer,
      $$ArticlesTableAnnotationComposer,
      $$ArticlesTableCreateCompanionBuilder,
      $$ArticlesTableUpdateCompanionBuilder,
      (ArticleRow, BaseReferences<_$AppDatabase, $ArticlesTable, ArticleRow>),
      ArticleRow,
      PrefetchHooks Function()
    >;
typedef $$ArticleRoomsTableCreateCompanionBuilder =
    ArticleRoomsCompanion Function({
      required String id,
      required int createdAt,
      required int updatedAt,
      Value<int?> deletedAt,
      required String homeId,
      required String articleId,
      required String roomId,
      Value<int> rowid,
    });
typedef $$ArticleRoomsTableUpdateCompanionBuilder =
    ArticleRoomsCompanion Function({
      Value<String> id,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int?> deletedAt,
      Value<String> homeId,
      Value<String> articleId,
      Value<String> roomId,
      Value<int> rowid,
    });

class $$ArticleRoomsTableFilterComposer
    extends Composer<_$AppDatabase, $ArticleRoomsTable> {
  $$ArticleRoomsTableFilterComposer({
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

  ColumnWithTypeConverterFilters<String, String, Uint8List> get articleId =>
      $composableBuilder(
        column: $table.articleId,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<String, String, Uint8List> get roomId =>
      $composableBuilder(
        column: $table.roomId,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );
}

class $$ArticleRoomsTableOrderingComposer
    extends Composer<_$AppDatabase, $ArticleRoomsTable> {
  $$ArticleRoomsTableOrderingComposer({
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

  ColumnOrderings<Uint8List> get articleId => $composableBuilder(
    column: $table.articleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get roomId => $composableBuilder(
    column: $table.roomId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ArticleRoomsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ArticleRoomsTable> {
  $$ArticleRoomsTableAnnotationComposer({
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

  GeneratedColumnWithTypeConverter<String, Uint8List> get articleId =>
      $composableBuilder(column: $table.articleId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<String, Uint8List> get roomId =>
      $composableBuilder(column: $table.roomId, builder: (column) => column);
}

class $$ArticleRoomsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ArticleRoomsTable,
          ArticleRoomRow,
          $$ArticleRoomsTableFilterComposer,
          $$ArticleRoomsTableOrderingComposer,
          $$ArticleRoomsTableAnnotationComposer,
          $$ArticleRoomsTableCreateCompanionBuilder,
          $$ArticleRoomsTableUpdateCompanionBuilder,
          (
            ArticleRoomRow,
            BaseReferences<_$AppDatabase, $ArticleRoomsTable, ArticleRoomRow>,
          ),
          ArticleRoomRow,
          PrefetchHooks Function()
        > {
  $$ArticleRoomsTableTableManager(_$AppDatabase db, $ArticleRoomsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ArticleRoomsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ArticleRoomsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ArticleRoomsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<String> homeId = const Value.absent(),
                Value<String> articleId = const Value.absent(),
                Value<String> roomId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ArticleRoomsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                homeId: homeId,
                articleId: articleId,
                roomId: roomId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                required String homeId,
                required String articleId,
                required String roomId,
                Value<int> rowid = const Value.absent(),
              }) => ArticleRoomsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                homeId: homeId,
                articleId: articleId,
                roomId: roomId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ArticleRoomsTable, ArticleRoomRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $ArticleRoomsTable,
                    ArticleRoomRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ArticleRoomsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ArticleRoomsTable,
      ArticleRoomRow,
      $$ArticleRoomsTableFilterComposer,
      $$ArticleRoomsTableOrderingComposer,
      $$ArticleRoomsTableAnnotationComposer,
      $$ArticleRoomsTableCreateCompanionBuilder,
      $$ArticleRoomsTableUpdateCompanionBuilder,
      (
        ArticleRoomRow,
        BaseReferences<_$AppDatabase, $ArticleRoomsTable, ArticleRoomRow>,
      ),
      ArticleRoomRow,
      PrefetchHooks Function()
    >;
typedef $$ArticleItemsTableCreateCompanionBuilder =
    ArticleItemsCompanion Function({
      required String id,
      required int createdAt,
      required int updatedAt,
      Value<int?> deletedAt,
      required String homeId,
      required String articleId,
      required String itemId,
      Value<int> rowid,
    });
typedef $$ArticleItemsTableUpdateCompanionBuilder =
    ArticleItemsCompanion Function({
      Value<String> id,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int?> deletedAt,
      Value<String> homeId,
      Value<String> articleId,
      Value<String> itemId,
      Value<int> rowid,
    });

class $$ArticleItemsTableFilterComposer
    extends Composer<_$AppDatabase, $ArticleItemsTable> {
  $$ArticleItemsTableFilterComposer({
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

  ColumnWithTypeConverterFilters<String, String, Uint8List> get articleId =>
      $composableBuilder(
        column: $table.articleId,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<String, String, Uint8List> get itemId =>
      $composableBuilder(
        column: $table.itemId,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );
}

class $$ArticleItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $ArticleItemsTable> {
  $$ArticleItemsTableOrderingComposer({
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

  ColumnOrderings<Uint8List> get articleId => $composableBuilder(
    column: $table.articleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ArticleItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ArticleItemsTable> {
  $$ArticleItemsTableAnnotationComposer({
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

  GeneratedColumnWithTypeConverter<String, Uint8List> get articleId =>
      $composableBuilder(column: $table.articleId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<String, Uint8List> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);
}

class $$ArticleItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ArticleItemsTable,
          ArticleItemRow,
          $$ArticleItemsTableFilterComposer,
          $$ArticleItemsTableOrderingComposer,
          $$ArticleItemsTableAnnotationComposer,
          $$ArticleItemsTableCreateCompanionBuilder,
          $$ArticleItemsTableUpdateCompanionBuilder,
          (
            ArticleItemRow,
            BaseReferences<_$AppDatabase, $ArticleItemsTable, ArticleItemRow>,
          ),
          ArticleItemRow,
          PrefetchHooks Function()
        > {
  $$ArticleItemsTableTableManager(_$AppDatabase db, $ArticleItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ArticleItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ArticleItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ArticleItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<String> homeId = const Value.absent(),
                Value<String> articleId = const Value.absent(),
                Value<String> itemId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ArticleItemsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                homeId: homeId,
                articleId: articleId,
                itemId: itemId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                required String homeId,
                required String articleId,
                required String itemId,
                Value<int> rowid = const Value.absent(),
              }) => ArticleItemsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                homeId: homeId,
                articleId: articleId,
                itemId: itemId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ArticleItemsTable, ArticleItemRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $ArticleItemsTable,
                    ArticleItemRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ArticleItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ArticleItemsTable,
      ArticleItemRow,
      $$ArticleItemsTableFilterComposer,
      $$ArticleItemsTableOrderingComposer,
      $$ArticleItemsTableAnnotationComposer,
      $$ArticleItemsTableCreateCompanionBuilder,
      $$ArticleItemsTableUpdateCompanionBuilder,
      (
        ArticleItemRow,
        BaseReferences<_$AppDatabase, $ArticleItemsTable, ArticleItemRow>,
      ),
      ArticleItemRow,
      PrefetchHooks Function()
    >;
typedef $$SuppliersTableCreateCompanionBuilder = SuppliersCompanion Function({
  required String id,
  required int createdAt,
  required int updatedAt,
  Value<int?> deletedAt,
  required String homeId,
  required String articleId,
  required String name,
  Value<String> reference,
  Value<String> url,
  Value<String?> lastPrice,
  Value<int> rowid,
});
typedef $$SuppliersTableUpdateCompanionBuilder = SuppliersCompanion Function({
  Value<String> id,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int?> deletedAt,
  Value<String> homeId,
  Value<String> articleId,
  Value<String> name,
  Value<String> reference,
  Value<String> url,
  Value<String?> lastPrice,
  Value<int> rowid,
});

class $$SuppliersTableFilterComposer
    extends Composer<_$AppDatabase, $SuppliersTable> {
  $$SuppliersTableFilterComposer({
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

  ColumnWithTypeConverterFilters<String, String, Uint8List> get articleId =>
      $composableBuilder(
        column: $table.articleId,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reference => $composableBuilder(
    column: $table.reference,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastPrice => $composableBuilder(
    column: $table.lastPrice,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SuppliersTableOrderingComposer
    extends Composer<_$AppDatabase, $SuppliersTable> {
  $$SuppliersTableOrderingComposer({
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

  ColumnOrderings<Uint8List> get articleId => $composableBuilder(
    column: $table.articleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reference => $composableBuilder(
    column: $table.reference,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastPrice => $composableBuilder(
    column: $table.lastPrice,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SuppliersTableAnnotationComposer
    extends Composer<_$AppDatabase, $SuppliersTable> {
  $$SuppliersTableAnnotationComposer({
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

  GeneratedColumnWithTypeConverter<String, Uint8List> get articleId =>
      $composableBuilder(column: $table.articleId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get reference =>
      $composableBuilder(column: $table.reference, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get lastPrice =>
      $composableBuilder(column: $table.lastPrice, builder: (column) => column);
}

class $$SuppliersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SuppliersTable,
          SupplierRow,
          $$SuppliersTableFilterComposer,
          $$SuppliersTableOrderingComposer,
          $$SuppliersTableAnnotationComposer,
          $$SuppliersTableCreateCompanionBuilder,
          $$SuppliersTableUpdateCompanionBuilder,
          (
            SupplierRow,
            BaseReferences<_$AppDatabase, $SuppliersTable, SupplierRow>,
          ),
          SupplierRow,
          PrefetchHooks Function()
        > {
  $$SuppliersTableTableManager(_$AppDatabase db, $SuppliersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SuppliersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SuppliersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SuppliersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<String> homeId = const Value.absent(),
                Value<String> articleId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> reference = const Value.absent(),
                Value<String> url = const Value.absent(),
                Value<String?> lastPrice = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SuppliersCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                homeId: homeId,
                articleId: articleId,
                name: name,
                reference: reference,
                url: url,
                lastPrice: lastPrice,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                required String homeId,
                required String articleId,
                required String name,
                Value<String> reference = const Value.absent(),
                Value<String> url = const Value.absent(),
                Value<String?> lastPrice = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SuppliersCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                homeId: homeId,
                articleId: articleId,
                name: name,
                reference: reference,
                url: url,
                lastPrice: lastPrice,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SuppliersTable, SupplierRow>(table),
                  BaseReferences<_$AppDatabase, $SuppliersTable, SupplierRow>(
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

typedef $$SuppliersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SuppliersTable,
      SupplierRow,
      $$SuppliersTableFilterComposer,
      $$SuppliersTableOrderingComposer,
      $$SuppliersTableAnnotationComposer,
      $$SuppliersTableCreateCompanionBuilder,
      $$SuppliersTableUpdateCompanionBuilder,
      (
        SupplierRow,
        BaseReferences<_$AppDatabase, $SuppliersTable, SupplierRow>,
      ),
      SupplierRow,
      PrefetchHooks Function()
    >;
typedef $$MovementsTableCreateCompanionBuilder = MovementsCompanion Function({
  required String id,
  required int createdAt,
  required int updatedAt,
  Value<int?> deletedAt,
  required String homeId,
  required String articleId,
  required String kind,
  required String quantity,
  required String occurredOn,
  Value<String> note,
  Value<String?> occurrenceId,
  Value<int> rowid,
});
typedef $$MovementsTableUpdateCompanionBuilder = MovementsCompanion Function({
  Value<String> id,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int?> deletedAt,
  Value<String> homeId,
  Value<String> articleId,
  Value<String> kind,
  Value<String> quantity,
  Value<String> occurredOn,
  Value<String> note,
  Value<String?> occurrenceId,
  Value<int> rowid,
});

class $$MovementsTableFilterComposer
    extends Composer<_$AppDatabase, $MovementsTable> {
  $$MovementsTableFilterComposer({
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

  ColumnWithTypeConverterFilters<String, String, Uint8List> get articleId =>
      $composableBuilder(
        column: $table.articleId,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get occurredOn => $composableBuilder(
    column: $table.occurredOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<String?, String, Uint8List> get occurrenceId =>
      $composableBuilder(
        column: $table.occurrenceId,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );
}

class $$MovementsTableOrderingComposer
    extends Composer<_$AppDatabase, $MovementsTable> {
  $$MovementsTableOrderingComposer({
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

  ColumnOrderings<Uint8List> get articleId => $composableBuilder(
    column: $table.articleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get occurredOn => $composableBuilder(
    column: $table.occurredOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get occurrenceId => $composableBuilder(
    column: $table.occurrenceId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MovementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MovementsTable> {
  $$MovementsTableAnnotationComposer({
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

  GeneratedColumnWithTypeConverter<String, Uint8List> get articleId =>
      $composableBuilder(column: $table.articleId, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<String> get occurredOn => $composableBuilder(
    column: $table.occurredOn,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumnWithTypeConverter<String?, Uint8List> get occurrenceId =>
      $composableBuilder(
        column: $table.occurrenceId,
        builder: (column) => column,
      );
}

class $$MovementsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MovementsTable,
          MovementRow,
          $$MovementsTableFilterComposer,
          $$MovementsTableOrderingComposer,
          $$MovementsTableAnnotationComposer,
          $$MovementsTableCreateCompanionBuilder,
          $$MovementsTableUpdateCompanionBuilder,
          (
            MovementRow,
            BaseReferences<_$AppDatabase, $MovementsTable, MovementRow>,
          ),
          MovementRow,
          PrefetchHooks Function()
        > {
  $$MovementsTableTableManager(_$AppDatabase db, $MovementsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MovementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MovementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MovementsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<String> homeId = const Value.absent(),
                Value<String> articleId = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> quantity = const Value.absent(),
                Value<String> occurredOn = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<String?> occurrenceId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MovementsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                homeId: homeId,
                articleId: articleId,
                kind: kind,
                quantity: quantity,
                occurredOn: occurredOn,
                note: note,
                occurrenceId: occurrenceId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                required String homeId,
                required String articleId,
                required String kind,
                required String quantity,
                required String occurredOn,
                Value<String> note = const Value.absent(),
                Value<String?> occurrenceId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MovementsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                homeId: homeId,
                articleId: articleId,
                kind: kind,
                quantity: quantity,
                occurredOn: occurredOn,
                note: note,
                occurrenceId: occurrenceId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MovementsTable, MovementRow>(table),
                  BaseReferences<_$AppDatabase, $MovementsTable, MovementRow>(
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

typedef $$MovementsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MovementsTable,
      MovementRow,
      $$MovementsTableFilterComposer,
      $$MovementsTableOrderingComposer,
      $$MovementsTableAnnotationComposer,
      $$MovementsTableCreateCompanionBuilder,
      $$MovementsTableUpdateCompanionBuilder,
      (
        MovementRow,
        BaseReferences<_$AppDatabase, $MovementsTable, MovementRow>,
      ),
      MovementRow,
      PrefetchHooks Function()
    >;
typedef $$TaskMaterialsTableCreateCompanionBuilder =
    TaskMaterialsCompanion Function({
      required String id,
      required int createdAt,
      required int updatedAt,
      Value<int?> deletedAt,
      required String homeId,
      required String taskId,
      required String articleId,
      required String quantity,
      Value<int> rowid,
    });
typedef $$TaskMaterialsTableUpdateCompanionBuilder =
    TaskMaterialsCompanion Function({
      Value<String> id,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int?> deletedAt,
      Value<String> homeId,
      Value<String> taskId,
      Value<String> articleId,
      Value<String> quantity,
      Value<int> rowid,
    });

class $$TaskMaterialsTableFilterComposer
    extends Composer<_$AppDatabase, $TaskMaterialsTable> {
  $$TaskMaterialsTableFilterComposer({
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

  ColumnWithTypeConverterFilters<String, String, Uint8List> get articleId =>
      $composableBuilder(
        column: $table.articleId,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TaskMaterialsTableOrderingComposer
    extends Composer<_$AppDatabase, $TaskMaterialsTable> {
  $$TaskMaterialsTableOrderingComposer({
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

  ColumnOrderings<Uint8List> get articleId => $composableBuilder(
    column: $table.articleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TaskMaterialsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TaskMaterialsTable> {
  $$TaskMaterialsTableAnnotationComposer({
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

  GeneratedColumnWithTypeConverter<String, Uint8List> get articleId =>
      $composableBuilder(column: $table.articleId, builder: (column) => column);

  GeneratedColumn<String> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);
}

class $$TaskMaterialsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TaskMaterialsTable,
          TaskMaterialRow,
          $$TaskMaterialsTableFilterComposer,
          $$TaskMaterialsTableOrderingComposer,
          $$TaskMaterialsTableAnnotationComposer,
          $$TaskMaterialsTableCreateCompanionBuilder,
          $$TaskMaterialsTableUpdateCompanionBuilder,
          (
            TaskMaterialRow,
            BaseReferences<_$AppDatabase, $TaskMaterialsTable, TaskMaterialRow>,
          ),
          TaskMaterialRow,
          PrefetchHooks Function()
        > {
  $$TaskMaterialsTableTableManager(_$AppDatabase db, $TaskMaterialsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TaskMaterialsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TaskMaterialsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TaskMaterialsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<String> homeId = const Value.absent(),
                Value<String> taskId = const Value.absent(),
                Value<String> articleId = const Value.absent(),
                Value<String> quantity = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TaskMaterialsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                homeId: homeId,
                taskId: taskId,
                articleId: articleId,
                quantity: quantity,
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
                required String articleId,
                required String quantity,
                Value<int> rowid = const Value.absent(),
              }) => TaskMaterialsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                homeId: homeId,
                taskId: taskId,
                articleId: articleId,
                quantity: quantity,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TaskMaterialsTable, TaskMaterialRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $TaskMaterialsTable,
                    TaskMaterialRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TaskMaterialsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TaskMaterialsTable,
      TaskMaterialRow,
      $$TaskMaterialsTableFilterComposer,
      $$TaskMaterialsTableOrderingComposer,
      $$TaskMaterialsTableAnnotationComposer,
      $$TaskMaterialsTableCreateCompanionBuilder,
      $$TaskMaterialsTableUpdateCompanionBuilder,
      (
        TaskMaterialRow,
        BaseReferences<_$AppDatabase, $TaskMaterialsTable, TaskMaterialRow>,
      ),
      TaskMaterialRow,
      PrefetchHooks Function()
    >;
typedef $$MaterialDrawsTableCreateCompanionBuilder =
    MaterialDrawsCompanion Function({
      required String id,
      required int createdAt,
      required int updatedAt,
      Value<int?> deletedAt,
      required String homeId,
      required String occurrenceId,
      required String articleId,
      required String wanted,
      required String drawn,
      Value<int> rowid,
    });
typedef $$MaterialDrawsTableUpdateCompanionBuilder =
    MaterialDrawsCompanion Function({
      Value<String> id,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int?> deletedAt,
      Value<String> homeId,
      Value<String> occurrenceId,
      Value<String> articleId,
      Value<String> wanted,
      Value<String> drawn,
      Value<int> rowid,
    });

class $$MaterialDrawsTableFilterComposer
    extends Composer<_$AppDatabase, $MaterialDrawsTable> {
  $$MaterialDrawsTableFilterComposer({
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

  ColumnWithTypeConverterFilters<String, String, Uint8List> get occurrenceId =>
      $composableBuilder(
        column: $table.occurrenceId,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<String, String, Uint8List> get articleId =>
      $composableBuilder(
        column: $table.articleId,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get wanted => $composableBuilder(
    column: $table.wanted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get drawn => $composableBuilder(
    column: $table.drawn,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MaterialDrawsTableOrderingComposer
    extends Composer<_$AppDatabase, $MaterialDrawsTable> {
  $$MaterialDrawsTableOrderingComposer({
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

  ColumnOrderings<Uint8List> get occurrenceId => $composableBuilder(
    column: $table.occurrenceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get articleId => $composableBuilder(
    column: $table.articleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get wanted => $composableBuilder(
    column: $table.wanted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get drawn => $composableBuilder(
    column: $table.drawn,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MaterialDrawsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MaterialDrawsTable> {
  $$MaterialDrawsTableAnnotationComposer({
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

  GeneratedColumnWithTypeConverter<String, Uint8List> get occurrenceId =>
      $composableBuilder(
        column: $table.occurrenceId,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<String, Uint8List> get articleId =>
      $composableBuilder(column: $table.articleId, builder: (column) => column);

  GeneratedColumn<String> get wanted =>
      $composableBuilder(column: $table.wanted, builder: (column) => column);

  GeneratedColumn<String> get drawn =>
      $composableBuilder(column: $table.drawn, builder: (column) => column);
}

class $$MaterialDrawsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MaterialDrawsTable,
          MaterialDrawRow,
          $$MaterialDrawsTableFilterComposer,
          $$MaterialDrawsTableOrderingComposer,
          $$MaterialDrawsTableAnnotationComposer,
          $$MaterialDrawsTableCreateCompanionBuilder,
          $$MaterialDrawsTableUpdateCompanionBuilder,
          (
            MaterialDrawRow,
            BaseReferences<_$AppDatabase, $MaterialDrawsTable, MaterialDrawRow>,
          ),
          MaterialDrawRow,
          PrefetchHooks Function()
        > {
  $$MaterialDrawsTableTableManager(_$AppDatabase db, $MaterialDrawsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MaterialDrawsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MaterialDrawsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MaterialDrawsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<String> homeId = const Value.absent(),
                Value<String> occurrenceId = const Value.absent(),
                Value<String> articleId = const Value.absent(),
                Value<String> wanted = const Value.absent(),
                Value<String> drawn = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MaterialDrawsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                homeId: homeId,
                occurrenceId: occurrenceId,
                articleId: articleId,
                wanted: wanted,
                drawn: drawn,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                required String homeId,
                required String occurrenceId,
                required String articleId,
                required String wanted,
                required String drawn,
                Value<int> rowid = const Value.absent(),
              }) => MaterialDrawsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                homeId: homeId,
                occurrenceId: occurrenceId,
                articleId: articleId,
                wanted: wanted,
                drawn: drawn,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MaterialDrawsTable, MaterialDrawRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $MaterialDrawsTable,
                    MaterialDrawRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MaterialDrawsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MaterialDrawsTable,
      MaterialDrawRow,
      $$MaterialDrawsTableFilterComposer,
      $$MaterialDrawsTableOrderingComposer,
      $$MaterialDrawsTableAnnotationComposer,
      $$MaterialDrawsTableCreateCompanionBuilder,
      $$MaterialDrawsTableUpdateCompanionBuilder,
      (
        MaterialDrawRow,
        BaseReferences<_$AppDatabase, $MaterialDrawsTable, MaterialDrawRow>,
      ),
      MaterialDrawRow,
      PrefetchHooks Function()
    >;
typedef $$ProjectsTableCreateCompanionBuilder = ProjectsCompanion Function({
  required String id,
  required int createdAt,
  required int updatedAt,
  Value<int?> deletedAt,
  required String homeId,
  required String title,
  Value<String> goal,
  Value<String> status,
  Value<String> priority,
  Value<int?> estimatedMinutes,
  Value<String> season,
  Value<int?> seasonStartMonth,
  Value<int?> seasonEndMonth,
  Value<int> rowid,
});
typedef $$ProjectsTableUpdateCompanionBuilder = ProjectsCompanion Function({
  Value<String> id,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int?> deletedAt,
  Value<String> homeId,
  Value<String> title,
  Value<String> goal,
  Value<String> status,
  Value<String> priority,
  Value<int?> estimatedMinutes,
  Value<String> season,
  Value<int?> seasonStartMonth,
  Value<int?> seasonEndMonth,
  Value<int> rowid,
});

class $$ProjectsTableFilterComposer
    extends Composer<_$AppDatabase, $ProjectsTable> {
  $$ProjectsTableFilterComposer({
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

  ColumnFilters<String> get goal => $composableBuilder(
    column: $table.goal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get estimatedMinutes => $composableBuilder(
    column: $table.estimatedMinutes,
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
}

class $$ProjectsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProjectsTable> {
  $$ProjectsTableOrderingComposer({
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

  ColumnOrderings<String> get goal => $composableBuilder(
    column: $table.goal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
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
}

class $$ProjectsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProjectsTable> {
  $$ProjectsTableAnnotationComposer({
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

  GeneratedColumn<String> get goal =>
      $composableBuilder(column: $table.goal, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<int> get estimatedMinutes => $composableBuilder(
    column: $table.estimatedMinutes,
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
}

class $$ProjectsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProjectsTable,
          ProjectRow,
          $$ProjectsTableFilterComposer,
          $$ProjectsTableOrderingComposer,
          $$ProjectsTableAnnotationComposer,
          $$ProjectsTableCreateCompanionBuilder,
          $$ProjectsTableUpdateCompanionBuilder,
          (
            ProjectRow,
            BaseReferences<_$AppDatabase, $ProjectsTable, ProjectRow>,
          ),
          ProjectRow,
          PrefetchHooks Function()
        > {
  $$ProjectsTableTableManager(_$AppDatabase db, $ProjectsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProjectsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProjectsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProjectsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<String> homeId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> goal = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> priority = const Value.absent(),
                Value<int?> estimatedMinutes = const Value.absent(),
                Value<String> season = const Value.absent(),
                Value<int?> seasonStartMonth = const Value.absent(),
                Value<int?> seasonEndMonth = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProjectsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                homeId: homeId,
                title: title,
                goal: goal,
                status: status,
                priority: priority,
                estimatedMinutes: estimatedMinutes,
                season: season,
                seasonStartMonth: seasonStartMonth,
                seasonEndMonth: seasonEndMonth,
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
                Value<String> goal = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> priority = const Value.absent(),
                Value<int?> estimatedMinutes = const Value.absent(),
                Value<String> season = const Value.absent(),
                Value<int?> seasonStartMonth = const Value.absent(),
                Value<int?> seasonEndMonth = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProjectsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                homeId: homeId,
                title: title,
                goal: goal,
                status: status,
                priority: priority,
                estimatedMinutes: estimatedMinutes,
                season: season,
                seasonStartMonth: seasonStartMonth,
                seasonEndMonth: seasonEndMonth,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ProjectsTable, ProjectRow>(table),
                  BaseReferences<_$AppDatabase, $ProjectsTable, ProjectRow>(
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

typedef $$ProjectsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProjectsTable,
      ProjectRow,
      $$ProjectsTableFilterComposer,
      $$ProjectsTableOrderingComposer,
      $$ProjectsTableAnnotationComposer,
      $$ProjectsTableCreateCompanionBuilder,
      $$ProjectsTableUpdateCompanionBuilder,
      (ProjectRow, BaseReferences<_$AppDatabase, $ProjectsTable, ProjectRow>),
      ProjectRow,
      PrefetchHooks Function()
    >;
typedef $$ProjectRoomsTableCreateCompanionBuilder =
    ProjectRoomsCompanion Function({
      required String id,
      required int createdAt,
      required int updatedAt,
      Value<int?> deletedAt,
      required String homeId,
      required String projectId,
      required String roomId,
      Value<int> rowid,
    });
typedef $$ProjectRoomsTableUpdateCompanionBuilder =
    ProjectRoomsCompanion Function({
      Value<String> id,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int?> deletedAt,
      Value<String> homeId,
      Value<String> projectId,
      Value<String> roomId,
      Value<int> rowid,
    });

class $$ProjectRoomsTableFilterComposer
    extends Composer<_$AppDatabase, $ProjectRoomsTable> {
  $$ProjectRoomsTableFilterComposer({
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

  ColumnWithTypeConverterFilters<String, String, Uint8List> get projectId =>
      $composableBuilder(
        column: $table.projectId,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<String, String, Uint8List> get roomId =>
      $composableBuilder(
        column: $table.roomId,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );
}

class $$ProjectRoomsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProjectRoomsTable> {
  $$ProjectRoomsTableOrderingComposer({
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

  ColumnOrderings<Uint8List> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get roomId => $composableBuilder(
    column: $table.roomId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProjectRoomsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProjectRoomsTable> {
  $$ProjectRoomsTableAnnotationComposer({
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

  GeneratedColumnWithTypeConverter<String, Uint8List> get projectId =>
      $composableBuilder(column: $table.projectId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<String, Uint8List> get roomId =>
      $composableBuilder(column: $table.roomId, builder: (column) => column);
}

class $$ProjectRoomsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProjectRoomsTable,
          ProjectRoomRow,
          $$ProjectRoomsTableFilterComposer,
          $$ProjectRoomsTableOrderingComposer,
          $$ProjectRoomsTableAnnotationComposer,
          $$ProjectRoomsTableCreateCompanionBuilder,
          $$ProjectRoomsTableUpdateCompanionBuilder,
          (
            ProjectRoomRow,
            BaseReferences<_$AppDatabase, $ProjectRoomsTable, ProjectRoomRow>,
          ),
          ProjectRoomRow,
          PrefetchHooks Function()
        > {
  $$ProjectRoomsTableTableManager(_$AppDatabase db, $ProjectRoomsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProjectRoomsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProjectRoomsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProjectRoomsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<String> homeId = const Value.absent(),
                Value<String> projectId = const Value.absent(),
                Value<String> roomId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProjectRoomsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                homeId: homeId,
                projectId: projectId,
                roomId: roomId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                required String homeId,
                required String projectId,
                required String roomId,
                Value<int> rowid = const Value.absent(),
              }) => ProjectRoomsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                homeId: homeId,
                projectId: projectId,
                roomId: roomId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ProjectRoomsTable, ProjectRoomRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $ProjectRoomsTable,
                    ProjectRoomRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProjectRoomsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProjectRoomsTable,
      ProjectRoomRow,
      $$ProjectRoomsTableFilterComposer,
      $$ProjectRoomsTableOrderingComposer,
      $$ProjectRoomsTableAnnotationComposer,
      $$ProjectRoomsTableCreateCompanionBuilder,
      $$ProjectRoomsTableUpdateCompanionBuilder,
      (
        ProjectRoomRow,
        BaseReferences<_$AppDatabase, $ProjectRoomsTable, ProjectRoomRow>,
      ),
      ProjectRoomRow,
      PrefetchHooks Function()
    >;
typedef $$BudgetLinesTableCreateCompanionBuilder =
    BudgetLinesCompanion Function({
      required String id,
      required int createdAt,
      required int updatedAt,
      Value<int?> deletedAt,
      required String homeId,
      required String projectId,
      required String label,
      Value<String> nature,
      Value<String> planned,
      Value<String> paid,
      Value<int> rowid,
    });
typedef $$BudgetLinesTableUpdateCompanionBuilder =
    BudgetLinesCompanion Function({
      Value<String> id,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int?> deletedAt,
      Value<String> homeId,
      Value<String> projectId,
      Value<String> label,
      Value<String> nature,
      Value<String> planned,
      Value<String> paid,
      Value<int> rowid,
    });

class $$BudgetLinesTableFilterComposer
    extends Composer<_$AppDatabase, $BudgetLinesTable> {
  $$BudgetLinesTableFilterComposer({
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

  ColumnWithTypeConverterFilters<String, String, Uint8List> get projectId =>
      $composableBuilder(
        column: $table.projectId,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nature => $composableBuilder(
    column: $table.nature,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get planned => $composableBuilder(
    column: $table.planned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paid => $composableBuilder(
    column: $table.paid,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BudgetLinesTableOrderingComposer
    extends Composer<_$AppDatabase, $BudgetLinesTable> {
  $$BudgetLinesTableOrderingComposer({
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

  ColumnOrderings<Uint8List> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nature => $composableBuilder(
    column: $table.nature,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get planned => $composableBuilder(
    column: $table.planned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paid => $composableBuilder(
    column: $table.paid,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BudgetLinesTableAnnotationComposer
    extends Composer<_$AppDatabase, $BudgetLinesTable> {
  $$BudgetLinesTableAnnotationComposer({
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

  GeneratedColumnWithTypeConverter<String, Uint8List> get projectId =>
      $composableBuilder(column: $table.projectId, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get nature =>
      $composableBuilder(column: $table.nature, builder: (column) => column);

  GeneratedColumn<String> get planned =>
      $composableBuilder(column: $table.planned, builder: (column) => column);

  GeneratedColumn<String> get paid =>
      $composableBuilder(column: $table.paid, builder: (column) => column);
}

class $$BudgetLinesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BudgetLinesTable,
          BudgetLineRow,
          $$BudgetLinesTableFilterComposer,
          $$BudgetLinesTableOrderingComposer,
          $$BudgetLinesTableAnnotationComposer,
          $$BudgetLinesTableCreateCompanionBuilder,
          $$BudgetLinesTableUpdateCompanionBuilder,
          (
            BudgetLineRow,
            BaseReferences<_$AppDatabase, $BudgetLinesTable, BudgetLineRow>,
          ),
          BudgetLineRow,
          PrefetchHooks Function()
        > {
  $$BudgetLinesTableTableManager(_$AppDatabase db, $BudgetLinesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BudgetLinesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BudgetLinesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BudgetLinesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<String> homeId = const Value.absent(),
                Value<String> projectId = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<String> nature = const Value.absent(),
                Value<String> planned = const Value.absent(),
                Value<String> paid = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BudgetLinesCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                homeId: homeId,
                projectId: projectId,
                label: label,
                nature: nature,
                planned: planned,
                paid: paid,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                required String homeId,
                required String projectId,
                required String label,
                Value<String> nature = const Value.absent(),
                Value<String> planned = const Value.absent(),
                Value<String> paid = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BudgetLinesCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                homeId: homeId,
                projectId: projectId,
                label: label,
                nature: nature,
                planned: planned,
                paid: paid,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BudgetLinesTable, BudgetLineRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $BudgetLinesTable,
                    BudgetLineRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BudgetLinesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BudgetLinesTable,
      BudgetLineRow,
      $$BudgetLinesTableFilterComposer,
      $$BudgetLinesTableOrderingComposer,
      $$BudgetLinesTableAnnotationComposer,
      $$BudgetLinesTableCreateCompanionBuilder,
      $$BudgetLinesTableUpdateCompanionBuilder,
      (
        BudgetLineRow,
        BaseReferences<_$AppDatabase, $BudgetLinesTable, BudgetLineRow>,
      ),
      BudgetLineRow,
      PrefetchHooks Function()
    >;
typedef $$QuotesTableCreateCompanionBuilder = QuotesCompanion Function({
  required String id,
  required int createdAt,
  required int updatedAt,
  Value<int?> deletedAt,
  required String homeId,
  required String projectId,
  Value<String?> contractorId,
  Value<String> amount,
  Value<String?> issuedOn,
  Value<String?> validUntil,
  Value<String> status,
  Value<String?> budgetLineId,
  Value<String> note,
  Value<int> rowid,
});
typedef $$QuotesTableUpdateCompanionBuilder = QuotesCompanion Function({
  Value<String> id,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int?> deletedAt,
  Value<String> homeId,
  Value<String> projectId,
  Value<String?> contractorId,
  Value<String> amount,
  Value<String?> issuedOn,
  Value<String?> validUntil,
  Value<String> status,
  Value<String?> budgetLineId,
  Value<String> note,
  Value<int> rowid,
});

class $$QuotesTableFilterComposer
    extends Composer<_$AppDatabase, $QuotesTable> {
  $$QuotesTableFilterComposer({
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

  ColumnWithTypeConverterFilters<String, String, Uint8List> get projectId =>
      $composableBuilder(
        column: $table.projectId,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<String?, String, Uint8List> get contractorId =>
      $composableBuilder(
        column: $table.contractorId,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get issuedOn => $composableBuilder(
    column: $table.issuedOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get validUntil => $composableBuilder(
    column: $table.validUntil,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<String?, String, Uint8List> get budgetLineId =>
      $composableBuilder(
        column: $table.budgetLineId,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );
}

class $$QuotesTableOrderingComposer
    extends Composer<_$AppDatabase, $QuotesTable> {
  $$QuotesTableOrderingComposer({
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

  ColumnOrderings<Uint8List> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get contractorId => $composableBuilder(
    column: $table.contractorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get issuedOn => $composableBuilder(
    column: $table.issuedOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get validUntil => $composableBuilder(
    column: $table.validUntil,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get budgetLineId => $composableBuilder(
    column: $table.budgetLineId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$QuotesTableAnnotationComposer
    extends Composer<_$AppDatabase, $QuotesTable> {
  $$QuotesTableAnnotationComposer({
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

  GeneratedColumnWithTypeConverter<String, Uint8List> get projectId =>
      $composableBuilder(column: $table.projectId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<String?, Uint8List> get contractorId =>
      $composableBuilder(
        column: $table.contractorId,
        builder: (column) => column,
      );

  GeneratedColumn<String> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get issuedOn =>
      $composableBuilder(column: $table.issuedOn, builder: (column) => column);

  GeneratedColumn<String> get validUntil => $composableBuilder(
    column: $table.validUntil,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumnWithTypeConverter<String?, Uint8List> get budgetLineId =>
      $composableBuilder(
        column: $table.budgetLineId,
        builder: (column) => column,
      );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);
}

class $$QuotesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $QuotesTable,
          QuoteRow,
          $$QuotesTableFilterComposer,
          $$QuotesTableOrderingComposer,
          $$QuotesTableAnnotationComposer,
          $$QuotesTableCreateCompanionBuilder,
          $$QuotesTableUpdateCompanionBuilder,
          (QuoteRow, BaseReferences<_$AppDatabase, $QuotesTable, QuoteRow>),
          QuoteRow,
          PrefetchHooks Function()
        > {
  $$QuotesTableTableManager(_$AppDatabase db, $QuotesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QuotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QuotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QuotesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<String> homeId = const Value.absent(),
                Value<String> projectId = const Value.absent(),
                Value<String?> contractorId = const Value.absent(),
                Value<String> amount = const Value.absent(),
                Value<String?> issuedOn = const Value.absent(),
                Value<String?> validUntil = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> budgetLineId = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => QuotesCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                homeId: homeId,
                projectId: projectId,
                contractorId: contractorId,
                amount: amount,
                issuedOn: issuedOn,
                validUntil: validUntil,
                status: status,
                budgetLineId: budgetLineId,
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
                required String projectId,
                Value<String?> contractorId = const Value.absent(),
                Value<String> amount = const Value.absent(),
                Value<String?> issuedOn = const Value.absent(),
                Value<String?> validUntil = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> budgetLineId = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => QuotesCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                homeId: homeId,
                projectId: projectId,
                contractorId: contractorId,
                amount: amount,
                issuedOn: issuedOn,
                validUntil: validUntil,
                status: status,
                budgetLineId: budgetLineId,
                note: note,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$QuotesTable, QuoteRow>(table),
                  BaseReferences<_$AppDatabase, $QuotesTable, QuoteRow>(
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

typedef $$QuotesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $QuotesTable,
      QuoteRow,
      $$QuotesTableFilterComposer,
      $$QuotesTableOrderingComposer,
      $$QuotesTableAnnotationComposer,
      $$QuotesTableCreateCompanionBuilder,
      $$QuotesTableUpdateCompanionBuilder,
      (QuoteRow, BaseReferences<_$AppDatabase, $QuotesTable, QuoteRow>),
      QuoteRow,
      PrefetchHooks Function()
    >;
typedef $$ProjectFilesTableCreateCompanionBuilder =
    ProjectFilesCompanion Function({
      required String id,
      required int createdAt,
      required int updatedAt,
      Value<int?> deletedAt,
      required String homeId,
      required String projectId,
      Value<String?> quoteId,
      required String name,
      Value<String?> file,
      Value<String> contentType,
      Value<bool> isImage,
      Value<int> sizeBytes,
      Value<int> rowid,
    });
typedef $$ProjectFilesTableUpdateCompanionBuilder =
    ProjectFilesCompanion Function({
      Value<String> id,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int?> deletedAt,
      Value<String> homeId,
      Value<String> projectId,
      Value<String?> quoteId,
      Value<String> name,
      Value<String?> file,
      Value<String> contentType,
      Value<bool> isImage,
      Value<int> sizeBytes,
      Value<int> rowid,
    });

class $$ProjectFilesTableFilterComposer
    extends Composer<_$AppDatabase, $ProjectFilesTable> {
  $$ProjectFilesTableFilterComposer({
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

  ColumnWithTypeConverterFilters<String, String, Uint8List> get projectId =>
      $composableBuilder(
        column: $table.projectId,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<String?, String, Uint8List> get quoteId =>
      $composableBuilder(
        column: $table.quoteId,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get file => $composableBuilder(
    column: $table.file,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentType => $composableBuilder(
    column: $table.contentType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isImage => $composableBuilder(
    column: $table.isImage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProjectFilesTableOrderingComposer
    extends Composer<_$AppDatabase, $ProjectFilesTable> {
  $$ProjectFilesTableOrderingComposer({
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

  ColumnOrderings<Uint8List> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get quoteId => $composableBuilder(
    column: $table.quoteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get file => $composableBuilder(
    column: $table.file,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentType => $composableBuilder(
    column: $table.contentType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isImage => $composableBuilder(
    column: $table.isImage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProjectFilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProjectFilesTable> {
  $$ProjectFilesTableAnnotationComposer({
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

  GeneratedColumnWithTypeConverter<String, Uint8List> get projectId =>
      $composableBuilder(column: $table.projectId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<String?, Uint8List> get quoteId =>
      $composableBuilder(column: $table.quoteId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get file =>
      $composableBuilder(column: $table.file, builder: (column) => column);

  GeneratedColumn<String> get contentType => $composableBuilder(
    column: $table.contentType,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isImage =>
      $composableBuilder(column: $table.isImage, builder: (column) => column);

  GeneratedColumn<int> get sizeBytes =>
      $composableBuilder(column: $table.sizeBytes, builder: (column) => column);
}

class $$ProjectFilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProjectFilesTable,
          ProjectFileRow,
          $$ProjectFilesTableFilterComposer,
          $$ProjectFilesTableOrderingComposer,
          $$ProjectFilesTableAnnotationComposer,
          $$ProjectFilesTableCreateCompanionBuilder,
          $$ProjectFilesTableUpdateCompanionBuilder,
          (
            ProjectFileRow,
            BaseReferences<_$AppDatabase, $ProjectFilesTable, ProjectFileRow>,
          ),
          ProjectFileRow,
          PrefetchHooks Function()
        > {
  $$ProjectFilesTableTableManager(_$AppDatabase db, $ProjectFilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProjectFilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProjectFilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProjectFilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<String> homeId = const Value.absent(),
                Value<String> projectId = const Value.absent(),
                Value<String?> quoteId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> file = const Value.absent(),
                Value<String> contentType = const Value.absent(),
                Value<bool> isImage = const Value.absent(),
                Value<int> sizeBytes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProjectFilesCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                homeId: homeId,
                projectId: projectId,
                quoteId: quoteId,
                name: name,
                file: file,
                contentType: contentType,
                isImage: isImage,
                sizeBytes: sizeBytes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                required String homeId,
                required String projectId,
                Value<String?> quoteId = const Value.absent(),
                required String name,
                Value<String?> file = const Value.absent(),
                Value<String> contentType = const Value.absent(),
                Value<bool> isImage = const Value.absent(),
                Value<int> sizeBytes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProjectFilesCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                homeId: homeId,
                projectId: projectId,
                quoteId: quoteId,
                name: name,
                file: file,
                contentType: contentType,
                isImage: isImage,
                sizeBytes: sizeBytes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ProjectFilesTable, ProjectFileRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $ProjectFilesTable,
                    ProjectFileRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProjectFilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProjectFilesTable,
      ProjectFileRow,
      $$ProjectFilesTableFilterComposer,
      $$ProjectFilesTableOrderingComposer,
      $$ProjectFilesTableAnnotationComposer,
      $$ProjectFilesTableCreateCompanionBuilder,
      $$ProjectFilesTableUpdateCompanionBuilder,
      (
        ProjectFileRow,
        BaseReferences<_$AppDatabase, $ProjectFilesTable, ProjectFileRow>,
      ),
      ProjectFileRow,
      PrefetchHooks Function()
    >;
typedef $$ProjectLinksTableCreateCompanionBuilder =
    ProjectLinksCompanion Function({
      required String id,
      required int createdAt,
      required int updatedAt,
      Value<int?> deletedAt,
      required String homeId,
      required String projectId,
      required String url,
      Value<String> title,
      Value<int> rowid,
    });
typedef $$ProjectLinksTableUpdateCompanionBuilder =
    ProjectLinksCompanion Function({
      Value<String> id,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int?> deletedAt,
      Value<String> homeId,
      Value<String> projectId,
      Value<String> url,
      Value<String> title,
      Value<int> rowid,
    });

class $$ProjectLinksTableFilterComposer
    extends Composer<_$AppDatabase, $ProjectLinksTable> {
  $$ProjectLinksTableFilterComposer({
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

  ColumnWithTypeConverterFilters<String, String, Uint8List> get projectId =>
      $composableBuilder(
        column: $table.projectId,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProjectLinksTableOrderingComposer
    extends Composer<_$AppDatabase, $ProjectLinksTable> {
  $$ProjectLinksTableOrderingComposer({
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

  ColumnOrderings<Uint8List> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProjectLinksTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProjectLinksTable> {
  $$ProjectLinksTableAnnotationComposer({
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

  GeneratedColumnWithTypeConverter<String, Uint8List> get projectId =>
      $composableBuilder(column: $table.projectId, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);
}

class $$ProjectLinksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProjectLinksTable,
          ProjectLinkRow,
          $$ProjectLinksTableFilterComposer,
          $$ProjectLinksTableOrderingComposer,
          $$ProjectLinksTableAnnotationComposer,
          $$ProjectLinksTableCreateCompanionBuilder,
          $$ProjectLinksTableUpdateCompanionBuilder,
          (
            ProjectLinkRow,
            BaseReferences<_$AppDatabase, $ProjectLinksTable, ProjectLinkRow>,
          ),
          ProjectLinkRow,
          PrefetchHooks Function()
        > {
  $$ProjectLinksTableTableManager(_$AppDatabase db, $ProjectLinksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProjectLinksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProjectLinksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProjectLinksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<String> homeId = const Value.absent(),
                Value<String> projectId = const Value.absent(),
                Value<String> url = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProjectLinksCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                homeId: homeId,
                projectId: projectId,
                url: url,
                title: title,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                required String homeId,
                required String projectId,
                required String url,
                Value<String> title = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProjectLinksCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                homeId: homeId,
                projectId: projectId,
                url: url,
                title: title,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ProjectLinksTable, ProjectLinkRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $ProjectLinksTable,
                    ProjectLinkRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProjectLinksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProjectLinksTable,
      ProjectLinkRow,
      $$ProjectLinksTableFilterComposer,
      $$ProjectLinksTableOrderingComposer,
      $$ProjectLinksTableAnnotationComposer,
      $$ProjectLinksTableCreateCompanionBuilder,
      $$ProjectLinksTableUpdateCompanionBuilder,
      (
        ProjectLinkRow,
        BaseReferences<_$AppDatabase, $ProjectLinksTable, ProjectLinkRow>,
      ),
      ProjectLinkRow,
      PrefetchHooks Function()
    >;
typedef $$ProjectTasksTableCreateCompanionBuilder =
    ProjectTasksCompanion Function({
      required String id,
      required int createdAt,
      required int updatedAt,
      Value<int?> deletedAt,
      required String homeId,
      required String projectId,
      required String taskId,
      Value<int> rowid,
    });
typedef $$ProjectTasksTableUpdateCompanionBuilder =
    ProjectTasksCompanion Function({
      Value<String> id,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int?> deletedAt,
      Value<String> homeId,
      Value<String> projectId,
      Value<String> taskId,
      Value<int> rowid,
    });

class $$ProjectTasksTableFilterComposer
    extends Composer<_$AppDatabase, $ProjectTasksTable> {
  $$ProjectTasksTableFilterComposer({
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

  ColumnWithTypeConverterFilters<String, String, Uint8List> get projectId =>
      $composableBuilder(
        column: $table.projectId,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<String, String, Uint8List> get taskId =>
      $composableBuilder(
        column: $table.taskId,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );
}

class $$ProjectTasksTableOrderingComposer
    extends Composer<_$AppDatabase, $ProjectTasksTable> {
  $$ProjectTasksTableOrderingComposer({
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

  ColumnOrderings<Uint8List> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProjectTasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProjectTasksTable> {
  $$ProjectTasksTableAnnotationComposer({
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

  GeneratedColumnWithTypeConverter<String, Uint8List> get projectId =>
      $composableBuilder(column: $table.projectId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<String, Uint8List> get taskId =>
      $composableBuilder(column: $table.taskId, builder: (column) => column);
}

class $$ProjectTasksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProjectTasksTable,
          ProjectTaskRow,
          $$ProjectTasksTableFilterComposer,
          $$ProjectTasksTableOrderingComposer,
          $$ProjectTasksTableAnnotationComposer,
          $$ProjectTasksTableCreateCompanionBuilder,
          $$ProjectTasksTableUpdateCompanionBuilder,
          (
            ProjectTaskRow,
            BaseReferences<_$AppDatabase, $ProjectTasksTable, ProjectTaskRow>,
          ),
          ProjectTaskRow,
          PrefetchHooks Function()
        > {
  $$ProjectTasksTableTableManager(_$AppDatabase db, $ProjectTasksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProjectTasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProjectTasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProjectTasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<String> homeId = const Value.absent(),
                Value<String> projectId = const Value.absent(),
                Value<String> taskId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProjectTasksCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                homeId: homeId,
                projectId: projectId,
                taskId: taskId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                required String homeId,
                required String projectId,
                required String taskId,
                Value<int> rowid = const Value.absent(),
              }) => ProjectTasksCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                homeId: homeId,
                projectId: projectId,
                taskId: taskId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ProjectTasksTable, ProjectTaskRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $ProjectTasksTable,
                    ProjectTaskRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProjectTasksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProjectTasksTable,
      ProjectTaskRow,
      $$ProjectTasksTableFilterComposer,
      $$ProjectTasksTableOrderingComposer,
      $$ProjectTasksTableAnnotationComposer,
      $$ProjectTasksTableCreateCompanionBuilder,
      $$ProjectTasksTableUpdateCompanionBuilder,
      (
        ProjectTaskRow,
        BaseReferences<_$AppDatabase, $ProjectTasksTable, ProjectTaskRow>,
      ),
      ProjectTaskRow,
      PrefetchHooks Function()
    >;
typedef $$AnnualEnvelopesTableCreateCompanionBuilder =
    AnnualEnvelopesCompanion Function({
      required String id,
      required int createdAt,
      required int updatedAt,
      Value<int?> deletedAt,
      required String homeId,
      required int year,
      required String amount,
      Value<int> rowid,
    });
typedef $$AnnualEnvelopesTableUpdateCompanionBuilder =
    AnnualEnvelopesCompanion Function({
      Value<String> id,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int?> deletedAt,
      Value<String> homeId,
      Value<int> year,
      Value<String> amount,
      Value<int> rowid,
    });

class $$AnnualEnvelopesTableFilterComposer
    extends Composer<_$AppDatabase, $AnnualEnvelopesTable> {
  $$AnnualEnvelopesTableFilterComposer({
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

  ColumnFilters<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AnnualEnvelopesTableOrderingComposer
    extends Composer<_$AppDatabase, $AnnualEnvelopesTable> {
  $$AnnualEnvelopesTableOrderingComposer({
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

  ColumnOrderings<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AnnualEnvelopesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AnnualEnvelopesTable> {
  $$AnnualEnvelopesTableAnnotationComposer({
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

  GeneratedColumn<int> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  GeneratedColumn<String> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);
}

class $$AnnualEnvelopesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AnnualEnvelopesTable,
          EnvelopeRow,
          $$AnnualEnvelopesTableFilterComposer,
          $$AnnualEnvelopesTableOrderingComposer,
          $$AnnualEnvelopesTableAnnotationComposer,
          $$AnnualEnvelopesTableCreateCompanionBuilder,
          $$AnnualEnvelopesTableUpdateCompanionBuilder,
          (
            EnvelopeRow,
            BaseReferences<_$AppDatabase, $AnnualEnvelopesTable, EnvelopeRow>,
          ),
          EnvelopeRow,
          PrefetchHooks Function()
        > {
  $$AnnualEnvelopesTableTableManager(
    _$AppDatabase db,
    $AnnualEnvelopesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AnnualEnvelopesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AnnualEnvelopesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AnnualEnvelopesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<String> homeId = const Value.absent(),
                Value<int> year = const Value.absent(),
                Value<String> amount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AnnualEnvelopesCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                homeId: homeId,
                year: year,
                amount: amount,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                required String homeId,
                required int year,
                required String amount,
                Value<int> rowid = const Value.absent(),
              }) => AnnualEnvelopesCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                homeId: homeId,
                year: year,
                amount: amount,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AnnualEnvelopesTable, EnvelopeRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $AnnualEnvelopesTable,
                    EnvelopeRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AnnualEnvelopesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AnnualEnvelopesTable,
      EnvelopeRow,
      $$AnnualEnvelopesTableFilterComposer,
      $$AnnualEnvelopesTableOrderingComposer,
      $$AnnualEnvelopesTableAnnotationComposer,
      $$AnnualEnvelopesTableCreateCompanionBuilder,
      $$AnnualEnvelopesTableUpdateCompanionBuilder,
      (
        EnvelopeRow,
        BaseReferences<_$AppDatabase, $AnnualEnvelopesTable, EnvelopeRow>,
      ),
      EnvelopeRow,
      PrefetchHooks Function()
    >;
typedef $$ReportsTableCreateCompanionBuilder = ReportsCompanion Function({
  required String id,
  required int createdAt,
  required int updatedAt,
  Value<int?> deletedAt,
  required String homeId,
  required String title,
  Value<String> status,
  Value<String?> roomId,
  Value<String?> itemId,
  Value<String?> articleId,
  Value<String> place,
  Value<String?> taskId,
  Value<int?> closedAt,
  Value<String?> photo,
  Value<int> rowid,
});
typedef $$ReportsTableUpdateCompanionBuilder = ReportsCompanion Function({
  Value<String> id,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int?> deletedAt,
  Value<String> homeId,
  Value<String> title,
  Value<String> status,
  Value<String?> roomId,
  Value<String?> itemId,
  Value<String?> articleId,
  Value<String> place,
  Value<String?> taskId,
  Value<int?> closedAt,
  Value<String?> photo,
  Value<int> rowid,
});

class $$ReportsTableFilterComposer
    extends Composer<_$AppDatabase, $ReportsTable> {
  $$ReportsTableFilterComposer({
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

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
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

  ColumnWithTypeConverterFilters<String?, String, Uint8List> get articleId =>
      $composableBuilder(
        column: $table.articleId,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get place => $composableBuilder(
    column: $table.place,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<String?, String, Uint8List> get taskId =>
      $composableBuilder(
        column: $table.taskId,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get closedAt => $composableBuilder(
    column: $table.closedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photo => $composableBuilder(
    column: $table.photo,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ReportsTableOrderingComposer
    extends Composer<_$AppDatabase, $ReportsTable> {
  $$ReportsTableOrderingComposer({
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

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
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

  ColumnOrderings<Uint8List> get articleId => $composableBuilder(
    column: $table.articleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get place => $composableBuilder(
    column: $table.place,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get closedAt => $composableBuilder(
    column: $table.closedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photo => $composableBuilder(
    column: $table.photo,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReportsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReportsTable> {
  $$ReportsTableAnnotationComposer({
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

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumnWithTypeConverter<String?, Uint8List> get roomId =>
      $composableBuilder(column: $table.roomId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<String?, Uint8List> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<String?, Uint8List> get articleId =>
      $composableBuilder(column: $table.articleId, builder: (column) => column);

  GeneratedColumn<String> get place =>
      $composableBuilder(column: $table.place, builder: (column) => column);

  GeneratedColumnWithTypeConverter<String?, Uint8List> get taskId =>
      $composableBuilder(column: $table.taskId, builder: (column) => column);

  GeneratedColumn<int> get closedAt =>
      $composableBuilder(column: $table.closedAt, builder: (column) => column);

  GeneratedColumn<String> get photo =>
      $composableBuilder(column: $table.photo, builder: (column) => column);
}

class $$ReportsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReportsTable,
          ReportRow,
          $$ReportsTableFilterComposer,
          $$ReportsTableOrderingComposer,
          $$ReportsTableAnnotationComposer,
          $$ReportsTableCreateCompanionBuilder,
          $$ReportsTableUpdateCompanionBuilder,
          (ReportRow, BaseReferences<_$AppDatabase, $ReportsTable, ReportRow>),
          ReportRow,
          PrefetchHooks Function()
        > {
  $$ReportsTableTableManager(_$AppDatabase db, $ReportsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReportsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReportsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReportsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<String> homeId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> roomId = const Value.absent(),
                Value<String?> itemId = const Value.absent(),
                Value<String?> articleId = const Value.absent(),
                Value<String> place = const Value.absent(),
                Value<String?> taskId = const Value.absent(),
                Value<int?> closedAt = const Value.absent(),
                Value<String?> photo = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReportsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                homeId: homeId,
                title: title,
                status: status,
                roomId: roomId,
                itemId: itemId,
                articleId: articleId,
                place: place,
                taskId: taskId,
                closedAt: closedAt,
                photo: photo,
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
                Value<String> status = const Value.absent(),
                Value<String?> roomId = const Value.absent(),
                Value<String?> itemId = const Value.absent(),
                Value<String?> articleId = const Value.absent(),
                Value<String> place = const Value.absent(),
                Value<String?> taskId = const Value.absent(),
                Value<int?> closedAt = const Value.absent(),
                Value<String?> photo = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReportsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                homeId: homeId,
                title: title,
                status: status,
                roomId: roomId,
                itemId: itemId,
                articleId: articleId,
                place: place,
                taskId: taskId,
                closedAt: closedAt,
                photo: photo,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ReportsTable, ReportRow>(table),
                  BaseReferences<_$AppDatabase, $ReportsTable, ReportRow>(
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

typedef $$ReportsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReportsTable,
      ReportRow,
      $$ReportsTableFilterComposer,
      $$ReportsTableOrderingComposer,
      $$ReportsTableAnnotationComposer,
      $$ReportsTableCreateCompanionBuilder,
      $$ReportsTableUpdateCompanionBuilder,
      (ReportRow, BaseReferences<_$AppDatabase, $ReportsTable, ReportRow>),
      ReportRow,
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
typedef $$OpLogTableCreateCompanionBuilder = OpLogCompanion Function({
  Value<int> seq,
  required Uint8List device,
  required String hlc,
  Value<String?> homeId,
  required String body,
});
typedef $$OpLogTableUpdateCompanionBuilder = OpLogCompanion Function({
  Value<int> seq,
  Value<Uint8List> device,
  Value<String> hlc,
  Value<String?> homeId,
  Value<String> body,
});

class $$OpLogTableFilterComposer extends Composer<_$AppDatabase, $OpLogTable> {
  $$OpLogTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get device => $composableBuilder(
    column: $table.device,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<String?, String, Uint8List> get homeId =>
      $composableBuilder(
        column: $table.homeId,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OpLogTableOrderingComposer
    extends Composer<_$AppDatabase, $OpLogTable> {
  $$OpLogTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get device => $composableBuilder(
    column: $table.device,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get homeId => $composableBuilder(
    column: $table.homeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OpLogTableAnnotationComposer
    extends Composer<_$AppDatabase, $OpLogTable> {
  $$OpLogTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get seq =>
      $composableBuilder(column: $table.seq, builder: (column) => column);

  GeneratedColumn<Uint8List> get device =>
      $composableBuilder(column: $table.device, builder: (column) => column);

  GeneratedColumn<String> get hlc =>
      $composableBuilder(column: $table.hlc, builder: (column) => column);

  GeneratedColumnWithTypeConverter<String?, Uint8List> get homeId =>
      $composableBuilder(column: $table.homeId, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);
}

class $$OpLogTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OpLogTable,
          OpLogRow,
          $$OpLogTableFilterComposer,
          $$OpLogTableOrderingComposer,
          $$OpLogTableAnnotationComposer,
          $$OpLogTableCreateCompanionBuilder,
          $$OpLogTableUpdateCompanionBuilder,
          (OpLogRow, BaseReferences<_$AppDatabase, $OpLogTable, OpLogRow>),
          OpLogRow,
          PrefetchHooks Function()
        > {
  $$OpLogTableTableManager(_$AppDatabase db, $OpLogTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OpLogTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OpLogTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OpLogTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> seq = const Value.absent(),
                Value<Uint8List> device = const Value.absent(),
                Value<String> hlc = const Value.absent(),
                Value<String?> homeId = const Value.absent(),
                Value<String> body = const Value.absent(),
              }) => OpLogCompanion(
                seq: seq,
                device: device,
                hlc: hlc,
                homeId: homeId,
                body: body,
              ),
          createCompanionCallback:
              ({
                Value<int> seq = const Value.absent(),
                required Uint8List device,
                required String hlc,
                Value<String?> homeId = const Value.absent(),
                required String body,
              }) => OpLogCompanion.insert(
                seq: seq,
                device: device,
                hlc: hlc,
                homeId: homeId,
                body: body,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$OpLogTable, OpLogRow>(table),
                  BaseReferences<_$AppDatabase, $OpLogTable, OpLogRow>(
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

typedef $$OpLogTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OpLogTable,
      OpLogRow,
      $$OpLogTableFilterComposer,
      $$OpLogTableOrderingComposer,
      $$OpLogTableAnnotationComposer,
      $$OpLogTableCreateCompanionBuilder,
      $$OpLogTableUpdateCompanionBuilder,
      (OpLogRow, BaseReferences<_$AppDatabase, $OpLogTable, OpLogRow>),
      OpLogRow,
      PrefetchHooks Function()
    >;
typedef $$ExtraTableCreateCompanionBuilder = ExtraCompanion Function({
  required String entity,
  required String rowId,
  Value<String?> homeId,
  required String json,
  Value<int> rowid,
});
typedef $$ExtraTableUpdateCompanionBuilder = ExtraCompanion Function({
  Value<String> entity,
  Value<String> rowId,
  Value<String?> homeId,
  Value<String> json,
  Value<int> rowid,
});

class $$ExtraTableFilterComposer extends Composer<_$AppDatabase, $ExtraTable> {
  $$ExtraTableFilterComposer({
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

  ColumnWithTypeConverterFilters<String?, String, Uint8List> get homeId =>
      $composableBuilder(
        column: $table.homeId,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get json => $composableBuilder(
    column: $table.json,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ExtraTableOrderingComposer
    extends Composer<_$AppDatabase, $ExtraTable> {
  $$ExtraTableOrderingComposer({
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

  ColumnOrderings<Uint8List> get homeId => $composableBuilder(
    column: $table.homeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get json => $composableBuilder(
    column: $table.json,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExtraTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExtraTable> {
  $$ExtraTableAnnotationComposer({
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

  GeneratedColumnWithTypeConverter<String?, Uint8List> get homeId =>
      $composableBuilder(column: $table.homeId, builder: (column) => column);

  GeneratedColumn<String> get json =>
      $composableBuilder(column: $table.json, builder: (column) => column);
}

class $$ExtraTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExtraTable,
          ExtraRow,
          $$ExtraTableFilterComposer,
          $$ExtraTableOrderingComposer,
          $$ExtraTableAnnotationComposer,
          $$ExtraTableCreateCompanionBuilder,
          $$ExtraTableUpdateCompanionBuilder,
          (ExtraRow, BaseReferences<_$AppDatabase, $ExtraTable, ExtraRow>),
          ExtraRow,
          PrefetchHooks Function()
        > {
  $$ExtraTableTableManager(_$AppDatabase db, $ExtraTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExtraTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExtraTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExtraTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> entity = const Value.absent(),
                Value<String> rowId = const Value.absent(),
                Value<String?> homeId = const Value.absent(),
                Value<String> json = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExtraCompanion(
                entity: entity,
                rowId: rowId,
                homeId: homeId,
                json: json,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String entity,
                required String rowId,
                Value<String?> homeId = const Value.absent(),
                required String json,
                Value<int> rowid = const Value.absent(),
              }) => ExtraCompanion.insert(
                entity: entity,
                rowId: rowId,
                homeId: homeId,
                json: json,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ExtraTable, ExtraRow>(table),
                  BaseReferences<_$AppDatabase, $ExtraTable, ExtraRow>(
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

typedef $$ExtraTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExtraTable,
      ExtraRow,
      $$ExtraTableFilterComposer,
      $$ExtraTableOrderingComposer,
      $$ExtraTableAnnotationComposer,
      $$ExtraTableCreateCompanionBuilder,
      $$ExtraTableUpdateCompanionBuilder,
      (ExtraRow, BaseReferences<_$AppDatabase, $ExtraTable, ExtraRow>),
      ExtraRow,
      PrefetchHooks Function()
    >;
typedef $$PendingTableCreateCompanionBuilder = PendingCompanion Function({
  required String key,
  required String entity,
  Value<String?> homeId,
  required String body,
  Value<int> rowid,
});
typedef $$PendingTableUpdateCompanionBuilder = PendingCompanion Function({
  Value<String> key,
  Value<String> entity,
  Value<String?> homeId,
  Value<String> body,
  Value<int> rowid,
});

class $$PendingTableFilterComposer
    extends Composer<_$AppDatabase, $PendingTable> {
  $$PendingTableFilterComposer({
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

  ColumnFilters<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<String?, String, Uint8List> get homeId =>
      $composableBuilder(
        column: $table.homeId,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PendingTableOrderingComposer
    extends Composer<_$AppDatabase, $PendingTable> {
  $$PendingTableOrderingComposer({
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

  ColumnOrderings<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get homeId => $composableBuilder(
    column: $table.homeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PendingTableAnnotationComposer
    extends Composer<_$AppDatabase, $PendingTable> {
  $$PendingTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get entity =>
      $composableBuilder(column: $table.entity, builder: (column) => column);

  GeneratedColumnWithTypeConverter<String?, Uint8List> get homeId =>
      $composableBuilder(column: $table.homeId, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);
}

class $$PendingTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PendingTable,
          PendingRow,
          $$PendingTableFilterComposer,
          $$PendingTableOrderingComposer,
          $$PendingTableAnnotationComposer,
          $$PendingTableCreateCompanionBuilder,
          $$PendingTableUpdateCompanionBuilder,
          (
            PendingRow,
            BaseReferences<_$AppDatabase, $PendingTable, PendingRow>,
          ),
          PendingRow,
          PrefetchHooks Function()
        > {
  $$PendingTableTableManager(_$AppDatabase db, $PendingTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PendingTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PendingTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PendingTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> entity = const Value.absent(),
                Value<String?> homeId = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PendingCompanion(
                key: key,
                entity: entity,
                homeId: homeId,
                body: body,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String entity,
                Value<String?> homeId = const Value.absent(),
                required String body,
                Value<int> rowid = const Value.absent(),
              }) => PendingCompanion.insert(
                key: key,
                entity: entity,
                homeId: homeId,
                body: body,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PendingTable, PendingRow>(table),
                  BaseReferences<_$AppDatabase, $PendingTable, PendingRow>(
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

typedef $$PendingTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PendingTable,
      PendingRow,
      $$PendingTableFilterComposer,
      $$PendingTableOrderingComposer,
      $$PendingTableAnnotationComposer,
      $$PendingTableCreateCompanionBuilder,
      $$PendingTableUpdateCompanionBuilder,
      (PendingRow, BaseReferences<_$AppDatabase, $PendingTable, PendingRow>),
      PendingRow,
      PrefetchHooks Function()
    >;
typedef $$PurgedHomesTableCreateCompanionBuilder =
    PurgedHomesCompanion Function({required String homeId, Value<int> rowid});
typedef $$PurgedHomesTableUpdateCompanionBuilder =
    PurgedHomesCompanion Function({Value<String> homeId, Value<int> rowid});

class $$PurgedHomesTableFilterComposer
    extends Composer<_$AppDatabase, $PurgedHomesTable> {
  $$PurgedHomesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnWithTypeConverterFilters<String, String, Uint8List> get homeId =>
      $composableBuilder(
        column: $table.homeId,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );
}

class $$PurgedHomesTableOrderingComposer
    extends Composer<_$AppDatabase, $PurgedHomesTable> {
  $$PurgedHomesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<Uint8List> get homeId => $composableBuilder(
    column: $table.homeId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PurgedHomesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PurgedHomesTable> {
  $$PurgedHomesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumnWithTypeConverter<String, Uint8List> get homeId =>
      $composableBuilder(column: $table.homeId, builder: (column) => column);
}

class $$PurgedHomesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PurgedHomesTable,
          PurgedHomeRow,
          $$PurgedHomesTableFilterComposer,
          $$PurgedHomesTableOrderingComposer,
          $$PurgedHomesTableAnnotationComposer,
          $$PurgedHomesTableCreateCompanionBuilder,
          $$PurgedHomesTableUpdateCompanionBuilder,
          (
            PurgedHomeRow,
            BaseReferences<_$AppDatabase, $PurgedHomesTable, PurgedHomeRow>,
          ),
          PurgedHomeRow,
          PrefetchHooks Function()
        > {
  $$PurgedHomesTableTableManager(_$AppDatabase db, $PurgedHomesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PurgedHomesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PurgedHomesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PurgedHomesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> homeId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => PurgedHomesCompanion(homeId: homeId, rowid: rowid),
          createCompanionCallback: ({
            required String homeId,
            Value<int> rowid = const Value.absent(),
          }) => PurgedHomesCompanion.insert(homeId: homeId, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PurgedHomesTable, PurgedHomeRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $PurgedHomesTable,
                    PurgedHomeRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PurgedHomesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PurgedHomesTable,
      PurgedHomeRow,
      $$PurgedHomesTableFilterComposer,
      $$PurgedHomesTableOrderingComposer,
      $$PurgedHomesTableAnnotationComposer,
      $$PurgedHomesTableCreateCompanionBuilder,
      $$PurgedHomesTableUpdateCompanionBuilder,
      (
        PurgedHomeRow,
        BaseReferences<_$AppDatabase, $PurgedHomesTable, PurgedHomeRow>,
      ),
      PurgedHomeRow,
      PrefetchHooks Function()
    >;
typedef $$OtherVersionsTableCreateCompanionBuilder =
    OtherVersionsCompanion Function({
      required String entity,
      required String rowId,
      Value<String?> homeId,
      required String field,
      required String value,
      required String hlc,
      required Uint8List device,
      required int keptUntil,
      Value<int> rowid,
    });
typedef $$OtherVersionsTableUpdateCompanionBuilder =
    OtherVersionsCompanion Function({
      Value<String> entity,
      Value<String> rowId,
      Value<String?> homeId,
      Value<String> field,
      Value<String> value,
      Value<String> hlc,
      Value<Uint8List> device,
      Value<int> keptUntil,
      Value<int> rowid,
    });

class $$OtherVersionsTableFilterComposer
    extends Composer<_$AppDatabase, $OtherVersionsTable> {
  $$OtherVersionsTableFilterComposer({
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

  ColumnWithTypeConverterFilters<String?, String, Uint8List> get homeId =>
      $composableBuilder(
        column: $table.homeId,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get field => $composableBuilder(
    column: $table.field,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
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

  ColumnFilters<int> get keptUntil => $composableBuilder(
    column: $table.keptUntil,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OtherVersionsTableOrderingComposer
    extends Composer<_$AppDatabase, $OtherVersionsTable> {
  $$OtherVersionsTableOrderingComposer({
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

  ColumnOrderings<Uint8List> get homeId => $composableBuilder(
    column: $table.homeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get field => $composableBuilder(
    column: $table.field,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
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

  ColumnOrderings<int> get keptUntil => $composableBuilder(
    column: $table.keptUntil,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OtherVersionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $OtherVersionsTable> {
  $$OtherVersionsTableAnnotationComposer({
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

  GeneratedColumnWithTypeConverter<String?, Uint8List> get homeId =>
      $composableBuilder(column: $table.homeId, builder: (column) => column);

  GeneratedColumn<String> get field =>
      $composableBuilder(column: $table.field, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<String> get hlc =>
      $composableBuilder(column: $table.hlc, builder: (column) => column);

  GeneratedColumn<Uint8List> get device =>
      $composableBuilder(column: $table.device, builder: (column) => column);

  GeneratedColumn<int> get keptUntil =>
      $composableBuilder(column: $table.keptUntil, builder: (column) => column);
}

class $$OtherVersionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OtherVersionsTable,
          OtherVersionRow,
          $$OtherVersionsTableFilterComposer,
          $$OtherVersionsTableOrderingComposer,
          $$OtherVersionsTableAnnotationComposer,
          $$OtherVersionsTableCreateCompanionBuilder,
          $$OtherVersionsTableUpdateCompanionBuilder,
          (
            OtherVersionRow,
            BaseReferences<_$AppDatabase, $OtherVersionsTable, OtherVersionRow>,
          ),
          OtherVersionRow,
          PrefetchHooks Function()
        > {
  $$OtherVersionsTableTableManager(_$AppDatabase db, $OtherVersionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OtherVersionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OtherVersionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OtherVersionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> entity = const Value.absent(),
                Value<String> rowId = const Value.absent(),
                Value<String?> homeId = const Value.absent(),
                Value<String> field = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<String> hlc = const Value.absent(),
                Value<Uint8List> device = const Value.absent(),
                Value<int> keptUntil = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OtherVersionsCompanion(
                entity: entity,
                rowId: rowId,
                homeId: homeId,
                field: field,
                value: value,
                hlc: hlc,
                device: device,
                keptUntil: keptUntil,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String entity,
                required String rowId,
                Value<String?> homeId = const Value.absent(),
                required String field,
                required String value,
                required String hlc,
                required Uint8List device,
                required int keptUntil,
                Value<int> rowid = const Value.absent(),
              }) => OtherVersionsCompanion.insert(
                entity: entity,
                rowId: rowId,
                homeId: homeId,
                field: field,
                value: value,
                hlc: hlc,
                device: device,
                keptUntil: keptUntil,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$OtherVersionsTable, OtherVersionRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $OtherVersionsTable,
                    OtherVersionRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OtherVersionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OtherVersionsTable,
      OtherVersionRow,
      $$OtherVersionsTableFilterComposer,
      $$OtherVersionsTableOrderingComposer,
      $$OtherVersionsTableAnnotationComposer,
      $$OtherVersionsTableCreateCompanionBuilder,
      $$OtherVersionsTableUpdateCompanionBuilder,
      (
        OtherVersionRow,
        BaseReferences<_$AppDatabase, $OtherVersionsTable, OtherVersionRow>,
      ),
      OtherVersionRow,
      PrefetchHooks Function()
    >;
typedef $$ServerSeenTableCreateCompanionBuilder = ServerSeenCompanion Function({
  required String entity,
  required String rowId,
  required String homeId,
  Value<int> rowid,
});
typedef $$ServerSeenTableUpdateCompanionBuilder = ServerSeenCompanion Function({
  Value<String> entity,
  Value<String> rowId,
  Value<String> homeId,
  Value<int> rowid,
});

class $$ServerSeenTableFilterComposer
    extends Composer<_$AppDatabase, $ServerSeenTable> {
  $$ServerSeenTableFilterComposer({
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

  ColumnWithTypeConverterFilters<String, String, Uint8List> get homeId =>
      $composableBuilder(
        column: $table.homeId,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );
}

class $$ServerSeenTableOrderingComposer
    extends Composer<_$AppDatabase, $ServerSeenTable> {
  $$ServerSeenTableOrderingComposer({
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

  ColumnOrderings<Uint8List> get homeId => $composableBuilder(
    column: $table.homeId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ServerSeenTableAnnotationComposer
    extends Composer<_$AppDatabase, $ServerSeenTable> {
  $$ServerSeenTableAnnotationComposer({
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

  GeneratedColumnWithTypeConverter<String, Uint8List> get homeId =>
      $composableBuilder(column: $table.homeId, builder: (column) => column);
}

class $$ServerSeenTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ServerSeenTable,
          ServerSeenRow,
          $$ServerSeenTableFilterComposer,
          $$ServerSeenTableOrderingComposer,
          $$ServerSeenTableAnnotationComposer,
          $$ServerSeenTableCreateCompanionBuilder,
          $$ServerSeenTableUpdateCompanionBuilder,
          (
            ServerSeenRow,
            BaseReferences<_$AppDatabase, $ServerSeenTable, ServerSeenRow>,
          ),
          ServerSeenRow,
          PrefetchHooks Function()
        > {
  $$ServerSeenTableTableManager(_$AppDatabase db, $ServerSeenTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ServerSeenTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ServerSeenTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ServerSeenTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> entity = const Value.absent(),
                Value<String> rowId = const Value.absent(),
                Value<String> homeId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ServerSeenCompanion(
                entity: entity,
                rowId: rowId,
                homeId: homeId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String entity,
                required String rowId,
                required String homeId,
                Value<int> rowid = const Value.absent(),
              }) => ServerSeenCompanion.insert(
                entity: entity,
                rowId: rowId,
                homeId: homeId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ServerSeenTable, ServerSeenRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $ServerSeenTable,
                    ServerSeenRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ServerSeenTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ServerSeenTable,
      ServerSeenRow,
      $$ServerSeenTableFilterComposer,
      $$ServerSeenTableOrderingComposer,
      $$ServerSeenTableAnnotationComposer,
      $$ServerSeenTableCreateCompanionBuilder,
      $$ServerSeenTableUpdateCompanionBuilder,
      (
        ServerSeenRow,
        BaseReferences<_$AppDatabase, $ServerSeenTable, ServerSeenRow>,
      ),
      ServerSeenRow,
      PrefetchHooks Function()
    >;
typedef $$FileSyncTableCreateCompanionBuilder = FileSyncCompanion Function({
  required String fileId,
  required String homeId,
  required String holder,
  required String rowId,
  required String direction,
  required String state,
  Value<int> attempts,
  Value<int> nextAt,
  Value<String?> code,
  Value<int> rowid,
});
typedef $$FileSyncTableUpdateCompanionBuilder = FileSyncCompanion Function({
  Value<String> fileId,
  Value<String> homeId,
  Value<String> holder,
  Value<String> rowId,
  Value<String> direction,
  Value<String> state,
  Value<int> attempts,
  Value<int> nextAt,
  Value<String?> code,
  Value<int> rowid,
});

class $$FileSyncTableFilterComposer
    extends Composer<_$AppDatabase, $FileSyncTable> {
  $$FileSyncTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get fileId => $composableBuilder(
    column: $table.fileId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<String, String, Uint8List> get homeId =>
      $composableBuilder(
        column: $table.homeId,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get holder => $composableBuilder(
    column: $table.holder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<String, String, Uint8List> get rowId =>
      $composableBuilder(
        column: $table.rowId,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get nextAt => $composableBuilder(
    column: $table.nextAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FileSyncTableOrderingComposer
    extends Composer<_$AppDatabase, $FileSyncTable> {
  $$FileSyncTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get fileId => $composableBuilder(
    column: $table.fileId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get homeId => $composableBuilder(
    column: $table.homeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get holder => $composableBuilder(
    column: $table.holder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get rowId => $composableBuilder(
    column: $table.rowId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get nextAt => $composableBuilder(
    column: $table.nextAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FileSyncTableAnnotationComposer
    extends Composer<_$AppDatabase, $FileSyncTable> {
  $$FileSyncTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get fileId =>
      $composableBuilder(column: $table.fileId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<String, Uint8List> get homeId =>
      $composableBuilder(column: $table.homeId, builder: (column) => column);

  GeneratedColumn<String> get holder =>
      $composableBuilder(column: $table.holder, builder: (column) => column);

  GeneratedColumnWithTypeConverter<String, Uint8List> get rowId =>
      $composableBuilder(column: $table.rowId, builder: (column) => column);

  GeneratedColumn<String> get direction =>
      $composableBuilder(column: $table.direction, builder: (column) => column);

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<int> get nextAt =>
      $composableBuilder(column: $table.nextAt, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);
}

class $$FileSyncTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FileSyncTable,
          FileSyncRow,
          $$FileSyncTableFilterComposer,
          $$FileSyncTableOrderingComposer,
          $$FileSyncTableAnnotationComposer,
          $$FileSyncTableCreateCompanionBuilder,
          $$FileSyncTableUpdateCompanionBuilder,
          (
            FileSyncRow,
            BaseReferences<_$AppDatabase, $FileSyncTable, FileSyncRow>,
          ),
          FileSyncRow,
          PrefetchHooks Function()
        > {
  $$FileSyncTableTableManager(_$AppDatabase db, $FileSyncTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FileSyncTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FileSyncTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FileSyncTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> fileId = const Value.absent(),
                Value<String> homeId = const Value.absent(),
                Value<String> holder = const Value.absent(),
                Value<String> rowId = const Value.absent(),
                Value<String> direction = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<int> nextAt = const Value.absent(),
                Value<String?> code = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FileSyncCompanion(
                fileId: fileId,
                homeId: homeId,
                holder: holder,
                rowId: rowId,
                direction: direction,
                state: state,
                attempts: attempts,
                nextAt: nextAt,
                code: code,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String fileId,
                required String homeId,
                required String holder,
                required String rowId,
                required String direction,
                required String state,
                Value<int> attempts = const Value.absent(),
                Value<int> nextAt = const Value.absent(),
                Value<String?> code = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FileSyncCompanion.insert(
                fileId: fileId,
                homeId: homeId,
                holder: holder,
                rowId: rowId,
                direction: direction,
                state: state,
                attempts: attempts,
                nextAt: nextAt,
                code: code,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FileSyncTable, FileSyncRow>(table),
                  BaseReferences<_$AppDatabase, $FileSyncTable, FileSyncRow>(
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

typedef $$FileSyncTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FileSyncTable,
      FileSyncRow,
      $$FileSyncTableFilterComposer,
      $$FileSyncTableOrderingComposer,
      $$FileSyncTableAnnotationComposer,
      $$FileSyncTableCreateCompanionBuilder,
      $$FileSyncTableUpdateCompanionBuilder,
      (FileSyncRow, BaseReferences<_$AppDatabase, $FileSyncTable, FileSyncRow>),
      FileSyncRow,
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
  $$ArticlesTableTableManager get articles =>
      $$ArticlesTableTableManager(_db, _db.articles);
  $$ArticleRoomsTableTableManager get articleRooms =>
      $$ArticleRoomsTableTableManager(_db, _db.articleRooms);
  $$ArticleItemsTableTableManager get articleItems =>
      $$ArticleItemsTableTableManager(_db, _db.articleItems);
  $$SuppliersTableTableManager get suppliers =>
      $$SuppliersTableTableManager(_db, _db.suppliers);
  $$MovementsTableTableManager get movements =>
      $$MovementsTableTableManager(_db, _db.movements);
  $$TaskMaterialsTableTableManager get taskMaterials =>
      $$TaskMaterialsTableTableManager(_db, _db.taskMaterials);
  $$MaterialDrawsTableTableManager get materialDraws =>
      $$MaterialDrawsTableTableManager(_db, _db.materialDraws);
  $$ProjectsTableTableManager get projects =>
      $$ProjectsTableTableManager(_db, _db.projects);
  $$ProjectRoomsTableTableManager get projectRooms =>
      $$ProjectRoomsTableTableManager(_db, _db.projectRooms);
  $$BudgetLinesTableTableManager get budgetLines =>
      $$BudgetLinesTableTableManager(_db, _db.budgetLines);
  $$QuotesTableTableManager get quotes =>
      $$QuotesTableTableManager(_db, _db.quotes);
  $$ProjectFilesTableTableManager get projectFiles =>
      $$ProjectFilesTableTableManager(_db, _db.projectFiles);
  $$ProjectLinksTableTableManager get projectLinks =>
      $$ProjectLinksTableTableManager(_db, _db.projectLinks);
  $$ProjectTasksTableTableManager get projectTasks =>
      $$ProjectTasksTableTableManager(_db, _db.projectTasks);
  $$AnnualEnvelopesTableTableManager get annualEnvelopes =>
      $$AnnualEnvelopesTableTableManager(_db, _db.annualEnvelopes);
  $$ReportsTableTableManager get reports =>
      $$ReportsTableTableManager(_db, _db.reports);
  $$FieldClockTableTableManager get fieldClock =>
      $$FieldClockTableTableManager(_db, _db.fieldClock);
  $$LocalSettingsTableTableManager get localSettings =>
      $$LocalSettingsTableTableManager(_db, _db.localSettings);
  $$OpLogTableTableManager get opLog =>
      $$OpLogTableTableManager(_db, _db.opLog);
  $$ExtraTableTableManager get extra =>
      $$ExtraTableTableManager(_db, _db.extra);
  $$PendingTableTableManager get pending =>
      $$PendingTableTableManager(_db, _db.pending);
  $$PurgedHomesTableTableManager get purgedHomes =>
      $$PurgedHomesTableTableManager(_db, _db.purgedHomes);
  $$OtherVersionsTableTableManager get otherVersions =>
      $$OtherVersionsTableTableManager(_db, _db.otherVersions);
  $$ServerSeenTableTableManager get serverSeen =>
      $$ServerSeenTableTableManager(_db, _db.serverSeen);
  $$FileSyncTableTableManager get fileSync =>
      $$FileSyncTableTableManager(_db, _db.fileSync);
}
