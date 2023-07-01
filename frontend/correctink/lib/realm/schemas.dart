import 'package:realm/realm.dart';
part 'schemas.g.dart';

@RealmModel()
class _Task {
  @MapTo('_id')
  @PrimaryKey()
  late ObjectId id;

  bool isComplete = false;
  late String task;

  @Ignored()
  bool get hasDeadline => deadline != null;
  @Ignored()
  bool get hasReminder => reminder != null;


  @Ignored()
  DateTime get creationDate => id.timestamp;

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

  late String key;
  late String value;

  late bool hasMultipleKeys;
  late bool hasMultipleValues;

  late DateTime? lastSeen;

  late int knowCount = 0;
  late int learningCount = 0;

  int get learningProgress => knowCount - learningCount;
  int get seenCount => knowCount + learningCount;

  bool get isLearning => learningProgress >= learningMinValue && learningProgress < knowMinValue;

  bool get isKnown => learningProgress >= knowMinValue;

  @Ignored()
  int get knowMinValue => 6;

  @Ignored()
  int get learningMinValue => -2;
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

  /// Users can save sets made by other users to learn them,
  /// this property is a reference to the original set,
  @MapTo('original_set_id')
  late ObjectId? originalSetId;
  @MapTo('original_owner_id')
  late ObjectId? originalOwnerId;

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
  
  @MapTo('study_streak')
  late int studyStreak;

  @MapTo('last_study_session')
  late DateTime? lastStudySession;
}
