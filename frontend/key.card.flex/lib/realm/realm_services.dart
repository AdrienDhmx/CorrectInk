import 'dart:async';

import 'package:key_card/realm/schemas.dart';
import 'package:realm/realm.dart';
import 'package:flutter/material.dart';

class RealmServices with ChangeNotifier {
  static const String queryAllTasks = "getAllTasksSubscription";
  static const String queryMyTasks = "getMyTasksSubscription";
  static const String queryAllSets = "getAllSetsSubscription";
  static const String queryMySets = "getMySetsSubscription";
  static const String queryCard = "getCardsSubscription";

  bool showAllTasks = false;
  bool showAllSets = false;
  bool offlineModeOn = false;
  bool isWaiting = false;
  late Realm realm;
  User? currentUser;
  App app;

  RealmServices(this.app) {
    if (app.currentUser != null || currentUser != app.currentUser) {
      currentUser ??= app.currentUser;
      realm = Realm(Configuration.flexibleSync(currentUser!, [Task.schema, CardSet.schema, KeyValueCard.schema]));
      showAllTasks = (realm.subscriptions.findByName(queryAllTasks) != null);
      showAllSets = (realm.subscriptions.findByName(queryAllSets) != null);
      updateSubscriptions();
    }
  }

  Future<void> updateSubscriptions() async {
    realm.subscriptions.update((mutableSubscriptions) {
      mutableSubscriptions.clear();
      mutableSubscriptions.add(realm.query<KeyValueCard>("TRUEPREDICATE"), name: queryCard);
      if (showAllTasks) {
        mutableSubscriptions.add(realm.all<Task>(), name: queryAllTasks);
      } else {
        mutableSubscriptions.add(
            realm.query<Task>(r'owner_id == $0', [currentUser?.id]),
            name: queryMyTasks);
      }

      if(showAllSets){
        mutableSubscriptions.add(realm.all<CardSet>(), name: queryAllSets);
      }else{
        mutableSubscriptions.add(
            realm.query<CardSet>(r'owner_id == $0', [currentUser?.id]),
            name: queryMySets);
      }
    });
    await realm.subscriptions.waitForSynchronization();
  }

  Future<void> sessionSwitch() async {
    offlineModeOn = !offlineModeOn;
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

  Future<void> switchTaskSubscription(bool value) async {
    showAllTasks = value;
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

  void createItem(String summary, bool isComplete) {
    final newItem =
    Task(ObjectId(), summary, currentUser!.id, isComplete: isComplete);
    realm.write<Task>(() => realm.add<Task>(newItem));
    notifyListeners();
  }

  void deleteItem(Task item) {
    realm.write(() => realm.delete(item));
    notifyListeners();
  }

  Future<void> updateItem(Task item,
      {String? summary, bool? isComplete}) async {
    realm.write(() {
      if (summary != null) {
        item.summary = summary;
      }
      if (isComplete != null) {
        item.isComplete = isComplete;
      }
    });
    notifyListeners();
  }

  void createSet(String name, String description, String? color){
    final newSet = CardSet(ObjectId(), name, DateTime.now(), currentUser!.id, description: description, color: color);
    realm.write<CardSet>(() => realm.add<CardSet>(newSet));
    notifyListeners();
  }

  void deleteSet(CardSet set) {
    realm.write(() => realm.delete(set));
    notifyListeners();
  }

  void deleteSetAsync(CardSet set){
    Timer(const Duration(seconds: 1),() {deleteSet(set);});
  }

  Future<void> updateSet(CardSet set,
      { String? name, String? description, String? color }) async{
    realm.write(() {
      if(name != null){
        set.name = name;
      }
      if(description != null){
        set.description = description;
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
