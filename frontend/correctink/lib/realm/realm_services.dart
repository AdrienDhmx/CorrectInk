import 'dart:async';

import 'package:correctink/realm/schemas.dart';
import 'package:flutter/foundation.dart';
import 'package:realm/realm.dart';

class RealmServices with ChangeNotifier {
  static const String queryMyTasks = "getMyTasksSubscription";
  static const String queryAllSets = "getAllSetsSubscription";
  static const String queryMySets = "getMySetsSubscription";
  static const String queryCard = "getCardsSubscription";
  static const String queryUsers = "getUsersSubscription";

  bool showAllSets = false;
  bool offlineModeOn = false;
  bool isWaiting = false;
  late Realm realm;
  User? currentUser;
  App app;

  RealmServices(this.app, this.offlineModeOn) {
    if (app.currentUser != null || currentUser != app.currentUser) {
      currentUser ??= app.currentUser;
      realm = Realm(Configuration.flexibleSync(currentUser!, [Task.schema, CardSet.schema, KeyValueCard.schema, Users.schema]));

      if(offlineModeOn) realm.syncSession.pause();

      showAllSets = (realm.subscriptions.findByName(queryAllSets) != null);

      updateSubscriptions();
    }
  }

  Future<void> initSubscriptions() async{
    realm.subscriptions.update((mutableSubscriptions) {
      mutableSubscriptions.add(realm.query<KeyValueCard>("TRUEPREDICATE"), name: queryCard);
      mutableSubscriptions.add(realm.query<Users>("TRUEPREDICATE"), name: queryUsers);
      mutableSubscriptions.add(realm.query<Task>(r'owner_id == $0', [currentUser?.id]),name: queryMyTasks);

      if(showAllSets){
        mutableSubscriptions.add(realm.query<CardSet>(r'is_public == true'), name: queryAllSets);
      }else{
        mutableSubscriptions.add(
            realm.query<CardSet>(r'owner_id == $0', [currentUser?.id]),
            name: queryMySets);
      }
    });
  }

  Future<void> updateSubscriptions() async {
    realm.subscriptions.update((mutableSubscriptions) {
      // remove current set subscription
      if(!mutableSubscriptions.removeByName(queryMySets)){
        mutableSubscriptions.removeByName(queryAllSets);
      }

      if(showAllSets) {
        mutableSubscriptions.add(realm.query<CardSet>(r'is_public == true'), name: queryAllSets);
      } else {
        mutableSubscriptions.add(realm.query<CardSet>(r'owner_id == $0', [currentUser?.id]),name: queryMySets);
      }
    });
    if(!realm.isClosed) await realm.subscriptions.waitForSynchronization();
  }

  void sessionSwitch() {
    changeSession(offlineModeOn);
  }

  Future<void> changeSession(bool connected) async{
    offlineModeOn = !connected;

    if (offlineModeOn) {
      realm.syncSession.pause();
    } else {
      try {
        isWaiting = true;
        notifyListeners();
        realm.syncSession.resume();
        await updateSubscriptions();
      } finally {
        isWaiting = false;
      }
    }
    notifyListeners();
  }

  Future<void> switchSetSubscription(bool value) async {
    showAllSets = value;
    if (!offlineModeOn) {
      try {
        isWaiting = true;
        notifyListeners();
        await updateSubscriptions();
      } finally {
        isWaiting = false;
      }
    }
    notifyListeners();
  }

  Future<Users?> getOtherUserData(ObjectId userId) async {
    return realm.query<Users>(r'_id == $0', [userId]).first;
  }

  Future<ObjectId> getSetOwnerId(CardSet set) async {
    if(set.originalSetId == null){
      throw Exception('The set original id is null');
    }

    String userId = realm.query<CardSet>(r'_id == $0', [set.originalSetId]).first.ownerId;

    return ObjectId.fromHexString(userId);
  }

  void createTask(String summary, bool isComplete, DateTime? deadline) {
    final newTask =
      Task(ObjectId(), summary, currentUser!.id, isComplete: isComplete, deadline: deadline?.add(const Duration(hours: 2)));
    realm.write<Task>(() => realm.add<Task>(newTask));
    notifyListeners();
  }

  void deleteTask(Task item) {
    realm.write(() => realm.delete(item));
    notifyListeners();
  }

  Future<void> updateTask(Task task,
      {String? summary, bool? isComplete, DateTime? deadline}) async {
    realm.write(() {
      if (summary != null) {
        task.task = summary;
      }
      if (isComplete != null) {
        task.isComplete = isComplete;
      }
      if (deadline != null) {
        task.deadline = deadline;
      }
    });
    notifyListeners();
  }

  void createSet(String name, String description, bool isPublic, String? color){
    final newSet = CardSet(ObjectId(), name, isPublic, currentUser!.id, description: description, color: color, originalSetId: null);
    realm.write<CardSet>(() => realm.add<CardSet>(newSet));
    notifyListeners();
  }

  void deleteSet(CardSet set) {
    ObjectId id = set.id;
    realm.write(() => realm.delete(set));

    final cards = getKeyValueCards(id.hexString);
    for(var card in cards){
      deleteKeyValueCard(card);
    }

    notifyListeners();
  }

  void deleteSetAsync(CardSet set){
    Timer(const Duration(seconds: 1),() {deleteSet(set);});
  }

  Future<void> updateSet(CardSet set,
      { String? name, String? description, bool? isPublic, String? color }) async{
    realm.write(() {
      if(name != null){
        set.name = name;
      }
      if(description != null){
        set.description = description;
      }
      if(isPublic != null){
        set.isPublic = isPublic;
      }
      set.color = color;
    });
    notifyListeners();
  }

  CardSet? getSet(String id){
    return realm.query<CardSet>(r'_id == $0', [ObjectId.fromHexString(id)]).first;
  }

  void createCard(String key, String value, ObjectId setId){
    final newCard = KeyValueCard(ObjectId(), key, value, setId);
    realm.write<KeyValueCard>(() => realm.add<KeyValueCard>(newCard));
    notifyListeners();
  }

  List<KeyValueCard> getKeyValueCards(String setId){
    return realm.query<KeyValueCard>(r'set_id == $0', [ObjectId.fromHexString(setId)]).toList();
  }

  Future<void> updateKeyValueCard(KeyValueCard card,
      { String? key, String? value, DateTime? lastSeen, int? learningProgress }) async{
    realm.write(() {
      if(key != null){
        card.key = key;
      }
      if(value != null){
        card.value = value;
      }
      if(lastSeen != null){
        card.lastSeen = lastSeen;
      }
      if(learningProgress != null){
        card.learningProgress = learningProgress;
      }
    });
    notifyListeners();
  }

  void deleteKeyValueCard(KeyValueCard card){
    realm.write(() => realm.delete(card));
    notifyListeners();
  }

  Future<void> close() async {
    if (currentUser != null) {
      await currentUser?.logOut();
      currentUser = null;
    }
    realm.close();
  }


  @override
  void dispose() {
    realm.close();
    super.dispose();
  }
}
