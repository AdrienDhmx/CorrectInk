import 'package:realm/realm.dart';
part 'schemas.g.dart';

@RealmModel()
class _Task {
  @MapTo('_id')
  @PrimaryKey()
  late ObjectId id;

  bool isComplete = false;
  late String task;
  late String? details;

  @Ignored()
  bool get hasDeadline => deadline != null;
  @Ignored()
  bool get hasReminder => reminder != null;

  @Ignored()
  DateTime get creationDate => id.timestamp;

  late DateTime? completionDate;

  late DateTime? deadline;

  late DateTime? reminder;
  late int reminderRepeatMode = 0;

  late ObjectId? linkedSet;

  late List<_TaskStep> steps;

  @MapTo('owner_id')
  late String ownerId;
}

@RealmModel()
class _TaskStep {
  @MapTo('_id')
  @PrimaryKey()
  late ObjectId id;

  late int index = 0;
  bool isComplete = false;
  late String todo;
}

@RealmModel()
class _KeyValueCard {
  @MapTo('_id')
  @PrimaryKey()
  late ObjectId id;

  late List<String> keys;
  late List<String> values;

  late DateTime? lastSeenDate;
  late DateTime? lastKnowDate;

  late int knowCount = 0;
  late int dontKnowCount = 0;

  late int currentBox = 1;

  bool get hasMultipleKeys => values.length > 1;
  bool get hasMultipleValues => keys.length > 1;

  int get knowRate => (knowCount / dontKnowCount * 100).round();
  int get seenCount => knowCount + dontKnowCount;
}

@RealmModel()
class _CardSet{
  @MapTo('_id')
  @PrimaryKey()
  late ObjectId id;

  late String name;
  late String? description;

  late String? color;

  late List<_Tags> tags;
  late List<_KeyValueCard> cards;

  @MapTo('is_public')
  late bool isPublic;

  late int uniqueUserVisitCount = 0;
  late int uniqueUserStudyCount = 0;
  int get popularity => uniqueUserStudyCount * 4 + uniqueUserVisitCount;

  late DateTime? lastStudyDate;
  late int studyCount = 0;

  /// Users can save sets made by other users to learn them,
  /// these properties are reference to the original set and its user,
  late _CardSet? originalSet;
  late _Users? originalOwner;

  late _Users? owner;
  @MapTo('owner_id')
  late String ownerId;
}

@RealmModel()
class _Tags {
  @MapTo('_id')
  @PrimaryKey()
  late ObjectId userId;

  late String tag;
}

@RealmModel()
class _Users {
  @MapTo('_id')
  @PrimaryKey()
  late ObjectId userId;
  
  late String firstname;
  late String lastname;

  late String email;
  late String about;
  
  @MapTo('study_streak')
  late int studyStreak;

  @MapTo('last_study_session')
  late DateTime? lastStudySession;
}
