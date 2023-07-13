import 'dart:io';

import 'package:correctink/realm/realm_services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../realm/schemas.dart';

class NotificationService {
  static final _notifications = FlutterLocalNotificationsPlugin();
  static final onNotifications = BehaviorSubject<String?>();
  static bool isInit = false;

  static Future init({bool initScheduled = false}) async {
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    _notifications.initialize(settings, onDidReceiveNotificationResponse: (details) async => {
      onNotifications.add(details.payload)
    });

    if(initScheduled){
      tz.initializeTimeZones();
      late String locationName;
      if(Platform.isWindows){
        var locations = tz.timeZoneDatabase.locations;

        int milliseconds=DateTime.now().toLocal().timeZoneOffset.inMilliseconds;

        for (int i = 0; i < locations.values.length; i++){
          if (locations.values.elementAt(i).currentTimeZone.offset == milliseconds) {
            locationName = locations.values.elementAt(i).name;
            break;
          }
        }
      } else {
        locationName = await FlutterTimezone.getLocalTimezone();
      }
      tz.setLocalLocation(tz.getLocation(locationName));
    }
    isInit = true;
  }

  static Future<NotificationDetails> _notificationDetails({StyleInformation? style}) async {
    return NotificationDetails(
      android: AndroidNotificationDetails("CorrectInk", "CorrectInk",
          importance: Importance.high,
          enableLights: true,
          ledColor: Colors.orange,
          ledOnMs: 1000, ledOffMs: 500,
        styleInformation: style,
      ),
      iOS: const DarwinNotificationDetails(),
      macOS: const DarwinNotificationDetails(),
      linux: const LinuxNotificationDetails(),
    );
  }

  static Future show({int id = 0, String? title, String? description, String? payload}) async{
    if(!Platform.isWindows) {
      _notifications.show(id, title, description, await _notificationDetails(), payload: payload);
    }
  }

  static Future schedule({required DateTime date, int id = 0, String? title, String? description, String? payload, Duration addDuration = const Duration(hours: -1)}) async{
    if(Platform.isWindows) return; // the library doesn't support windows...

    final d =  tz.TZDateTime.from(date.add(addDuration), tz.local);

    // don't schedule a notification if it's due in less than an hour from now
    if(d.isBefore(DateTime.now())){
      return;
    }

    if (kDebugMode) {
      print('notification scheduled for $d with id: $id');
    }

    StyleInformation? bigTextStyleInformation = description != null ?
    BigTextStyleInformation(
      description,
      htmlFormatBigText: true,
      contentTitle: title,
      htmlFormatContentTitle: true,
    ) : null;

    _notifications.zonedSchedule(
        id,
        title,
        description,
        d,
        await _notificationDetails(style: bigTextStyleInformation),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: payload,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<PendingNotificationRequest?> tryGetScheduled(int id) async {
    final allPending = await _notifications.pendingNotificationRequests();
    for(int i = 0; i < allPending.length; i++){
      if(allPending[i].id == id){
        return allPending[i];
      }
    }
    return null;
  }

  static void cancel(int id) {
    if(Platform.isWindows)return;

    if (kDebugMode) {
      print('notification canceled with id: $id');
    }
    _notifications.cancel(id);
  }

  static void scheduleForTask(Task task, {DateTime? oldDeadline, DateTime? oldReminder, int? oldRepeat}){
    if(Platform.isWindows) return;

    // if there is a reminder
    if(task.hasReminder) {
      // nothing to do
      if(task.reminder == oldReminder) {
        return;
      }

      if(oldReminder != null || oldDeadline != null){
        // need to cancel the old scheduled notification
        cancel(task.id.timestamp.hashCode);
      }

      DateTime? nextReminder = getNextReminder(task.reminder!, task.reminderRepeatMode);

      if(nextReminder != null){
        schedule(
            date: nextReminder,
            id: task.id.timestamp.hashCode,
            title: 'Don\'t forget your task!',
            description: task.task,
            payload: task.id.hexString,
          addDuration: const Duration(),
        );
      }
    } else if(task.hasDeadline){
      // nothing to do
      if(task.deadline == oldDeadline) {
        return;
      }

      if(oldReminder != null || oldDeadline != null){
        // need to cancel the old scheduled notification
        cancel(task.id.timestamp.hashCode);
      }

      // if has a deadline and it has changed
      if(!task.isComplete && task.hasDeadline && task.deadline != oldDeadline){
        schedule(
            date: task.deadline!,
            id: task.id.timestamp.hashCode,
            title: 'Task due in 1 hour!',
            description: task.task,
            payload: task.id.hexString
        );
      }
    } else {
      // try to cancel anyway just in case
      cancel(task.id.timestamp.hashCode);
    }
  }

  static DateTime? getNextReminder(DateTime reminder, int repeatMode){
    DateTime now = DateTime.now();
    // reminder not repeated and passed
    if(repeatMode == 0 && reminder.isBefore(now)){
      return null;
    }
    // passed,
    // need to update the reminder date and return the new date based on the repeat value
    if(reminder.isBefore(now)){
      return addRepeatToDate(reminder, repeatMode);
    } else {
      return reminder;
    }
  }

  static DateTime addRepeatToDate(DateTime nextReminder, int reminderMode){
    switch(reminderMode){
      case 1:
        return nextReminder.add(const Duration(days: 1));
      case 7:
        return nextReminder.add(const Duration(days: 7));
      case 30:
        return DateTime(
          nextReminder.year,
          nextReminder.month + 1,
          nextReminder.day,
          nextReminder.hour,
          nextReminder.minute,
          nextReminder.second,
        );
      case 365:
        return DateTime(
          nextReminder.year + 1,
          nextReminder.month,
          nextReminder.day,
          nextReminder.hour,
          nextReminder.minute,
          nextReminder.second,
        );
    }
    return nextReminder;
  }

  static Future<void> verifyAllTask(RealmServices realmServices) async {
    final tasks = await realmServices.taskCollection.getAll();

    // go trough all the tasks to see if any have not be scheduled and should be
    // or if the task is scheduled but shouldn't be
    for (int i = 0; i < tasks.length; i++){
      if(Platform.isWindows) {
        // only update the reminder date if needed
        verifyReminder(tasks[i], realmServices);
        continue;
      }

      if((tasks[i].hasReminder || tasks[i].hasDeadline)){
        if(tasks[i].hasReminder) {
          DateTime? nextReminder = getNextReminder(tasks[i].reminder!, tasks[i].reminderRepeatMode);

          realmServices.taskCollection.updateReminder(tasks[i], nextReminder, tasks[i].reminderRepeatMode);
          if(nextReminder != null && nextReminder.isBefore(DateTime.now().add(const Duration(days: 2)))){
            schedule(
                date: nextReminder,
                id: tasks[i].id.timestamp.hashCode,
                title: 'Don\'t forget your task!',
                description: tasks[i].task,
                payload: tasks[i].id.hexString,
                addDuration: const Duration(),
            );
            continue;
          }
        } else if(!tasks[i].isComplete && tasks[i].deadline!.isBefore(DateTime.now().add(const Duration(days: 2)))){ // if the task is complete the deadline doesn't matter
          schedule(
              date: tasks[i].deadline!,
              id: tasks[i].id.timestamp.hashCode,
              title: 'Task due in 1 hour!',
              description: tasks[i].task,
              payload: tasks[i].id.hexString
          );
          continue;
        }
      }
      // try cancel anyway
      cancel(tasks[i].id.timestamp.hashCode);
    }
  }

  static void verifyReminder(Task task, RealmServices realmServices) {
    if(task.hasReminder) {
      DateTime? nextReminder = getNextReminder(task.reminder!, task.reminderRepeatMode);

      if (nextReminder != task.reminder) {
        realmServices.taskCollection.updateReminder(task, nextReminder, task.reminderRepeatMode);
      }
    }
  }
}

