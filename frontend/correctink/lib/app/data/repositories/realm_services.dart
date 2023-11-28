import 'dart:async';
import 'dart:io';

import 'package:correctink/app/data/repositories/collections/users_collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:realm/realm.dart';

import '../app_services.dart';
import '../models/schemas.dart';
import 'collections/card_collection.dart';
import 'collections/set_collection.dart';
import 'collections/task_collection.dart';
import 'collections/todo_collection.dart';

class RealmServices with ChangeNotifier {
  static const String queryMyTasks = "getMyTasksSubscription";
  static const String queryMyTodos = "getMyTodosSubscription";
  static const String queryMySetsAndPublicSets = "getMySetsAndPublicSets";
  static const String queryCard = "getCardsSubscription";
  static const String queryCardSide = "getCardSidesSubscription";
  static const String queryUsers = "getUsersSubscription";

  bool loggedOut = false;
  bool offlineModeOn = false;
  bool isWaiting = false;
  late Realm realm;
  late TaskCollection taskCollection;
  late TodoCollection todoCollection;
  late SetCollection setCollection;
  late CardCollection cardCollection;

  late UserService userService;

  AppServices app;
  User? get currentUser => app.app.currentUser;

  RealmServices(this.app, this.offlineModeOn) {
   init();
  }

  void init(){
    if (app.app.currentUser != null || currentUser != app.app.currentUser) {

      // init realm
      realm = Realm(Configuration.flexibleSync(currentUser!,
          [Task.schema, TaskStep.schema, FlashcardSet.schema,
            Flashcard.schema, Tags.schema, Users.schema, CardSide.schema,
            Inbox.schema, UserMessage.schema, Message.schema, ReportMessage.schema],
          syncErrorHandler: (error) {
            if (kDebugMode) {
              print(error);
            }
          },
          clientResetHandler: const RecoverOrDiscardUnsyncedChangesHandler(),
      ));

      // init collections crud
      taskCollection = TaskCollection(this);
      todoCollection = TodoCollection(this);
      setCollection = SetCollection(this);
      cardCollection = CardCollection(this);
      // userService = UserService(this);

      // check connection status
      if(offlineModeOn) realm.syncSession.pause();

      initSubscriptions();

      // the user logged out and logged back in, potentially with a different account
      if(loggedOut) {
        loggedOut = false;
        userService.init();
      }
    }
  }

  Future<void> initSubscriptions() async {
    realm.subscriptions.update((mutableSubscriptions) {
      mutableSubscriptions.clear();

      mutableSubscriptions.add(realm.query<Users>(r"TRUEPREDICATE"), name: queryUsers);
      mutableSubscriptions.add(realm.query<FlashcardSet>(r'owner_id == $0 OR is_public == true', [currentUser?.id]), name: queryMySetsAndPublicSets);
      mutableSubscriptions.add(realm.query<Flashcard>(r"TRUEPREDICATE"), name: queryCard);
      mutableSubscriptions.add(realm.query<CardSide>(r"TRUEPREDICATE"), name: queryCardSide);
      mutableSubscriptions.add(realm.query<Task>(r'owner_id == $0', [currentUser?.id]),name: queryMyTasks);
      mutableSubscriptions.add(realm.query<TaskStep>(r'TRUEPREDICATE'),name: queryMyTodos);

      mutableSubscriptions.add(realm.query<Inbox>(r'TRUEPREDICATE'),name: "queryInboxes");
      mutableSubscriptions.add(realm.query<Message>(r'TRUEPREDICATE'),name: "queryMessages");
      mutableSubscriptions.add(realm.query<UserMessage>(r'TRUEPREDICATE'),name: "queryUserMessages");
      mutableSubscriptions.add(realm.query<ReportMessage>(r'TRUEPREDICATE'),name: "queryReportMessages");
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
        wait(true);

        // Avoid waiting more than 2 seconds if the sync session can't be resumed
        // If it can't be resumed then the user goes in offline mode
        Timer(const Duration(seconds: 2), (){
          if(isWaiting) {
            offlineModeOn = true;
            wait(false);
          }
        });

        // try to resume the sync
        realm.syncSession.resume();
      } finally {
        wait(false);
      }
    }

    offlineModeOn = !connected;
    notifyListeners();
  }

  void wait(bool wait) {
    isWaiting = wait;
    notifyListeners();
  }

  /// log the user out of the realm
  void logout() {
    app.logOut();
    loggedOut = true;
  }

  void deleteAccount() async {
    // delete all user data => tasks, sets, cards...
    await _deleteAllUserData();

    // delete all local data
    final path = realm.config.path;
    realm.close();

    // give some time for the process to release the file and allow its deletion
    Timer(const Duration(milliseconds: 500), () {
      File localRealm = File(path);
      localRealm.delete();

      app.deleteAccount();

      if(kDebugMode){
        print("ACCOUNT DELETED !");
      }
    });
  }

  Future<void> _deleteAllUserData() async {
      List<Task> tasks = await taskCollection.getAll();
      List<FlashcardSet> sets = await setCollection.getAll(app.app.currentUser!.id.toString());

      realm.write(() => {
        realm.deleteMany(tasks),
        realm.deleteMany(sets),
        userService.deleteCurrentUserAccount(),
      });
  }

  Future<void> close() async {
    if (currentUser != null) {
      await app.logOut();
    }
    realm.close();
  }

  @override
  void dispose() {
    realm.close();
    taskCollection.dispose();
    todoCollection.dispose();
    setCollection.dispose();
    cardCollection.dispose();
    userService.dispose();
    super.dispose();
  }
}
