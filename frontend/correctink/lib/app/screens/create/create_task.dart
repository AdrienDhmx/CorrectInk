import 'package:correctink/blocs/tasks/reminder_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:correctink/widgets/widgets.dart';
import 'package:localization/localization.dart';
import 'package:provider/provider.dart';

import '../../../utils/task_helper.dart';
import '../../../widgets/buttons.dart';
import '../../data/repositories/realm_services.dart';


class CreateTaskAction extends StatelessWidget {
  const CreateTaskAction({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return styledFloatingButton(context,
        tooltip: 'Create task'.i18n(),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(12), bottomRight: Radius.circular(6), bottomLeft: Radius.circular(12))
        ),
        onPressed: () => showBottomSheetModal(context, const CreateTaskForm()),
    );
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
  DateTime? reminder;
  int reminderMode = 0;
  late bool useDeadline = false;
  late bool useReminder = false;
  late bool useRepeatReminder = false;
  late RealmServices realmServices;

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
    realmServices = Provider.of(context);
    return modalLayout(
        context,
        Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                maxLines: null,
                autofocus: true,
                controller: _itemEditingController,
                validator: (value) => (value ?? "").isEmpty ? "Task name hint".i18n() : null,
                decoration: InputDecoration(
                  labelText: "Task".i18n(),
                ),
                onFieldSubmitted: (value) => save(realmServices, context),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 8.0, 0, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children:[
                    Checkbox(value: useDeadline,
                        onChanged: (value) {
                            setState(() {
                              useDeadline = value ?? false;
                            });
                        }),
                    AnimatedOpacity(opacity: useDeadline ? 1 : 0.6,
                      duration: const Duration(milliseconds: 200),
                      child: labeledAction(
                        context: context,
                        height: 35,
                        infiniteWidth: false,
                        center: true,
                        labelFirst: false,
                        onTapAction: () async {
                          final date = await showDateTimePicker(
                            context: context,
                            initialDate: deadline,
                            firstDate: DateTime.now(),
                          );
                          if (date != null) {
                            setState(() {
                              deadline = date;
                              useDeadline = true;
                            });
                          }
                        },
                        child: Icon(Icons.calendar_month_rounded, color: Theme.of(context).colorScheme.primary,),
                        label: deadline == null ? 'Pick deadline'.i18n() : DateFormat('yyyy-MM-dd – kk:mm').format(deadline!),
                      ),
                    ),
                  ],
                ),
              ),
              ReminderWidget(reminder, reminderMode, (remind, remindMode, useReminder, useRepeatReminder) => {
                setState(() {
                  reminder = remind;
                  reminderMode = remindMode;
                  this.useReminder = useReminder;
                  this.useRepeatReminder = useRepeatReminder;
                })
              }),
              Padding(
                padding: const EdgeInsets.only(top: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    cancelButton(context),
                    okButton(context, "Create".i18n(),
                        onPressed: () => save(realmServices, context)
                    ),
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
      final task = realmServices.taskCollection.create(summary, false,
          useDeadline ? deadline : null,
          useReminder ? reminder : null, useRepeatReminder ? reminderMode : 0);
      TaskHelper.scheduleForTask(task);
      Navigator.pop(context);
    }
  }
}
