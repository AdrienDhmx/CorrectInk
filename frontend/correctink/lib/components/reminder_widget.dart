import 'package:correctink/components/widgets.dart';
import 'package:flutter/material.dart';
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
                PopupMenuButton(
                  onSelected: (RepeatMode repeat) => {
                    setState(() => {
                      reminderMode = repeat.days,
                      repeatMode = repeat,
                    }),
                    widget.updateCallback(reminder, reminderMode),
                  },
                  enableFeedback: true,
                  tooltip: "Pick repeat".i18n(),
                  itemBuilder: (BuildContext context) => [
                    PopupMenuItem<RepeatMode>(
                      value: RepeatMode.daily,
                      child: Text("Daily".i18n()),
                    ),
                    PopupMenuItem<RepeatMode>(
                      value: RepeatMode.weekly,
                      child: Text("Weekly".i18n()),
                    ),
                    PopupMenuItem<RepeatMode>(
                      value: RepeatMode.monthly,
                      child: Text("Monthly".i18n()),
                    ),
                    PopupMenuItem<RepeatMode>(
                      value: RepeatMode.yearly,
                      child: Text("Yearly".i18n()),
                    ),
                  ],
                  child: Row(
                    children: [
                      Icon(Icons.repeat_rounded, color: Theme.of(context).colorScheme.primary,),
                      const SizedBox(width: 8),
                      Text(repeatMode == RepeatMode.never ? 'Pick repeat'.i18n() : repeatMode.name.i18n()),
                    ],
                  ),
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