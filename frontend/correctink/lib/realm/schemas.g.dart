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
    String? details,
    DateTime? completionDate,
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
    RealmObjectBase.set(this, 'details', details);
    RealmObjectBase.set(this, 'completionDate', completionDate);
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
  String? get details =>
      RealmObjectBase.get<String>(this, 'details') as String?;
  @override
  set details(String? value) => RealmObjectBase.set(this, 'details', value);

  @override
  DateTime? get completionDate =>
      RealmObjectBase.get<DateTime>(this, 'completionDate') as DateTime?;
  @override
  set completionDate(DateTime? value) =>
      RealmObjectBase.set(this, 'completionDate', value);

  @override
  DateTime? get deadline =>
      RealmObjectBase.get<DateTime>(this, 'deadline') as DateTime?;
  @override
  set deadline(DateTime? value) => RealmObjectBase.set(this, 'deadline', value);

  @override
  DateTime? get reminder =>
      RealmObjectBase.get<DateTime>(this, 'reminder') as DateTime?;
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
      SchemaProperty('details', RealmPropertyType.string, optional: true),
      SchemaProperty('completionDate', RealmPropertyType.timestamp,
          optional: true),
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
    String front,
    String back, {
    DateTime? lastSeenDate,
    DateTime? lastKnowDate,
    int knowCount = 0,
    int dontKnowCount = 0,
    int currentBox = 1,
    bool allowFrontMultipleValues = true,
    bool allowBackMultipleValues = true,
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<KeyValueCard>({
        'knowCount': 0,
        'dontKnowCount': 0,
        'currentBox': 1,
        'allowFrontMultipleValues': true,
        'allowBackMultipleValues': true,
      });
    }
    RealmObjectBase.set(this, '_id', id);
    RealmObjectBase.set(this, 'front', front);
    RealmObjectBase.set(this, 'back', back);
    RealmObjectBase.set(this, 'lastSeenDate', lastSeenDate);
    RealmObjectBase.set(this, 'lastKnowDate', lastKnowDate);
    RealmObjectBase.set(this, 'knowCount', knowCount);
    RealmObjectBase.set(this, 'dontKnowCount', dontKnowCount);
    RealmObjectBase.set(this, 'currentBox', currentBox);
    RealmObjectBase.set(
        this, 'allowFrontMultipleValues', allowFrontMultipleValues);
    RealmObjectBase.set(
        this, 'allowBackMultipleValues', allowBackMultipleValues);
  }

  KeyValueCard._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, '_id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, '_id', value);

  @override
  String get front => RealmObjectBase.get<String>(this, 'front') as String;
  @override
  set front(String value) => RealmObjectBase.set(this, 'front', value);

  @override
  String get back => RealmObjectBase.get<String>(this, 'back') as String;
  @override
  set back(String value) => RealmObjectBase.set(this, 'back', value);

  @override
  DateTime? get lastSeenDate =>
      RealmObjectBase.get<DateTime>(this, 'lastSeenDate') as DateTime?;
  @override
  set lastSeenDate(DateTime? value) =>
      RealmObjectBase.set(this, 'lastSeenDate', value);

  @override
  DateTime? get lastKnowDate =>
      RealmObjectBase.get<DateTime>(this, 'lastKnowDate') as DateTime?;
  @override
  set lastKnowDate(DateTime? value) =>
      RealmObjectBase.set(this, 'lastKnowDate', value);

  @override
  int get knowCount => RealmObjectBase.get<int>(this, 'knowCount') as int;
  @override
  set knowCount(int value) => RealmObjectBase.set(this, 'knowCount', value);

  @override
  int get dontKnowCount =>
      RealmObjectBase.get<int>(this, 'dontKnowCount') as int;
  @override
  set dontKnowCount(int value) =>
      RealmObjectBase.set(this, 'dontKnowCount', value);

  @override
  int get currentBox => RealmObjectBase.get<int>(this, 'currentBox') as int;
  @override
  set currentBox(int value) => RealmObjectBase.set(this, 'currentBox', value);

  @override
  bool get allowFrontMultipleValues =>
      RealmObjectBase.get<bool>(this, 'allowFrontMultipleValues') as bool;
  @override
  set allowFrontMultipleValues(bool value) =>
      RealmObjectBase.set(this, 'allowFrontMultipleValues', value);

  @override
  bool get allowBackMultipleValues =>
      RealmObjectBase.get<bool>(this, 'allowBackMultipleValues') as bool;
  @override
  set allowBackMultipleValues(bool value) =>
      RealmObjectBase.set(this, 'allowBackMultipleValues', value);

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
      SchemaProperty('front', RealmPropertyType.string),
      SchemaProperty('back', RealmPropertyType.string),
      SchemaProperty('lastSeenDate', RealmPropertyType.timestamp,
          optional: true),
      SchemaProperty('lastKnowDate', RealmPropertyType.timestamp,
          optional: true),
      SchemaProperty('knowCount', RealmPropertyType.int),
      SchemaProperty('dontKnowCount', RealmPropertyType.int),
      SchemaProperty('currentBox', RealmPropertyType.int),
      SchemaProperty('allowFrontMultipleValues', RealmPropertyType.bool),
      SchemaProperty('allowBackMultipleValues', RealmPropertyType.bool),
    ]);
  }
}

class CardSet extends _CardSet with RealmEntity, RealmObjectBase, RealmObject {
  static var _defaultsSet = false;

  CardSet(
    ObjectId id,
    String name,
    bool isPublic,
    String ownerId, {
    String? description,
    String? color,
    int uniqueUserVisitCount = 0,
    int uniqueUserStudyCount = 0,
    DateTime? lastStudyDate,
    int studyCount = 0,
    CardSet? originalSet,
    Users? originalOwner,
    Users? owner,
    int sideToGuess = 0,
    int studyMethod = 0,
    bool repeatUntilKnown = false,
    int resultHarshness = 1,
    bool getAllAnswersRight = false,
    bool lenientMode = false,
    Iterable<Tags> tags = const [],
    Iterable<KeyValueCard> cards = const [],
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<CardSet>({
        'uniqueUserVisitCount': 0,
        'uniqueUserStudyCount': 0,
        'studyCount': 0,
        'sideToGuess': 0,
        'studyMethod': 0,
        'repeatUntilKnown': false,
        'resultHarshness': 1,
        'getAllAnswersRight': false,
        'lenientMode': false,
      });
    }
    RealmObjectBase.set(this, '_id', id);
    RealmObjectBase.set(this, 'name', name);
    RealmObjectBase.set(this, 'description', description);
    RealmObjectBase.set(this, 'color', color);
    RealmObjectBase.set(this, 'is_public', isPublic);
    RealmObjectBase.set(this, 'uniqueUserVisitCount', uniqueUserVisitCount);
    RealmObjectBase.set(this, 'uniqueUserStudyCount', uniqueUserStudyCount);
    RealmObjectBase.set(this, 'lastStudyDate', lastStudyDate);
    RealmObjectBase.set(this, 'studyCount', studyCount);
    RealmObjectBase.set(this, 'originalSet', originalSet);
    RealmObjectBase.set(this, 'originalOwner', originalOwner);
    RealmObjectBase.set(this, 'owner', owner);
    RealmObjectBase.set(this, 'owner_id', ownerId);
    RealmObjectBase.set(this, 'sideToGuess', sideToGuess);
    RealmObjectBase.set(this, 'studyMethod', studyMethod);
    RealmObjectBase.set(this, 'repeatUntilKnown', repeatUntilKnown);
    RealmObjectBase.set(this, 'resultHarshness', resultHarshness);
    RealmObjectBase.set(this, 'getAllAnswersRight', getAllAnswersRight);
    RealmObjectBase.set(this, 'lenientMode', lenientMode);
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
  int get uniqueUserVisitCount =>
      RealmObjectBase.get<int>(this, 'uniqueUserVisitCount') as int;
  @override
  set uniqueUserVisitCount(int value) =>
      RealmObjectBase.set(this, 'uniqueUserVisitCount', value);

  @override
  int get uniqueUserStudyCount =>
      RealmObjectBase.get<int>(this, 'uniqueUserStudyCount') as int;
  @override
  set uniqueUserStudyCount(int value) =>
      RealmObjectBase.set(this, 'uniqueUserStudyCount', value);

  @override
  DateTime? get lastStudyDate =>
      RealmObjectBase.get<DateTime>(this, 'lastStudyDate') as DateTime?;
  @override
  set lastStudyDate(DateTime? value) =>
      RealmObjectBase.set(this, 'lastStudyDate', value);

  @override
  int get studyCount => RealmObjectBase.get<int>(this, 'studyCount') as int;
  @override
  set studyCount(int value) => RealmObjectBase.set(this, 'studyCount', value);

  @override
  CardSet? get originalSet =>
      RealmObjectBase.get<CardSet>(this, 'originalSet') as CardSet?;
  @override
  set originalSet(covariant CardSet? value) =>
      RealmObjectBase.set(this, 'originalSet', value);

  @override
  Users? get originalOwner =>
      RealmObjectBase.get<Users>(this, 'originalOwner') as Users?;
  @override
  set originalOwner(covariant Users? value) =>
      RealmObjectBase.set(this, 'originalOwner', value);

  @override
  Users? get owner => RealmObjectBase.get<Users>(this, 'owner') as Users?;
  @override
  set owner(covariant Users? value) =>
      RealmObjectBase.set(this, 'owner', value);

  @override
  String get ownerId => RealmObjectBase.get<String>(this, 'owner_id') as String;
  @override
  set ownerId(String value) => RealmObjectBase.set(this, 'owner_id', value);

  @override
  int get sideToGuess => RealmObjectBase.get<int>(this, 'sideToGuess') as int;
  @override
  set sideToGuess(int value) => RealmObjectBase.set(this, 'sideToGuess', value);

  @override
  int get studyMethod => RealmObjectBase.get<int>(this, 'studyMethod') as int;
  @override
  set studyMethod(int value) => RealmObjectBase.set(this, 'studyMethod', value);

  @override
  bool get repeatUntilKnown =>
      RealmObjectBase.get<bool>(this, 'repeatUntilKnown') as bool;
  @override
  set repeatUntilKnown(bool value) =>
      RealmObjectBase.set(this, 'repeatUntilKnown', value);

  @override
  int get resultHarshness =>
      RealmObjectBase.get<int>(this, 'resultHarshness') as int;
  @override
  set resultHarshness(int value) =>
      RealmObjectBase.set(this, 'resultHarshness', value);

  @override
  bool get getAllAnswersRight =>
      RealmObjectBase.get<bool>(this, 'getAllAnswersRight') as bool;
  @override
  set getAllAnswersRight(bool value) =>
      RealmObjectBase.set(this, 'getAllAnswersRight', value);

  @override
  bool get lenientMode =>
      RealmObjectBase.get<bool>(this, 'lenientMode') as bool;
  @override
  set lenientMode(bool value) =>
      RealmObjectBase.set(this, 'lenientMode', value);

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
      SchemaProperty('uniqueUserVisitCount', RealmPropertyType.int),
      SchemaProperty('uniqueUserStudyCount', RealmPropertyType.int),
      SchemaProperty('lastStudyDate', RealmPropertyType.timestamp,
          optional: true),
      SchemaProperty('studyCount', RealmPropertyType.int),
      SchemaProperty('originalSet', RealmPropertyType.object,
          optional: true, linkTarget: 'CardSet'),
      SchemaProperty('originalOwner', RealmPropertyType.object,
          optional: true, linkTarget: 'Users'),
      SchemaProperty('owner', RealmPropertyType.object,
          optional: true, linkTarget: 'Users'),
      SchemaProperty('ownerId', RealmPropertyType.string, mapTo: 'owner_id'),
      SchemaProperty('sideToGuess', RealmPropertyType.int),
      SchemaProperty('studyMethod', RealmPropertyType.int),
      SchemaProperty('repeatUntilKnown', RealmPropertyType.bool),
      SchemaProperty('resultHarshness', RealmPropertyType.int),
      SchemaProperty('getAllAnswersRight', RealmPropertyType.bool),
      SchemaProperty('lenientMode', RealmPropertyType.bool),
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
    String email,
    String about,
    int studyStreak, {
    DateTime? lastStudySession,
    Iterable<CardSet> visitedSets = const [],
    Iterable<CardSet> studiedSets = const [],
  }) {
    RealmObjectBase.set(this, '_id', userId);
    RealmObjectBase.set(this, 'firstname', firstname);
    RealmObjectBase.set(this, 'lastname', lastname);
    RealmObjectBase.set(this, 'email', email);
    RealmObjectBase.set(this, 'about', about);
    RealmObjectBase.set(this, 'study_streak', studyStreak);
    RealmObjectBase.set(this, 'last_study_session', lastStudySession);
    RealmObjectBase.set<RealmList<CardSet>>(
        this, 'visitedSets', RealmList<CardSet>(visitedSets));
    RealmObjectBase.set<RealmList<CardSet>>(
        this, 'studiedSets', RealmList<CardSet>(studiedSets));
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
  String get email => RealmObjectBase.get<String>(this, 'email') as String;
  @override
  set email(String value) => RealmObjectBase.set(this, 'email', value);

  @override
  String get about => RealmObjectBase.get<String>(this, 'about') as String;
  @override
  set about(String value) => RealmObjectBase.set(this, 'about', value);

  @override
  RealmList<CardSet> get visitedSets =>
      RealmObjectBase.get<CardSet>(this, 'visitedSets') as RealmList<CardSet>;
  @override
  set visitedSets(covariant RealmList<CardSet> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmList<CardSet> get studiedSets =>
      RealmObjectBase.get<CardSet>(this, 'studiedSets') as RealmList<CardSet>;
  @override
  set studiedSets(covariant RealmList<CardSet> value) =>
      throw RealmUnsupportedSetError();

  @override
  int get studyStreak => RealmObjectBase.get<int>(this, 'study_streak') as int;
  @override
  set studyStreak(int value) =>
      RealmObjectBase.set(this, 'study_streak', value);

  @override
  DateTime? get lastStudySession =>
      RealmObjectBase.get<DateTime>(this, 'last_study_session') as DateTime?;
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
      SchemaProperty('email', RealmPropertyType.string),
      SchemaProperty('about', RealmPropertyType.string),
      SchemaProperty('visitedSets', RealmPropertyType.object,
          linkTarget: 'CardSet', collectionType: RealmCollectionType.list),
      SchemaProperty('studiedSets', RealmPropertyType.object,
          linkTarget: 'CardSet', collectionType: RealmCollectionType.list),
      SchemaProperty('studyStreak', RealmPropertyType.int,
          mapTo: 'study_streak'),
      SchemaProperty('lastStudySession', RealmPropertyType.timestamp,
          mapTo: 'last_study_session', optional: true),
    ]);
  }
}
