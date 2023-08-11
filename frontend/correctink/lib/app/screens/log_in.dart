import 'package:correctink/widgets/snackbars_widgets.dart';
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
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  @override
  void initState() {
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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

  void _logInUser(BuildContext context, String email, String password) async {
    final appServices = Provider.of<AppServices>(context, listen: false);
    try {
      await appServices.logInUserEmailPassword(email, password);
      if(context.mounted) GoRouter.of(context).go(RouterHelper.taskLibraryRoute);
    } catch (err) {
      errorMessageSnackBar(context,"Error".i18n(),  "Error credential".i18n()).show(context);
    }
  }
}
