
import 'package:correctink/app/services/notification_service.dart';
import 'package:correctink/widgets/snackbars_widgets.dart';
import 'package:correctink/widgets/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:localization/localization.dart';

import '../../utils/utils.dart';
import '../../widgets/buttons.dart';


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
  final bool useReminder;
  final bool useRepeatReminder;

  final Function(DateTime? reminder, int reminderMode, bool useReminder, bool useRepeatReminder) updateCallback;

  const ReminderWidget(this.reminder, this.reminderMode, this.updateCallback,
      {super.key, this.useReminder = false, this.useRepeatReminder = false});

  @override
  State<StatefulWidget> createState() => _ReminderWidget();
}

class _ReminderWidget extends State<ReminderWidget>{
  static const repeatModes = <RepeatMode>[RepeatMode.daily, RepeatMode.weekly, RepeatMode.monthly, RepeatMode.yearly];
  static const customRepeatStrings = <String>["days", "weeks", "months", "years"];
  static const double repeatOptionsHeight = 40;
  late DateTime? reminder;
  late int reminderMode;
  late RepeatMode repeatMode;
  late bool customRepeat = false;
  late int customRepeatFactor = 0;
  late bool useReminder = widget.useReminder;
  late bool useRepeatReminder = widget.useRepeatReminder;
  late int customRepeatStringSelectedIndex;
  late TextEditingController customRepeatController;

  @override
  void didChangeDependencies(){
    super.didChangeDependencies();

    reminder = widget.reminder;
    reminderMode = widget.reminderMode;

    switch (reminderMode){
      case 0:
        repeatMode = RepeatMode.never;
        customRepeatStringSelectedIndex = 0;
        break;
      case 1:
        repeatMode = RepeatMode.daily;
        customRepeatStringSelectedIndex = 0;
        break;
      case 7:
        repeatMode = RepeatMode.weekly;
        customRepeatStringSelectedIndex = 1;
        break;
      case 30:
        repeatMode = RepeatMode.monthly;
        customRepeatStringSelectedIndex = 2;
        break;
      case 365:
        repeatMode = RepeatMode.yearly;
        customRepeatStringSelectedIndex = 3;
        break;
      default:
        setCustomRepeat();
    }

    customRepeatController = TextEditingController(text: customRepeatFactor.toString());
  }
  
  void setCustomRepeat(){
    // making sure it's custom
    if(reminderMode == 365 || reminderMode == 30 ||reminderMode == 7 || reminderMode == 1){
      customRepeat = false;
    } else {
      customRepeat = true;
    }

    if(reminderMode > 365 && reminderMode % 365 == 0){
      repeatMode = RepeatMode.yearly;
      customRepeatFactor = (reminderMode / 365).round();
      customRepeatStringSelectedIndex = 3;
      return;
    }

    if(reminderMode > 30 && reminderMode % 30 == 0){
      repeatMode = RepeatMode.monthly;
      customRepeatFactor = (reminderMode / 30).round();
      customRepeatStringSelectedIndex = 2;
      return;
    }

    if(reminderMode > 7 && reminderMode % 7 == 0){
      repeatMode = RepeatMode.monthly;
      customRepeatFactor = (reminderMode / 7).round();
      customRepeatStringSelectedIndex = 1;
      return;
    }

    repeatMode = RepeatMode.daily;
    customRepeatFactor = reminderMode;
    customRepeatStringSelectedIndex = 0;
    return;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 0,0),
      child: Wrap(
        alignment: WrapAlignment.start,
        runAlignment: WrapAlignment.start,
        spacing: 12,
        runSpacing: 6,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Checkbox(
                  value: useReminder,
                  onChanged: (value) => setState(() {
                    useReminder = value ?? false;
                  })
              ),
              AnimatedOpacity(opacity: useReminder ? 1 : 0.6,
                duration: const Duration(milliseconds: 200),
                child: labeledAction(
                  context: context,
                  height: 35,
                  infiniteWidth: false,
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
                      useReminder = true;
                    });

                    widget.updateCallback(reminder, reminderMode, useReminder, useRepeatReminder);
                  },
                  child: Icon(Icons.notifications_active_rounded, color: Theme.of(context).colorScheme.primary,),
                  label: reminder == null ? "Pick reminder".i18n() : DateFormat(
                      'yyyy-MM-dd – kk:mm').format(reminder!),
                ),
              ),
            ],
          ),
          if(reminder != null && useReminder)
            Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Checkbox(
                  value: useRepeatReminder,
                  onChanged: (value) => setState(() {
                      useRepeatReminder = value ?? false;
                  })
              ),
              AnimatedOpacity(opacity: useRepeatReminder ? 1 : 0.6,
                duration: const Duration(milliseconds: 200),
                child: labeledAction(
                    context: context,
                    infiniteWidth: false,
                    height: 35,
                    center: true,
                    labelFirst: false,
                    onTapAction: () async {
                      showDialog<void>(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("Pick repeat".i18n()),
                            titleTextStyle: Theme.of(context).textTheme.headlineMedium,
                            content: Column(
                                mainAxisSize: MainAxisSize.min,
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
                                            setState(() {
                                              reminderMode = repeatModes[i].days;
                                              repeatMode = repeatModes[i];
                                              useRepeatReminder = true;
                                            });
                                            widget.updateCallback(reminder, reminderMode, useReminder, useRepeatReminder);
                                            GoRouter.of(context).pop();
                                          },
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                              child: Text(
                                                repeatModes[i].name.i18n(),
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  const SizedBox(height: 6,),
                                  SizedBox(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Text("Custom".i18n(), style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500
                                          ),),
                                          const Padding(
                                            padding: EdgeInsets.fromLTRB(10.0, 2, 10, 4),
                                            child: Divider(),
                                          ),
                                          Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  SizedBox(width: 60,
                                                    child: Align(
                                                      alignment: Alignment.topCenter,
                                                      child: TextField(
                                                        keyboardType: TextInputType.number,
                                                        controller: customRepeatController,
                                                        inputFormatters: <TextInputFormatter>[
                                                          FilteringTextInputFormatter.digitsOnly
                                                        ],
                                                        decoration: const InputDecoration(
                                                          isDense: true,
                                                        ),
                                                        onChanged: (value){
                                                          if(value.isNotEmpty) {
                                                            setState(() {
                                                              customRepeatFactor = int.parse(value);
                                                              if(customRepeatFactor > 1) {
                                                                customRepeat = true;
                                                              }
                                                              switch(customRepeatStringSelectedIndex){
                                                                case 0:
                                                                  reminderMode = customRepeatFactor * 1;
                                                                case 1:
                                                                  reminderMode = customRepeatFactor * 7;
                                                                case 2:
                                                                  reminderMode = customRepeatFactor * 30;
                                                                case 3:
                                                                  reminderMode = customRepeatFactor * 365;
                                                              }
                                                            });
                                                            widget.updateCallback(reminder, reminderMode, useReminder, useRepeatReminder);
                                                          }
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 110,
                                                    child: DropdownButtonFormField<int>(
                                                      value: customRepeatStringSelectedIndex,
                                                      borderRadius: const BorderRadius.all(Radius.circular(4)),
                                                      decoration: const InputDecoration(
                                                        isDense: true,
                                                      ),
                                                      alignment: AlignmentDirectional.topStart,
                                                      items: <DropdownMenuItem<int>>[
                                                        for(int i = 0; i < customRepeatStrings.length; i++)
                                                          DropdownMenuItem<int>(
                                                            value: i,
                                                            child: Padding(
                                                              padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
                                                              child: Text(customRepeatStrings[i].i18n()),
                                                            ),
                                                          ),
                                                      ],
                                                      onChanged: (int? value) {
                                                        setState(() {
                                                          if(customRepeatFactor != 1 ) {
                                                            customRepeat = true;
                                                          }
                                                          customRepeatStringSelectedIndex = value!;
                                                          switch(value){
                                                            case 0:
                                                              reminderMode = customRepeatFactor * 1;
                                                            case 1:
                                                              reminderMode = customRepeatFactor * 7;
                                                            case 2:
                                                              reminderMode = customRepeatFactor * 30;
                                                            case 3:
                                                              reminderMode = customRepeatFactor * 365;
                                                          }
                                                          widget.updateCallback(reminder, reminderMode, useReminder, useRepeatReminder);
                                                        });
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 12,),
                                              okButton(
                                                  context,
                                                  "Done".i18n(),
                                                  onPressed: (){
                                                    GoRouter.of(context).pop();
                                                  })
                                            ],
                                          ),
                                        ],
                                      )
                                  )
                                ]
                            ),
                          );
                        },
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0,0,8,0),
                      child: Icon(Icons.repeat_rounded, color: Theme.of(context).colorScheme.primary,),
                    ),
                    label: reminderMode == 0 ? "Pick repeat".i18n() : Utils.getRepeatString(reminderMode)
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

}