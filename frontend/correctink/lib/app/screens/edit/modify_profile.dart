import 'dart:async';

import 'package:correctink/app/data/repositories/collections/users_collection.dart';
import 'package:flutter/material.dart';
import 'package:correctink/widgets/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:localization/localization.dart';

import '../../../widgets/buttons.dart';
import '../../data/models/schemas.dart';


class ModifyProfileForm extends StatefulWidget {
  final Users user;
  final UserService userService;
  const ModifyProfileForm({Key? key, required this.user, required this.userService}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ModifyProfileForm();
}

class _ModifyProfileForm extends State<ModifyProfileForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _aboutController;

  @override
  void initState() {
    _nameController = TextEditingController(text: widget.user.name);
    _aboutController = TextEditingController(text: widget.user.about);

    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _aboutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return modalLayout(
        context,
        Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  controller: _nameController,
                  keyboardType: TextInputType.name,
                  validator: (value) => (value ?? "").isEmpty ? "Firstname hint".i18n() : null,
                  decoration: InputDecoration(
                    labelText: "Firstname".i18n(),
                  ),
                ),
                TextFormField(
                  controller: _aboutController,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  maxLength: 200,
                  decoration: InputDecoration(
                    labelText: "About you".i18n(),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        cancelButton(context),
                        okButton(context, "Update".i18n(),
                            onPressed: () => update(context)),
                      ]
                  ),
                ),
              ],
            )
        )
    );
  }

  void update(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      Timer(
        const Duration(milliseconds: 100), () {
          widget.userService.updateUserData(widget.user, _nameController.text, _aboutController.text);
        },
      );

      GoRouter.of(context).pop();
    }
  }
}