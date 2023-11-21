import 'dart:convert';

import 'package:correctink/blocs/password_form.dart';
import 'package:correctink/widgets/countdown_timer.dart';
import 'package:correctink/widgets/snackbars_widgets.dart';
import 'package:easy_stepper/easy_stepper.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:localization/localization.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../../utils/router_helper.dart';
import '../../widgets/buttons.dart';
import '../../widgets/widgets.dart';
import '../data/app_services.dart';


class ResetPassword extends StatefulWidget {
  const ResetPassword({super.key});

  @override
  State<StatefulWidget> createState() => _ResetPassword();
}

class _ResetPassword extends State<ResetPassword> {
  late TextEditingController _emailController;
  late TextEditingController _confirmCodeController;
  late String password = "";
  late bool isPasswordStrong = false;
  late bool passwordEqual = false;
  late int currentStep = 1;

  late int confirmCode = -1;
  late bool askConfirmCode = false;
  late bool waiting = false;

  @override
  void initState() {
    _emailController = TextEditingController();
    _confirmCodeController = TextEditingController()..addListener(() {
      if(int.tryParse(_confirmCodeController.text) == confirmCode) {
        setState(() {
          currentStep = 2;
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _confirmCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Form(
          child: Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Container(
                      constraints: const BoxConstraints(minWidth: 250, maxWidth: 1000),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 20,),
                          Text('Reset your password'.i18n(), style: Theme.of(context).textTheme.headlineLarge),
                          const SizedBox(height: 20,),
                          EasyStepper(activeStep: currentStep,
                            showLoadingAnimation: false,
                            lineLength: MediaQuery.of(context).size.width * 0.4,
                            lineSpace: 2,
                            lineType: LineType.normal,
                            defaultLineColor: theme.onBackground.withAlpha(160),
                            finishedLineColor: theme.primary,
                            activeStepTextColor: theme.primary,
                            finishedStepTextColor: theme.primary,
                            internalPadding: 0,
                            stepRadius: 16,
                            showStepBorder: true,
                            borderThickness: 3,
                            enableStepTapping: false,
                            steps: [
                              EasyStep(
                                customStep: Container(
                                ),
                                title: 'Email confirmation'.i18n(),
                              ),
                              EasyStep(
                                customStep: Container(
                                ),
                                title: 'Password reset'.i18n(),
                              ),
                            ],
                          ),
                          if(currentStep == 1) ... [
                            if(!askConfirmCode)...[
                              loginField(_emailController, labelText: "Email".i18n(), hintText: "Email reset password hint".i18n()),
                              elevatedButton(context,
                                  child: Text('Send verification code'.i18n()),
                                  onPressed: () => _sendVerificationMail(context, _emailController.text),
                              ),
                            ]
                            else...[
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                child: Text(
                                  "Reset password security code".i18n(),
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.secondary,
                                    fontSize: 16,
                                      fontWeight: FontWeight.w500
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: CountDownTimer(secondsRemaining: 300,
                                  whenTimeExpires: () {
                                    setState(() {
                                      confirmCode = -1;
                                      askConfirmCode = false;
                                      _confirmCodeController.text = "";
                                    });
                                  },
                                  countDownTimerStyle: TextStyle(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontSize: 18.0,
                                    height: 1.2,
                                    fontWeight: FontWeight.w600
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                child: TextFormField(
                                    controller: _confirmCodeController,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      border: const OutlineInputBorder(),
                                      labelText: "Enter the code you received by mail".i18n(),
                                    )
                                ),
                              ),
                              const SizedBox(height: 10,),
                            ]
                          ]
                          else... [
                            PasswordForm(onPasswordChanged: (valid, equal, newPassword) {
                              setState(() {
                                isPasswordStrong = valid;
                                passwordEqual = equal;
                                password = newPassword;
                              });
                            }),
                            elevatedButton(context,
                                child: Text('Reset password'.i18n()),
                                onPressed: () => resetPassword(_emailController.text),
                                background: Theme.of(context).colorScheme.primaryContainer
                            ),
                          ],
                          Wrap(
                            spacing: 10,
                            alignment: WrapAlignment.center,
                            children: [
                              linkButton(context,
                                  text: 'Login hint'.i18n(),
                                  onPressed: () {
                                    GoRouter.of(context).go(RouterHelper.signupRoute);
                                  }
                              ),
                              linkButton(context,
                                  text: 'Sign up hint'.i18n(),
                                  onPressed: () {
                                    GoRouter.of(context).go(RouterHelper.loginRoute);
                                  }
                              ),
                            ],
                          ),
                          const SizedBox(height: 20,),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if(waiting)
                waitingIndicator(),
            ],
          ),
        ),
      ),
    );
  }

  void _sendVerificationMail(BuildContext context, String email) async {
    if(!RegExp(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b').hasMatch(_emailController.text)) {
      errorMessageSnackBar(context, "Error".i18n(), "Error email invalid".i18n()).show(context);
      return;
    }

    try {
      setState(() {
        waiting = true;
      });
      final response = await http.post(
          Uri.parse("https://correctink-web.vercel.app/api/reset-password"),
          body: jsonEncode({"email": email}),
        );

      if(response.statusCode == 200) {
          final resultBody = jsonDecode(response.body) as Map<String, dynamic>;
          setState(() {
            askConfirmCode = true;
            confirmCode = resultBody.values.first;
            waiting = false;
          });
          return;
      } else {
        if(context.mounted) {
          errorMessageSnackBar(context,"Error".i18n(),  response.body).show(context);
        }
      }
    } catch (err) {
      if(context.mounted) {
        errorMessageSnackBar(context,"Error".i18n(),  "The mail could not be send, verify your email address and try again.").show(context);
      }
    }
    setState(() {
      waiting = false;
    });
  }

  void resetPassword(String email) async {
    if(!isPasswordStrong){
      errorMessageSnackBar(context,"Error".i18n(),  "Error password weak".i18n()).show(context);
      return;
    } else if(!passwordEqual) {
      errorMessageSnackBar(context,"Error".i18n(),  "Error password not equal".i18n()).show(context);
      return;
    }

    final appServices = Provider.of<AppServices>(context, listen: false);
    try{
      await appServices.app.emailPasswordAuthProvider.callResetPasswordFunction(email, password);
      if(context.mounted) {
        GoRouter.of(context).go(RouterHelper.loginRoute);
        successMessageSnackBar(context, "Password changed!", icon: Icons.done_rounded, description: "You can now login to your account with this new password.").show(context);
      }
    } catch(error) {
      if(mounted) {
        errorMessageSnackBar(context,"Error".i18n(), "Your email is not linked to an account.").show(context);
      }
      setState(() {
        askConfirmCode = false;
        confirmCode = -1;
        currentStep = 1;
        passwordEqual = false;
        password = "";
        isPasswordStrong = false;
        _confirmCodeController.text = "";
      });
    }
  }
}
