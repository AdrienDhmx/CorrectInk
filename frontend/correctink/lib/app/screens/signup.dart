import 'package:easy_stepper/easy_stepper.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:localization/localization.dart';
import 'package:provider/provider.dart';

import '../../utils/router_helper.dart';
import '../../widgets/snackbars_widgets.dart';
import '../../widgets/widgets.dart';
import '../data/app_services.dart';

class _PasswordRequirement {
  final String requirement;
  late bool done = false;
  
  _PasswordRequirement(this.requirement);
}

class Signup extends StatefulWidget{
  const Signup({super.key});

  @override
  State<StatefulWidget> createState() => _Signup();
}

class _Signup extends State<Signup> {
  late List<_PasswordRequirement> requirements = <_PasswordRequirement>[
    _PasswordRequirement("password requirement min char"),
    _PasswordRequirement("password requirement lower char"),
    _PasswordRequirement("password requirement upper char"),
    _PasswordRequirement("password requirement special char"),
    _PasswordRequirement("password requirement digit"),
  ];
  
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _passwordConfirmationController;
  late TextEditingController _firstnameController;
  late TextEditingController _lastnameController;

  late int currentStep = 1;
  late bool passwordWeak = false;

  @override
  void initState() {
    _emailController = TextEditingController();
    _passwordController = TextEditingController()..addListener(() {checkPasswordRequirements();});
    _passwordConfirmationController = TextEditingController();
    _firstnameController = TextEditingController(); 
    _lastnameController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmationController.dispose();
    _firstnameController.dispose();
    _lastnameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SingleChildScrollView(
        child: Form(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 40,20,20),
            child: Align(
              alignment: Alignment.center,
              child: Container(
                constraints: const BoxConstraints(minWidth: 250, maxWidth: 1000),
                child: LayoutBuilder(
                  builder: (context, constraint) {
                    return Column(
                      children: [
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
                          loginField(_passwordController, labelText: "Password".i18n(), hintText: "Password hint".i18n(), obscure: true),
                          loginField(_passwordConfirmationController, labelText: "Password confirmation".i18n(), hintText: "Password confirmation hint".i18n(), obscure: true),
                          styledBox(context,
                            borderRadius: 6,
                            width: constraint.maxWidth * 0.7,
                            borderColor: passwordWeak ? theme.error : null,
                            showBorder: passwordWeak,
                            child: Column(
                              children: [
                                for(_PasswordRequirement requirement in requirements)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2),
                                    child: Row(
                                      children: [
                                        Text(String.fromCharCode(Icons.check_rounded.codePoint),
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight:  requirement.done ? FontWeight.w800 : null,
                                            fontFamily: Icons.check_rounded.fontFamily,
                                            color: requirement.done ? Theme.of(context).colorScheme.primary : null,
                                          ),
                                        ),
                                        const SizedBox(width: 4,),
                                        Flexible(
                                          child: Text(requirement.requirement.i18n(),
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: requirement.done ? Theme.of(context).colorScheme.primary : null,
                                              fontWeight: requirement.done ? FontWeight.w600 : null,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                              ],
                            )
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              elevatedButton(context,
                                  child: Text('Previous'.i18n()),
                                  onPressed: () => {
                                    setState(() => currentStep--)
                                  },
                                width: constraint.maxWidth * 0.4
                              ),
                              elevatedButton(context,
                                  child: Text('Signup'.i18n()),
                                  onPressed: () => _signUpUser(),
                                  width: constraint.maxWidth * 0.5,
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

  void checkPasswordRequirements() {
    setState(() {
      requirements[0].done = _passwordController.text.length >= 8;
      requirements[1].done = RegExp(r'[a-z]').hasMatch(_passwordController.text); // lower case
      requirements[2].done = RegExp(r'[A-Z]').hasMatch(_passwordController.text); // upper case
      requirements[3].done = RegExp(r'[^\w\s]').hasMatch(_passwordController.text); // special char
      requirements[4].done = RegExp(r'[1-9]').hasMatch(_passwordController.text); // digit

      if(passwordWeak && !requirements.any((requirement) => !requirement.done)){
        setState(() {
          passwordWeak = false;
        });
      }
    });

  }
  
  _signUpUser() async {
    if(requirements.any((requirement) => !requirement.done)){
      setState(() {
        passwordWeak = true;
      });
      errorMessageSnackBar(context,"Error".i18n(),  "Error password weak".i18n()).show(context);
      return;
    }

    if(_passwordController.text != _passwordConfirmationController.text){
      errorMessageSnackBar(context,"Error".i18n(),  "Error password not equal".i18n()).show(context);
      return;
    }

    final appServices = Provider.of<AppServices>(context, listen: false);
    try {
      await appServices.registerUserEmailPassword(_emailController.text, _passwordController.text, _firstnameController.text, _lastnameController.text);
      if(context.mounted) GoRouter.of(context).go(RouterHelper.taskLibraryRoute);
    } catch (err) {
      errorMessageSnackBar(context,"Error".i18n(),  "Error credential".i18n()).show(context);
    }
  }
}