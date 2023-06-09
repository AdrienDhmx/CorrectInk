import 'package:flutter/material.dart';
import 'package:correctink/components/widgets.dart';
import 'package:correctink/theme.dart';
import 'package:localization/localization.dart';
import 'package:provider/provider.dart';

import '../realm/realm_services.dart';

class CreateSetAction extends StatelessWidget{
  const CreateSetAction({super.key});

  @override
  Widget build(BuildContext context) {
    return styledFloatingButton(context,
        tooltip: 'Create set'.i18n(),
        onPressed: () => showModalBottomSheet(
          isScrollControlled: true,
          context: context,
          builder: (_) => Wrap(children: const [CreateSetForm()]),
        ));
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
  int selectedColorIndex = 0;
  bool isPublic = false;

  @override
  void initState() {
    _setNameEditingController = TextEditingController();
    _setDescriptionEditingController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _setNameEditingController.dispose();
    _setDescriptionEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    TextTheme theme = Theme.of(context).textTheme;
    return formLayout(
            context,
            Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text("Create set".i18n(), style: theme.titleLarge),
                  TextFormField(
                    autofocus: true,
                    controller: _setNameEditingController,
                    validator: (value) => (value ?? "").isEmpty ? "Set name hint".i18n() : null,
                    decoration: InputDecoration(
                        labelText: 'Name'.i18n()
                    ),
                  ),
                  TextFormField(
                    controller: _setDescriptionEditingController,
                    decoration: InputDecoration(
                        labelText: "Description optional".i18n()
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: SizedBox(
                            width: 30,
                            height: 30,
                            child: ElevatedButton(
                                onPressed: () => setState(() {
                                  selectedColorIndex = 0;
                                }),
                                style: ButtonStyle(
                                   backgroundColor: MaterialStatePropertyAll<Color>(Theme.of(context).colorScheme.onBackground),
                                  shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                                    borderRadius: const BorderRadius.all(Radius.circular(15.0)),
                                    side: selectedColorIndex == 0 ? BorderSide(color: Theme.of(context).colorScheme.background, width: 2.0) : BorderSide.none,
                                  )),
                                ),
                                child: const SizedBox(
                                  width: 20,
                                  height: 20,
                                ),

                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: SizedBox(
                            width: 30,
                            height: 30,
                            child: ElevatedButton(
                              onPressed: () => setState(() {
                                selectedColorIndex = 1;
                              }),
                              style: ButtonStyle(
                                backgroundColor: MaterialStatePropertyAll<Color>(ThemeProvider.setColors[0]),
                                shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                                  borderRadius: const BorderRadius.all(Radius.circular(15.0)),
                                  side: selectedColorIndex == 1 ? BorderSide(color: Theme.of(context).colorScheme.onBackground, width: 2.0) : BorderSide.none,
                                )),
                              ),
                              child: const SizedBox(
                                width: 20,
                                height: 20,
                              ),

                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: SizedBox(
                            width: 30,
                            height: 30,
                            child: ElevatedButton(
                              onPressed: () => setState(() {
                                selectedColorIndex = 2;
                              }),
                              style: ButtonStyle(
                                backgroundColor: MaterialStatePropertyAll<Color>(ThemeProvider.setColors[1]),
                                shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                                  borderRadius: const BorderRadius.all(Radius.circular(15.0)),
                                  side: selectedColorIndex == 2 ? BorderSide(color: Theme.of(context).colorScheme.onBackground, width: 2.0) : BorderSide.none,
                                )),
                              ),
                              child: const SizedBox(
                                width: 20,
                                height: 20,
                              ),

                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: SizedBox(
                            width: 30,
                            height: 30,
                            child: ElevatedButton(
                              onPressed: () => setState(() {
                                selectedColorIndex = 3;
                              }),
                              style: ButtonStyle(
                                backgroundColor: MaterialStatePropertyAll<Color>(ThemeProvider.setColors[2]),

                                shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                                  borderRadius: const BorderRadius.all(Radius.circular(15.0)),
                                  side: selectedColorIndex == 3 ? BorderSide(color: Theme.of(context).colorScheme.onBackground, width: 2.0) : BorderSide.none,
                                )),
                              ),
                              child: const SizedBox(
                                width: 20,
                                height: 20,
                              ),

                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: SizedBox(
                            width: 30,
                            height: 30,
                            child: ElevatedButton(
                              onPressed: () => setState(() {
                                selectedColorIndex = 4;
                              }),
                              style: ButtonStyle(
                                backgroundColor: MaterialStatePropertyAll<Color>(ThemeProvider.setColors[3]),

                                shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                                  borderRadius: const BorderRadius.all(Radius.circular(15.0)),
                                  side: selectedColorIndex == 4 ? BorderSide(color: Theme.of(context).colorScheme.onBackground, width: 2.0) : BorderSide.none,
                                )),
                              ),
                              child: const SizedBox(
                                width: 20,
                                height: 20,
                              ),

                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: SizedBox(
                            width: 30,
                            height: 30,
                            child: ElevatedButton(
                              onPressed: () => setState(() {
                                selectedColorIndex = 5;
                              }),
                              style: ButtonStyle(
                                backgroundColor: MaterialStatePropertyAll<Color>(ThemeProvider.setColors[4]),
                                shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                                  borderRadius:const BorderRadius.all(Radius.circular(15.0)),
                                  side: selectedColorIndex == 5 ? BorderSide(color: Theme.of(context).colorScheme.onBackground, width: 2.0) : BorderSide.none,
                                  ),
                                ),
                              ),
                              child: const SizedBox(
                                width: 20,
                                height: 20,
                              ),

                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: SizedBox(
                            width: 30,
                            height: 30,
                            child: ElevatedButton(
                              onPressed: () => setState(() {
                                selectedColorIndex = 6;
                              }),
                              style: ButtonStyle(
                                backgroundColor: MaterialStatePropertyAll<Color>(ThemeProvider.setColors[5]),
                                shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                                  borderRadius: const BorderRadius.all(Radius.circular(15.0)),
                                  side: selectedColorIndex == 6 ? BorderSide(color: Theme.of(context).colorScheme.onBackground, width: 2.0) : BorderSide.none,
                                )),
                              ),
                              child: const SizedBox(
                                width: 20,
                                height: 20,
                              ),

                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
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
      realmServices.setCollection.create(name, description, isPublic, selectedColorIndex == 0 ? null : ThemeProvider.setColors[selectedColorIndex - 1].toHex());
      Navigator.pop(context);
    }
  }
}
