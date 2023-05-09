import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:correctink/main.dart';
import 'package:provider/provider.dart';

import '../components/widgets.dart';
import '../realm/app_services.dart';
import '../theme.dart';

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
      body: Container(
        padding: const EdgeInsets.all(25),
        margin: const EdgeInsets.only(top: 30),
        child: Form(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text(_isLogin ? 'Log In' : 'Sign Up', style: const TextStyle(fontSize: 25)),
                if(!_isLogin) loginField(_firstnameController, labelText: "Firstname", hintText: "Enter your firstname"),
                if(!_isLogin) loginField(_lastnameController, labelText: "Lastname", hintText: "Enter your lastname"),
                loginField(_emailController, labelText: "Email", hintText: "Enter valid email like abc@gmail.com"),
                loginField(_passwordController, labelText: "Password", hintText: "Enter secure password", obscure: true),
                const Padding(
                  padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                  child: Text(
                      "Please login or register a new account.",
                      textAlign: TextAlign.center),
                ),
                loginButton(context,
                    child: Text(
                      _isLogin ? "Log in" : "Sign up"),
                    onPressed: () => _logInOrSignUpUser(context,
                        _emailController.text, _passwordController.text, _firstnameController.text, _lastnameController.text)),
                TextButton(
                    onPressed: () => setState(() => _isLogin = !_isLogin),
                    child: Text(
                      _isLogin ? "New to CorrectInk? Sign up" : 'Already have an account? Log in.',
                    )),
                Padding(
                  padding: const EdgeInsets.all(25),
                  child: Text(_errorMessage ?? "",
                      style: errorTextStyle(context),
                      textAlign: TextAlign.center),
                ),
              ],
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
      if(context.mounted) GoRouter.of(context).push(RouterHelper.taskRoute);
    } catch (err) {
      setState(() {
        _errorMessage = 'Your credentials are not valid! \n error: $err';
      });
    }
  }
}
