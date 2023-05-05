import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:correctink/main.dart';
import 'package:provider/provider.dart';
import '../components/widgets.dart';
import '../realm/realm_services.dart';
import '../realm/schemas.dart';
import '../theme.dart';

void modifySet(BuildContext context, CardSet set, RealmServices realmServices){
  bool isMine = (set.ownerId == realmServices.currentUser?.id);
  if (isMine) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Wrap(children: [ModifySetForm(set)]),
    );
  } else {
    errorMessageSnackBar(context, "Edit not allowed!",
        "You are not allowed to edit sets \nthat don't belong to you.")
        .show(context);
  }
}

class ModifySetForm extends StatefulWidget {
  final CardSet set;
  const ModifySetForm(this.set, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ModifySetFormState();
}

class _ModifySetFormState extends State<ModifySetForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  int selectedColorIndex = 0;
  late bool isPublic;

  _ModifySetFormState();

  @override
  void initState() {
    _nameController = TextEditingController(text: widget.set.name);
    _descriptionController = TextEditingController(text: widget.set.description);

    selectedColorIndex = widget.set.color != null ? ThemeProvider.setColors.indexOf(HexColor.fromHex(widget.set.color!)) + 1: 0;
    isPublic = widget.set.isPublic;
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    TextTheme myTextTheme = Theme.of(context).textTheme;
    final realmServices = Provider.of<RealmServices>(context, listen: false);
    return formLayout(
        context,
        Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text("Update your set", style: myTextTheme.titleLarge),
                TextFormField(
                  controller: _nameController,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  validator: (value) => (value ?? "").isEmpty ? "Please enter a name for your set" : null,
                  decoration: const InputDecoration(
                    labelText: "Name",
                  ),
                ),
                TextFormField(
                  controller: _descriptionController,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  decoration: const InputDecoration(
                    labelText: "Description (optional)",
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
                        deleteButton(context, onPressed: () => delete(realmServices, widget.set, context)),
                        okButton(context, "Update",
                            onPressed: () async => await update(context, realmServices, widget.set, _nameController.text, _descriptionController.text)),
                      ]
                  ),
                ),
              ],
            )
        ));
  }

  Future<void> update(BuildContext context, RealmServices realmServices, CardSet set, String name, String? description) async {
    if (_formKey.currentState!.validate()) {
      await realmServices.updateSet(set, name: name, description: description, isPublic: isPublic, color: selectedColorIndex == 0 ? null : ThemeProvider.setColors[selectedColorIndex - 1].toHex());
      if(context.mounted) Navigator.pop(context);
    }
  }

  void delete(RealmServices realmServices, CardSet set, BuildContext context) {
    GoRouter.of(context).push(RouterHelper.setLibraryRoute);
    realmServices.deleteSetAsync(set);
  }
}