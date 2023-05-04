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

  @MapTo('owner_id')
  late String ownerId;
}

@RealmModel()
class _KeyValueCard{
  @MapTo('_id')
  @PrimaryKey()
  late ObjectId id;

  late String key;
  late String value;

  late DateTime? lastSeen;
  late int learningProgress = 0;

  @MapTo('set_id')
  late ObjectId setId;
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

  @MapTo('creation_date')
  late DateTime creationDate;

  @MapTo('owner_id')
  late String ownerId;
}
