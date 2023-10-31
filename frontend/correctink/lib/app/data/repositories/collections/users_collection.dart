import 'dart:async';

import 'package:correctink/utils/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:realm/realm.dart';

import '../../models/schemas.dart';
import '../realm_services.dart';

class UserService with ChangeNotifier {
  static int admin = 10;
  static int moderator = 8;

  final RealmServices _realmServices;
  Realm get realm => _realmServices.realm;
  Users? currentUserData;

  UserService(this._realmServices);

  void tempInboxInit() {
    if(currentUserData!.inbox == null) {
      // create an inbox and get the message pre made about CorrectInk
      Inbox inbox = Inbox(ObjectId());
      realm.write(() => {
        currentUserData!.inbox = inbox,
      });
      sendWelcomeMessage();
    }
  }

  void sendWelcomeMessage() {
    final messages = currentUserData!.realm.query<Message>(r'_id = $0', [ObjectId.fromHexString("652e9f486a2da42b2a051af3")]);

    Message message = messages.first;
    UserMessage userMessage = UserMessage(ObjectId(), message: message);

    realm.write(() => {
      currentUserData!.inbox!.receivedMessages.add(userMessage),
    });
  }

  void _panic(String message) {
    if(kDebugMode) {
      print(message);
    }
    _realmServices.logout();
  }

  /// Make sure the user is correctly logged in and init the inbox the service.
  /// Otherwise the user is logged out (if was logged in) and the realm is closed.
  Future<Users?> initUserData({int retry = 3}) async {
    if(_realmServices.app.app.currentUser == null){ // panic
      _panic("[ERROR] The user is not logged in.");
      return null;
    }

    int nextRetry = retry - 1;
    if(currentUserData != null && currentUserData!.isValid && _realmServices.app.app.currentUser!.profile.email == currentUserData!.email) {
      if(currentUserData!.lastStudySession != null
        && currentUserData!.lastStudySession!.isNotToday()
        && !currentUserData!.lastStudySession!.isYesterday()) {
        realm.write(() => {
          currentUserData!.studyStreak = 0,
        });
      }

      return _initInbox(currentUserData!);
    }

    // try to get from the database
    currentUserData = realm.query<Users>(r'_id = $0', [ObjectId.fromHexString(_realmServices.app.app.currentUser!.id)]).firstOrNull;
    if(currentUserData != null) {
      return _initInbox(currentUserData!);
    }

    // max try number reached,
    if(retry == 0) {
      if(_realmServices.app.currentUserData != null) {
        // to make sure the user is not in the database
        // only register him after trying to get the data from the database 3 times
        //
        // The user data should not be registered here.
        // Normally this register function is only called in main.dart after the "registered" property of the AppServices is set to true when
        // the "ChangeNotifierProxyProvider" call the "update" callback (which also init the realm when the user is logged in)
        currentUserData = await registerUserData(userData: _realmServices.app.currentUserData);
        if(currentUserData != null) { // should not be null but just in case...
          if (kDebugMode) {
            print("[WARNING] The user data was registered in the getCurrentUser() function !");
          }
          return _initInbox(currentUserData!);
        }
      }

      _panic("[ERROR] The user data can't be fetched nor registered.");
      return null;
    }

    return initUserData(retry: nextRetry);
  }

  Users _initInbox(Users userData) {
    if(userData.inbox == null) {
      tempInboxInit();
    }

    notifyListeners();
    return userData;
  }

  Users? get(ObjectId userId) {
    return realm.query<Users>(r'_id == $0', [userId]).first;
  }

  Future<Users?> registerUserData({Users? userData}) async{
    if(userData != null){
      return _registerUserData(userData);
    } else {
      return _registerUserData(currentUserData);
    }
  }

  Future<Users?> _registerUserData(Users? userData) async{
    if(_realmServices.app.app.currentUser == null) {
      _realmServices.logout();
    } else if(userData == null){
      if (kDebugMode) {
        print("EROR: The user data is null!");
      }
      return null;
    }

    realm.write(() => {
      realm.add<Users>(userData!),
    });

    currentUserData = userData;
    _realmServices.wait(false);
    Timer(
      const Duration(seconds: 2),
      sendWelcomeMessage,
    );
    return userData;
  }

  Future<bool> updateUserData(Users? user, String firstname, String lastname, String about) async {
    if(user == null || !user.isValid) return false;

    realm.write(() => {
      user.firstname = firstname,
      user.lastname = lastname,
      user.about = about,
    });

    notifyListeners();
    return true;
  }

  Future<bool> updateStudyStreak() async {
    if(currentUserData == null) await initUserData();

    if(currentUserData != null){ // if null the realm is closed and the user logged out
      if(currentUserData!.lastStudySession == null){ // 1st session ever
        realm.write(() => {
          currentUserData!.studyStreak = 1,
          currentUserData!.lastStudySession = DateTime.now().toUtc()
        });
      } else if(currentUserData!.lastStudySession!.isNotToday()){ // no session today yet
        if(currentUserData!.lastStudySession!.isYesterday()){ // last session was yesterday
          realm.write(() => {
            currentUserData!.studyStreak++,
            currentUserData!.lastStudySession = DateTime.now().toUtc()
          });
          return true;
        } else { // missed 1 or more days
          realm.write(() => {
            currentUserData!.studyStreak = 1,
            currentUserData!.lastStudySession = DateTime.now().toUtc()
          });
        }
      } else { // already had a session today but still update last study session date time
        realm.write(() => {
          currentUserData!.lastStudySession = DateTime.now().toUtc(),
        });
      }
    }
    return false;
  }

  void addReportedSet(CardSet set) {
    realm.writeAsync(() {
      currentUserData!.reportedSets.add(set);
    });
  }

  void likeSet(CardSet set, bool like) {
    realm.writeAsync(() {
      if(like) {
        currentUserData!.likedSets.add(set);
      } else {
        currentUserData!.likedSets.removeWhere((s) => s.id == set.id);
      }
    });
  }

  void deleteCurrentUserAccount(){
    realm.delete(currentUserData!);
  }
}