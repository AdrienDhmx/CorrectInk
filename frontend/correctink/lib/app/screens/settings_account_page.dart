import 'package:flutter/material.dart';
import 'package:localization/localization.dart';
import 'package:provider/provider.dart';

import '../../widgets/widgets.dart';
import '../data/app_services.dart';
import '../data/models/schemas.dart';
import '../data/repositories/realm_services.dart';

class SettingsAccountPage extends StatefulWidget {
  const SettingsAccountPage({super.key});

  @override
  State<StatefulWidget> createState() => _SettingsAccountPage();

}

class _SettingsAccountPage extends State<SettingsAccountPage> {
  String? _errorMessage;
  String? _successMessage;

  late RealmServices realmServices;
  late AppServices appServices;
  Users? user;

  late bool init = false;

  late TextEditingController _firstnameController;
  late TextEditingController _lastnameController;

  @override
  void initState() {
    _firstnameController = TextEditingController()..addListener(clearMessages);
    _lastnameController = TextEditingController()..addListener(clearMessages);
    super.initState();
  }

  @override
  void didChangeDependencies() async {
    realmServices = Provider.of<RealmServices>(context);
    appServices = Provider.of<AppServices>(context);

    user ??= appServices.currentUserData;
    if(user == null){
      final currentUser = await realmServices.usersCollection.getCurrentUser();
      setState(() {
        user = currentUser;
      });
    } else if(user!.isValid){
      user!.freeze();
    }

    if(!init){
      _firstnameController.text = user?.firstname?? '';
      _lastnameController.text = user?.lastname?? '';
    }

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _firstnameController.dispose();
    _lastnameController.dispose();
    super.dispose();
  }

  void clearMessages() {
    if (_errorMessage != null) {
      setState(() {
        // Reset error message when user starts typing
        _errorMessage = null;
      });
    }

    if(_successMessage != null){
      setState(() {
        // Reset error message when user starts typing
        _successMessage = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
        shadowColor: Theme.of(context).colorScheme.shadow,
        surfaceTintColor: Theme.of(context).colorScheme.primary,
        automaticallyImplyLeading: false,
        titleSpacing: 4,
        leading: backButton(context),
        title: Text('Settings account'.i18n(), style: Theme.of(context).textTheme.headlineMedium,),
      ),
      body: Container(
        padding: const EdgeInsets.all(25),
          child: Form(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  loginField(_firstnameController, labelText: "Firstname".i18n(), hintText: "Firstname hint".i18n()),
                  loginField(_lastnameController, labelText: "Lastname".i18n(), hintText: "Lastname hint".i18n()),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: loginButton(context,
                        child: Text("Update".i18n()),
                        onPressed: () => updateUser(context, _firstnameController.text, _lastnameController.text)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(_errorMessage ?? "",
                        style: errorTextStyle(context),
                        textAlign: TextAlign.center),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(_successMessage ?? "",
                        style: infoTextStyle(context),
                        textAlign: TextAlign.center),
                  ),
                ],
              )
            )
          )
      )
    );
  }

  Future<void> updateUser(BuildContext context, String firstname, String lastname) async {
    clearMessages();

    if(firstname.isNotEmpty && firstname != user?.firstname && lastname.isNotEmpty && lastname != user?.lastname) {
       if(!await realmServices.usersCollection.updateUserData(realmServices.usersCollection.currentUserData, firstname, lastname)){
         setState(() {
           _errorMessage = 'Error update account'.i18n();
         });
       } else {
         setState(() {
           _successMessage = "Account updated".i18n();
         });
       }
    } else if(lastname.isNotEmpty && lastname != user?.lastname){
      if(!await realmServices.usersCollection.updateUserData(realmServices.usersCollection.currentUserData, firstname, lastname)){
        setState(() {
          _errorMessage = "Error update lastname".i18n();
        });
      } else {
        setState(() {
          _successMessage = 'Lastname updated'.i18n();
        });
      }
    } else if(firstname.isNotEmpty && firstname != user?.firstname) {
      if(!await realmServices.usersCollection.updateUserData(realmServices.usersCollection.currentUserData, firstname, lastname)) {
        setState(() {
          _errorMessage = "Error update firstname".i18n();
        });
      } else {
        setState(() {
          _successMessage = 'Firstname updated'.i18n();
        });
      }
    }
  }
}

