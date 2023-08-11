import 'dart:io';

import 'package:correctink/app/services/notification_service.dart';
import 'package:correctink/utils/utils.dart';
import 'package:localization/localization.dart';

import '../app/data/models/schemas.dart';
import '../app/data/repositories/realm_services.dart';

class TaskHelper {

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
        NotificationService.cancel(task.id.timestamp.hashCode);
      }

      DateTime? nextReminder = getNextReminder(task.reminder!, task.reminderRepeatMode);

      if(nextReminder != null){
        NotificationService.schedule(
          date: nextReminder,
          id: task.id.timestamp.hashCode,
          title: "Notification title reminder".i18n(),
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
        NotificationService.cancel(task.id.timestamp.hashCode);
      }

      // if has a deadline and it has changed
      if(!task.isComplete && task.hasDeadline && task.deadline != oldDeadline){
        NotificationService.schedule(
            date: task.deadline!,
            id: task.id.timestamp.hashCode,
            title: "Notification title deadline".i18n(),
            description: task.task,
            payload: task.id.hexString
        );
      }
    } else {
      // try to cancel anyway just in case
      NotificationService.cancel(task.id.timestamp.hashCode);
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
    if(reminderMode < 30 && reminderMode > 0){
      return nextReminder.add(Duration(days: reminderMode));
    }

    if(reminderMode >= 365 && reminderMode % 365 == 0){
      return DateTime(
        nextReminder.year + (reminderMode / 365).round(),
        nextReminder.month,
        nextReminder.day,
        nextReminder.hour,
        nextReminder.minute,
        nextReminder.second,
      );
    }

    if(reminderMode >= 30 && reminderMode % 30 == 0){
      return DateTime(
        nextReminder.year,
        nextReminder.month + (reminderMode / 30).round(),
        nextReminder.day,
        nextReminder.hour,
        nextReminder.minute,
        nextReminder.second,
      );
    }

    return nextReminder;
  }

  static DateTime getPreviousDate(DateTime reminder, int reminderMode){
    if(reminderMode < 30 && reminderMode > 0){
      return reminder.add(Duration(days: -reminderMode));
    }

    if(reminderMode >= 365 && reminderMode % 365 == 0){
      return DateTime(
        reminder.year - (reminderMode / 365).round(),
        reminder.month,
        reminder.day,
        reminder.hour,
        reminder.minute,
        reminder.second,
      );
    }

    if(reminderMode >= 30 && reminderMode % 30 == 0){
      return DateTime(
        reminder.year,
        reminder.month - (reminderMode / 30).round(),
        reminder.day,
        reminder.hour,
        reminder.minute,
        reminder.second,
      );
    }

    return reminder;
  }


  static Future<void> verifyAllTask(RealmServices realmServices) async {
    final tasks = await realmServices.taskCollection.getAll();

    if(Platform.isWindows){
      verifyReminder(tasks, realmServices);
    }

    // go trough all the tasks to see if any have not be scheduled and should be
    // or if the task is scheduled but shouldn't be
    for (int i = 0; i < tasks.length; i++){

      if((tasks[i].hasReminder || tasks[i].hasDeadline)){
        // reminder takes the priority on the deadline for notifications
        if(tasks[i].hasReminder) {
          DateTime? nextReminder = getNextReminder(tasks[i].reminder!, tasks[i].reminderRepeatMode);
          realmServices.taskCollection.updateReminder(tasks[i], nextReminder, tasks[i].reminderRepeatMode);

          // don't schedule notification more than 15 days in advance
          if(nextReminder != null){

            // if reminder is passed by at least a day and is completed then un-complete it
            if(getPreviousDate(tasks[i].reminder!, tasks[i].reminderRepeatMode).isBeforeToday() && tasks[i].isComplete) {
              realmServices.taskCollection.update(tasks[i], isComplete: false);
            }

            if(nextReminder.isBefore(DateTime.now().add(const Duration(days: 15)))) {
              NotificationService.schedule(
              date: nextReminder,
              id: tasks[i].id.timestamp.hashCode,
              title: "Notification title reminder".i18n(),
              description: tasks[i].task,
              payload: tasks[i].id.hexString,
              addDuration: const Duration(),
            );
            }
            continue;
          }
        } else if(!tasks[i].isComplete && tasks[i].deadline!.isBefore(DateTime.now().add(const Duration(days: 15)))){ // if the task is complete the deadline doesn't matter
          NotificationService.schedule(
              date: tasks[i].deadline!,
              id: tasks[i].id.timestamp.hashCode,
              title: "Notification title deadline".i18n(),
              description: tasks[i].task,
              payload: tasks[i].id.hexString
          );
          continue;
        }
      }
      // try cancel anyway
      NotificationService.cancel(tasks[i].id.timestamp.hashCode);
    }
  }

  static void verifyReminder(List<Task> tasks, RealmServices realmServices) {
    for(Task task in tasks) {
      if(task.hasReminder) {
        DateTime? nextReminder = getNextReminder(task.reminder!, task.reminderRepeatMode);

        if (nextReminder != task.reminder) {
          realmServices.taskCollection.updateReminder(task, nextReminder, task.reminderRepeatMode);

          // un-complete the task since the reminder is passed
          if(task.isComplete){
            realmServices.taskCollection.update(task, isComplete: false);
          }
        }
      }
    }
  }
}