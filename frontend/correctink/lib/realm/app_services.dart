import 'package:correctink/realm/schemas.dart';
import 'package:flutter/foundation.dart';
import 'package:realm/realm.dart';

class AppServices with ChangeNotifier {
  String id;
  Uri baseUrl;
  late App app;
  Users? currentUserData;

  bool userDataRegistered = false;

  AppServices(this.id, this.baseUrl){
    app = App(AppConfiguration(id, baseUrl: baseUrl));
  }

  Future<User> logInUserEmailPassword(String email, String password) async {
    User loggedInUser =
        await app.logIn(Credentials.emailPassword(email, password));

    if(app.currentUser != null) {
      // the user is not new
      userDataRegistered = true;
    }

    notifyListeners();
    return loggedInUser;
  }

  Future<Users?> getUserData(Realm realm, {int retry = 3}) async{
    if(currentUserData != null && currentUserData!.isValid) return currentUserData!.freeze();

    if(app.currentUser == null){
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

    currentUserData = realm.query<Users>(r'_id = $0', [ObjectId.fromHexString(app.currentUser!.id)]).first;

    return getUserData(realm, retry: retry--);
  }

  Future<User> registerUserEmailPassword(String email, String password, String firstname, String lastname) async {

    EmailPasswordAuthProvider authProvider = EmailPasswordAuthProvider(app);
    await authProvider.registerUser(email, password);
    User loggedInUser =
        await app.logIn(Credentials.emailPassword(email, password));

    currentUserData = Users(ObjectId.fromHexString(app.currentUser!.id), firstname, lastname, 0);
    userDataRegistered = false;

    notifyListeners();
    return loggedInUser;
  }

  Future<Users?> registerUserData(Realm realm) async{
    if(app.currentUser == null){
      throw Exception('[ERROR] The user is not logged in, the data cannot be registered!');
    } else if(currentUserData == null || userDataRegistered){
      return null;
    }

    //  save custom user data
    if (kDebugMode) {
      print('[INFO] The user data has been registered!');
    }
    userDataRegistered = true;
    return realm.write<Users>(() => realm.add<Users>(currentUserData!));
  }

  Future<bool> updateUserData(Realm realm, Users? user, String firstname, lastname) async {
    if(user == null || !user.isValid) return false;

    realm.write(() => {
      user.firstname = firstname,
      user.lastname = lastname,
    });

    return true;
  }

  Future<void> logOut() async {
    await app.currentUser?.logOut();
    currentUserData = null;
  }
}
