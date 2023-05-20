import 'package:flutter/material.dart';
import 'package:correctink/components/widgets.dart';
import 'package:objectid/objectid.dart';
import 'package:provider/provider.dart';

import '../realm/realm_services.dart';

class CreateTodoAction extends StatelessWidget {
  final ObjectId taskId;

  const CreateTodoAction(this.taskId, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return styledFloatingButton(context,
        tooltip: 'create a step',
        onPressed: () => showModalBottomSheet(
          isScrollControlled: true,
          context: context,
          builder: (_) => Wrap(children: [CreateTodoForm(taskId)]),
        ));
  }
}

class CreateTodoForm extends StatefulWidget {
  final ObjectId taskId;

  const CreateTodoForm(this.taskId, {Key? key}) : super(key: key);

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
              Text("Create a new step", style: theme.titleLarge),
              TextFormField(
                keyboardType: TextInputType.multiline,
                maxLines: null,
                autofocus: true,
                controller: _itemEditingController,
                validator: (value) => (value ?? "").isEmpty ? "Please enter some text" : null,
                decoration: const InputDecoration(
                  labelText: "Step",
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    cancelButton(context),
                    Consumer<RealmServices>(builder: (context, realmServices, child) {
                      return okButton(context, "Create", onPressed: () => save(realmServices, context));
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
      realmServices.todoCollection.create(summary, widget.taskId, false);
      Navigator.pop(context);
    }
  }
}