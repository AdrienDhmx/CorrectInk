import 'package:flutter/material.dart';
import 'package:correctink/widgets/widgets.dart';
import 'package:localization/localization.dart';
import 'package:objectid/objectid.dart';
import 'package:provider/provider.dart';

import '../../../utils/utils.dart';
import '../../data/repositories/realm_services.dart';


class CreateTodoAction extends StatelessWidget {
  final ObjectId todoId;
  final int index;

  const CreateTodoAction(this.todoId, this.index, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return styledFloatingButton(context,
        tooltip: 'Create step'.i18n(),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(12), bottomRight: Radius.circular(6), bottomLeft: Radius.circular(12))
        ),
        onPressed: () => showModalBottomSheet(
          isScrollControlled: true,
          context: context,
          builder: (_) => Wrap(children: [CreateTodoForm(todoId, index)]),
        ));
  }
}

class CreateTodoForm extends StatefulWidget {
  final ObjectId todoId;
  final int index;

  const CreateTodoForm(this.todoId, this.index, {Key? key}) : super(key: key);

  @override
  createState() => _CreateTodoFormState();
}

class _CreateTodoFormState extends State<CreateTodoForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _stepEditingController;
  late FocusNode _stepTextFieldFocusNode;

  @override
  void initState() {
    _stepEditingController = TextEditingController();
    _stepTextFieldFocusNode = FocusNode();
    _stepTextFieldFocusNode.requestFocus();
    super.initState();
  }

  @override
  void dispose() {
    _stepEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final RealmServices realmServices = Provider.of(context);
    return modalLayout(
        context,
        Form(
          key: _formKey,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Expanded(
                    child: TextFormField(
                      controller: _stepEditingController,
                      focusNode: _stepTextFieldFocusNode,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.done,
                      maxLines: 1,
                      autofocus: true,
                      validator: (value) => (value ?? "").isEmpty ? "Step name hint".i18n() : null,
                      decoration: InputDecoration(
                        labelText: "Step".i18n(),
                      ),
                      onFieldSubmitted: (value) => save(realmServices, context),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 5.0, 0, 0),
                    child: pushButton(context, onTap: () => save(realmServices, context, pop: false),)
                  ),
                ],
              ),
              if(!Utils.isOnPhone())
                Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      cancelButton(context),
                      okButton(context,
                          "Create".i18n(),
                          onPressed: () => save(realmServices, context),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ));
  }

  void save(RealmServices realmServices, BuildContext context, {bool pop = true}) {
    if (_formKey.currentState!.validate()) {
      final summary = _stepEditingController.text;
      final task = realmServices.taskCollection.get(widget.todoId.hexString);
      if(task != null){
        realmServices.taskCollection.addStep(task, summary, false, widget.index);
      }
      if(pop) {
        Navigator.pop(context);
      } else {
        _stepEditingController.text = "";
        _stepTextFieldFocusNode.requestFocus();
      }
    }
  }
}