import 'package:correctink/components/reminder_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:correctink/components/widgets.dart';
import 'package:localization/localization.dart';
import 'package:provider/provider.dart';

import '../Notifications/notification_service.dart';
import '../realm/realm_services.dart';
import '../utils.dart';

class CreateTaskAction extends StatelessWidget {
  const CreateTaskAction({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return styledFloatingButton(context,
        tooltip: 'Create task'.i18n(),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(12), bottomRight: Radius.circular(6), bottomLeft: Radius.circular(12))
        ),
        onPressed: () => showModalBottomSheet(
              isScrollControlled: true,
              context: context,
              builder: (_) => const Wrap(children: [CreateTaskForm()]),
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
  DateTime? reminder;
  int reminderMode = 0;

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
                autofocus: true,
                controller: _itemEditingController,
                validator: (value) => (value ?? "").isEmpty ? "Task name hint".i18n() : null,
                decoration: InputDecoration(
                  labelText: "Task".i18n(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 8.0, 0, 0),
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
      final task = realmServices.taskCollection.create(summary, false, deadline, reminder, reminderMode);
      NotificationService.scheduleForTask(task);
      Navigator.pop(context);
    }
  }
}
