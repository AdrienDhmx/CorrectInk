import 'package:flutter/material.dart';
import 'package:key_card/components/widgets.dart';
import 'package:provider/provider.dart';

import '../realm/realm_services.dart';
import '../realm/schemas.dart';

class ModifyTaskForm extends StatefulWidget {
  final Task item;
  const ModifyTaskForm(this.item, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ModifyTaskFormState();
}

class _ModifyTaskFormState extends State<ModifyTaskForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _summaryController;
  late ValueNotifier<bool> _isCompleteController;

  _ModifyTaskFormState();

  @override
  void initState() {
    _summaryController = TextEditingController(text: widget.item.summary);
    _isCompleteController = ValueNotifier<bool>(widget.item.isComplete)..addListener(() => setState(() {}));

    super.initState();
  }

  @override
  void dispose() {
    _summaryController.dispose();
    _isCompleteController.dispose();
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
                Text("Update your task", style: myTextTheme.titleLarge),
                TextFormField(
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  controller: _summaryController,
                  validator: (value) => (value ?? "").isEmpty ? "Please enter some text" : null,
                  decoration: const InputDecoration(
                    labelText: "Task",
                  ),
                ),
                StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
                  return Column(
                    children: <Widget>[
                      radioButton("Complete", true, _isCompleteController),
                      radioButton("Incomplete", false, _isCompleteController),
                    ],
                  );
                }),
                Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      cancelButton(context),
                      deleteButton(context, onPressed: () => delete(realmServices, widget.item, context)),
                      okButton(context, "Update",
                          onPressed: () async => await update(context, realmServices, widget.item, _summaryController.text, _isCompleteController.value)),
                    ],
                  ),
                ),
              ],
            )));
  }

  Future<void> update(BuildContext context, RealmServices realmServices, Task item, String summary, bool isComplete) async {
    if (_formKey.currentState!.validate()) {
      await realmServices.updateItem(item, summary: summary, isComplete: isComplete);
      if(context.mounted) Navigator.pop(context);
    }
  }

  void delete(RealmServices realmServices, Task item, BuildContext context) {
    realmServices.deleteItem(item);
    Navigator.pop(context);
  }
}
