// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schemas.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

class Task extends _Task with RealmEntity, RealmObjectBase, RealmObject {
  static var _defaultsSet = false;

  Task(
    ObjectId id,
    String summary,
    String ownerId, {
    bool isComplete = false,
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<Task>({
        'isComplete': false,
      });
    }
    RealmObjectBase.set(this, '_id', id);
    RealmObjectBase.set(this, 'isComplete', isComplete);
    RealmObjectBase.set(this, 'summary', summary);
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
  String get summary => RealmObjectBase.get<String>(this, 'summary') as String;
  @override
  set summary(String value) => RealmObjectBase.set(this, 'summary', value);

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
      SchemaProperty('summary', RealmPropertyType.string),
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
    DateTime creationDate,
    String ownerId, {
    String? description,
    String? color,
  }) {
    RealmObjectBase.set(this, '_id', id);
    RealmObjectBase.set(this, 'name', name);
    RealmObjectBase.set(this, 'description', description);
    RealmObjectBase.set(this, 'color', color);
    RealmObjectBase.set(this, 'creation_date', creationDate);
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
  DateTime get creationDate =>
      RealmObjectBase.get<DateTime>(this, 'creation_date') as DateTime;
  @override
  set creationDate(DateTime value) =>
      RealmObjectBase.set(this, 'creation_date', value);

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
      SchemaProperty('creationDate', RealmPropertyType.timestamp,
          mapTo: 'creation_date'),
      SchemaProperty('ownerId', RealmPropertyType.string, mapTo: 'owner_id'),
    ]);
  }
}
