import 'package:correctink/Notifications/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:correctink/components/widgets.dart';
import 'package:localization/localization.dart';
import 'package:provider/provider.dart';

import '../components/reminder_widget.dart';
import '../main.dart';
import '../realm/realm_services.dart';
import '../realm/schemas.dart';
import '../utils.dart';

class ModifyTaskForm extends StatefulWidget {
  final Task task;
  const ModifyTaskForm(this.task, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ModifyTaskFormState();
}

class _ModifyTaskFormState extends State<ModifyTaskForm> {
  final _formKey = GlobalKey<FormState>();
  final completeGroup = <bool>[true, false];
  late bool isComplete = widget.task.isComplete;
  late TextEditingController _summaryController;
  late DateTime? deadline = widget.task.deadline;
  late DateTime? reminder = widget.task.reminder;
  late int reminderMode = widget.task.reminderRepeatMode;

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
    TextTheme myTextTheme = Theme
        .of(context)
        .textTheme;
    final realmServices = Provider.of<RealmServices>(context, listen: false);
    return formLayout(
        context,
        Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text("Update task".i18n(), style: myTextTheme.titleLarge),
                TextFormField(
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  controller: _summaryController,
                  validator: (value) =>
                  (value ?? "").isEmpty
                      ? "Task name hint".i18n()
                      : null,
                  decoration: InputDecoration(
                    labelText: "Task".i18n(),
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
                        onChanged: (bool? value) {
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
                  padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:[
                      labeledAction(
                        context: context,
                        height: 35,
                        width: Utils.isOnPhone() ? 200 : 220,
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
                            });
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(0,0,8,0),
                          child: Icon(Icons.calendar_month_rounded, color: Theme.of(context).colorScheme.primary,),
                        ),
                        label: deadline == null ? 'Pick deadline'.i18n() : DateFormat(
                            'yyyy-MM-dd – kk:mm').format(deadline!),
                      ),
                      if(deadline != null) IconButton(
                          onPressed: () {
                            setState(() {
                              deadline = null;
                            });
                          },
                          tooltip: 'Remove deadline'.i18n(),
                          icon: Icon(Icons.clear_rounded, color: Theme.of(context).colorScheme.error,)
                      ),
                    ],
                  ),
                ),
                ReminderWidget(reminder, reminderMode, (remind, remindMode) => {
                  setState(() => {
                    reminder = remind,
                    reminderMode = remindMode,
                  })
                }),
                Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      cancelButton(context),
                      deleteButton(context, onPressed: () =>
                          delete(realmServices, widget.task, context)),
                      okButton(context, "Update".i18n(),
                          onPressed: () async =>
                          await update(context, realmServices, widget.task,
                              _summaryController.text, isComplete, deadline)),
                    ],
                  ),
                ),
              ],
            )));
  }

  Future<void> update(BuildContext context, RealmServices realmServices,
      Task task, String summary, bool isComplete, DateTime? deadline) async {
    if (_formKey.currentState!.validate()) {
      NotificationService.scheduleForTask(
        Task(task.id, summary, task.ownerId, isComplete: isComplete, deadline: deadline, reminder: reminder, reminderRepeatMode: reminderMode),
        oldDeadline: task.deadline,
        oldReminder: task.reminder,
        oldRepeat: task.reminderRepeatMode,
      );

      await realmServices.taskCollection.update(task, summary: summary,
          isComplete: isComplete == task.isComplete ? null : isComplete,
          deadline: deadline != task.deadline ? deadline : task.deadline,
      );

      if(reminder != task.reminder || reminderMode != task.reminderRepeatMode){
        await realmServices.taskCollection.updateReminder(task, reminder, reminderMode);
      }

      if (context.mounted) Navigator.pop(context);
    }
  }

  void cancelNotification(DateTime? deadline){
    if(deadline != null) {
      NotificationService.cancel(deadline.millisecondsSinceEpoch);
    }
  }

  void delete(RealmServices realmServices, Task task, BuildContext context) {
    cancelNotification(task.deadline);
    GoRouter.of(context).push(RouterHelper.taskLibraryRoute); // go to the task library page
    GoRouter.of(context).pop(); // close the modal
    realmServices.taskCollection.deleteAsync(task); // delete task in 1 second
  }
}