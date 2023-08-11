import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:correctink/main.dart';
import 'package:localization/localization.dart';
import 'package:provider/provider.dart';

import '../../widgets/widgets.dart';
import '../data/app_services.dart';


class LogIn extends StatefulWidget {
  const LogIn({super.key});

  @override
  State<StatefulWidget> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  bool _isLogin = true;
  String? _errorMessage;

  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _firstnameController;
  late TextEditingController _lastnameController;


  @override
  void initState() {
    _emailController = TextEditingController()..addListener(clearError);
    _passwordController = TextEditingController()..addListener(clearError);
    _firstnameController = TextEditingController()..addListener(clearError);
    _lastnameController = TextEditingController()..addListener(clearError);
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _firstnameController.dispose();
    _lastnameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Align(
            alignment: Alignment.center,
            child: Container(
              constraints: const BoxConstraints(minWidth: 250, maxWidth: 1000),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Login'.i18n(), style: Theme.of(context).textTheme.headlineLarge),
                  const SizedBox(height: 20,),
                  loginField(_emailController, labelText: "Email".i18n(), hintText: "Email login hint".i18n()),
                  loginField(_passwordController, labelText: "Password".i18n(), hintText: "Password login hint".i18n(), obscure: true),
                  elevatedButton(context,
                      child: Text('Login'.i18n()),
                      onPressed: () => _logInUser(context,_emailController.text, _passwordController.text),
                      background: Theme.of(context).colorScheme.primaryContainer
                  ),
                  linkButton(context,
                      text: 'Login hint'.i18n(),
                    onPressed: () {
                      GoRouter.of(context).go(RouterHelper.signupRoute);
                    }
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void clearError() {
    if (_errorMessage != null) {
      setState(() {
        // Reset error message when user starts typing
        _errorMessage = null;
      });
    }
  }

  void _logInOrSignUpUser(BuildContext context, String email, String password, String firstname, String lastname) async {
    final appServices = Provider.of<AppServices>(context, listen: false);
    clearError();
    try {
      if (_isLogin) {
        await appServices.logInUserEmailPassword(email, password);
      } else {
        await appServices.registerUserEmailPassword(email, password, firstname, lastname);
      }
      if(context.mounted) GoRouter.of(context).push(RouterHelper.taskLibraryRoute);
    } catch (err) {
      setState(() {
        _errorMessage = "Error credential".i18n();
      });
    }
  }
}
