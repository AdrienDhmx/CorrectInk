import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:correctink/components/widgets.dart';
import 'package:provider/provider.dart';

import '../realm/realm_services.dart';
import '../realm/schemas.dart';

class ModifyTaskForm extends StatefulWidget {
  final Task task;
  const ModifyTaskForm(this.task, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ModifyTaskFormState();
}

class _ModifyTaskFormState extends State<ModifyTaskForm> {
  final _formKey = GlobalKey<FormState>();
  final completeGroup = <bool>[true, false];
  late  bool isComplete = widget.task.isComplete;
  late TextEditingController _summaryController;
  late DateTime? deadline = widget.task.deadline;

  _ModifyTaskFormState();

  @override
  void initState() {
    _summaryController = TextEditingController(text: widget.task.task);
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
                        label: 'Complete',
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
                      label: 'Incomplete',
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
                      deleteButton(context, onPressed: () => delete(realmServices, widget.task, context)),
                      okButton(context, "Update",
                          onPressed: () async => await update(context, realmServices, widget.task, _summaryController.text, isComplete, deadline)),
                    ],
                  ),
                ),
              ],
            )));
  }

  Future<void> update(BuildContext context, RealmServices realmServices, Task task, String summary, bool isComplete, DateTime? deadline) async {
    if (_formKey.currentState!.validate()) {
      await realmServices.taskCollection.update(task, summary: summary, isComplete: isComplete, deadline: deadline != task.deadline ? deadline : null);
      if(context.mounted) Navigator.pop(context);
    }
  }

  void delete(RealmServices realmServices, Task task, BuildContext context) {
    realmServices.taskCollection.delete(task);
    Navigator.pop(context);
  }
}
