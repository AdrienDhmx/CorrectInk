import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:realm/realm.dart';

import '../app_services.dart';
import '../models/schemas.dart';
import 'collections/card_collection.dart';
import 'collections/set_collection.dart';
import 'collections/task_collection.dart';
import 'collections/todo_collection.dart';
import 'collections/users_collection.dart';

class RealmServices with ChangeNotifier {
  static const String queryMyTasks = "getMyTasksSubscription";
  static const String queryMyTodos = "getMyTodosSubscription";
  static const String queryMySetsAndPublicSets = "getMySetsAndPublicSets";
  static const String queryCard = "getCardsSubscription";
  static const String queryUsers = "getUsersSubscription";

  bool offlineModeOn = false;
  bool isWaiting = false;
  late Realm realm;
  late TaskCollection taskCollection;
  late TodoCollection todoCollection;
  late SetCollection setCollection;
  late CardCollection cardCollection;
  late UsersCollection usersCollection;
  User? currentUser;
  AppServices app;

  RealmServices(this.app, this.offlineModeOn) {
   init();
  }

  void init(){
    if (app.app.currentUser != null || currentUser != app.app.currentUser) {
      // get connected user
      currentUser ??= app.app.currentUser;

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

      initSubscriptions();
      // get the custom data of the user
      usersCollection.getCurrentUser();
    }
  }

  Future<void> initSubscriptions() async {
    realm.subscriptions.update((mutableSubscriptions) {
      mutableSubscriptions.clear();

      mutableSubscriptions.add(realm.query<Users>(r"TRUEPREDICATE"), name: queryUsers);
      mutableSubscriptions.add(realm.query<CardSet>(r'owner_id == $0 OR is_public == true', [currentUser?.id]),name: queryMySetsAndPublicSets);
      mutableSubscriptions.add(realm.query<KeyValueCard>(r"TRUEPREDICATE"), name: queryCard);
      mutableSubscriptions.add(realm.query<Task>(r'owner_id == $0', [currentUser?.id]),name: queryMyTasks);
      mutableSubscriptions.add(realm.query<TaskStep>(r'TRUEPREDICATE'),name: queryMyTodos);
    });
  }

  Future<void> toggleSyncSession() async{
    if (kDebugMode) {
      print('offline mode changed: $offlineModeOn');
    }
    await changeSyncSession(offlineModeOn);
  }

  Future<void> changeSyncSession(bool connected) async{
    // pause the sync with the cloud until the user goes back online
    if (!connected) {
      realm.syncSession.pause();
    } else {
      try {
        isWaiting = true;
        notifyListeners();

        // Avoid waiting more than 2 seconds if the sync session can't be resumed
        // If it can't be resumed then the user goes in offline mode
        Timer(const Duration(seconds: 2), (){
          if(isWaiting) {
            offlineModeOn = true;
            isWaiting = false;
            notifyListeners();
          }
        });

        // try to resume the sync with the cloud
        realm.syncSession.resume();
      } finally {
        // sync session is resumed
        isWaiting = false;
      }
    }

    offlineModeOn = !connected;
    notifyListeners();
  }

  void logout() {
    app.logOut();
    currentUser = null;
    usersCollection.currentUserData = null;
    close();
  }

  Future<void> close() async {
    if (currentUser != null) {
      await app.logOut();
      currentUser = null;
    }
    realm.close();
  }

  @override
  void dispose() {
    realm.close();
    usersCollection.dispose();
    taskCollection.dispose();
    todoCollection.dispose();
    setCollection.dispose();
    cardCollection.dispose();
    super.dispose();
  }
}
