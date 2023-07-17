import 'package:correctink/realm/schemas.dart';
import 'package:flutter/material.dart';
import 'package:localization/localization.dart';
import 'package:provider/provider.dart';

import '../components/widgets.dart';
import '../realm/realm_services.dart';

class ModifyTodoForm extends StatefulWidget {
  final TaskStep todo;
  const ModifyTodoForm(this.todo, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ModifyTodoFormState();
}

class _ModifyTodoFormState extends State<ModifyTodoForm> {
  final _formKey = GlobalKey<FormState>();
  final completeGroup = <bool>[true, false];
  late  bool isComplete = widget.todo.isComplete;
  late TextEditingController _summaryController;

  @override
  void initState() {
    _summaryController = TextEditingController(text: widget.todo.todo);
    super.initState();
  }

  @override
  void dispose() {
    _summaryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    TextTheme myTextTheme = Theme.of(context).textTheme;
    final realmServices = Provider.of<RealmServices>(context, listen: false);
    return modalLayout(
        context,
        Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text("Update step".i18n(), style: myTextTheme.titleLarge),
                TextFormField(
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  controller: _summaryController,
                  validator: (value) => (value ?? "").isEmpty ? "Step name hint".i18n() : null,
                  decoration: InputDecoration(
                    labelText: "Step".i18n(),
                  ),
                ),
                const SizedBox(height: 8,),
                Wrap(
                  children: [
                    labeledAction(
                      context: context,
                      child: Radio<bool>(
                        value: true,
                        groupValue: isComplete,
                        onChanged: (bool? value) {
                          setState(() {
                            isComplete = value ?? false;
                          });
                        },
                      ),
                      label: 'Complete'.i18n(),
                      onTapAction: () {
                        setState(() {
                          isComplete = true;
                        });
                      },
                      width: 130,
                      labelFirst: false,
                    ),
                    labeledAction(
                      context: context,
                      child: Radio<bool>(
                        value: false,
                        groupValue: isComplete,
                        onChanged: (bool? value){
                          setState(() {
                            isComplete = value ?? false;
                          });
                        },
                      ),
                      label: 'Incomplete'.i18n(),
                      onTapAction: () {
                        setState(() {
                          isComplete = false;
                        });
                      },
                      width: 140,
                      labelFirst: false,
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      cancelButton(context),
                      deleteButton(context, onPressed: () => delete(realmServices, widget.todo, context)),
                      okButton(context, "Update".i18n(),
                          onPressed: () async => await update(context, realmServices, widget.todo, _summaryController.text, isComplete)),
                    ],
                  ),
                ),
              ],
            )));
  }

  Future<void> update(BuildContext context, RealmServices realmServices, TaskStep todo, String summary, bool isComplete) async {
    if (_formKey.currentState!.validate()) {
      await realmServices.todoCollection.update(todo, summary: summary, isComplete: isComplete);
      if(context.mounted) Navigator.pop(context);
    }
  }

  void delete(RealmServices realmServices, TaskStep todo, BuildContext context) {
    realmServices.todoCollection.delete(todo);
    Navigator.pop(context);
  }
}
