import 'package:flutter/material.dart';
import 'package:correctink/components/widgets.dart';
import 'package:localization/localization.dart';
import 'package:objectid/objectid.dart';
import 'package:provider/provider.dart';

import '../realm/realm_services.dart';

class CreateTodoAction extends StatelessWidget {
  final ObjectId todoId;
  final int index;

  const CreateTodoAction(this.todoId, this.index, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return styledFloatingButton(context,
        tooltip: 'Create step'.i18n(),
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
  late TextEditingController _itemEditingController;

  @override
  void initState() {
    _itemEditingController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _itemEditingController.dispose();
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
              Text("Create step".i18n(), style: theme.titleLarge),
              TextFormField(
                keyboardType: TextInputType.multiline,
                maxLines: null,
                autofocus: true,
                controller: _itemEditingController,
                validator: (value) => (value ?? "").isEmpty ? "Step name hint".i18n() : null,
                decoration: InputDecoration(
                  labelText: "Step".i18n(),
                ),
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
        ));
  }

  void save(RealmServices realmServices, BuildContext context) {
    if (_formKey.currentState!.validate()) {
      final summary = _itemEditingController.text;
      final task = realmServices.taskCollection.get(widget.todoId.hexString);
      if(task != null){
        realmServices.taskCollection.addStep(task, summary, false, widget.index);
      }
      Navigator.pop(context);
    }
  }
}