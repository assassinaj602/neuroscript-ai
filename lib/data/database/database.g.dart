// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $UserProfilesTable extends UserProfiles
    with TableInfo<$UserProfilesTable, UserProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _profileTypeMeta = const VerificationMeta(
    'profileType',
  );
  @override
  late final GeneratedColumn<String> profileType = GeneratedColumn<String>(
    'profile_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _themeSettingsMeta = const VerificationMeta(
    'themeSettings',
  );
  @override
  late final GeneratedColumn<String> themeSettings = GeneratedColumn<String>(
    'theme_settings',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    profileType,
    themeSettings,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserProfile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('profile_type')) {
      context.handle(
        _profileTypeMeta,
        profileType.isAcceptableOrUnknown(
          data['profile_type']!,
          _profileTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_profileTypeMeta);
    }
    if (data.containsKey('theme_settings')) {
      context.handle(
        _themeSettingsMeta,
        themeSettings.isAcceptableOrUnknown(
          data['theme_settings']!,
          _themeSettingsMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserProfile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      profileType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_type'],
      )!,
      themeSettings: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}theme_settings'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $UserProfilesTable createAlias(String alias) {
    return $UserProfilesTable(attachedDatabase, alias);
  }
}

class UserProfile extends DataClass implements Insertable<UserProfile> {
  final int id;
  final String profileType;
  final String themeSettings;
  final DateTime createdAt;
  const UserProfile({
    required this.id,
    required this.profileType,
    required this.themeSettings,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['profile_type'] = Variable<String>(profileType);
    map['theme_settings'] = Variable<String>(themeSettings);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  UserProfilesCompanion toCompanion(bool nullToAbsent) {
    return UserProfilesCompanion(
      id: Value(id),
      profileType: Value(profileType),
      themeSettings: Value(themeSettings),
      createdAt: Value(createdAt),
    );
  }

  factory UserProfile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserProfile(
      id: serializer.fromJson<int>(json['id']),
      profileType: serializer.fromJson<String>(json['profileType']),
      themeSettings: serializer.fromJson<String>(json['themeSettings']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'profileType': serializer.toJson<String>(profileType),
      'themeSettings': serializer.toJson<String>(themeSettings),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  UserProfile copyWith({
    int? id,
    String? profileType,
    String? themeSettings,
    DateTime? createdAt,
  }) => UserProfile(
    id: id ?? this.id,
    profileType: profileType ?? this.profileType,
    themeSettings: themeSettings ?? this.themeSettings,
    createdAt: createdAt ?? this.createdAt,
  );
  UserProfile copyWithCompanion(UserProfilesCompanion data) {
    return UserProfile(
      id: data.id.present ? data.id.value : this.id,
      profileType: data.profileType.present
          ? data.profileType.value
          : this.profileType,
      themeSettings: data.themeSettings.present
          ? data.themeSettings.value
          : this.themeSettings,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserProfile(')
          ..write('id: $id, ')
          ..write('profileType: $profileType, ')
          ..write('themeSettings: $themeSettings, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, profileType, themeSettings, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserProfile &&
          other.id == this.id &&
          other.profileType == this.profileType &&
          other.themeSettings == this.themeSettings &&
          other.createdAt == this.createdAt);
}

class UserProfilesCompanion extends UpdateCompanion<UserProfile> {
  final Value<int> id;
  final Value<String> profileType;
  final Value<String> themeSettings;
  final Value<DateTime> createdAt;
  const UserProfilesCompanion({
    this.id = const Value.absent(),
    this.profileType = const Value.absent(),
    this.themeSettings = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  UserProfilesCompanion.insert({
    this.id = const Value.absent(),
    required String profileType,
    this.themeSettings = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : profileType = Value(profileType);
  static Insertable<UserProfile> custom({
    Expression<int>? id,
    Expression<String>? profileType,
    Expression<String>? themeSettings,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileType != null) 'profile_type': profileType,
      if (themeSettings != null) 'theme_settings': themeSettings,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  UserProfilesCompanion copyWith({
    Value<int>? id,
    Value<String>? profileType,
    Value<String>? themeSettings,
    Value<DateTime>? createdAt,
  }) {
    return UserProfilesCompanion(
      id: id ?? this.id,
      profileType: profileType ?? this.profileType,
      themeSettings: themeSettings ?? this.themeSettings,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (profileType.present) {
      map['profile_type'] = Variable<String>(profileType.value);
    }
    if (themeSettings.present) {
      map['theme_settings'] = Variable<String>(themeSettings.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserProfilesCompanion(')
          ..write('id: $id, ')
          ..write('profileType: $profileType, ')
          ..write('themeSettings: $themeSettings, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $SourceNotesTable extends SourceNotes
    with TableInfo<$SourceNotesTable, SourceNote> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SourceNotesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _noteIdMeta = const VerificationMeta('noteId');
  @override
  late final GeneratedColumn<String> noteId = GeneratedColumn<String>(
    'note_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rawOcrTextMeta = const VerificationMeta(
    'rawOcrText',
  );
  @override
  late final GeneratedColumn<String> rawOcrText = GeneratedColumn<String>(
    'raw_ocr_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _documentHashMeta = const VerificationMeta(
    'documentHash',
  );
  @override
  late final GeneratedColumn<String> documentHash = GeneratedColumn<String>(
    'document_hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    noteId,
    rawOcrText,
    documentHash,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'source_notes';
  @override
  VerificationContext validateIntegrity(
    Insertable<SourceNote> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('note_id')) {
      context.handle(
        _noteIdMeta,
        noteId.isAcceptableOrUnknown(data['note_id']!, _noteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_noteIdMeta);
    }
    if (data.containsKey('raw_ocr_text')) {
      context.handle(
        _rawOcrTextMeta,
        rawOcrText.isAcceptableOrUnknown(
          data['raw_ocr_text']!,
          _rawOcrTextMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_rawOcrTextMeta);
    }
    if (data.containsKey('document_hash')) {
      context.handle(
        _documentHashMeta,
        documentHash.isAcceptableOrUnknown(
          data['document_hash']!,
          _documentHashMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_documentHashMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {noteId};
  @override
  SourceNote map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SourceNote(
      noteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note_id'],
      )!,
      rawOcrText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_ocr_text'],
      )!,
      documentHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}document_hash'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SourceNotesTable createAlias(String alias) {
    return $SourceNotesTable(attachedDatabase, alias);
  }
}

class SourceNote extends DataClass implements Insertable<SourceNote> {
  final String noteId;
  final String rawOcrText;
  final String documentHash;
  final DateTime createdAt;
  const SourceNote({
    required this.noteId,
    required this.rawOcrText,
    required this.documentHash,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['note_id'] = Variable<String>(noteId);
    map['raw_ocr_text'] = Variable<String>(rawOcrText);
    map['document_hash'] = Variable<String>(documentHash);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SourceNotesCompanion toCompanion(bool nullToAbsent) {
    return SourceNotesCompanion(
      noteId: Value(noteId),
      rawOcrText: Value(rawOcrText),
      documentHash: Value(documentHash),
      createdAt: Value(createdAt),
    );
  }

  factory SourceNote.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SourceNote(
      noteId: serializer.fromJson<String>(json['noteId']),
      rawOcrText: serializer.fromJson<String>(json['rawOcrText']),
      documentHash: serializer.fromJson<String>(json['documentHash']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'noteId': serializer.toJson<String>(noteId),
      'rawOcrText': serializer.toJson<String>(rawOcrText),
      'documentHash': serializer.toJson<String>(documentHash),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SourceNote copyWith({
    String? noteId,
    String? rawOcrText,
    String? documentHash,
    DateTime? createdAt,
  }) => SourceNote(
    noteId: noteId ?? this.noteId,
    rawOcrText: rawOcrText ?? this.rawOcrText,
    documentHash: documentHash ?? this.documentHash,
    createdAt: createdAt ?? this.createdAt,
  );
  SourceNote copyWithCompanion(SourceNotesCompanion data) {
    return SourceNote(
      noteId: data.noteId.present ? data.noteId.value : this.noteId,
      rawOcrText: data.rawOcrText.present
          ? data.rawOcrText.value
          : this.rawOcrText,
      documentHash: data.documentHash.present
          ? data.documentHash.value
          : this.documentHash,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SourceNote(')
          ..write('noteId: $noteId, ')
          ..write('rawOcrText: $rawOcrText, ')
          ..write('documentHash: $documentHash, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(noteId, rawOcrText, documentHash, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SourceNote &&
          other.noteId == this.noteId &&
          other.rawOcrText == this.rawOcrText &&
          other.documentHash == this.documentHash &&
          other.createdAt == this.createdAt);
}

class SourceNotesCompanion extends UpdateCompanion<SourceNote> {
  final Value<String> noteId;
  final Value<String> rawOcrText;
  final Value<String> documentHash;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const SourceNotesCompanion({
    this.noteId = const Value.absent(),
    this.rawOcrText = const Value.absent(),
    this.documentHash = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SourceNotesCompanion.insert({
    required String noteId,
    required String rawOcrText,
    required String documentHash,
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : noteId = Value(noteId),
       rawOcrText = Value(rawOcrText),
       documentHash = Value(documentHash);
  static Insertable<SourceNote> custom({
    Expression<String>? noteId,
    Expression<String>? rawOcrText,
    Expression<String>? documentHash,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (noteId != null) 'note_id': noteId,
      if (rawOcrText != null) 'raw_ocr_text': rawOcrText,
      if (documentHash != null) 'document_hash': documentHash,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SourceNotesCompanion copyWith({
    Value<String>? noteId,
    Value<String>? rawOcrText,
    Value<String>? documentHash,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return SourceNotesCompanion(
      noteId: noteId ?? this.noteId,
      rawOcrText: rawOcrText ?? this.rawOcrText,
      documentHash: documentHash ?? this.documentHash,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (noteId.present) {
      map['note_id'] = Variable<String>(noteId.value);
    }
    if (rawOcrText.present) {
      map['raw_ocr_text'] = Variable<String>(rawOcrText.value);
    }
    if (documentHash.present) {
      map['document_hash'] = Variable<String>(documentHash.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SourceNotesCompanion(')
          ..write('noteId: $noteId, ')
          ..write('rawOcrText: $rawOcrText, ')
          ..write('documentHash: $documentHash, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LessonsTable extends Lessons with TableInfo<$LessonsTable, Lesson> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LessonsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _lessonIdMeta = const VerificationMeta(
    'lessonId',
  );
  @override
  late final GeneratedColumn<String> lessonId = GeneratedColumn<String>(
    'lesson_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteIdMeta = const VerificationMeta('noteId');
  @override
  late final GeneratedColumn<String> noteId = GeneratedColumn<String>(
    'note_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES source_notes (note_id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _conceptMapJsonMeta = const VerificationMeta(
    'conceptMapJson',
  );
  @override
  late final GeneratedColumn<String> conceptMapJson = GeneratedColumn<String>(
    'concept_map_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _promptVersionMeta = const VerificationMeta(
    'promptVersion',
  );
  @override
  late final GeneratedColumn<String> promptVersion = GeneratedColumn<String>(
    'prompt_version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('v1'),
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('seed'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    lessonId,
    noteId,
    title,
    conceptMapJson,
    promptVersion,
    source,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lessons';
  @override
  VerificationContext validateIntegrity(
    Insertable<Lesson> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('lesson_id')) {
      context.handle(
        _lessonIdMeta,
        lessonId.isAcceptableOrUnknown(data['lesson_id']!, _lessonIdMeta),
      );
    } else if (isInserting) {
      context.missing(_lessonIdMeta);
    }
    if (data.containsKey('note_id')) {
      context.handle(
        _noteIdMeta,
        noteId.isAcceptableOrUnknown(data['note_id']!, _noteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_noteIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('concept_map_json')) {
      context.handle(
        _conceptMapJsonMeta,
        conceptMapJson.isAcceptableOrUnknown(
          data['concept_map_json']!,
          _conceptMapJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_conceptMapJsonMeta);
    }
    if (data.containsKey('prompt_version')) {
      context.handle(
        _promptVersionMeta,
        promptVersion.isAcceptableOrUnknown(
          data['prompt_version']!,
          _promptVersionMeta,
        ),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {lessonId};
  @override
  Lesson map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Lesson(
      lessonId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lesson_id'],
      )!,
      noteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      conceptMapJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}concept_map_json'],
      )!,
      promptVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}prompt_version'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $LessonsTable createAlias(String alias) {
    return $LessonsTable(attachedDatabase, alias);
  }
}

class Lesson extends DataClass implements Insertable<Lesson> {
  final String lessonId;
  final String noteId;
  final String title;
  final String conceptMapJson;
  final String promptVersion;
  final String source;
  final DateTime createdAt;
  const Lesson({
    required this.lessonId,
    required this.noteId,
    required this.title,
    required this.conceptMapJson,
    required this.promptVersion,
    required this.source,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['lesson_id'] = Variable<String>(lessonId);
    map['note_id'] = Variable<String>(noteId);
    map['title'] = Variable<String>(title);
    map['concept_map_json'] = Variable<String>(conceptMapJson);
    map['prompt_version'] = Variable<String>(promptVersion);
    map['source'] = Variable<String>(source);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  LessonsCompanion toCompanion(bool nullToAbsent) {
    return LessonsCompanion(
      lessonId: Value(lessonId),
      noteId: Value(noteId),
      title: Value(title),
      conceptMapJson: Value(conceptMapJson),
      promptVersion: Value(promptVersion),
      source: Value(source),
      createdAt: Value(createdAt),
    );
  }

  factory Lesson.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Lesson(
      lessonId: serializer.fromJson<String>(json['lessonId']),
      noteId: serializer.fromJson<String>(json['noteId']),
      title: serializer.fromJson<String>(json['title']),
      conceptMapJson: serializer.fromJson<String>(json['conceptMapJson']),
      promptVersion: serializer.fromJson<String>(json['promptVersion']),
      source: serializer.fromJson<String>(json['source']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'lessonId': serializer.toJson<String>(lessonId),
      'noteId': serializer.toJson<String>(noteId),
      'title': serializer.toJson<String>(title),
      'conceptMapJson': serializer.toJson<String>(conceptMapJson),
      'promptVersion': serializer.toJson<String>(promptVersion),
      'source': serializer.toJson<String>(source),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Lesson copyWith({
    String? lessonId,
    String? noteId,
    String? title,
    String? conceptMapJson,
    String? promptVersion,
    String? source,
    DateTime? createdAt,
  }) => Lesson(
    lessonId: lessonId ?? this.lessonId,
    noteId: noteId ?? this.noteId,
    title: title ?? this.title,
    conceptMapJson: conceptMapJson ?? this.conceptMapJson,
    promptVersion: promptVersion ?? this.promptVersion,
    source: source ?? this.source,
    createdAt: createdAt ?? this.createdAt,
  );
  Lesson copyWithCompanion(LessonsCompanion data) {
    return Lesson(
      lessonId: data.lessonId.present ? data.lessonId.value : this.lessonId,
      noteId: data.noteId.present ? data.noteId.value : this.noteId,
      title: data.title.present ? data.title.value : this.title,
      conceptMapJson: data.conceptMapJson.present
          ? data.conceptMapJson.value
          : this.conceptMapJson,
      promptVersion: data.promptVersion.present
          ? data.promptVersion.value
          : this.promptVersion,
      source: data.source.present ? data.source.value : this.source,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Lesson(')
          ..write('lessonId: $lessonId, ')
          ..write('noteId: $noteId, ')
          ..write('title: $title, ')
          ..write('conceptMapJson: $conceptMapJson, ')
          ..write('promptVersion: $promptVersion, ')
          ..write('source: $source, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    lessonId,
    noteId,
    title,
    conceptMapJson,
    promptVersion,
    source,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Lesson &&
          other.lessonId == this.lessonId &&
          other.noteId == this.noteId &&
          other.title == this.title &&
          other.conceptMapJson == this.conceptMapJson &&
          other.promptVersion == this.promptVersion &&
          other.source == this.source &&
          other.createdAt == this.createdAt);
}

class LessonsCompanion extends UpdateCompanion<Lesson> {
  final Value<String> lessonId;
  final Value<String> noteId;
  final Value<String> title;
  final Value<String> conceptMapJson;
  final Value<String> promptVersion;
  final Value<String> source;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const LessonsCompanion({
    this.lessonId = const Value.absent(),
    this.noteId = const Value.absent(),
    this.title = const Value.absent(),
    this.conceptMapJson = const Value.absent(),
    this.promptVersion = const Value.absent(),
    this.source = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LessonsCompanion.insert({
    required String lessonId,
    required String noteId,
    required String title,
    required String conceptMapJson,
    this.promptVersion = const Value.absent(),
    this.source = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : lessonId = Value(lessonId),
       noteId = Value(noteId),
       title = Value(title),
       conceptMapJson = Value(conceptMapJson);
  static Insertable<Lesson> custom({
    Expression<String>? lessonId,
    Expression<String>? noteId,
    Expression<String>? title,
    Expression<String>? conceptMapJson,
    Expression<String>? promptVersion,
    Expression<String>? source,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (lessonId != null) 'lesson_id': lessonId,
      if (noteId != null) 'note_id': noteId,
      if (title != null) 'title': title,
      if (conceptMapJson != null) 'concept_map_json': conceptMapJson,
      if (promptVersion != null) 'prompt_version': promptVersion,
      if (source != null) 'source': source,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LessonsCompanion copyWith({
    Value<String>? lessonId,
    Value<String>? noteId,
    Value<String>? title,
    Value<String>? conceptMapJson,
    Value<String>? promptVersion,
    Value<String>? source,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return LessonsCompanion(
      lessonId: lessonId ?? this.lessonId,
      noteId: noteId ?? this.noteId,
      title: title ?? this.title,
      conceptMapJson: conceptMapJson ?? this.conceptMapJson,
      promptVersion: promptVersion ?? this.promptVersion,
      source: source ?? this.source,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (lessonId.present) {
      map['lesson_id'] = Variable<String>(lessonId.value);
    }
    if (noteId.present) {
      map['note_id'] = Variable<String>(noteId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (conceptMapJson.present) {
      map['concept_map_json'] = Variable<String>(conceptMapJson.value);
    }
    if (promptVersion.present) {
      map['prompt_version'] = Variable<String>(promptVersion.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LessonsCompanion(')
          ..write('lessonId: $lessonId, ')
          ..write('noteId: $noteId, ')
          ..write('title: $title, ')
          ..write('conceptMapJson: $conceptMapJson, ')
          ..write('promptVersion: $promptVersion, ')
          ..write('source: $source, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FlashcardsTable extends Flashcards
    with TableInfo<$FlashcardsTable, Flashcard> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FlashcardsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _cardIdMeta = const VerificationMeta('cardId');
  @override
  late final GeneratedColumn<String> cardId = GeneratedColumn<String>(
    'card_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lessonIdMeta = const VerificationMeta(
    'lessonId',
  );
  @override
  late final GeneratedColumn<String> lessonId = GeneratedColumn<String>(
    'lesson_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES lessons (lesson_id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _questionMeta = const VerificationMeta(
    'question',
  );
  @override
  late final GeneratedColumn<String> question = GeneratedColumn<String>(
    'question',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _answerMeta = const VerificationMeta('answer');
  @override
  late final GeneratedColumn<String> answer = GeneratedColumn<String>(
    'answer',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceLineReferenceMeta =
      const VerificationMeta('sourceLineReference');
  @override
  late final GeneratedColumn<String> sourceLineReference =
      GeneratedColumn<String>(
        'source_line_reference',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _groundingScoreMeta = const VerificationMeta(
    'groundingScore',
  );
  @override
  late final GeneratedColumn<double> groundingScore = GeneratedColumn<double>(
    'grounding_score',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _verifiedMeta = const VerificationMeta(
    'verified',
  );
  @override
  late final GeneratedColumn<bool> verified = GeneratedColumn<bool>(
    'verified',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("verified" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    cardId,
    lessonId,
    question,
    answer,
    sourceLineReference,
    groundingScore,
    verified,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'flashcards';
  @override
  VerificationContext validateIntegrity(
    Insertable<Flashcard> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('card_id')) {
      context.handle(
        _cardIdMeta,
        cardId.isAcceptableOrUnknown(data['card_id']!, _cardIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cardIdMeta);
    }
    if (data.containsKey('lesson_id')) {
      context.handle(
        _lessonIdMeta,
        lessonId.isAcceptableOrUnknown(data['lesson_id']!, _lessonIdMeta),
      );
    } else if (isInserting) {
      context.missing(_lessonIdMeta);
    }
    if (data.containsKey('question')) {
      context.handle(
        _questionMeta,
        question.isAcceptableOrUnknown(data['question']!, _questionMeta),
      );
    } else if (isInserting) {
      context.missing(_questionMeta);
    }
    if (data.containsKey('answer')) {
      context.handle(
        _answerMeta,
        answer.isAcceptableOrUnknown(data['answer']!, _answerMeta),
      );
    } else if (isInserting) {
      context.missing(_answerMeta);
    }
    if (data.containsKey('source_line_reference')) {
      context.handle(
        _sourceLineReferenceMeta,
        sourceLineReference.isAcceptableOrUnknown(
          data['source_line_reference']!,
          _sourceLineReferenceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sourceLineReferenceMeta);
    }
    if (data.containsKey('grounding_score')) {
      context.handle(
        _groundingScoreMeta,
        groundingScore.isAcceptableOrUnknown(
          data['grounding_score']!,
          _groundingScoreMeta,
        ),
      );
    }
    if (data.containsKey('verified')) {
      context.handle(
        _verifiedMeta,
        verified.isAcceptableOrUnknown(data['verified']!, _verifiedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {cardId};
  @override
  Flashcard map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Flashcard(
      cardId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}card_id'],
      )!,
      lessonId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lesson_id'],
      )!,
      question: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}question'],
      )!,
      answer: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}answer'],
      )!,
      sourceLineReference: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_line_reference'],
      )!,
      groundingScore: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}grounding_score'],
      ),
      verified: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}verified'],
      )!,
    );
  }

  @override
  $FlashcardsTable createAlias(String alias) {
    return $FlashcardsTable(attachedDatabase, alias);
  }
}

class Flashcard extends DataClass implements Insertable<Flashcard> {
  final String cardId;
  final String lessonId;
  final String question;
  final String answer;
  final String sourceLineReference;
  final double? groundingScore;
  final bool verified;
  const Flashcard({
    required this.cardId,
    required this.lessonId,
    required this.question,
    required this.answer,
    required this.sourceLineReference,
    this.groundingScore,
    required this.verified,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['card_id'] = Variable<String>(cardId);
    map['lesson_id'] = Variable<String>(lessonId);
    map['question'] = Variable<String>(question);
    map['answer'] = Variable<String>(answer);
    map['source_line_reference'] = Variable<String>(sourceLineReference);
    if (!nullToAbsent || groundingScore != null) {
      map['grounding_score'] = Variable<double>(groundingScore);
    }
    map['verified'] = Variable<bool>(verified);
    return map;
  }

  FlashcardsCompanion toCompanion(bool nullToAbsent) {
    return FlashcardsCompanion(
      cardId: Value(cardId),
      lessonId: Value(lessonId),
      question: Value(question),
      answer: Value(answer),
      sourceLineReference: Value(sourceLineReference),
      groundingScore: groundingScore == null && nullToAbsent
          ? const Value.absent()
          : Value(groundingScore),
      verified: Value(verified),
    );
  }

  factory Flashcard.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Flashcard(
      cardId: serializer.fromJson<String>(json['cardId']),
      lessonId: serializer.fromJson<String>(json['lessonId']),
      question: serializer.fromJson<String>(json['question']),
      answer: serializer.fromJson<String>(json['answer']),
      sourceLineReference: serializer.fromJson<String>(
        json['sourceLineReference'],
      ),
      groundingScore: serializer.fromJson<double?>(json['groundingScore']),
      verified: serializer.fromJson<bool>(json['verified']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'cardId': serializer.toJson<String>(cardId),
      'lessonId': serializer.toJson<String>(lessonId),
      'question': serializer.toJson<String>(question),
      'answer': serializer.toJson<String>(answer),
      'sourceLineReference': serializer.toJson<String>(sourceLineReference),
      'groundingScore': serializer.toJson<double?>(groundingScore),
      'verified': serializer.toJson<bool>(verified),
    };
  }

  Flashcard copyWith({
    String? cardId,
    String? lessonId,
    String? question,
    String? answer,
    String? sourceLineReference,
    Value<double?> groundingScore = const Value.absent(),
    bool? verified,
  }) => Flashcard(
    cardId: cardId ?? this.cardId,
    lessonId: lessonId ?? this.lessonId,
    question: question ?? this.question,
    answer: answer ?? this.answer,
    sourceLineReference: sourceLineReference ?? this.sourceLineReference,
    groundingScore: groundingScore.present
        ? groundingScore.value
        : this.groundingScore,
    verified: verified ?? this.verified,
  );
  Flashcard copyWithCompanion(FlashcardsCompanion data) {
    return Flashcard(
      cardId: data.cardId.present ? data.cardId.value : this.cardId,
      lessonId: data.lessonId.present ? data.lessonId.value : this.lessonId,
      question: data.question.present ? data.question.value : this.question,
      answer: data.answer.present ? data.answer.value : this.answer,
      sourceLineReference: data.sourceLineReference.present
          ? data.sourceLineReference.value
          : this.sourceLineReference,
      groundingScore: data.groundingScore.present
          ? data.groundingScore.value
          : this.groundingScore,
      verified: data.verified.present ? data.verified.value : this.verified,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Flashcard(')
          ..write('cardId: $cardId, ')
          ..write('lessonId: $lessonId, ')
          ..write('question: $question, ')
          ..write('answer: $answer, ')
          ..write('sourceLineReference: $sourceLineReference, ')
          ..write('groundingScore: $groundingScore, ')
          ..write('verified: $verified')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    cardId,
    lessonId,
    question,
    answer,
    sourceLineReference,
    groundingScore,
    verified,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Flashcard &&
          other.cardId == this.cardId &&
          other.lessonId == this.lessonId &&
          other.question == this.question &&
          other.answer == this.answer &&
          other.sourceLineReference == this.sourceLineReference &&
          other.groundingScore == this.groundingScore &&
          other.verified == this.verified);
}

class FlashcardsCompanion extends UpdateCompanion<Flashcard> {
  final Value<String> cardId;
  final Value<String> lessonId;
  final Value<String> question;
  final Value<String> answer;
  final Value<String> sourceLineReference;
  final Value<double?> groundingScore;
  final Value<bool> verified;
  final Value<int> rowid;
  const FlashcardsCompanion({
    this.cardId = const Value.absent(),
    this.lessonId = const Value.absent(),
    this.question = const Value.absent(),
    this.answer = const Value.absent(),
    this.sourceLineReference = const Value.absent(),
    this.groundingScore = const Value.absent(),
    this.verified = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FlashcardsCompanion.insert({
    required String cardId,
    required String lessonId,
    required String question,
    required String answer,
    required String sourceLineReference,
    this.groundingScore = const Value.absent(),
    this.verified = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : cardId = Value(cardId),
       lessonId = Value(lessonId),
       question = Value(question),
       answer = Value(answer),
       sourceLineReference = Value(sourceLineReference);
  static Insertable<Flashcard> custom({
    Expression<String>? cardId,
    Expression<String>? lessonId,
    Expression<String>? question,
    Expression<String>? answer,
    Expression<String>? sourceLineReference,
    Expression<double>? groundingScore,
    Expression<bool>? verified,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (cardId != null) 'card_id': cardId,
      if (lessonId != null) 'lesson_id': lessonId,
      if (question != null) 'question': question,
      if (answer != null) 'answer': answer,
      if (sourceLineReference != null)
        'source_line_reference': sourceLineReference,
      if (groundingScore != null) 'grounding_score': groundingScore,
      if (verified != null) 'verified': verified,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FlashcardsCompanion copyWith({
    Value<String>? cardId,
    Value<String>? lessonId,
    Value<String>? question,
    Value<String>? answer,
    Value<String>? sourceLineReference,
    Value<double?>? groundingScore,
    Value<bool>? verified,
    Value<int>? rowid,
  }) {
    return FlashcardsCompanion(
      cardId: cardId ?? this.cardId,
      lessonId: lessonId ?? this.lessonId,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      sourceLineReference: sourceLineReference ?? this.sourceLineReference,
      groundingScore: groundingScore ?? this.groundingScore,
      verified: verified ?? this.verified,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (cardId.present) {
      map['card_id'] = Variable<String>(cardId.value);
    }
    if (lessonId.present) {
      map['lesson_id'] = Variable<String>(lessonId.value);
    }
    if (question.present) {
      map['question'] = Variable<String>(question.value);
    }
    if (answer.present) {
      map['answer'] = Variable<String>(answer.value);
    }
    if (sourceLineReference.present) {
      map['source_line_reference'] = Variable<String>(
        sourceLineReference.value,
      );
    }
    if (groundingScore.present) {
      map['grounding_score'] = Variable<double>(groundingScore.value);
    }
    if (verified.present) {
      map['verified'] = Variable<bool>(verified.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FlashcardsCompanion(')
          ..write('cardId: $cardId, ')
          ..write('lessonId: $lessonId, ')
          ..write('question: $question, ')
          ..write('answer: $answer, ')
          ..write('sourceLineReference: $sourceLineReference, ')
          ..write('groundingScore: $groundingScore, ')
          ..write('verified: $verified, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReviewProgressTable extends ReviewProgress
    with TableInfo<$ReviewProgressTable, ReviewProgressData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReviewProgressTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _progressIdMeta = const VerificationMeta(
    'progressId',
  );
  @override
  late final GeneratedColumn<int> progressId = GeneratedColumn<int>(
    'progress_id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _cardIdMeta = const VerificationMeta('cardId');
  @override
  late final GeneratedColumn<String> cardId = GeneratedColumn<String>(
    'card_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES flashcards (card_id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _boxMeta = const VerificationMeta('box');
  @override
  late final GeneratedColumn<int> box = GeneratedColumn<int>(
    'box',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _spacedRepetitionIntervalMeta =
      const VerificationMeta('spacedRepetitionInterval');
  @override
  late final GeneratedColumn<int> spacedRepetitionInterval =
      GeneratedColumn<int>(
        'spaced_repetition_interval',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(1),
      );
  static const VerificationMeta _nextReviewDateMeta = const VerificationMeta(
    'nextReviewDate',
  );
  @override
  late final GeneratedColumn<DateTime> nextReviewDate =
      GeneratedColumn<DateTime>(
        'next_review_date',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _lastReviewedAtMeta = const VerificationMeta(
    'lastReviewedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastReviewedAt =
      GeneratedColumn<DateTime>(
        'last_reviewed_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _consecutiveCorrectMeta =
      const VerificationMeta('consecutiveCorrect');
  @override
  late final GeneratedColumn<int> consecutiveCorrect = GeneratedColumn<int>(
    'consecutive_correct',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    progressId,
    cardId,
    box,
    spacedRepetitionInterval,
    nextReviewDate,
    lastReviewedAt,
    consecutiveCorrect,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'review_progress';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReviewProgressData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('progress_id')) {
      context.handle(
        _progressIdMeta,
        progressId.isAcceptableOrUnknown(data['progress_id']!, _progressIdMeta),
      );
    }
    if (data.containsKey('card_id')) {
      context.handle(
        _cardIdMeta,
        cardId.isAcceptableOrUnknown(data['card_id']!, _cardIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cardIdMeta);
    }
    if (data.containsKey('box')) {
      context.handle(
        _boxMeta,
        box.isAcceptableOrUnknown(data['box']!, _boxMeta),
      );
    }
    if (data.containsKey('spaced_repetition_interval')) {
      context.handle(
        _spacedRepetitionIntervalMeta,
        spacedRepetitionInterval.isAcceptableOrUnknown(
          data['spaced_repetition_interval']!,
          _spacedRepetitionIntervalMeta,
        ),
      );
    }
    if (data.containsKey('next_review_date')) {
      context.handle(
        _nextReviewDateMeta,
        nextReviewDate.isAcceptableOrUnknown(
          data['next_review_date']!,
          _nextReviewDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_nextReviewDateMeta);
    }
    if (data.containsKey('last_reviewed_at')) {
      context.handle(
        _lastReviewedAtMeta,
        lastReviewedAt.isAcceptableOrUnknown(
          data['last_reviewed_at']!,
          _lastReviewedAtMeta,
        ),
      );
    }
    if (data.containsKey('consecutive_correct')) {
      context.handle(
        _consecutiveCorrectMeta,
        consecutiveCorrect.isAcceptableOrUnknown(
          data['consecutive_correct']!,
          _consecutiveCorrectMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {progressId};
  @override
  ReviewProgressData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReviewProgressData(
      progressId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}progress_id'],
      )!,
      cardId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}card_id'],
      )!,
      box: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}box'],
      )!,
      spacedRepetitionInterval: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}spaced_repetition_interval'],
      )!,
      nextReviewDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_review_date'],
      )!,
      lastReviewedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_reviewed_at'],
      ),
      consecutiveCorrect: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}consecutive_correct'],
      )!,
    );
  }

  @override
  $ReviewProgressTable createAlias(String alias) {
    return $ReviewProgressTable(attachedDatabase, alias);
  }
}

class ReviewProgressData extends DataClass
    implements Insertable<ReviewProgressData> {
  final int progressId;
  final String cardId;
  final int box;
  final int spacedRepetitionInterval;
  final DateTime nextReviewDate;
  final DateTime? lastReviewedAt;
  final int consecutiveCorrect;
  const ReviewProgressData({
    required this.progressId,
    required this.cardId,
    required this.box,
    required this.spacedRepetitionInterval,
    required this.nextReviewDate,
    this.lastReviewedAt,
    required this.consecutiveCorrect,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['progress_id'] = Variable<int>(progressId);
    map['card_id'] = Variable<String>(cardId);
    map['box'] = Variable<int>(box);
    map['spaced_repetition_interval'] = Variable<int>(spacedRepetitionInterval);
    map['next_review_date'] = Variable<DateTime>(nextReviewDate);
    if (!nullToAbsent || lastReviewedAt != null) {
      map['last_reviewed_at'] = Variable<DateTime>(lastReviewedAt);
    }
    map['consecutive_correct'] = Variable<int>(consecutiveCorrect);
    return map;
  }

  ReviewProgressCompanion toCompanion(bool nullToAbsent) {
    return ReviewProgressCompanion(
      progressId: Value(progressId),
      cardId: Value(cardId),
      box: Value(box),
      spacedRepetitionInterval: Value(spacedRepetitionInterval),
      nextReviewDate: Value(nextReviewDate),
      lastReviewedAt: lastReviewedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastReviewedAt),
      consecutiveCorrect: Value(consecutiveCorrect),
    );
  }

  factory ReviewProgressData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReviewProgressData(
      progressId: serializer.fromJson<int>(json['progressId']),
      cardId: serializer.fromJson<String>(json['cardId']),
      box: serializer.fromJson<int>(json['box']),
      spacedRepetitionInterval: serializer.fromJson<int>(
        json['spacedRepetitionInterval'],
      ),
      nextReviewDate: serializer.fromJson<DateTime>(json['nextReviewDate']),
      lastReviewedAt: serializer.fromJson<DateTime?>(json['lastReviewedAt']),
      consecutiveCorrect: serializer.fromJson<int>(json['consecutiveCorrect']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'progressId': serializer.toJson<int>(progressId),
      'cardId': serializer.toJson<String>(cardId),
      'box': serializer.toJson<int>(box),
      'spacedRepetitionInterval': serializer.toJson<int>(
        spacedRepetitionInterval,
      ),
      'nextReviewDate': serializer.toJson<DateTime>(nextReviewDate),
      'lastReviewedAt': serializer.toJson<DateTime?>(lastReviewedAt),
      'consecutiveCorrect': serializer.toJson<int>(consecutiveCorrect),
    };
  }

  ReviewProgressData copyWith({
    int? progressId,
    String? cardId,
    int? box,
    int? spacedRepetitionInterval,
    DateTime? nextReviewDate,
    Value<DateTime?> lastReviewedAt = const Value.absent(),
    int? consecutiveCorrect,
  }) => ReviewProgressData(
    progressId: progressId ?? this.progressId,
    cardId: cardId ?? this.cardId,
    box: box ?? this.box,
    spacedRepetitionInterval:
        spacedRepetitionInterval ?? this.spacedRepetitionInterval,
    nextReviewDate: nextReviewDate ?? this.nextReviewDate,
    lastReviewedAt: lastReviewedAt.present
        ? lastReviewedAt.value
        : this.lastReviewedAt,
    consecutiveCorrect: consecutiveCorrect ?? this.consecutiveCorrect,
  );
  ReviewProgressData copyWithCompanion(ReviewProgressCompanion data) {
    return ReviewProgressData(
      progressId: data.progressId.present
          ? data.progressId.value
          : this.progressId,
      cardId: data.cardId.present ? data.cardId.value : this.cardId,
      box: data.box.present ? data.box.value : this.box,
      spacedRepetitionInterval: data.spacedRepetitionInterval.present
          ? data.spacedRepetitionInterval.value
          : this.spacedRepetitionInterval,
      nextReviewDate: data.nextReviewDate.present
          ? data.nextReviewDate.value
          : this.nextReviewDate,
      lastReviewedAt: data.lastReviewedAt.present
          ? data.lastReviewedAt.value
          : this.lastReviewedAt,
      consecutiveCorrect: data.consecutiveCorrect.present
          ? data.consecutiveCorrect.value
          : this.consecutiveCorrect,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReviewProgressData(')
          ..write('progressId: $progressId, ')
          ..write('cardId: $cardId, ')
          ..write('box: $box, ')
          ..write('spacedRepetitionInterval: $spacedRepetitionInterval, ')
          ..write('nextReviewDate: $nextReviewDate, ')
          ..write('lastReviewedAt: $lastReviewedAt, ')
          ..write('consecutiveCorrect: $consecutiveCorrect')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    progressId,
    cardId,
    box,
    spacedRepetitionInterval,
    nextReviewDate,
    lastReviewedAt,
    consecutiveCorrect,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReviewProgressData &&
          other.progressId == this.progressId &&
          other.cardId == this.cardId &&
          other.box == this.box &&
          other.spacedRepetitionInterval == this.spacedRepetitionInterval &&
          other.nextReviewDate == this.nextReviewDate &&
          other.lastReviewedAt == this.lastReviewedAt &&
          other.consecutiveCorrect == this.consecutiveCorrect);
}

class ReviewProgressCompanion extends UpdateCompanion<ReviewProgressData> {
  final Value<int> progressId;
  final Value<String> cardId;
  final Value<int> box;
  final Value<int> spacedRepetitionInterval;
  final Value<DateTime> nextReviewDate;
  final Value<DateTime?> lastReviewedAt;
  final Value<int> consecutiveCorrect;
  const ReviewProgressCompanion({
    this.progressId = const Value.absent(),
    this.cardId = const Value.absent(),
    this.box = const Value.absent(),
    this.spacedRepetitionInterval = const Value.absent(),
    this.nextReviewDate = const Value.absent(),
    this.lastReviewedAt = const Value.absent(),
    this.consecutiveCorrect = const Value.absent(),
  });
  ReviewProgressCompanion.insert({
    this.progressId = const Value.absent(),
    required String cardId,
    this.box = const Value.absent(),
    this.spacedRepetitionInterval = const Value.absent(),
    required DateTime nextReviewDate,
    this.lastReviewedAt = const Value.absent(),
    this.consecutiveCorrect = const Value.absent(),
  }) : cardId = Value(cardId),
       nextReviewDate = Value(nextReviewDate);
  static Insertable<ReviewProgressData> custom({
    Expression<int>? progressId,
    Expression<String>? cardId,
    Expression<int>? box,
    Expression<int>? spacedRepetitionInterval,
    Expression<DateTime>? nextReviewDate,
    Expression<DateTime>? lastReviewedAt,
    Expression<int>? consecutiveCorrect,
  }) {
    return RawValuesInsertable({
      if (progressId != null) 'progress_id': progressId,
      if (cardId != null) 'card_id': cardId,
      if (box != null) 'box': box,
      if (spacedRepetitionInterval != null)
        'spaced_repetition_interval': spacedRepetitionInterval,
      if (nextReviewDate != null) 'next_review_date': nextReviewDate,
      if (lastReviewedAt != null) 'last_reviewed_at': lastReviewedAt,
      if (consecutiveCorrect != null) 'consecutive_correct': consecutiveCorrect,
    });
  }

  ReviewProgressCompanion copyWith({
    Value<int>? progressId,
    Value<String>? cardId,
    Value<int>? box,
    Value<int>? spacedRepetitionInterval,
    Value<DateTime>? nextReviewDate,
    Value<DateTime?>? lastReviewedAt,
    Value<int>? consecutiveCorrect,
  }) {
    return ReviewProgressCompanion(
      progressId: progressId ?? this.progressId,
      cardId: cardId ?? this.cardId,
      box: box ?? this.box,
      spacedRepetitionInterval:
          spacedRepetitionInterval ?? this.spacedRepetitionInterval,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
      consecutiveCorrect: consecutiveCorrect ?? this.consecutiveCorrect,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (progressId.present) {
      map['progress_id'] = Variable<int>(progressId.value);
    }
    if (cardId.present) {
      map['card_id'] = Variable<String>(cardId.value);
    }
    if (box.present) {
      map['box'] = Variable<int>(box.value);
    }
    if (spacedRepetitionInterval.present) {
      map['spaced_repetition_interval'] = Variable<int>(
        spacedRepetitionInterval.value,
      );
    }
    if (nextReviewDate.present) {
      map['next_review_date'] = Variable<DateTime>(nextReviewDate.value);
    }
    if (lastReviewedAt.present) {
      map['last_reviewed_at'] = Variable<DateTime>(lastReviewedAt.value);
    }
    if (consecutiveCorrect.present) {
      map['consecutive_correct'] = Variable<int>(consecutiveCorrect.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReviewProgressCompanion(')
          ..write('progressId: $progressId, ')
          ..write('cardId: $cardId, ')
          ..write('box: $box, ')
          ..write('spacedRepetitionInterval: $spacedRepetitionInterval, ')
          ..write('nextReviewDate: $nextReviewDate, ')
          ..write('lastReviewedAt: $lastReviewedAt, ')
          ..write('consecutiveCorrect: $consecutiveCorrect')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UserProfilesTable userProfiles = $UserProfilesTable(this);
  late final $SourceNotesTable sourceNotes = $SourceNotesTable(this);
  late final $LessonsTable lessons = $LessonsTable(this);
  late final $FlashcardsTable flashcards = $FlashcardsTable(this);
  late final $ReviewProgressTable reviewProgress = $ReviewProgressTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    userProfiles,
    sourceNotes,
    lessons,
    flashcards,
    reviewProgress,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'source_notes',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('lessons', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'lessons',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('flashcards', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'flashcards',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('review_progress', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$UserProfilesTableCreateCompanionBuilder =
    UserProfilesCompanion Function({
      Value<int> id,
      required String profileType,
      Value<String> themeSettings,
      Value<DateTime> createdAt,
    });
typedef $$UserProfilesTableUpdateCompanionBuilder =
    UserProfilesCompanion Function({
      Value<int> id,
      Value<String> profileType,
      Value<String> themeSettings,
      Value<DateTime> createdAt,
    });

class $$UserProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get profileType => $composableBuilder(
    column: $table.profileType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get themeSettings => $composableBuilder(
    column: $table.themeSettings,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get profileType => $composableBuilder(
    column: $table.profileType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get themeSettings => $composableBuilder(
    column: $table.themeSettings,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get profileType => $composableBuilder(
    column: $table.profileType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get themeSettings => $composableBuilder(
    column: $table.themeSettings,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$UserProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserProfilesTable,
          UserProfile,
          $$UserProfilesTableFilterComposer,
          $$UserProfilesTableOrderingComposer,
          $$UserProfilesTableAnnotationComposer,
          $$UserProfilesTableCreateCompanionBuilder,
          $$UserProfilesTableUpdateCompanionBuilder,
          (
            UserProfile,
            BaseReferences<_$AppDatabase, $UserProfilesTable, UserProfile>,
          ),
          UserProfile,
          PrefetchHooks Function()
        > {
  $$UserProfilesTableTableManager(_$AppDatabase db, $UserProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> profileType = const Value.absent(),
                Value<String> themeSettings = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => UserProfilesCompanion(
                id: id,
                profileType: profileType,
                themeSettings: themeSettings,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String profileType,
                Value<String> themeSettings = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => UserProfilesCompanion.insert(
                id: id,
                profileType: profileType,
                themeSettings: themeSettings,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$UserProfilesTable, UserProfile>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $UserProfilesTable,
                    UserProfile
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserProfilesTable,
      UserProfile,
      $$UserProfilesTableFilterComposer,
      $$UserProfilesTableOrderingComposer,
      $$UserProfilesTableAnnotationComposer,
      $$UserProfilesTableCreateCompanionBuilder,
      $$UserProfilesTableUpdateCompanionBuilder,
      (
        UserProfile,
        BaseReferences<_$AppDatabase, $UserProfilesTable, UserProfile>,
      ),
      UserProfile,
      PrefetchHooks Function()
    >;
typedef $$SourceNotesTableCreateCompanionBuilder =
    SourceNotesCompanion Function({
      required String noteId,
      required String rawOcrText,
      required String documentHash,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$SourceNotesTableUpdateCompanionBuilder =
    SourceNotesCompanion Function({
      Value<String> noteId,
      Value<String> rawOcrText,
      Value<String> documentHash,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$SourceNotesTableReferences
    extends BaseReferences<_$AppDatabase, $SourceNotesTable, SourceNote> {
  $$SourceNotesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$LessonsTable, List<Lesson>> _lessonsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.lessons,
    aliasName: 'source_notes__note_id__lessons__note_id',
  );

  $$LessonsTableProcessedTableManager get lessonsRefs {
    final manager = $$LessonsTableTableManager($_db, $_db.lessons).filter(
      (f) => f.noteId.noteId.sqlEquals($_itemColumn<String>('note_id')!),
    );

    final cache = $_typedResult.readTableOrNull(_lessonsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SourceNotesTableFilterComposer
    extends Composer<_$AppDatabase, $SourceNotesTable> {
  $$SourceNotesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get noteId => $composableBuilder(
    column: $table.noteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawOcrText => $composableBuilder(
    column: $table.rawOcrText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get documentHash => $composableBuilder(
    column: $table.documentHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> lessonsRefs(
    Expression<bool> Function($$LessonsTableFilterComposer f) f,
  ) {
    final $$LessonsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.noteId,
      referencedTable: $db.lessons,
      getReferencedColumn: (t) => t.noteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LessonsTableFilterComposer(
            $db: $db,
            $table: $db.lessons,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SourceNotesTableOrderingComposer
    extends Composer<_$AppDatabase, $SourceNotesTable> {
  $$SourceNotesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get noteId => $composableBuilder(
    column: $table.noteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawOcrText => $composableBuilder(
    column: $table.rawOcrText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get documentHash => $composableBuilder(
    column: $table.documentHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SourceNotesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SourceNotesTable> {
  $$SourceNotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get noteId =>
      $composableBuilder(column: $table.noteId, builder: (column) => column);

  GeneratedColumn<String> get rawOcrText => $composableBuilder(
    column: $table.rawOcrText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get documentHash => $composableBuilder(
    column: $table.documentHash,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> lessonsRefs<T extends Object>(
    Expression<T> Function($$LessonsTableAnnotationComposer a) f,
  ) {
    final $$LessonsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.noteId,
      referencedTable: $db.lessons,
      getReferencedColumn: (t) => t.noteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LessonsTableAnnotationComposer(
            $db: $db,
            $table: $db.lessons,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SourceNotesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SourceNotesTable,
          SourceNote,
          $$SourceNotesTableFilterComposer,
          $$SourceNotesTableOrderingComposer,
          $$SourceNotesTableAnnotationComposer,
          $$SourceNotesTableCreateCompanionBuilder,
          $$SourceNotesTableUpdateCompanionBuilder,
          (SourceNote, $$SourceNotesTableReferences),
          SourceNote,
          PrefetchHooks Function({bool lessonsRefs})
        > {
  $$SourceNotesTableTableManager(_$AppDatabase db, $SourceNotesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SourceNotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SourceNotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SourceNotesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> noteId = const Value.absent(),
                Value<String> rawOcrText = const Value.absent(),
                Value<String> documentHash = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SourceNotesCompanion(
                noteId: noteId,
                rawOcrText: rawOcrText,
                documentHash: documentHash,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String noteId,
                required String rawOcrText,
                required String documentHash,
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SourceNotesCompanion.insert(
                noteId: noteId,
                rawOcrText: rawOcrText,
                documentHash: documentHash,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SourceNotesTable, SourceNote>(table),
                  $$SourceNotesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({lessonsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (lessonsRefs) db.lessons],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (lessonsRefs)
                    await $_getPrefetchedDataByColumns<
                      SourceNote,
                      $SourceNotesTable,
                      Lesson,
                      $LessonsTable
                    >(
                      currentTable: table,
                      referencedTable: $$SourceNotesTableReferences
                          ._lessonsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$SourceNotesTableReferences(
                            db,
                            table,
                            p0,
                          ).lessonsRefs,
                      currentColumn: 'note_id',
                      referencedColumn: 'note_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$SourceNotesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SourceNotesTable,
      SourceNote,
      $$SourceNotesTableFilterComposer,
      $$SourceNotesTableOrderingComposer,
      $$SourceNotesTableAnnotationComposer,
      $$SourceNotesTableCreateCompanionBuilder,
      $$SourceNotesTableUpdateCompanionBuilder,
      (SourceNote, $$SourceNotesTableReferences),
      SourceNote,
      PrefetchHooks Function({bool lessonsRefs})
    >;
typedef $$LessonsTableCreateCompanionBuilder = LessonsCompanion Function({
  required String lessonId,
  required String noteId,
  required String title,
  required String conceptMapJson,
  Value<String> promptVersion,
  Value<String> source,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $$LessonsTableUpdateCompanionBuilder = LessonsCompanion Function({
  Value<String> lessonId,
  Value<String> noteId,
  Value<String> title,
  Value<String> conceptMapJson,
  Value<String> promptVersion,
  Value<String> source,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$LessonsTableReferences
    extends BaseReferences<_$AppDatabase, $LessonsTable, Lesson> {
  $$LessonsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SourceNotesTable _noteIdTable(_$AppDatabase db) =>
      db.sourceNotes.createAlias('lessons__note_id__source_notes__note_id');

  $$SourceNotesTableProcessedTableManager get noteId {
    final $_column = $_itemColumn<String>('note_id')!;

    final manager = $$SourceNotesTableTableManager(
      $_db,
      $_db.sourceNotes,
    ).filter((f) => f.noteId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_noteIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$FlashcardsTable, List<Flashcard>>
  _flashcardsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.flashcards,
    aliasName: 'lessons__lesson_id__flashcards__lesson_id',
  );

  $$FlashcardsTableProcessedTableManager get flashcardsRefs {
    final manager = $$FlashcardsTableTableManager($_db, $_db.flashcards).filter(
      (f) => f.lessonId.lessonId.sqlEquals($_itemColumn<String>('lesson_id')!),
    );

    final cache = $_typedResult.readTableOrNull(_flashcardsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$LessonsTableFilterComposer
    extends Composer<_$AppDatabase, $LessonsTable> {
  $$LessonsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get lessonId => $composableBuilder(
    column: $table.lessonId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get conceptMapJson => $composableBuilder(
    column: $table.conceptMapJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get promptVersion => $composableBuilder(
    column: $table.promptVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$SourceNotesTableFilterComposer get noteId {
    final $$SourceNotesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.noteId,
      referencedTable: $db.sourceNotes,
      getReferencedColumn: (t) => t.noteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SourceNotesTableFilterComposer(
            $db: $db,
            $table: $db.sourceNotes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> flashcardsRefs(
    Expression<bool> Function($$FlashcardsTableFilterComposer f) f,
  ) {
    final $$FlashcardsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.lessonId,
      referencedTable: $db.flashcards,
      getReferencedColumn: (t) => t.lessonId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FlashcardsTableFilterComposer(
            $db: $db,
            $table: $db.flashcards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LessonsTableOrderingComposer
    extends Composer<_$AppDatabase, $LessonsTable> {
  $$LessonsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get lessonId => $composableBuilder(
    column: $table.lessonId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get conceptMapJson => $composableBuilder(
    column: $table.conceptMapJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get promptVersion => $composableBuilder(
    column: $table.promptVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$SourceNotesTableOrderingComposer get noteId {
    final $$SourceNotesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.noteId,
      referencedTable: $db.sourceNotes,
      getReferencedColumn: (t) => t.noteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SourceNotesTableOrderingComposer(
            $db: $db,
            $table: $db.sourceNotes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LessonsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LessonsTable> {
  $$LessonsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get lessonId =>
      $composableBuilder(column: $table.lessonId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get conceptMapJson => $composableBuilder(
    column: $table.conceptMapJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get promptVersion => $composableBuilder(
    column: $table.promptVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$SourceNotesTableAnnotationComposer get noteId {
    final $$SourceNotesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.noteId,
      referencedTable: $db.sourceNotes,
      getReferencedColumn: (t) => t.noteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SourceNotesTableAnnotationComposer(
            $db: $db,
            $table: $db.sourceNotes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> flashcardsRefs<T extends Object>(
    Expression<T> Function($$FlashcardsTableAnnotationComposer a) f,
  ) {
    final $$FlashcardsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.lessonId,
      referencedTable: $db.flashcards,
      getReferencedColumn: (t) => t.lessonId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FlashcardsTableAnnotationComposer(
            $db: $db,
            $table: $db.flashcards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LessonsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LessonsTable,
          Lesson,
          $$LessonsTableFilterComposer,
          $$LessonsTableOrderingComposer,
          $$LessonsTableAnnotationComposer,
          $$LessonsTableCreateCompanionBuilder,
          $$LessonsTableUpdateCompanionBuilder,
          (Lesson, $$LessonsTableReferences),
          Lesson,
          PrefetchHooks Function({bool noteId, bool flashcardsRefs})
        > {
  $$LessonsTableTableManager(_$AppDatabase db, $LessonsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LessonsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LessonsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LessonsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> lessonId = const Value.absent(),
                Value<String> noteId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> conceptMapJson = const Value.absent(),
                Value<String> promptVersion = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LessonsCompanion(
                lessonId: lessonId,
                noteId: noteId,
                title: title,
                conceptMapJson: conceptMapJson,
                promptVersion: promptVersion,
                source: source,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String lessonId,
                required String noteId,
                required String title,
                required String conceptMapJson,
                Value<String> promptVersion = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LessonsCompanion.insert(
                lessonId: lessonId,
                noteId: noteId,
                title: title,
                conceptMapJson: conceptMapJson,
                promptVersion: promptVersion,
                source: source,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LessonsTable, Lesson>(table),
                  $$LessonsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({noteId = false, flashcardsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (flashcardsRefs) db.flashcards],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (noteId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.noteId,
                        referencedTable: $$LessonsTableReferences._noteIdTable(
                          db,
                        ),
                        referencedColumn: $$LessonsTableReferences
                            ._noteIdTable(db)
                            .noteId,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (flashcardsRefs)
                    await $_getPrefetchedDataByColumns<
                      Lesson,
                      $LessonsTable,
                      Flashcard,
                      $FlashcardsTable
                    >(
                      currentTable: table,
                      referencedTable: $$LessonsTableReferences
                          ._flashcardsRefsTable(db),
                      managerFromTypedResult: (p0) => $$LessonsTableReferences(
                        db,
                        table,
                        p0,
                      ).flashcardsRefs,
                      currentColumn: 'lesson_id',
                      referencedColumn: 'lesson_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$LessonsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LessonsTable,
      Lesson,
      $$LessonsTableFilterComposer,
      $$LessonsTableOrderingComposer,
      $$LessonsTableAnnotationComposer,
      $$LessonsTableCreateCompanionBuilder,
      $$LessonsTableUpdateCompanionBuilder,
      (Lesson, $$LessonsTableReferences),
      Lesson,
      PrefetchHooks Function({bool noteId, bool flashcardsRefs})
    >;
typedef $$FlashcardsTableCreateCompanionBuilder = FlashcardsCompanion Function({
  required String cardId,
  required String lessonId,
  required String question,
  required String answer,
  required String sourceLineReference,
  Value<double?> groundingScore,
  Value<bool> verified,
  Value<int> rowid,
});
typedef $$FlashcardsTableUpdateCompanionBuilder = FlashcardsCompanion Function({
  Value<String> cardId,
  Value<String> lessonId,
  Value<String> question,
  Value<String> answer,
  Value<String> sourceLineReference,
  Value<double?> groundingScore,
  Value<bool> verified,
  Value<int> rowid,
});

final class $$FlashcardsTableReferences
    extends BaseReferences<_$AppDatabase, $FlashcardsTable, Flashcard> {
  $$FlashcardsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $LessonsTable _lessonIdTable(_$AppDatabase db) =>
      db.lessons.createAlias('flashcards__lesson_id__lessons__lesson_id');

  $$LessonsTableProcessedTableManager get lessonId {
    final $_column = $_itemColumn<String>('lesson_id')!;

    final manager = $$LessonsTableTableManager(
      $_db,
      $_db.lessons,
    ).filter((f) => f.lessonId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_lessonIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ReviewProgressTable, List<ReviewProgressData>>
  _reviewProgressRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.reviewProgress,
    aliasName: 'flashcards__card_id__review_progress__card_id',
  );

  $$ReviewProgressTableProcessedTableManager get reviewProgressRefs {
    final manager = $$ReviewProgressTableTableManager($_db, $_db.reviewProgress)
        .filter(
          (f) => f.cardId.cardId.sqlEquals($_itemColumn<String>('card_id')!),
        );

    final cache = $_typedResult.readTableOrNull(_reviewProgressRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$FlashcardsTableFilterComposer
    extends Composer<_$AppDatabase, $FlashcardsTable> {
  $$FlashcardsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get cardId => $composableBuilder(
    column: $table.cardId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get question => $composableBuilder(
    column: $table.question,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get answer => $composableBuilder(
    column: $table.answer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceLineReference => $composableBuilder(
    column: $table.sourceLineReference,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get groundingScore => $composableBuilder(
    column: $table.groundingScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get verified => $composableBuilder(
    column: $table.verified,
    builder: (column) => ColumnFilters(column),
  );

  $$LessonsTableFilterComposer get lessonId {
    final $$LessonsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.lessonId,
      referencedTable: $db.lessons,
      getReferencedColumn: (t) => t.lessonId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LessonsTableFilterComposer(
            $db: $db,
            $table: $db.lessons,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> reviewProgressRefs(
    Expression<bool> Function($$ReviewProgressTableFilterComposer f) f,
  ) {
    final $$ReviewProgressTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cardId,
      referencedTable: $db.reviewProgress,
      getReferencedColumn: (t) => t.cardId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReviewProgressTableFilterComposer(
            $db: $db,
            $table: $db.reviewProgress,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FlashcardsTableOrderingComposer
    extends Composer<_$AppDatabase, $FlashcardsTable> {
  $$FlashcardsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get cardId => $composableBuilder(
    column: $table.cardId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get question => $composableBuilder(
    column: $table.question,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get answer => $composableBuilder(
    column: $table.answer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceLineReference => $composableBuilder(
    column: $table.sourceLineReference,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get groundingScore => $composableBuilder(
    column: $table.groundingScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get verified => $composableBuilder(
    column: $table.verified,
    builder: (column) => ColumnOrderings(column),
  );

  $$LessonsTableOrderingComposer get lessonId {
    final $$LessonsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.lessonId,
      referencedTable: $db.lessons,
      getReferencedColumn: (t) => t.lessonId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LessonsTableOrderingComposer(
            $db: $db,
            $table: $db.lessons,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FlashcardsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FlashcardsTable> {
  $$FlashcardsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get cardId =>
      $composableBuilder(column: $table.cardId, builder: (column) => column);

  GeneratedColumn<String> get question =>
      $composableBuilder(column: $table.question, builder: (column) => column);

  GeneratedColumn<String> get answer =>
      $composableBuilder(column: $table.answer, builder: (column) => column);

  GeneratedColumn<String> get sourceLineReference => $composableBuilder(
    column: $table.sourceLineReference,
    builder: (column) => column,
  );

  GeneratedColumn<double> get groundingScore => $composableBuilder(
    column: $table.groundingScore,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get verified =>
      $composableBuilder(column: $table.verified, builder: (column) => column);

  $$LessonsTableAnnotationComposer get lessonId {
    final $$LessonsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.lessonId,
      referencedTable: $db.lessons,
      getReferencedColumn: (t) => t.lessonId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LessonsTableAnnotationComposer(
            $db: $db,
            $table: $db.lessons,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> reviewProgressRefs<T extends Object>(
    Expression<T> Function($$ReviewProgressTableAnnotationComposer a) f,
  ) {
    final $$ReviewProgressTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cardId,
      referencedTable: $db.reviewProgress,
      getReferencedColumn: (t) => t.cardId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReviewProgressTableAnnotationComposer(
            $db: $db,
            $table: $db.reviewProgress,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FlashcardsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FlashcardsTable,
          Flashcard,
          $$FlashcardsTableFilterComposer,
          $$FlashcardsTableOrderingComposer,
          $$FlashcardsTableAnnotationComposer,
          $$FlashcardsTableCreateCompanionBuilder,
          $$FlashcardsTableUpdateCompanionBuilder,
          (Flashcard, $$FlashcardsTableReferences),
          Flashcard,
          PrefetchHooks Function({bool lessonId, bool reviewProgressRefs})
        > {
  $$FlashcardsTableTableManager(_$AppDatabase db, $FlashcardsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FlashcardsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FlashcardsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FlashcardsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> cardId = const Value.absent(),
                Value<String> lessonId = const Value.absent(),
                Value<String> question = const Value.absent(),
                Value<String> answer = const Value.absent(),
                Value<String> sourceLineReference = const Value.absent(),
                Value<double?> groundingScore = const Value.absent(),
                Value<bool> verified = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FlashcardsCompanion(
                cardId: cardId,
                lessonId: lessonId,
                question: question,
                answer: answer,
                sourceLineReference: sourceLineReference,
                groundingScore: groundingScore,
                verified: verified,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String cardId,
                required String lessonId,
                required String question,
                required String answer,
                required String sourceLineReference,
                Value<double?> groundingScore = const Value.absent(),
                Value<bool> verified = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FlashcardsCompanion.insert(
                cardId: cardId,
                lessonId: lessonId,
                question: question,
                answer: answer,
                sourceLineReference: sourceLineReference,
                groundingScore: groundingScore,
                verified: verified,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FlashcardsTable, Flashcard>(table),
                  $$FlashcardsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({lessonId = false, reviewProgressRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (reviewProgressRefs) db.reviewProgress,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (lessonId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.lessonId,
                            referencedTable: $$FlashcardsTableReferences
                                ._lessonIdTable(db),
                            referencedColumn: $$FlashcardsTableReferences
                                ._lessonIdTable(db)
                                .lessonId,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (reviewProgressRefs)
                        await $_getPrefetchedDataByColumns<
                          Flashcard,
                          $FlashcardsTable,
                          ReviewProgressData,
                          $ReviewProgressTable
                        >(
                          currentTable: table,
                          referencedTable: $$FlashcardsTableReferences
                              ._reviewProgressRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$FlashcardsTableReferences(
                                db,
                                table,
                                p0,
                              ).reviewProgressRefs,
                          currentColumn: 'card_id',
                          referencedColumn: 'card_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$FlashcardsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FlashcardsTable,
      Flashcard,
      $$FlashcardsTableFilterComposer,
      $$FlashcardsTableOrderingComposer,
      $$FlashcardsTableAnnotationComposer,
      $$FlashcardsTableCreateCompanionBuilder,
      $$FlashcardsTableUpdateCompanionBuilder,
      (Flashcard, $$FlashcardsTableReferences),
      Flashcard,
      PrefetchHooks Function({bool lessonId, bool reviewProgressRefs})
    >;
typedef $$ReviewProgressTableCreateCompanionBuilder =
    ReviewProgressCompanion Function({
      Value<int> progressId,
      required String cardId,
      Value<int> box,
      Value<int> spacedRepetitionInterval,
      required DateTime nextReviewDate,
      Value<DateTime?> lastReviewedAt,
      Value<int> consecutiveCorrect,
    });
typedef $$ReviewProgressTableUpdateCompanionBuilder =
    ReviewProgressCompanion Function({
      Value<int> progressId,
      Value<String> cardId,
      Value<int> box,
      Value<int> spacedRepetitionInterval,
      Value<DateTime> nextReviewDate,
      Value<DateTime?> lastReviewedAt,
      Value<int> consecutiveCorrect,
    });

final class $$ReviewProgressTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ReviewProgressTable,
          ReviewProgressData
        > {
  $$ReviewProgressTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $FlashcardsTable _cardIdTable(_$AppDatabase db) => db.flashcards
      .createAlias('review_progress__card_id__flashcards__card_id');

  $$FlashcardsTableProcessedTableManager get cardId {
    final $_column = $_itemColumn<String>('card_id')!;

    final manager = $$FlashcardsTableTableManager(
      $_db,
      $_db.flashcards,
    ).filter((f) => f.cardId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_cardIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ReviewProgressTableFilterComposer
    extends Composer<_$AppDatabase, $ReviewProgressTable> {
  $$ReviewProgressTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get progressId => $composableBuilder(
    column: $table.progressId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get box => $composableBuilder(
    column: $table.box,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get spacedRepetitionInterval => $composableBuilder(
    column: $table.spacedRepetitionInterval,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextReviewDate => $composableBuilder(
    column: $table.nextReviewDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastReviewedAt => $composableBuilder(
    column: $table.lastReviewedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get consecutiveCorrect => $composableBuilder(
    column: $table.consecutiveCorrect,
    builder: (column) => ColumnFilters(column),
  );

  $$FlashcardsTableFilterComposer get cardId {
    final $$FlashcardsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cardId,
      referencedTable: $db.flashcards,
      getReferencedColumn: (t) => t.cardId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FlashcardsTableFilterComposer(
            $db: $db,
            $table: $db.flashcards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReviewProgressTableOrderingComposer
    extends Composer<_$AppDatabase, $ReviewProgressTable> {
  $$ReviewProgressTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get progressId => $composableBuilder(
    column: $table.progressId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get box => $composableBuilder(
    column: $table.box,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get spacedRepetitionInterval => $composableBuilder(
    column: $table.spacedRepetitionInterval,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextReviewDate => $composableBuilder(
    column: $table.nextReviewDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastReviewedAt => $composableBuilder(
    column: $table.lastReviewedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get consecutiveCorrect => $composableBuilder(
    column: $table.consecutiveCorrect,
    builder: (column) => ColumnOrderings(column),
  );

  $$FlashcardsTableOrderingComposer get cardId {
    final $$FlashcardsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cardId,
      referencedTable: $db.flashcards,
      getReferencedColumn: (t) => t.cardId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FlashcardsTableOrderingComposer(
            $db: $db,
            $table: $db.flashcards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReviewProgressTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReviewProgressTable> {
  $$ReviewProgressTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get progressId => $composableBuilder(
    column: $table.progressId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get box =>
      $composableBuilder(column: $table.box, builder: (column) => column);

  GeneratedColumn<int> get spacedRepetitionInterval => $composableBuilder(
    column: $table.spacedRepetitionInterval,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get nextReviewDate => $composableBuilder(
    column: $table.nextReviewDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastReviewedAt => $composableBuilder(
    column: $table.lastReviewedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get consecutiveCorrect => $composableBuilder(
    column: $table.consecutiveCorrect,
    builder: (column) => column,
  );

  $$FlashcardsTableAnnotationComposer get cardId {
    final $$FlashcardsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cardId,
      referencedTable: $db.flashcards,
      getReferencedColumn: (t) => t.cardId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FlashcardsTableAnnotationComposer(
            $db: $db,
            $table: $db.flashcards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReviewProgressTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReviewProgressTable,
          ReviewProgressData,
          $$ReviewProgressTableFilterComposer,
          $$ReviewProgressTableOrderingComposer,
          $$ReviewProgressTableAnnotationComposer,
          $$ReviewProgressTableCreateCompanionBuilder,
          $$ReviewProgressTableUpdateCompanionBuilder,
          (ReviewProgressData, $$ReviewProgressTableReferences),
          ReviewProgressData,
          PrefetchHooks Function({bool cardId})
        > {
  $$ReviewProgressTableTableManager(
    _$AppDatabase db,
    $ReviewProgressTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReviewProgressTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReviewProgressTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReviewProgressTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> progressId = const Value.absent(),
                Value<String> cardId = const Value.absent(),
                Value<int> box = const Value.absent(),
                Value<int> spacedRepetitionInterval = const Value.absent(),
                Value<DateTime> nextReviewDate = const Value.absent(),
                Value<DateTime?> lastReviewedAt = const Value.absent(),
                Value<int> consecutiveCorrect = const Value.absent(),
              }) => ReviewProgressCompanion(
                progressId: progressId,
                cardId: cardId,
                box: box,
                spacedRepetitionInterval: spacedRepetitionInterval,
                nextReviewDate: nextReviewDate,
                lastReviewedAt: lastReviewedAt,
                consecutiveCorrect: consecutiveCorrect,
              ),
          createCompanionCallback:
              ({
                Value<int> progressId = const Value.absent(),
                required String cardId,
                Value<int> box = const Value.absent(),
                Value<int> spacedRepetitionInterval = const Value.absent(),
                required DateTime nextReviewDate,
                Value<DateTime?> lastReviewedAt = const Value.absent(),
                Value<int> consecutiveCorrect = const Value.absent(),
              }) => ReviewProgressCompanion.insert(
                progressId: progressId,
                cardId: cardId,
                box: box,
                spacedRepetitionInterval: spacedRepetitionInterval,
                nextReviewDate: nextReviewDate,
                lastReviewedAt: lastReviewedAt,
                consecutiveCorrect: consecutiveCorrect,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ReviewProgressTable, ReviewProgressData>(table),
                  $$ReviewProgressTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({cardId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (cardId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.cardId,
                        referencedTable: $$ReviewProgressTableReferences
                            ._cardIdTable(db),
                        referencedColumn: $$ReviewProgressTableReferences
                            ._cardIdTable(db)
                            .cardId,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ReviewProgressTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReviewProgressTable,
      ReviewProgressData,
      $$ReviewProgressTableFilterComposer,
      $$ReviewProgressTableOrderingComposer,
      $$ReviewProgressTableAnnotationComposer,
      $$ReviewProgressTableCreateCompanionBuilder,
      $$ReviewProgressTableUpdateCompanionBuilder,
      (ReviewProgressData, $$ReviewProgressTableReferences),
      ReviewProgressData,
      PrefetchHooks Function({bool cardId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UserProfilesTableTableManager get userProfiles =>
      $$UserProfilesTableTableManager(_db, _db.userProfiles);
  $$SourceNotesTableTableManager get sourceNotes =>
      $$SourceNotesTableTableManager(_db, _db.sourceNotes);
  $$LessonsTableTableManager get lessons =>
      $$LessonsTableTableManager(_db, _db.lessons);
  $$FlashcardsTableTableManager get flashcards =>
      $$FlashcardsTableTableManager(_db, _db.flashcards);
  $$ReviewProgressTableTableManager get reviewProgress =>
      $$ReviewProgressTableTableManager(_db, _db.reviewProgress);
}
