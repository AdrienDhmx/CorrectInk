import 'package:flutter/material.dart';
import 'package:localization/localization.dart';
import 'package:provider/provider.dart';

import '../../../widgets/buttons.dart';
import '../../../widgets/widgets.dart';
import '../../data/models/schemas.dart';
import '../../data/repositories/realm_services.dart';



class ModifyTodoForm extends StatefulWidget {
  final TaskStep step;
  const ModifyTodoForm(this.step, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ModifyTodoFormState();
}

class _ModifyTodoFormState extends State<ModifyTodoForm> {
  final _formKey = GlobalKey<FormState>();
  final completeGroup = <bool>[true, false];
  late  bool isComplete = widget.step.isComplete;
  late TextEditingController _summaryController;

  @override
  void initState() {
    _summaryController = TextEditingController(text: widget.step.todo);
    super.initState();
  }

  @override
  void dispose() {
    _summaryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final realmServices = Provider.of<RealmServices>(context, listen: false);
    return modalLayout(
        context,
        Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  controller: _summaryController,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.done,
                  maxLines: 1,
                  autofocus: true,
                  validator: (value) => (value ?? "").isEmpty ? "Step name hint".i18n() : null,
                  decoration: InputDecoration(
                    labelText: "Step".i18n(),
                  ),
                  onFieldSubmitted: (value) => update(context, realmServices, widget.step, value, isComplete),
                ),
                const SizedBox(height: 8,),
                Wrap(
                  children: [
                    customRadioButton(context,
                      label: 'Complete'.i18n(),
                      isSelected: isComplete,
                      onPressed: () {
                        setState(() {
                          isComplete = true;
                        });
                      },
                      width: 130,
                    ),
                    customRadioButton(context,
                      label: 'Incomplete'.i18n(),
                      isSelected: !isComplete,
                      onPressed: () {
                        setState(() {
                          isComplete = false;
                        });
                      },
                      width: 140,
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      cancelButton(context),
                      okButton(context,
                          "Update".i18n(),
                          onPressed: () async => await update(context, realmServices, widget.step, _summaryController.text, isComplete)),
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
}
