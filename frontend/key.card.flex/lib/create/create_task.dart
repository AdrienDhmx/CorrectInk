import 'package:flutter/material.dart';
import 'package:key_card/components/widgets.dart';
import 'package:provider/provider.dart';

import '../realm/realm_services.dart';

class CreateTaskAction extends StatelessWidget {
  const CreateTaskAction({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return styledFloatingButton(context,
        tooltip: 'create a task',
        onPressed: () => showModalBottomSheet(
              isScrollControlled: true,
              context: context,
              builder: (_) => Wrap(children: const [CreateTaskForm()]),
            ));
  }
}

class CreateTaskForm extends StatefulWidget {
  const CreateTaskForm({Key? key}) : super(key: key);

  @override
  createState() => _CreateTaskFormState();
}

class _CreateTaskFormState extends State<CreateTaskForm> {
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
              Text("Create a new task", style: theme.titleLarge),
              TextFormField(
                keyboardType: TextInputType.multiline,
                maxLines: null,
                autofocus: true,
                controller: _itemEditingController,
                validator: (value) => (value ?? "").isEmpty ? "Please enter some text" : null,
                decoration: const InputDecoration(
                  labelText: "Task",
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
      realmServices.createItem(summary, false);
      Navigator.pop(context);
    }
  }
}
