import 'package:correctink/Notifications/notification_service.dart';
import 'package:correctink/components/snackbars_widgets.dart';
import 'package:correctink/components/widgets.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:localization/localization.dart';


enum RepeatMode{
  never(days: 0, name: "Never"),
  daily(days: 1, name: "Daily"),
  weekly(days: 7, name: "Weekly"),
  monthly(days: 30, name: "Monthly"),
  yearly(days: 365, name: "Yearly");

  const RepeatMode({required this.days, required this.name});

  final int days;
  final String name;
}

class ReminderWidget extends StatefulWidget {
  final DateTime? reminder;
  final int reminderMode;

  final Function(DateTime? reminder, int reminderMode) updateCallback;

  const ReminderWidget(this.reminder, this.reminderMode, this.updateCallback, {super.key});

  @override
  State<StatefulWidget> createState() => _ReminderWidget();
}

class _ReminderWidget extends State<ReminderWidget>{
  static const repeatModes = <RepeatMode>[RepeatMode.daily, RepeatMode.weekly, RepeatMode.monthly, RepeatMode.yearly];
  static const double repeatOptionsHeight = 35;
  late DateTime? reminder;
  late int reminderMode;
  late RepeatMode repeatMode;

  @override
  void didChangeDependencies(){
    super.didChangeDependencies();

    reminder = widget.reminder;
    reminderMode = widget.reminderMode;

    switch (reminderMode){
      case 0:
        repeatMode = RepeatMode.never;
        break;
      case 1:
        repeatMode = RepeatMode.daily;
        break;
      case 7:
        repeatMode = RepeatMode.weekly;
        break;
      case 30:
        repeatMode = RepeatMode.monthly;
        break;
      case 365:
        repeatMode = RepeatMode.yearly;
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 0,0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              labeledAction(
                  context: context,
                  height: 35,
                  width: 195,
                  center: true,
                  labelFirst: false,
                  onTapAction: () async {
                    if(NotificationService.notificationAreDenied){
                      errorMessageSnackBar(context, 'Error'.i18n(), 'Notification denied'.i18n()).show(context);
                      return;
                    }

                    final date = await showDateTimePicker(
                      context: context,
                      initialDate: reminder,
                      firstDate: DateTime.now(),
                    );
                    setState(() {
                      reminder = date;
                    });

                    widget.updateCallback(reminder, reminderMode);
                  },
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 8.0, 0),
                    child: Icon(Icons.notifications_active_rounded, color: Theme.of(context).colorScheme.primary,),
                  ),
                  label: reminder == null ? "Pick reminder".i18n() : DateFormat(
                      'yyyy-MM-dd – kk:mm').format(reminder!),
              ),
              if(reminder != null) IconButton(
                  onPressed: () {
                    setState(() {
                      reminder = null;
                    });
                    widget.updateCallback(reminder, reminderMode);
                  },
                  tooltip: 'Remove reminder'.i18n(),
                  icon: Icon(Icons.clear_rounded, color: Theme.of(context).colorScheme.error,)
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if(reminder != null)
                labeledAction(
                  context: context,
                  width: repeatMode.days == 0 ? 220 : 180,
                  height: 35,
                  center: true,
                  labelFirst: false,
                  onTapAction: () async {
                    showDialog<void>(
                        context: context,
                        builder: (BuildContext context) {
                          final double height = repeatModes.length * repeatOptionsHeight;
                          return AlertDialog(
                            title: Text("Pick repeat".i18n()),
                            titleTextStyle: Theme.of(context).textTheme.headlineMedium,
                            content: SizedBox(
                              height: height,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  for(int i = 0; i < repeatModes.length; i++)
                                    SizedBox(
                                      height: repeatOptionsHeight,
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          borderRadius: const BorderRadius.all(Radius.circular(4)),
                                          hoverColor: Theme.of(context).colorScheme.primary.withAlpha(20),
                                          splashColor: Theme.of(context).colorScheme.primary.withAlpha(50),
                                          splashFactory: InkRipple.splashFactory,
                                          onTap: () {
                                            setState(() => {
                                              reminderMode = repeatModes[i].days,
                                              repeatMode = repeatModes[i],
                                            });
                                            widget.updateCallback(reminder, reminderMode);
                                            GoRouter.of(context).pop();
                                          },
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                              child: Text(
                                                repeatModes[i].name.i18n(),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ]
                                ),
                            ),
                            );
                          },
                        );
                      },
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0,0,8,0),
                    child: Icon(Icons.repeat_rounded, color: Theme.of(context).colorScheme.primary,),
                  ),
                  label: reminderMode == 0 ? "Pick repeat".i18n() : repeatMode.name.i18n(),
                ),
              if(reminderMode != 0 && reminder != null) Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 4.0, 0),
                child: IconButton(
                    onPressed: () {
                      setState(() {
                        reminderMode = 0;
                        repeatMode = RepeatMode.never;
                      });
                      widget.updateCallback(reminder, reminderMode);
                    },
                    tooltip: 'Remove repeat'.i18n(),
                    icon: Icon(Icons.clear_rounded, color: Theme.of(context).colorScheme.error,)
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

}