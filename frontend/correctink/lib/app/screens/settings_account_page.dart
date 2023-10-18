import 'dart:async';

import 'package:correctink/utils/delete_helper.dart';
import 'package:correctink/widgets/snackbars_widgets.dart';
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
  late StreamSubscription stream;
  late bool init = false;

  late TextEditingController _firstnameController;
  late TextEditingController _lastnameController;

  @override
  void initState() {
    _firstnameController = TextEditingController();
    _lastnameController = TextEditingController();
    super.initState();
  }

  @override
  void didChangeDependencies() async {
    realmServices = Provider.of<RealmServices>(context);
    appServices = Provider.of<AppServices>(context);

    user ??= appServices.currentUserData;
    if(user == null){
      final currentUser = await realmServices.userService.initUserData();
      setState(() {
        user = currentUser;
      });
    }

    if(!init){
      _firstnameController.text = user?.firstname?? '';
      _lastnameController.text = user?.lastname?? '';

      stream = user!.changes.listen((event) {
        setState(() {
          user = event.object;
        });
      });
    }

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    stream.cancel();
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
        title: Text('Settings account'.i18n(), style: Theme.of(context).textTheme.headlineSmall,),
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
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: elevatedButton(context,
                            child: Text("Update".i18n()),
                            background: Theme.of(context).colorScheme.primaryContainer,
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                            onPressed: () => updateUser(context, _firstnameController.text, _lastnameController.text)
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: elevatedButton(context,
                        child: Text("Delete Account".i18n()),
                        background: Theme.of(context).colorScheme.error,
                        color: Theme.of(context).colorScheme.onError,
                        onPressed: () => DeleteUtils.deleteAccount(context, realmServices),
                    ),
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

    if((firstname.isNotEmpty && firstname != user?.firstname) || (lastname.isNotEmpty && lastname != user?.lastname)) {
       if(!await realmServices.userService.updateUserData(realmServices.userService.currentUserData, firstname, lastname)){
         setState(() {
           _errorMessage = 'Error update account'.i18n();
         });
       } else {
         setState(() {
           _successMessage = "Account updated".i18n();
         });
       }
    } else if(firstname.isEmpty || lastname.isEmpty){
      _errorMessage = "Error name empty".i18n();
    }

    if(mounted){
      if(_errorMessage != null && _errorMessage!.isNotEmpty){
        errorMessageSnackBar(context, "Error".i18n(), _errorMessage!).show(context);
      }
      if(_successMessage != null && _successMessage!.isNotEmpty){
        infoMessageSnackBar(context, _successMessage!).show(context);
      }
    }
  }
}

