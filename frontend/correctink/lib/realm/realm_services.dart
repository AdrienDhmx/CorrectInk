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
      realm = Realm(Configuration.flexibleSync(currentUser!, [Task.schema, ToDo.schema, CardSet.schema, KeyValueCard.schema, Users.schema]));

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
      mutableSubscriptions.removeByName(queryAllSets);
      mutableSubscriptions.removeByName(queryMyTodos);

      if(realm.subscriptions.findByName(queryCard) == null) {
        mutableSubscriptions.add(realm.query<KeyValueCard>("TRUEPREDICATE"), name: queryCard);
      }
      if(realm.subscriptions.findByName(queryUsers) == null) {
        mutableSubscriptions.add(realm.query<Users>("TRUEPREDICATE"), name: queryUsers);
      }

      if(realm.subscriptions.findByName(queryMyTasks) == null){
        mutableSubscriptions.add(realm.query<Task>(r'owner_id == $0', [currentUser?.id]),name: queryMyTasks);
      }
      mutableSubscriptions.add(realm.query<ToDo>(r'TRUEPREDICATE'),name: queryMyTodos);
    });
    updateSetSubscriptions(currentSetSubscription);
  }

  Future<void> updateSetSubscriptions(String subscription) async {
    realm.subscriptions.update((mutableSubscriptions) {
      // remove current set subscription
      if(!mutableSubscriptions.removeByName(currentSetSubscription)){
        if (kDebugMode) {
          print('The set subscription could not be removed');
        }
      }

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
    // if(!realm.isClosed) await realm.subscriptions.waitForSynchronization();
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
        await updateSetSubscriptions(offlineModeOn ? queryMySets : currentSetSubscription);
      } finally {
        isWaiting = false;
      }
    }
    notifyListeners();
  }

  Future<void> switchSetSubscription(bool showAllPublicSet) async {
    showAllPublicSets = showAllPublicSet;
    if (!offlineModeOn) {
      try {
        isWaiting = true;
        notifyListeners();
        await updateSetSubscriptions(showAllPublicSet ? queryAllPublicSets : queryMySets);
      } finally {
        isWaiting = false;
      }
    }
    notifyListeners();
  }

  Future<void> queryAllSetSubscription() async {
    if(!offlineModeOn) {
      await updateSetSubscriptions(queryAllSets);
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
