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

  Future<void> sessionSwitch() async{
    if (kDebugMode) {
      print('offline mode changed: $offlineModeOn');
    }
    await changeSession(offlineModeOn);
  }

  Future<void> changeSession(bool connected) async{

    if (!connected) {
      realm.syncSession.pause();

    } else {
      try {
        isWaiting = true;
        notifyListeners();

        Timer(const Duration(seconds: 2), (){
          if(isWaiting) {
            isWaiting = false;
            notifyListeners();
          }
        });
        realm.syncSession.resume();
      } finally {
        isWaiting = false;
      }
    }
    offlineModeOn = !connected;
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
