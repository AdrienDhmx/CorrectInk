import 'dart:async';

import 'package:correctink/realm/collections/card_collection.dart';
import 'package:correctink/realm/collections/task_collection.dart';
import 'package:correctink/realm/collections/todo_collection.dart';
import 'package:correctink/realm/schemas.dart';
import 'package:correctink/realm/collections/set_collection.dart';
import 'package:correctink/realm/collections/users_collection.dart';
import 'package:flutter/foundation.dart';
import 'package:realm/realm.dart';


class RealmServices with ChangeNotifier {
  static const String queryMyTasks = "getMyTasksSubscription";
  static const String queryMyTodos = "getMyTodosSubscription";
  static const String queryAllSets = "getAllSetsSubscription";
  static const String queryAllPublicSets = "getAllPublicSetsSubscription";
  static const String queryMySets = "getMySetsSubscription";
  static const String queryCard = "getCardsSubscription";
  static const String queryUsers = "getUsersSubscription";

  bool showAllPublicSets = false;
  String currentSetSubscription = queryMySets;
  bool offlineModeOn = false;
  bool isWaiting = false;
  late Realm realm;
  late TaskCollection taskCollection;
  late TodoCollection todoCollection;
  late SetCollection setCollection;
  late CardCollection cardCollection;
  late UsersCollection usersCollection;
  User? currentUser;
  App app;

  RealmServices(this.app, this.offlineModeOn) {
    if (app.currentUser != null || currentUser != app.currentUser) {
      // get connected user
      currentUser ??= app.currentUser;

      // init realm
      realm = Realm(Configuration.flexibleSync(currentUser!, [Task.schema, TaskStep.schema, CardSet.schema, KeyValueCard.schema, Tags.schema, Users.schema]));

      // init collections crud
      taskCollection = TaskCollection(this);
      todoCollection = TodoCollection(this);
      setCollection = SetCollection(this);
      cardCollection = CardCollection(this);
      usersCollection = UsersCollection(this);

      // check connection status
      if(offlineModeOn) realm.syncSession.pause();

      // init subscriptions
      showAllPublicSets = (realm.subscriptions.findByName(queryAllPublicSets) != null);
      if(showAllPublicSets) currentSetSubscription = queryAllPublicSets;

      initSubscriptions();
    }
  }

  Future<void> initSubscriptions() async {
    realm.subscriptions.update((mutableSubscriptions) {
      mutableSubscriptions.clear();

      mutableSubscriptions.add(realm.query<Users>(r"TRUEPREDICATE"), name: queryUsers);
      mutableSubscriptions.add(realm.query<KeyValueCard>(r"TRUEPREDICATE"), name: queryCard);
      mutableSubscriptions.add(realm.query<Task>(r'owner_id == $0', [currentUser?.id]),name: queryMyTasks);
      mutableSubscriptions.add(realm.query<TaskStep>(r'TRUEPREDICATE'),name: queryMyTodos);
    });
    updateSetSubscriptions(currentSetSubscription);
  }

  Future<void> updateSetSubscriptions(String subscription) async {
    realm.subscriptions.update((mutableSubscriptions) {

      // remove set subscription
      mutableSubscriptions.removeByName(RealmServices.queryMySets);
      mutableSubscriptions.removeByName(RealmServices.queryAllPublicSets);
      mutableSubscriptions.removeByName(RealmServices.queryAllSets);

      if(subscription == queryAllPublicSets) {
        mutableSubscriptions.add(realm.query<CardSet>(r'is_public == true'), name: queryAllPublicSets);
      } else if(subscription == queryMySets){
        mutableSubscriptions.add(realm.query<CardSet>(r'owner_id == $0', [currentUser?.id]),name: queryMySets);
      } else if (subscription == queryAllSets){
        mutableSubscriptions.add(realm.query<CardSet>(r'TRUEPREDICATE'), name: queryAllSets);
      }

      currentSetSubscription = subscription;
      if (kDebugMode) {
        print(currentSetSubscription);
      }
    });
  }

  Future<void> sessionSwitch() async{
    await changeSession(offlineModeOn);
  }

  Future<void> changeSession(bool connected) async{

    if (!connected) {
      await switchSetSubscription(false);
      realm.syncSession.pause();
    } else {
      try {
        isWaiting = true;
        notifyListeners();
        realm.syncSession.resume();
      } finally {
        isWaiting = false;
      }
    }
    offlineModeOn = !connected;
    notifyListeners();
  }

  Future<void> switchSetSubscription(bool showAllPublicSet) async {
    if(offlineModeOn) return;

    showAllPublicSets = showAllPublicSet;
    try {
      isWaiting = true;
      notifyListeners();
      await updateSetSubscriptions(showAllPublicSet ? queryAllPublicSets : queryMySets);
      await realm.subscriptions.waitForSynchronization();
    } finally {
      isWaiting = false;
    }
    notifyListeners();
  }

  Future<void> queryAllSetSubscription() async {
    if(!offlineModeOn) {
      await updateSetSubscriptions(queryAllSets);
      await realm.subscriptions.waitForSynchronization();
    }
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
