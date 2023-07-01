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
    DateTime? reminder,
    int reminderRepeatMode = 0,
    ObjectId? linkedSet,
    Iterable<TaskStep> steps = const [],
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<Task>({
        'isComplete': false,
        'reminderRepeatMode': 0,
      });
    }
    RealmObjectBase.set(this, '_id', id);
    RealmObjectBase.set(this, 'isComplete', isComplete);
    RealmObjectBase.set(this, 'task', task);
    RealmObjectBase.set(this, 'deadline', deadline);
    RealmObjectBase.set(this, 'reminder', reminder);
    RealmObjectBase.set(this, 'reminderRepeatMode', reminderRepeatMode);
    RealmObjectBase.set(this, 'linkedSet', linkedSet);
    RealmObjectBase.set(this, 'owner_id', ownerId);
    RealmObjectBase.set<RealmList<TaskStep>>(
        this, 'steps', RealmList<TaskStep>(steps));
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
      (RealmObjectBase.get<DateTime>(this, 'deadline') as DateTime?)?.toLocal();
  @override
  set deadline(DateTime? value) => RealmObjectBase.set(this, 'deadline', value);

  @override
  DateTime? get reminder =>
      (RealmObjectBase.get<DateTime>(this, 'reminder') as DateTime?)?.toLocal();
  @override
  set reminder(DateTime? value) => RealmObjectBase.set(this, 'reminder', value);

  @override
  int get reminderRepeatMode =>
      RealmObjectBase.get<int>(this, 'reminderRepeatMode') as int;
  @override
  set reminderRepeatMode(int value) =>
      RealmObjectBase.set(this, 'reminderRepeatMode', value);

  @override
  ObjectId? get linkedSet =>
      RealmObjectBase.get<ObjectId>(this, 'linkedSet') as ObjectId?;
  @override
  set linkedSet(ObjectId? value) =>
      RealmObjectBase.set(this, 'linkedSet', value);

  @override
  RealmList<TaskStep> get steps =>
      RealmObjectBase.get<TaskStep>(this, 'steps') as RealmList<TaskStep>;
  @override
  set steps(covariant RealmList<TaskStep> value) =>
      throw RealmUnsupportedSetError();

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
      SchemaProperty('reminder', RealmPropertyType.timestamp, optional: true),
      SchemaProperty('reminderRepeatMode', RealmPropertyType.int),
      SchemaProperty('linkedSet', RealmPropertyType.objectid, optional: true),
      SchemaProperty('steps', RealmPropertyType.object,
          linkTarget: 'TaskStep', collectionType: RealmCollectionType.list),
      SchemaProperty('ownerId', RealmPropertyType.string, mapTo: 'owner_id'),
    ]);
  }
}

class TaskStep extends _TaskStep
    with RealmEntity, RealmObjectBase, RealmObject {
  static var _defaultsSet = false;

  TaskStep(
    ObjectId id,
    String todo, {
    int index = 0,
    bool isComplete = false,
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<TaskStep>({
        'index': 0,
        'isComplete': false,
      });
    }
    RealmObjectBase.set(this, '_id', id);
    RealmObjectBase.set(this, 'index', index);
    RealmObjectBase.set(this, 'isComplete', isComplete);
    RealmObjectBase.set(this, 'todo', todo);
  }

  TaskStep._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, '_id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, '_id', value);

  @override
  int get index => RealmObjectBase.get<int>(this, 'index') as int;
  @override
  set index(int value) => RealmObjectBase.set(this, 'index', value);

  @override
  bool get isComplete => RealmObjectBase.get<bool>(this, 'isComplete') as bool;
  @override
  set isComplete(bool value) => RealmObjectBase.set(this, 'isComplete', value);

  @override
  String get todo => RealmObjectBase.get<String>(this, 'todo') as String;
  @override
  set todo(String value) => RealmObjectBase.set(this, 'todo', value);

  @override
  Stream<RealmObjectChanges<TaskStep>> get changes =>
      RealmObjectBase.getChanges<TaskStep>(this);

  @override
  TaskStep freeze() => RealmObjectBase.freezeObject<TaskStep>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(TaskStep._);
    return const SchemaObject(ObjectType.realmObject, TaskStep, 'TaskStep', [
      SchemaProperty('id', RealmPropertyType.objectid,
          mapTo: '_id', primaryKey: true),
      SchemaProperty('index', RealmPropertyType.int),
      SchemaProperty('isComplete', RealmPropertyType.bool),
      SchemaProperty('todo', RealmPropertyType.string),
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
    bool hasMultipleKeys,
    bool hasMultipleValues, {
    DateTime? lastSeen,
    int knowCount = 0,
    int learningCount = 0,
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<KeyValueCard>({
        'knowCount': 0,
        'learningCount': 0,
      });
    }
    RealmObjectBase.set(this, '_id', id);
    RealmObjectBase.set(this, 'key', key);
    RealmObjectBase.set(this, 'value', value);
    RealmObjectBase.set(this, 'hasMultipleKeys', hasMultipleKeys);
    RealmObjectBase.set(this, 'hasMultipleValues', hasMultipleValues);
    RealmObjectBase.set(this, 'lastSeen', lastSeen);
    RealmObjectBase.set(this, 'knowCount', knowCount);
    RealmObjectBase.set(this, 'learningCount', learningCount);
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
  bool get hasMultipleKeys =>
      RealmObjectBase.get<bool>(this, 'hasMultipleKeys') as bool;
  @override
  set hasMultipleKeys(bool value) =>
      RealmObjectBase.set(this, 'hasMultipleKeys', value);

  @override
  bool get hasMultipleValues =>
      RealmObjectBase.get<bool>(this, 'hasMultipleValues') as bool;
  @override
  set hasMultipleValues(bool value) =>
      RealmObjectBase.set(this, 'hasMultipleValues', value);

  @override
  DateTime? get lastSeen =>
      (RealmObjectBase.get<DateTime>(this, 'lastSeen') as DateTime?)?.toLocal();
  @override
  set lastSeen(DateTime? value) => RealmObjectBase.set(this, 'lastSeen', value);

  @override
  int get knowCount => RealmObjectBase.get<int>(this, 'knowCount') as int;
  @override
  set knowCount(int value) => RealmObjectBase.set(this, 'knowCount', value);

  @override
  int get learningCount =>
      RealmObjectBase.get<int>(this, 'learningCount') as int;
  @override
  set learningCount(int value) =>
      RealmObjectBase.set(this, 'learningCount', value);

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
      SchemaProperty('hasMultipleKeys', RealmPropertyType.bool),
      SchemaProperty('hasMultipleValues', RealmPropertyType.bool),
      SchemaProperty('lastSeen', RealmPropertyType.timestamp, optional: true),
      SchemaProperty('knowCount', RealmPropertyType.int),
      SchemaProperty('learningCount', RealmPropertyType.int),
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
    ObjectId? originalOwnerId,
    Iterable<Tags> tags = const [],
    Iterable<KeyValueCard> cards = const [],
  }) {
    RealmObjectBase.set(this, '_id', id);
    RealmObjectBase.set(this, 'name', name);
    RealmObjectBase.set(this, 'description', description);
    RealmObjectBase.set(this, 'color', color);
    RealmObjectBase.set(this, 'is_public', isPublic);
    RealmObjectBase.set(this, 'original_set_id', originalSetId);
    RealmObjectBase.set(this, 'original_owner_id', originalOwnerId);
    RealmObjectBase.set(this, 'owner_id', ownerId);
    RealmObjectBase.set<RealmList<Tags>>(this, 'tags', RealmList<Tags>(tags));
    RealmObjectBase.set<RealmList<KeyValueCard>>(
        this, 'cards', RealmList<KeyValueCard>(cards));
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
  RealmList<Tags> get tags =>
      RealmObjectBase.get<Tags>(this, 'tags') as RealmList<Tags>;
  @override
  set tags(covariant RealmList<Tags> value) => throw RealmUnsupportedSetError();

  @override
  RealmList<KeyValueCard> get cards =>
      RealmObjectBase.get<KeyValueCard>(this, 'cards')
          as RealmList<KeyValueCard>;
  @override
  set cards(covariant RealmList<KeyValueCard> value) =>
      throw RealmUnsupportedSetError();

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
  ObjectId? get originalOwnerId =>
      RealmObjectBase.get<ObjectId>(this, 'original_owner_id') as ObjectId?;
  @override
  set originalOwnerId(ObjectId? value) =>
      RealmObjectBase.set(this, 'original_owner_id', value);

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
      SchemaProperty('tags', RealmPropertyType.object,
          linkTarget: 'Tags', collectionType: RealmCollectionType.list),
      SchemaProperty('cards', RealmPropertyType.object,
          linkTarget: 'KeyValueCard', collectionType: RealmCollectionType.list),
      SchemaProperty('isPublic', RealmPropertyType.bool, mapTo: 'is_public'),
      SchemaProperty('originalSetId', RealmPropertyType.objectid,
          mapTo: 'original_set_id', optional: true),
      SchemaProperty('originalOwnerId', RealmPropertyType.objectid,
          mapTo: 'original_owner_id', optional: true),
      SchemaProperty('ownerId', RealmPropertyType.string, mapTo: 'owner_id'),
    ]);
  }
}

class Tags extends _Tags with RealmEntity, RealmObjectBase, RealmObject {
  Tags(
    ObjectId userId,
    String tag,
  ) {
    RealmObjectBase.set(this, '_id', userId);
    RealmObjectBase.set(this, 'tag', tag);
  }

  Tags._();

  @override
  ObjectId get userId => RealmObjectBase.get<ObjectId>(this, '_id') as ObjectId;
  @override
  set userId(ObjectId value) => RealmObjectBase.set(this, '_id', value);

  @override
  String get tag => RealmObjectBase.get<String>(this, 'tag') as String;
  @override
  set tag(String value) => RealmObjectBase.set(this, 'tag', value);

  @override
  Stream<RealmObjectChanges<Tags>> get changes =>
      RealmObjectBase.getChanges<Tags>(this);

  @override
  Tags freeze() => RealmObjectBase.freezeObject<Tags>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(Tags._);
    return const SchemaObject(ObjectType.realmObject, Tags, 'Tags', [
      SchemaProperty('userId', RealmPropertyType.objectid,
          mapTo: '_id', primaryKey: true),
      SchemaProperty('tag', RealmPropertyType.string),
    ]);
  }
}

class Users extends _Users with RealmEntity, RealmObjectBase, RealmObject {
  Users(
    ObjectId userId,
    String firstname,
    String lastname,
    int studyStreak, {
    DateTime? lastStudySession,
  }) {
    RealmObjectBase.set(this, '_id', userId);
    RealmObjectBase.set(this, 'firstname', firstname);
    RealmObjectBase.set(this, 'lastname', lastname);
    RealmObjectBase.set(this, 'study_streak', studyStreak);
    RealmObjectBase.set(this, 'last_study_session', lastStudySession);
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
  DateTime? get lastStudySession =>
      (RealmObjectBase.get<DateTime>(this, 'last_study_session') as DateTime?)?.toLocal();
  @override
  set lastStudySession(DateTime? value) =>
      RealmObjectBase.set(this, 'last_study_session', value);

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
      SchemaProperty('lastStudySession', RealmPropertyType.timestamp,
          mapTo: 'last_study_session', optional: true),
    ]);
  }
}
