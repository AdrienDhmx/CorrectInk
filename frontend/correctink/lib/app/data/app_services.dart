import 'package:flutter/foundation.dart';
import 'package:realm/realm.dart';

import 'models/schemas.dart';

class AppServices with ChangeNotifier {
  String id;
  Uri baseUrl;
  late App app;
  Users? currentUserData;
  bool loggedIn = false;
  bool registered = false;

  AppServices(this.id, this.baseUrl){
    app = App(AppConfiguration(id, baseUrl: baseUrl));
  }

  Future<User> logInUserEmailPassword(String email, String password) async {
    User loggedInUser = await app.logIn(Credentials.emailPassword(email, password));
    loggedIn = true;
    notifyListeners();
    return loggedInUser;
  }

  Future<User> registerUserEmailPassword(String email, String password, String username) async {
    EmailPasswordAuthProvider authProvider = EmailPasswordAuthProvider(app);
    await authProvider.registerUser(email, password);
    User loggedInUser =  await app.logIn(Credentials.emailPassword(email, password));

    Inbox inbox = Inbox(ObjectId());
    currentUserData = Users(ObjectId.fromHexString(loggedInUser.id), username, email, '', username, 0, 0, inbox: inbox);
    registered = true;

    notifyListeners();
    return loggedInUser;
  }

  Future<void> deleteAccount() async {
    if(app.currentUser != null) {
      await app.deleteUser(app.currentUser!);
    }
  }

  Future<void> logOut() async {
    await app.currentUser?.logOut();
    currentUserData = null;
    loggedIn = false;
    registered = false;
  }
}
