import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:correctink/components/widgets.dart';
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
  DateTime? deadline;

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
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Center(
                  child: SizedBox(
                    width: deadline == null ? 140 : 300,
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      runAlignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if(deadline != null) Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 4.0, 0),
                          child: IconButton(
                              onPressed: () {
                                setState(() {
                                  deadline = null;
                                });
                              },
                              tooltip: 'Remove deadline',
                              icon: Icon(Icons.clear_rounded, color: Theme.of(context).colorScheme.error,)
                          ),
                        ),
                        Text(deadline == null ? '' : DateFormat('yyyy-MM-dd – kk:mm').format(deadline!),),
                        TextButton(
                          onPressed: () async{
                            final date = await showDateTimePicker(context: context,
                              initialDate: deadline,
                              firstDate: DateTime.now(),
                            );
                            if(date != null){
                              setState(() {
                                deadline = date;
                              });
                            }
                          },
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.0),
                            child: Text('Pick a deadline'),
                          ),
                        ),
                      ],
                    ),
                  ),
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
      realmServices.createTask(summary, false, deadline);
      Navigator.pop(context);
    }
  }
}
