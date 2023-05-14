import 'package:correctink/realm/realm_services.dart';
import 'package:correctink/realm/schemas.dart';
import 'package:correctink/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:realm/realm.dart';

class UsersCollection extends ChangeNotifier {
  final RealmServices _realmServices;
  Realm get realm => _realmServices.realm;
  Users? currentUserData;

  UsersCollection(this._realmServices);

  Future<Users?> getCurrentUser({int retry = 3}) async {
    if(currentUserData != null && currentUserData!.isValid) return currentUserData!.freeze();

    if(_realmServices.app.currentUser == null){
      if (kDebugMode) {
        print('[ERROR] The current user is null.');
      }
      return null;
    }

    if(retry == 0) { // max retry reached
      if (kDebugMode) {
        print('[INFO] The user data could not be fetched.');
      }
      return null;
    }

    currentUserData = realm.query<Users>(r'_id = $0', [ObjectId.fromHexString(_realmServices.app.currentUser!.id)]).first;
    return getCurrentUser(retry: retry--);
  }

  Future<Users?> get(ObjectId userId) async {
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
    if(_realmServices.app.currentUser == null){
      throw Exception('[ERROR] The user is not logged in, the data cannot be registered!');
    } else if(userData == null){
      return null;
    }

    //  save custom user data
    if (kDebugMode) {
      print('[INFO] The user data has been registered!');
    }
    return realm.write<Users>(() => realm.add<Users>(userData));
  }

  Future<bool> updateUserData(Users? user, String firstname, lastname) async {
    if(user == null || !user.isValid) return false;

    realm.write(() => {
      user.firstname = firstname,
      user.lastname = lastname,
    });

    return true;
  }

  Future<bool> updateStudyStreak() async {
    if(currentUserData == null) await getCurrentUser();

    if(currentUserData != null){
      if(currentUserData!.lastStudySession == null){ // 1st session ever
        realm.write(() => {
          currentUserData!.studyStreak = 1,
          currentUserData!.lastStudySession = DateTime.now()
        });
      } else if(currentUserData!.lastStudySession!.isNotToday()){ // no session today yet
        if(currentUserData!.lastStudySession!.isYesterday()){ // last session was yesterday
          realm.write(() => {
            currentUserData!.studyStreak++,
            currentUserData!.lastStudySession = DateTime.now()
          });
          return true;
        } else { // missed 1 or more days
          realm.write(() => {
            currentUserData!.studyStreak = 1,
            currentUserData!.lastStudySession = DateTime.now()
          });
        }
      } else { // still update last study session
        realm.write(() => {
          currentUserData!.lastStudySession = DateTime.now(),
        });
      }
    }
    return false;
  }
}