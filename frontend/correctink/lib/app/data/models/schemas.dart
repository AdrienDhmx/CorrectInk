import 'package:realm/realm.dart';

part 'schemas.g.dart';

@RealmModel()
class _Task {
  @MapTo('_id')
  @PrimaryKey()
  late ObjectId id;

  bool isComplete = false;
  late String task;
  late String note = '';

  late int priorityLevel = 0;

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

  late String front;
  late String back;

  late DateTime? lastSeenDate;
  late DateTime? lastKnowDate;

  late int knowCount = 0;
  late int dontKnowCount = 0;

  late int currentBox = 1;

  late bool allowFrontMultipleValues = true;
  late bool allowBackMultipleValues = true;

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


  // 0 is default => show the key guess the value
  // 1 => show the value guess the key
  // -1 => randomly show the key or the value
  late int sideToGuess = 0;

  // 0 is default => use the Leitner and spaced repetition algorithms to decide what to cards to study in a set
  // -1 => always study all the cards
  // 1+ => always study the cards in the corresponding box and under
  late int studyMethod = 0;

  // don't end the study session until all the user got all the cards right
  // keep showing the cards the user got wrong until he gets the right
  late bool repeatUntilKnown = false;

  // 0 => the current box of the card will not be updated not matter the result
  // 1 is default => increase (correct answer) or decrease (wrong answer) the current box by 1
  // 2 => increase by 1 when right, but always go back to the first box when wrong
  late int resultHarshness = 1;

  // whether the user needs to give all the answers of the cards if there are multiple
  late bool getAllAnswersRight = false;

  // whether to accept answer with a typo (true) or not (false) => for written mode only
  // default to false
  late bool lenientMode = false;
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

  late List<_CardSet> visitedSets;
  late List<_CardSet> studiedSets;

  late _Inbox? inbox;

  late int role;
  
  @MapTo('study_streak')
  late int studyStreak;

  @MapTo('last_study_session')
  late DateTime? lastStudySession;
}

@RealmModel()
class _Inbox {
  @MapTo('_id')
  @PrimaryKey()
  late ObjectId inboxId;

  late List<_Message> newMessages;
  late List<_UserMessage> receivedMessages;
  late List<_Message> sendMessages; // admin only
}

@RealmModel()
class _Message {
  @MapTo('_id')
  @PrimaryKey()
  late ObjectId messageId;

  late String title;
  late String message;

  late int type;

  late DateTime sendDate;
  late DateTime expirationDate;
}

@RealmModel()
class _UserMessage {
  @MapTo('_id')
  @PrimaryKey()
  late ObjectId userMessageId;

  late _Message? message;
  late bool read = false;
}