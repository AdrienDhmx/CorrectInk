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
class _CardSide {
  @MapTo('_id')
  @PrimaryKey()
  late ObjectId id;

  late String value;
  late String additionalInfo;
  late bool allowMultipleValues = true;

  late DateTime? lastSeenDate;
  late DateTime? lastKnowDate;

  late int knowCount = 0;
  late int dontKnowCount = 0;

  late int currentBox = 0;

  int get knowRate => (knowCount / dontKnowCount * 100).round();
  int get seenCount => knowCount + dontKnowCount;
}

@RealmModel()
class _Flashcard {
  @MapTo('_id')
  @PrimaryKey()
  late ObjectId id;

  late _CardSide? front;
  late _CardSide? back;

  late bool canBeReversed = true;

  String get frontValue => front!.value;
  String get backValue => back!.value;

  DateTime? get lastSeenDate =>
      (front!.lastSeenDate?.millisecondsSinceEpoch ?? 0) > (back!.lastSeenDate?.millisecondsSinceEpoch ?? 0)
          ? front!.lastSeenDate
          : back!.lastSeenDate;
  DateTime? get lastKnowDate =>
    (front!.lastKnowDate?.millisecondsSinceEpoch ?? 0) > (back!.lastKnowDate?.millisecondsSinceEpoch ?? 0)
        ? front!.lastKnowDate
        : back!.lastKnowDate;

  int get knowCount => front!.knowCount + back!.knowCount;
  int get dontKnowCount => front!.dontKnowCount + back!.dontKnowCount;

  int get currentBox => canBeReversed ? ((front!.currentBox + back!.currentBox) / 2).ceil() : back!.currentBox;

  int get seenCount => (front!.seenCount) + (back!.seenCount);
  int get knowRate => (knowCount / dontKnowCount * 100).round();
}

@RealmModel()
class _FlashcardSet {
  @MapTo('_id')
  @PrimaryKey()
  late ObjectId id;

  late String name;
  late String? description;

  late String? color;

  late List<_Tags> tags;
  late List<_Flashcard> cards;

  @MapTo('is_public')
  late bool isPublic;

  late DateTime? lastStudyDate;
  late int studyCount = 0;

  /// Users can save sets made by other users to learn them,
  /// these properties are reference to the original set and its user,
  late _FlashcardSet? originalSet;
  late _Users? originalOwner;

  late _Users? owner;
  @MapTo("owner_id")
  late String ownerId;

  late int reportCount = 0;
  late _ReportMessage? lastReport;
  late bool blocked = false;

  late int likes = 0;

  int get popularity => likes - (reportCount * 5);

  // 0 is default => show the front guess the back
  // 1 => show the back guess the front
  // 2 => randomly show the front or the back
  // 3 => let the spaced repetition algorithm decide
  late int sideToGuess = 3;

  // 0 => always study all the cards
  // 1 is default => use the Leitner and spaced repetition algorithms to decide what to cards to study in a set
  // 1+ => always study the cards in the corresponding box and under
  late int studyMethod = 1;

  // don't end the study session until all the user got all the cards right
  // keep showing the cards the user got wrong until he gets the right
  late bool repeatUntilKnown = false;

  // 0 => the current box of the card will not be updated no matter the result
  // 1 is default => increase (correct answer) or decrease (wrong answer) the current box by 2
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

  late String name;
  late String email;
  late String about;
  late String avatar;

  late List<_FlashcardSet> likedSets;
  late List<_FlashcardSet> reportedSets;

  late _Inbox? inbox;

  late int role;

  late bool blocked = false;
  
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
  late List<_Message> sendMessages; // moderator & admin only
  late List<_ReportMessage> reports; // moderator & admin only
}

@RealmModel()
class _Message {
  @MapTo('_id')
  @PrimaryKey()
  late ObjectId messageId;

  late String title;
  late String message;

  late int icon;

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

@RealmModel()
class _ReportMessage {
  @MapTo('_id')
  @PrimaryKey()
  late ObjectId reportMessageId;

  late int setReportCount; // the set report count at that moment
  late List<String> reasons; // the user reason for the report
  late String additionalInformation; // the additional information provided by the user reporting the set

  late int moderatorChoice; // the action the moderator decided to make
  late String moderatorAdditionalInformation; // the explanation of the moderator decision

  late _ReportMessage? previousReport;
  late _FlashcardSet? reportedSet;
  late _Users? reportedUser;
  late _Users? reportingUser;

  late DateTime reportDate;

  late bool resolved = false; // action taken
}