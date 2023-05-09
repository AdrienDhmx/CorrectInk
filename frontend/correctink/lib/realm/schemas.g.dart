// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schemas.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

class Task extends _Task with RealmEntity, RealmObjectBase, RealmObject {
  static var _defaultsSet = false;

  Task(
    ObjectId id,
    String task,
    String ownerId, {
    bool isComplete = false,
    DateTime? deadline,
    ObjectId? linkedSet,
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<Task>({
        'isComplete': false,
      });
    }
    RealmObjectBase.set(this, '_id', id);
    RealmObjectBase.set(this, 'isComplete', isComplete);
    RealmObjectBase.set(this, 'task', task);
    RealmObjectBase.set(this, 'deadline', deadline);
    RealmObjectBase.set(this, 'linkedSet', linkedSet);
    RealmObjectBase.set(this, 'owner_id', ownerId);
  }

  Task._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, '_id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, '_id', value);

  @override
  bool get isComplete => RealmObjectBase.get<bool>(this, 'isComplete') as bool;
  @override
  set isComplete(bool value) => RealmObjectBase.set(this, 'isComplete', value);

  @override
  String get task => RealmObjectBase.get<String>(this, 'task') as String;
  @override
  set task(String value) => RealmObjectBase.set(this, 'task', value);

  @override
  DateTime? get deadline =>
      RealmObjectBase.get<DateTime>(this, 'deadline') as DateTime?;
  @override
  set deadline(DateTime? value) => RealmObjectBase.set(this, 'deadline', value);

  @override
  ObjectId? get linkedSet =>
      RealmObjectBase.get<ObjectId>(this, 'linkedSet') as ObjectId?;
  @override
  set linkedSet(ObjectId? value) =>
      RealmObjectBase.set(this, 'linkedSet', value);

  @override
  String get ownerId => RealmObjectBase.get<String>(this, 'owner_id') as String;
  @override
  set ownerId(String value) => RealmObjectBase.set(this, 'owner_id', value);

  @override
  Stream<RealmObjectChanges<Task>> get changes =>
      RealmObjectBase.getChanges<Task>(this);

  @override
  Task freeze() => RealmObjectBase.freezeObject<Task>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(Task._);
    return const SchemaObject(ObjectType.realmObject, Task, 'Task', [
      SchemaProperty('id', RealmPropertyType.objectid,
          mapTo: '_id', primaryKey: true),
      SchemaProperty('isComplete', RealmPropertyType.bool),
      SchemaProperty('task', RealmPropertyType.string),
      SchemaProperty('deadline', RealmPropertyType.timestamp, optional: true),
      SchemaProperty('linkedSet', RealmPropertyType.objectid, optional: true),
      SchemaProperty('ownerId', RealmPropertyType.string, mapTo: 'owner_id'),
    ]);
  }
}

class KeyValueCard extends _KeyValueCard
    with RealmEntity, RealmObjectBase, RealmObject {
  static var _defaultsSet = false;

  KeyValueCard(
    ObjectId id,
    String key,
    String value,
    ObjectId setId, {
    DateTime? lastSeen,
    int learningProgress = 0,
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<KeyValueCard>({
        'learningProgress': 0,
      });
    }
    RealmObjectBase.set(this, '_id', id);
    RealmObjectBase.set(this, 'key', key);
    RealmObjectBase.set(this, 'value', value);
    RealmObjectBase.set(this, 'lastSeen', lastSeen);
    RealmObjectBase.set(this, 'learningProgress', learningProgress);
    RealmObjectBase.set(this, 'set_id', setId);
  }

  KeyValueCard._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, '_id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, '_id', value);

  @override
  String get key => RealmObjectBase.get<String>(this, 'key') as String;
  @override
  set key(String value) => RealmObjectBase.set(this, 'key', value);

  @override
  String get value => RealmObjectBase.get<String>(this, 'value') as String;
  @override
  set value(String value) => RealmObjectBase.set(this, 'value', value);

  @override
  DateTime? get lastSeen =>
      RealmObjectBase.get<DateTime>(this, 'lastSeen') as DateTime?;
  @override
  set lastSeen(DateTime? value) => RealmObjectBase.set(this, 'lastSeen', value);

  @override
  int get learningProgress =>
      RealmObjectBase.get<int>(this, 'learningProgress') as int;
  @override
  set learningProgress(int value) =>
      RealmObjectBase.set(this, 'learningProgress', value);

  @override
  ObjectId get setId =>
      RealmObjectBase.get<ObjectId>(this, 'set_id') as ObjectId;
  @override
  set setId(ObjectId value) => RealmObjectBase.set(this, 'set_id', value);

  @override
  Stream<RealmObjectChanges<KeyValueCard>> get changes =>
      RealmObjectBase.getChanges<KeyValueCard>(this);

  @override
  KeyValueCard freeze() => RealmObjectBase.freezeObject<KeyValueCard>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(KeyValueCard._);
    return const SchemaObject(
        ObjectType.realmObject, KeyValueCard, 'KeyValueCard', [
      SchemaProperty('id', RealmPropertyType.objectid,
          mapTo: '_id', primaryKey: true),
      SchemaProperty('key', RealmPropertyType.string),
      SchemaProperty('value', RealmPropertyType.string),
      SchemaProperty('lastSeen', RealmPropertyType.timestamp, optional: true),
      SchemaProperty('learningProgress', RealmPropertyType.int),
      SchemaProperty('setId', RealmPropertyType.objectid, mapTo: 'set_id'),
    ]);
  }
}

class CardSet extends _CardSet with RealmEntity, RealmObjectBase, RealmObject {
  CardSet(
    ObjectId id,
    String name,
    bool isPublic,
    String ownerId, {
    String? description,
    String? color,
    ObjectId? originalSetId,
  }) {
    RealmObjectBase.set(this, '_id', id);
    RealmObjectBase.set(this, 'name', name);
    RealmObjectBase.set(this, 'description', description);
    RealmObjectBase.set(this, 'color', color);
    RealmObjectBase.set(this, 'is_public', isPublic);
    RealmObjectBase.set(this, 'original_set_id', originalSetId);
    RealmObjectBase.set(this, 'owner_id', ownerId);
  }

  CardSet._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, '_id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, '_id', value);

  @override
  String get name => RealmObjectBase.get<String>(this, 'name') as String;
  @override
  set name(String value) => RealmObjectBase.set(this, 'name', value);

  @override
  String? get description =>
      RealmObjectBase.get<String>(this, 'description') as String?;
  @override
  set description(String? value) =>
      RealmObjectBase.set(this, 'description', value);

  @override
  String? get color => RealmObjectBase.get<String>(this, 'color') as String?;
  @override
  set color(String? value) => RealmObjectBase.set(this, 'color', value);

  @override
  bool get isPublic => RealmObjectBase.get<bool>(this, 'is_public') as bool;
  @override
  set isPublic(bool value) => RealmObjectBase.set(this, 'is_public', value);

  @override
  ObjectId? get originalSetId =>
      RealmObjectBase.get<ObjectId>(this, 'original_set_id') as ObjectId?;
  @override
  set originalSetId(ObjectId? value) =>
      RealmObjectBase.set(this, 'original_set_id', value);

  @override
  String get ownerId => RealmObjectBase.get<String>(this, 'owner_id') as String;
  @override
  set ownerId(String value) => RealmObjectBase.set(this, 'owner_id', value);

  @override
  Stream<RealmObjectChanges<CardSet>> get changes =>
      RealmObjectBase.getChanges<CardSet>(this);

  @override
  CardSet freeze() => RealmObjectBase.freezeObject<CardSet>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(CardSet._);
    return const SchemaObject(ObjectType.realmObject, CardSet, 'CardSet', [
      SchemaProperty('id', RealmPropertyType.objectid,
          mapTo: '_id', primaryKey: true),
      SchemaProperty('name', RealmPropertyType.string),
      SchemaProperty('description', RealmPropertyType.string, optional: true),
      SchemaProperty('color', RealmPropertyType.string, optional: true),
      SchemaProperty('isPublic', RealmPropertyType.bool, mapTo: 'is_public'),
      SchemaProperty('originalSetId', RealmPropertyType.objectid,
          mapTo: 'original_set_id', optional: true),
      SchemaProperty('ownerId', RealmPropertyType.string, mapTo: 'owner_id'),
    ]);
  }
}

class Users extends _Users with RealmEntity, RealmObjectBase, RealmObject {
  Users(
    ObjectId userId,
    String firstname,
    String lastname,
    int studyStreak,
  ) {
    RealmObjectBase.set(this, '_id', userId);
    RealmObjectBase.set(this, 'firstname', firstname);
    RealmObjectBase.set(this, 'lastname', lastname);
    RealmObjectBase.set(this, 'study_streak', studyStreak);
  }

  Users._();

  @override
  ObjectId get userId => RealmObjectBase.get<ObjectId>(this, '_id') as ObjectId;
  @override
  set userId(ObjectId value) => RealmObjectBase.set(this, '_id', value);

  @override
  String get firstname =>
      RealmObjectBase.get<String>(this, 'firstname') as String;
  @override
  set firstname(String value) => RealmObjectBase.set(this, 'firstname', value);

  @override
  String get lastname =>
      RealmObjectBase.get<String>(this, 'lastname') as String;
  @override
  set lastname(String value) => RealmObjectBase.set(this, 'lastname', value);

  @override
  int get studyStreak => RealmObjectBase.get<int>(this, 'study_streak') as int;
  @override
  set studyStreak(int value) =>
      RealmObjectBase.set(this, 'study_streak', value);

  @override
  Stream<RealmObjectChanges<Users>> get changes =>
      RealmObjectBase.getChanges<Users>(this);

  @override
  Users freeze() => RealmObjectBase.freezeObject<Users>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(Users._);
    return const SchemaObject(ObjectType.realmObject, Users, 'Users', [
      SchemaProperty('userId', RealmPropertyType.objectid,
          mapTo: '_id', primaryKey: true),
      SchemaProperty('firstname', RealmPropertyType.string),
      SchemaProperty('lastname', RealmPropertyType.string),
      SchemaProperty('studyStreak', RealmPropertyType.int,
          mapTo: 'study_streak'),
    ]);
  }
}
