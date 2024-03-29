import 'package:correctink/app/data/repositories/collections/users_collection.dart';
import 'package:flutter/material.dart';
import 'package:correctink/widgets/widgets.dart';
import 'package:localization/localization.dart';
import 'package:provider/provider.dart';

import '../../../widgets/buttons.dart';
import '../../data/repositories/realm_services.dart';
import '../../services/theme.dart';


class CreateSetAction extends StatelessWidget{
  const CreateSetAction({super.key});

  @override
  Widget build(BuildContext context) {
    return styledFloatingButton(context,
        tooltip: 'Create set'.i18n(),
        onPressed: () => showBottomSheetModal(context, const CreateSetForm())
    );
  }
}

class CreateSetForm extends StatefulWidget {
  const CreateSetForm({Key? key}) : super(key: key);

  @override
  createState() => _CreateSetFormState();
}

class _CreateSetFormState extends State<CreateSetForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _setNameEditingController;
  late TextEditingController _setDescriptionEditingController;
  int selectedColorIndex = ThemeProvider.setColors.length;
  bool isPublic = false;
  late UserService userService;

  @override
  void initState() {
    _setNameEditingController = TextEditingController();
    _setDescriptionEditingController = TextEditingController();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    userService = Provider.of(context);
  }

  @override
  void dispose() {
    _setNameEditingController.dispose();
    _setDescriptionEditingController.dispose();
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
                    autofocus: true,
                    controller: _setNameEditingController,
                    validator: (value) => (value ?? "").isEmpty ? "Set name hint".i18n() : null,
                    maxLength: 50,
                    decoration: InputDecoration(
                        labelText: 'Name'.i18n()
                    ),
                  ),
                  TextFormField(
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                    maxLines: null,
                    maxLength: 300,
                    controller: _setDescriptionEditingController,
                    decoration: InputDecoration(
                        labelText: "Description optional".i18n()
                    ),
                  ),
                  setColorsPicker(
                      context: context,
                      selectedIndex: selectedColorIndex,
                      onPressed: (index) {
                        if(index == 0){
                          index = ThemeProvider.setColors.length;
                        } else {
                          index = index - 1;
                        }

                        setState(() {
                          selectedColorIndex = index;
                        });
                      }
                  ),
                  if(!userService.currentUserData!.blocked)
                    labeledAction(
                      context: context,
                      child: Switch(
                          value: isPublic,
                          onChanged: (value) {
                            setState(() {
                              isPublic = value;
                            });
                          },
                        ),
                        label: 'Public',
                      center: true,
                      width: 150
                      ),
                  Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        cancelButton(context),
                        Consumer<RealmServices>(builder: (context, realmServices, child) {
                          return okButton(context, "Create".i18n(), onPressed: () => save(realmServices, context));
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            )
        );
  }

  void save(RealmServices realmServices, BuildContext context) {
    if (_formKey.currentState!.validate()) {
      final name = _setNameEditingController.text;
      final description = _setDescriptionEditingController.text;
      realmServices.setCollection.create(name, description, isPublic,  selectedColorIndex ==  ThemeProvider.setColors.length ? null : ThemeProvider.setColors[selectedColorIndex].toHex());
      Navigator.pop(context);
    }
  }
}
