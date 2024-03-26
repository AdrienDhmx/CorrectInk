import 'package:flutter/material.dart';
import 'package:localization/localization.dart';

import '../widgets/widgets.dart';

class _PasswordRequirement {
  final String requirement;
  late bool done = false;

  _PasswordRequirement(this.requirement);
}

class PasswordForm extends StatefulWidget {
  final Function(bool, bool, String) onPasswordChanged;

  const PasswordForm({super.key, required this.onPasswordChanged});

  @override
  State<StatefulWidget> createState()  => _PasswordForm();
}

class _PasswordForm extends State<PasswordForm> {
  late List<_PasswordRequirement> requirements = <_PasswordRequirement>[
    _PasswordRequirement("password requirement min char"),
    _PasswordRequirement("password requirement lower char"),
    _PasswordRequirement("password requirement upper char"),
    _PasswordRequirement("password requirement special char"),
    _PasswordRequirement("password requirement digit"),
  ];

  late TextEditingController _passwordController;
  late TextEditingController _passwordConfirmationController;

  @override
  void initState() {
    _passwordController = TextEditingController()..addListener(() {checkPasswordRequirements();});
    _passwordConfirmationController = TextEditingController()..addListener(() {checkPasswordEquality();});
    super.initState();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _passwordConfirmationController.dispose();
    super.dispose();
  }

  void checkPasswordRequirements() {
    setState(() {
      requirements[0].done = _passwordController.text.length >= 8;
      requirements[1].done = RegExp(r'[a-z]').hasMatch(_passwordController.text); // lower case
      requirements[2].done = RegExp(r'[A-Z]').hasMatch(_passwordController.text); // upper case
      requirements[3].done = RegExp(r'[^\w\s]').hasMatch(_passwordController.text); // special char
      requirements[4].done = RegExp(r'[1-9]').hasMatch(_passwordController.text); // digit
    });

    widget.onPasswordChanged(!requirements.any((requirement) => !requirement.done), _passwordController.text.trim() == _passwordConfirmationController.text.trim(), _passwordController.text.trim());
  }

  void checkPasswordEquality() {
    widget.onPasswordChanged(!requirements.any((requirement) => !requirement.done), _passwordController.text.trim() == _passwordConfirmationController.text.trim(), _passwordController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        loginField(_passwordController, labelText: "Password".i18n(), hintText: "Password hint".i18n(), obscure: true),
        loginField(_passwordConfirmationController, labelText: "Password confirmation".i18n(), hintText: "Password confirmation hint".i18n(), obscure: true),
        styledBox(context,
            borderRadius: 6,
            width: 400,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
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
      ],
    );
  }

}