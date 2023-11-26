import 'package:correctink/blocs/password_form.dart';
import 'package:easy_stepper/easy_stepper.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:localization/localization.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../utils/router_helper.dart';
import '../../widgets/buttons.dart';
import '../../widgets/snackbars_widgets.dart';
import '../../widgets/widgets.dart';
import '../data/app_services.dart';

class Signup extends StatefulWidget{
  const Signup({super.key});

  @override
  State<StatefulWidget> createState() => _Signup();
}

class _Signup extends State<Signup> {
  late TextEditingController _emailController;
  late TextEditingController _firstnameController;
  late TextEditingController _lastnameController;

  TapGestureRecognizer? termsOfServicesTapRecognizer;
  TapGestureRecognizer? privacyPolicyTapRecognizer;

  late int currentStep = 1;
  late bool isPasswordValid = false;
  late bool isPasswordEqual = false;
  late String password = "";
  late bool agreedToTerms = false;
  late bool agreedToTermsError = false;

  @override
  void initState() {
    _emailController = TextEditingController();
    _firstnameController = TextEditingController(); 
    _lastnameController = TextEditingController();

    termsOfServicesTapRecognizer = TapGestureRecognizer()..onTap = goToTermsOfServices;
    privacyPolicyTapRecognizer = TapGestureRecognizer()..onTap = goToPrivacyPolicy;

    super.initState();
  }

  void goToTermsOfServices() {
    launchUrl(Uri.parse("https://correctink-web.vercel.app/terms"));
  }

  void goToPrivacyPolicy() {
    launchUrl(Uri.parse("https://correctink-web.vercel.app/privacy"));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _firstnameController.dispose();
    _lastnameController.dispose();

    termsOfServicesTapRecognizer?.dispose();
    privacyPolicyTapRecognizer?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Form(
          child: Align(
            alignment: Alignment.center,
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                constraints: const BoxConstraints(minWidth: 250, maxWidth: 1000),
                child: LayoutBuilder(
                  builder: (context, constraint) {
                    return Column(
                      children: [
                        const SizedBox(height: 20,),
                        Text('Signup'.i18n(), style: Theme.of(context).textTheme.headlineLarge),
                        const SizedBox(height: 20,),
                        EasyStepper(activeStep: currentStep,
                          showLoadingAnimation: false,
                          lineLength: constraint.maxWidth * 0.2,
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
                              title: 'Email',
                            ),
                            EasyStep(
                              customStep: Container(
                              ),
                              title: 'Password',
                            ),
                          ],

                        ),
                        if(currentStep == 1)...[
                          loginField(_firstnameController, labelText: "Firstname".i18n(), hintText: "Firstname hint".i18n()),
                          loginField(_lastnameController, labelText: "Lastname".i18n(), hintText: "Lastname hint".i18n()),
                          loginField(_emailController, labelText: "Email".i18n(), hintText: "Email hint".i18n()),
                          elevatedButton(context,
                              child: Text('Next'.i18n()),
                              onPressed: () => {
                                setState(() => checkEmailInformation())
                              }
                          ),
                        ]
                        else...[
                          PasswordForm(onPasswordChanged: (valid, equal, newPassword) => {
                            setState(() => {
                              isPasswordValid = valid,
                              isPasswordEqual = equal,
                              password = newPassword,
                            })
                          }),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                            child: Material(
                              color: !agreedToTerms && agreedToTermsError ? Theme.of(context).colorScheme.error.withAlpha(20) : Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: InkWell(
                                onTap: () => setState(() {
                                  agreedToTerms = !agreedToTerms;
                                }),
                                borderRadius: BorderRadius.circular(4),
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(4, 4, 10, 4),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children:[
                                      Checkbox(
                                        value: agreedToTerms,
                                        onChanged: (value) => setState(() {
                                          agreedToTerms = value ?? false;
                                        }),
                                        isError: !agreedToTerms && agreedToTermsError,
                                      ),
                                      const SizedBox(width: 8,),
                                      Flexible(
                                        child: RichText(
                                          text: TextSpan(
                                              style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onBackground),
                                              children: [
                                                TextSpan(text:"I've read and agree with".i18n()),
                                                TextSpan(
                                                  text: "Terms of services".i18n(),
                                                  style: TextStyle(color: Theme.of(context).colorScheme.primary),
                                                  recognizer: termsOfServicesTapRecognizer,
                                                ),
                                                TextSpan(text:" and ".i18n()),
                                                TextSpan(
                                                  text: "Privacy policy".i18n(),
                                                  style: TextStyle(color: Theme.of(context).colorScheme.primary),
                                                  recognizer: privacyPolicyTapRecognizer,
                                                ),
                                              ]
                                          ),
                                        ),
                                      ),
                                    ]
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              elevatedButton(context,
                                  child: Text('Previous'.i18n()),
                                  onPressed: () => {
                                    setState(() => currentStep--)
                                  },
                                width: constraint.maxWidth * 0.35 < 200 ? constraint.maxWidth * 0.4 :  constraint.maxWidth * 0.35
                              ),
                              elevatedButton(context,
                                  child: Text('Signup'.i18n()),
                                  onPressed: () => _signUpUser(),
                                  width: constraint.maxWidth * 0.55,
                                background: Theme.of(context).colorScheme.primaryContainer
                              ),
                            ],
                          )
                        ],
                        linkButton(context,
                            text: 'Sign up hint'.i18n(),
                            onPressed: () {
                                GoRouter.of(context).go(RouterHelper.loginRoute);
                            }
                        ),
                        const SizedBox(height: 20,),
                      ],
                    );
                  }
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  checkEmailInformation() {
    if(_firstnameController.text.isEmpty || _lastnameController.text.isEmpty){
      errorMessageSnackBar(context, "Error".i18n(), "Error name empty".i18n()).show(context);
      return;
    }

    if(!RegExp(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b').hasMatch(_emailController.text)) {
      errorMessageSnackBar(context, "Error".i18n(), "Error email invalid".i18n()).show(context);
      return;
    }

    currentStep++;
  }
  
  _signUpUser() async {
    if(!isPasswordValid){
      errorMessageSnackBar(context,"Error".i18n(),  "Error password weak".i18n()).show(context);
      return;
    } else if(!isPasswordEqual) {
      errorMessageSnackBar(context,"Error".i18n(),  "Error password not equal".i18n()).show(context);
      return;
    }

    if(!agreedToTerms) {
      setState(() {
        agreedToTermsError = true;
      });
      return;
    }

    final appServices = Provider.of<AppServices>(context, listen: false);
    try {
      await appServices.registerUserEmailPassword(_emailController.text, password, _firstnameController.text, _lastnameController.text);
      if(context.mounted) GoRouter.of(context).go(RouterHelper.taskLibraryRoute);
    } catch (err) {
      if(mounted) {
        errorMessageSnackBar(context,"Error".i18n(),  "Error signup".i18n()).show(context);
      }
    }
  }
}