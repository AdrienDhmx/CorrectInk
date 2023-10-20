import 'dart:async';

import 'package:correctink/app/services/notification_service.dart';
import 'package:correctink/utils/markdown_extension.dart';
import 'package:correctink/widgets/animated_widgets.dart';
import 'package:correctink/widgets/buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:correctink/widgets/widgets.dart';
import 'package:localization/localization.dart';
import 'package:provider/provider.dart';

import '../../../blocs/link_dialog.dart';
import '../../../blocs/tasks/reminder_widget.dart';
import '../../../utils/task_helper.dart';
import '../../../utils/utils.dart';
import '../../data/models/schemas.dart';
import '../../data/repositories/realm_services.dart';

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
                  padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:[
                      labeledAction(
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
                            });
                          }
                        },
                        child: Icon(Icons.calendar_month_rounded, color: Theme.of(context).colorScheme.primary,),
                        label: deadline == null ? 'Pick deadline'.i18n() : DateFormat('yyyy-MM-dd – kk:mm').format(deadline!),
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
      TaskHelper.scheduleForTask(
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
}