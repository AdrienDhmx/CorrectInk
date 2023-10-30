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
    String note = '',
    int priorityLevel = 0,
    DateTime? completionDate,
    DateTime? deadline,
    DateTime? reminder,
    int reminderRepeatMode = 0,
    Iterable<TaskStep> steps = const [],
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<Task>({
        'isComplete': false,
        'note': '',
        'priorityLevel': 0,
        'reminderRepeatMode': 0,
      });
    }
    RealmObjectBase.set(this, '_id', id);
    RealmObjectBase.set(this, 'isComplete', isComplete);
    RealmObjectBase.set(this, 'task', task);
    RealmObjectBase.set(this, 'note', note);
    RealmObjectBase.set(this, 'priorityLevel', priorityLevel);
    RealmObjectBase.set(this, 'completionDate', completionDate);
    RealmObjectBase.set(this, 'deadline', deadline);
    RealmObjectBase.set(this, 'reminder', reminder);
    RealmObjectBase.set(this, 'reminderRepeatMode', reminderRepeatMode);
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
  String get note => RealmObjectBase.get<String>(this, 'note') as String;
  @override
  set note(String value) => RealmObjectBase.set(this, 'note', value);

  @override
  int get priorityLevel =>
      RealmObjectBase.get<int>(this, 'priorityLevel') as int;
  @override
  set priorityLevel(int value) =>
      RealmObjectBase.set(this, 'priorityLevel', value);

  @override
  DateTime? get completionDate =>
      (RealmObjectBase.get<DateTime>(this, 'completionDate') as DateTime?)?.toLocal();
  @override
  set completionDate(DateTime? value) =>
      RealmObjectBase.set(this, 'completionDate', value);

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
      SchemaProperty('note', RealmPropertyType.string),
      SchemaProperty('priorityLevel', RealmPropertyType.int),
      SchemaProperty('completionDate', RealmPropertyType.timestamp,
          optional: true),
      SchemaProperty('deadline', RealmPropertyType.timestamp, optional: true),
      SchemaProperty('reminder', RealmPropertyType.timestamp, optional: true),
      SchemaProperty('reminderRepeatMode', RealmPropertyType.int),
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
      (RealmObjectBase.get<DateTime>(this, 'lastSeenDate') as DateTime?)?.toLocal();
  @override
  set lastSeenDate(DateTime? value) =>
      RealmObjectBase.set(this, 'lastSeenDate', value);

  @override
  DateTime? get lastKnowDate =>
      (RealmObjectBase.get<DateTime>(this, 'lastKnowDate') as DateTime?)?.toLocal();
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
    DateTime? lastStudyDate,
    int studyCount = 0,
    CardSet? originalSet,
    Users? originalOwner,
    Users? owner,
    int reportCount = 0,
    ReportMessage? lastReport,
    bool blocked = false,
    int likes = 0,
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
        'studyCount': 0,
        'reportCount': 0,
        'blocked': false,
        'likes': 0,
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
    RealmObjectBase.set(this, 'lastStudyDate', lastStudyDate);
    RealmObjectBase.set(this, 'studyCount', studyCount);
    RealmObjectBase.set(this, 'originalSet', originalSet);
    RealmObjectBase.set(this, 'originalOwner', originalOwner);
    RealmObjectBase.set(this, 'owner', owner);
    RealmObjectBase.set(this, 'owner_id', ownerId);
    RealmObjectBase.set(this, 'reportCount', reportCount);
    RealmObjectBase.set(this, 'lastReport', lastReport);
    RealmObjectBase.set(this, 'blocked', blocked);
    RealmObjectBase.set(this, 'likes', likes);
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
  DateTime? get lastStudyDate =>
      (RealmObjectBase.get<DateTime>(this, 'lastStudyDate') as DateTime?)?.toLocal();
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
  int get reportCount => RealmObjectBase.get<int>(this, 'reportCount') as int;
  @override
  set reportCount(int value) => RealmObjectBase.set(this, 'reportCount', value);

  @override
  ReportMessage? get lastReport =>
      RealmObjectBase.get<ReportMessage>(this, 'lastReport') as ReportMessage?;
  @override
  set lastReport(covariant ReportMessage? value) =>
      RealmObjectBase.set(this, 'lastReport', value);

  @override
  bool get blocked => RealmObjectBase.get<bool>(this, 'blocked') as bool;
  @override
  set blocked(bool value) => RealmObjectBase.set(this, 'blocked', value);

  @override
  int get likes => RealmObjectBase.get<int>(this, 'likes') as int;
  @override
  set likes(int value) => RealmObjectBase.set(this, 'likes', value);

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
      SchemaProperty('reportCount', RealmPropertyType.int),
      SchemaProperty('lastReport', RealmPropertyType.object,
          optional: true, linkTarget: 'ReportMessage'),
      SchemaProperty('blocked', RealmPropertyType.bool),
      SchemaProperty('likes', RealmPropertyType.int),
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
  static var _defaultsSet = false;

  Users(
    ObjectId userId,
    String firstname,
    String lastname,
    String email,
    String about,
    int role,
    int studyStreak, {
    Inbox? inbox,
    bool blocked = false,
    DateTime? lastStudySession,
    Iterable<CardSet> likedSets = const [],
    Iterable<CardSet> reportedSets = const [],
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<Users>({
        'blocked': false,
      });
    }
    RealmObjectBase.set(this, '_id', userId);
    RealmObjectBase.set(this, 'firstname', firstname);
    RealmObjectBase.set(this, 'lastname', lastname);
    RealmObjectBase.set(this, 'email', email);
    RealmObjectBase.set(this, 'about', about);
    RealmObjectBase.set(this, 'inbox', inbox);
    RealmObjectBase.set(this, 'role', role);
    RealmObjectBase.set(this, 'blocked', blocked);
    RealmObjectBase.set(this, 'study_streak', studyStreak);
    RealmObjectBase.set(this, 'last_study_session', lastStudySession);
    RealmObjectBase.set<RealmList<CardSet>>(
        this, 'likedSets', RealmList<CardSet>(likedSets));
    RealmObjectBase.set<RealmList<CardSet>>(
        this, 'reportedSets', RealmList<CardSet>(reportedSets));
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
  RealmList<CardSet> get likedSets =>
      RealmObjectBase.get<CardSet>(this, 'likedSets') as RealmList<CardSet>;
  @override
  set likedSets(covariant RealmList<CardSet> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmList<CardSet> get reportedSets =>
      RealmObjectBase.get<CardSet>(this, 'reportedSets') as RealmList<CardSet>;
  @override
  set reportedSets(covariant RealmList<CardSet> value) =>
      throw RealmUnsupportedSetError();

  @override
  Inbox? get inbox => RealmObjectBase.get<Inbox>(this, 'inbox') as Inbox?;
  @override
  set inbox(covariant Inbox? value) =>
      RealmObjectBase.set(this, 'inbox', value);

  @override
  int get role => RealmObjectBase.get<int>(this, 'role') as int;
  @override
  set role(int value) => RealmObjectBase.set(this, 'role', value);

  @override
  bool get blocked => RealmObjectBase.get<bool>(this, 'blocked') as bool;
  @override
  set blocked(bool value) => RealmObjectBase.set(this, 'blocked', value);

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
      SchemaProperty('email', RealmPropertyType.string),
      SchemaProperty('about', RealmPropertyType.string),
      SchemaProperty('likedSets', RealmPropertyType.object,
          linkTarget: 'CardSet', collectionType: RealmCollectionType.list),
      SchemaProperty('reportedSets', RealmPropertyType.object,
          linkTarget: 'CardSet', collectionType: RealmCollectionType.list),
      SchemaProperty('inbox', RealmPropertyType.object,
          optional: true, linkTarget: 'Inbox'),
      SchemaProperty('role', RealmPropertyType.int),
      SchemaProperty('blocked', RealmPropertyType.bool),
      SchemaProperty('studyStreak', RealmPropertyType.int,
          mapTo: 'study_streak'),
      SchemaProperty('lastStudySession', RealmPropertyType.timestamp,
          mapTo: 'last_study_session', optional: true),
    ]);
  }
}

class Inbox extends _Inbox with RealmEntity, RealmObjectBase, RealmObject {
  Inbox(
    ObjectId inboxId, {
    Iterable<Message> newMessages = const [],
    Iterable<UserMessage> receivedMessages = const [],
    Iterable<Message> sendMessages = const [],
    Iterable<ReportMessage> reports = const [],
  }) {
    RealmObjectBase.set(this, '_id', inboxId);
    RealmObjectBase.set<RealmList<Message>>(
        this, 'newMessages', RealmList<Message>(newMessages));
    RealmObjectBase.set<RealmList<UserMessage>>(
        this, 'receivedMessages', RealmList<UserMessage>(receivedMessages));
    RealmObjectBase.set<RealmList<Message>>(
        this, 'sendMessages', RealmList<Message>(sendMessages));
    RealmObjectBase.set<RealmList<ReportMessage>>(
        this, 'reports', RealmList<ReportMessage>(reports));
  }

  Inbox._();

  @override
  ObjectId get inboxId =>
      RealmObjectBase.get<ObjectId>(this, '_id') as ObjectId;
  @override
  set inboxId(ObjectId value) => RealmObjectBase.set(this, '_id', value);

  @override
  RealmList<Message> get newMessages =>
      RealmObjectBase.get<Message>(this, 'newMessages') as RealmList<Message>;
  @override
  set newMessages(covariant RealmList<Message> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmList<UserMessage> get receivedMessages =>
      RealmObjectBase.get<UserMessage>(this, 'receivedMessages')
          as RealmList<UserMessage>;
  @override
  set receivedMessages(covariant RealmList<UserMessage> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmList<Message> get sendMessages =>
      RealmObjectBase.get<Message>(this, 'sendMessages') as RealmList<Message>;
  @override
  set sendMessages(covariant RealmList<Message> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmList<ReportMessage> get reports =>
      RealmObjectBase.get<ReportMessage>(this, 'reports')
          as RealmList<ReportMessage>;
  @override
  set reports(covariant RealmList<ReportMessage> value) =>
      throw RealmUnsupportedSetError();

  @override
  Stream<RealmObjectChanges<Inbox>> get changes =>
      RealmObjectBase.getChanges<Inbox>(this);

  @override
  Inbox freeze() => RealmObjectBase.freezeObject<Inbox>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(Inbox._);
    return const SchemaObject(ObjectType.realmObject, Inbox, 'Inbox', [
      SchemaProperty('inboxId', RealmPropertyType.objectid,
          mapTo: '_id', primaryKey: true),
      SchemaProperty('newMessages', RealmPropertyType.object,
          linkTarget: 'Message', collectionType: RealmCollectionType.list),
      SchemaProperty('receivedMessages', RealmPropertyType.object,
          linkTarget: 'UserMessage', collectionType: RealmCollectionType.list),
      SchemaProperty('sendMessages', RealmPropertyType.object,
          linkTarget: 'Message', collectionType: RealmCollectionType.list),
      SchemaProperty('reports', RealmPropertyType.object,
          linkTarget: 'ReportMessage',
          collectionType: RealmCollectionType.list),
    ]);
  }
}

class Message extends _Message with RealmEntity, RealmObjectBase, RealmObject {
  Message(
    ObjectId messageId,
    String title,
    String message,
    int icon,
    DateTime sendDate,
    DateTime expirationDate,
  ) {
    RealmObjectBase.set(this, '_id', messageId);
    RealmObjectBase.set(this, 'title', title);
    RealmObjectBase.set(this, 'message', message);
    RealmObjectBase.set(this, 'icon', icon);
    RealmObjectBase.set(this, 'sendDate', sendDate);
    RealmObjectBase.set(this, 'expirationDate', expirationDate);
  }

  Message._();

  @override
  ObjectId get messageId =>
      RealmObjectBase.get<ObjectId>(this, '_id') as ObjectId;
  @override
  set messageId(ObjectId value) => RealmObjectBase.set(this, '_id', value);

  @override
  String get title => RealmObjectBase.get<String>(this, 'title') as String;
  @override
  set title(String value) => RealmObjectBase.set(this, 'title', value);

  @override
  String get message => RealmObjectBase.get<String>(this, 'message') as String;
  @override
  set message(String value) => RealmObjectBase.set(this, 'message', value);

  @override
  int get icon => RealmObjectBase.get<int>(this, 'icon') as int;
  @override
  set icon(int value) => RealmObjectBase.set(this, 'icon', value);

  @override
  DateTime get sendDate =>
      (RealmObjectBase.get<DateTime>(this, 'sendDate') as DateTime).toLocal();
  @override
  set sendDate(DateTime value) => RealmObjectBase.set(this, 'sendDate', value);

  @override
  DateTime get expirationDate =>
      (RealmObjectBase.get<DateTime>(this, 'expirationDate') as DateTime).toLocal();
  @override
  set expirationDate(DateTime value) =>
      RealmObjectBase.set(this, 'expirationDate', value);

  @override
  Stream<RealmObjectChanges<Message>> get changes =>
      RealmObjectBase.getChanges<Message>(this);

  @override
  Message freeze() => RealmObjectBase.freezeObject<Message>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(Message._);
    return const SchemaObject(ObjectType.realmObject, Message, 'Message', [
      SchemaProperty('messageId', RealmPropertyType.objectid,
          mapTo: '_id', primaryKey: true),
      SchemaProperty('title', RealmPropertyType.string),
      SchemaProperty('message', RealmPropertyType.string),
      SchemaProperty('icon', RealmPropertyType.int),
      SchemaProperty('sendDate', RealmPropertyType.timestamp),
      SchemaProperty('expirationDate', RealmPropertyType.timestamp),
    ]);
  }
}

class UserMessage extends _UserMessage
    with RealmEntity, RealmObjectBase, RealmObject {
  static var _defaultsSet = false;

  UserMessage(
    ObjectId userMessageId, {
    Message? message,
    bool read = false,
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<UserMessage>({
        'read': false,
      });
    }
    RealmObjectBase.set(this, '_id', userMessageId);
    RealmObjectBase.set(this, 'message', message);
    RealmObjectBase.set(this, 'read', read);
  }

  UserMessage._();

  @override
  ObjectId get userMessageId =>
      RealmObjectBase.get<ObjectId>(this, '_id') as ObjectId;
  @override
  set userMessageId(ObjectId value) => RealmObjectBase.set(this, '_id', value);

  @override
  Message? get message =>
      RealmObjectBase.get<Message>(this, 'message') as Message?;
  @override
  set message(covariant Message? value) =>
      RealmObjectBase.set(this, 'message', value);

  @override
  bool get read => RealmObjectBase.get<bool>(this, 'read') as bool;
  @override
  set read(bool value) => RealmObjectBase.set(this, 'read', value);

  @override
  Stream<RealmObjectChanges<UserMessage>> get changes =>
      RealmObjectBase.getChanges<UserMessage>(this);

  @override
  UserMessage freeze() => RealmObjectBase.freezeObject<UserMessage>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(UserMessage._);
    return const SchemaObject(
        ObjectType.realmObject, UserMessage, 'UserMessage', [
      SchemaProperty('userMessageId', RealmPropertyType.objectid,
          mapTo: '_id', primaryKey: true),
      SchemaProperty('message', RealmPropertyType.object,
          optional: true, linkTarget: 'Message'),
      SchemaProperty('read', RealmPropertyType.bool),
    ]);
  }
}

class ReportMessage extends _ReportMessage
    with RealmEntity, RealmObjectBase, RealmObject {
  static var _defaultsSet = false;

  ReportMessage(
    ObjectId reportMessageId,
    int setReportCount,
    String additionalInformation,
    int moderatorChoice,
    String moderatorAdditionalInformation,
    DateTime reportDate, {
    ReportMessage? previousReport,
    CardSet? reportedSet,
    Users? reportedUser,
    Users? reportingUser,
    bool resolved = false,
    Iterable<String> reasons = const [],
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<ReportMessage>({
        'resolved': false,
      });
    }
    RealmObjectBase.set(this, '_id', reportMessageId);
    RealmObjectBase.set(this, 'setReportCount', setReportCount);
    RealmObjectBase.set(this, 'additionalInformation', additionalInformation);
    RealmObjectBase.set(this, 'moderatorChoice', moderatorChoice);
    RealmObjectBase.set(
        this, 'moderatorAdditionalInformation', moderatorAdditionalInformation);
    RealmObjectBase.set(this, 'previousReport', previousReport);
    RealmObjectBase.set(this, 'reportedSet', reportedSet);
    RealmObjectBase.set(this, 'reportedUser', reportedUser);
    RealmObjectBase.set(this, 'reportingUser', reportingUser);
    RealmObjectBase.set(this, 'reportDate', reportDate);
    RealmObjectBase.set(this, 'resolved', resolved);
    RealmObjectBase.set<RealmList<String>>(
        this, 'reasons', RealmList<String>(reasons));
  }

  ReportMessage._();

  @override
  ObjectId get reportMessageId =>
      RealmObjectBase.get<ObjectId>(this, '_id') as ObjectId;
  @override
  set reportMessageId(ObjectId value) =>
      RealmObjectBase.set(this, '_id', value);

  @override
  int get setReportCount =>
      RealmObjectBase.get<int>(this, 'setReportCount') as int;
  @override
  set setReportCount(int value) =>
      RealmObjectBase.set(this, 'setReportCount', value);

  @override
  RealmList<String> get reasons =>
      RealmObjectBase.get<String>(this, 'reasons') as RealmList<String>;
  @override
  set reasons(covariant RealmList<String> value) =>
      throw RealmUnsupportedSetError();

  @override
  String get additionalInformation =>
      RealmObjectBase.get<String>(this, 'additionalInformation') as String;
  @override
  set additionalInformation(String value) =>
      RealmObjectBase.set(this, 'additionalInformation', value);

  @override
  int get moderatorChoice =>
      RealmObjectBase.get<int>(this, 'moderatorChoice') as int;
  @override
  set moderatorChoice(int value) =>
      RealmObjectBase.set(this, 'moderatorChoice', value);

  @override
  String get moderatorAdditionalInformation =>
      RealmObjectBase.get<String>(this, 'moderatorAdditionalInformation')
          as String;
  @override
  set moderatorAdditionalInformation(String value) =>
      RealmObjectBase.set(this, 'moderatorAdditionalInformation', value);

  @override
  ReportMessage? get previousReport =>
      RealmObjectBase.get<ReportMessage>(this, 'previousReport')
          as ReportMessage?;
  @override
  set previousReport(covariant ReportMessage? value) =>
      RealmObjectBase.set(this, 'previousReport', value);

  @override
  CardSet? get reportedSet =>
      RealmObjectBase.get<CardSet>(this, 'reportedSet') as CardSet?;
  @override
  set reportedSet(covariant CardSet? value) =>
      RealmObjectBase.set(this, 'reportedSet', value);

  @override
  Users? get reportedUser =>
      RealmObjectBase.get<Users>(this, 'reportedUser') as Users?;
  @override
  set reportedUser(covariant Users? value) =>
      RealmObjectBase.set(this, 'reportedUser', value);

  @override
  Users? get reportingUser =>
      RealmObjectBase.get<Users>(this, 'reportingUser') as Users?;
  @override
  set reportingUser(covariant Users? value) =>
      RealmObjectBase.set(this, 'reportingUser', value);

  @override
  DateTime get reportDate =>
      (RealmObjectBase.get<DateTime>(this, 'reportDate') as DateTime).toLocal();
  @override
  set reportDate(DateTime value) =>
      RealmObjectBase.set(this, 'reportDate', value);

  @override
  bool get resolved => RealmObjectBase.get<bool>(this, 'resolved') as bool;
  @override
  set resolved(bool value) => RealmObjectBase.set(this, 'resolved', value);

  @override
  Stream<RealmObjectChanges<ReportMessage>> get changes =>
      RealmObjectBase.getChanges<ReportMessage>(this);

  @override
  ReportMessage freeze() => RealmObjectBase.freezeObject<ReportMessage>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(ReportMessage._);
    return const SchemaObject(
        ObjectType.realmObject, ReportMessage, 'ReportMessage', [
      SchemaProperty('reportMessageId', RealmPropertyType.objectid,
          mapTo: '_id', primaryKey: true),
      SchemaProperty('setReportCount', RealmPropertyType.int),
      SchemaProperty('reasons', RealmPropertyType.string,
          collectionType: RealmCollectionType.list),
      SchemaProperty('additionalInformation', RealmPropertyType.string),
      SchemaProperty('moderatorChoice', RealmPropertyType.int),
      SchemaProperty(
          'moderatorAdditionalInformation', RealmPropertyType.string),
      SchemaProperty('previousReport', RealmPropertyType.object,
          optional: true, linkTarget: 'ReportMessage'),
      SchemaProperty('reportedSet', RealmPropertyType.object,
          optional: true, linkTarget: 'CardSet'),
      SchemaProperty('reportedUser', RealmPropertyType.object,
          optional: true, linkTarget: 'Users'),
      SchemaProperty('reportingUser', RealmPropertyType.object,
          optional: true, linkTarget: 'Users'),
      SchemaProperty('reportDate', RealmPropertyType.timestamp),
      SchemaProperty('resolved', RealmPropertyType.bool),
    ]);
  }
}
