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
  DateTime get creationDate => id.timestamp;

  late DateTime? deadline;

  late ObjectId? linkedSet;

  @MapTo('owner_id')
  late String ownerId;
}

@RealmModel()
class _ToDo {
  @MapTo('_id')
  @PrimaryKey()
  late ObjectId id;

  late int index = 0;
  bool isComplete = false;
  late String todo;

  @MapTo('task_id')
  late ObjectId taskId;
}

@RealmModel()
class _KeyValueCard {
  @MapTo('_id')
  @PrimaryKey()
  late ObjectId id;

  late String key;
  late String value;

  late DateTime? lastSeen;
  late int learningProgress = 0;

  @MapTo('set_id')
  late ObjectId setId;

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
