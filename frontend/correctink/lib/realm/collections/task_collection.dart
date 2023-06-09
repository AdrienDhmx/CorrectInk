import 'dart:async';

import 'package:correctink/Notifications/notification_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:realm/realm.dart';

import '../../sorting/task_sorting.dart';
import '../realm_services.dart';
import '../schemas.dart';

class TaskCollection extends ChangeNotifier {
  final RealmServices _realmServices;
  Realm get realm => _realmServices.realm;

  TaskCollection(this._realmServices);

  Task create(String summary, bool isComplete, DateTime? deadline, DateTime? reminder, int? reminderMode) {
    final newTask = Task(ObjectId(), summary, _realmServices.currentUser!.id, isComplete: isComplete, deadline: deadline, reminder: reminder, reminderRepeatMode: reminderMode?? 0);
    realm.write<Task>(() => realm.add<Task>(newTask));
    notifyListeners();
    return newTask;
  }

  Future<void> addStep(Task task, String summary, bool isComplete, int index) async {
    final newStep = TaskStep(ObjectId(), summary, isComplete: isComplete, index: index);
    realm.write(() => {
      task.steps.add(newStep),
    });
  }

  void updateStepsOrder(Task task, int oldIndex, int newIndex){
    realm.write(() => {
      task.steps.move(oldIndex, newIndex),
    });
  }

  void delete(Task task) {

    if(task.hasReminder || task.hasDeadline){
      NotificationService.cancel(task.id.timestamp.hashCode);
    }

    realm.write(() => {
      realm.delete(task),
    });
    notifyListeners();
  }

  void deleteAsync(Task task){
    Timer(const Duration(seconds: 1),() { delete(task); });
  }

  Task? get(String taskId){
    return realm.query<Task>(r'_id = $0', [ObjectId.fromHexString(taskId)]).first;
  }

  Stream<RealmResultsChanges<Task>> getStream(String sortDir, String sortBy) {
    String query;
    if(sortBy == SortingField.creationDate.name){
      query = "TRUEPREDICATE SORT(_id $sortDir)";
    }else{
      query = "TRUEPREDICATE SORT($sortBy $sortDir)";
    }

    return realm.query<Task>(query).changes;
  }

  Future<List<Task>> getAll() async {
    return realm.query<Task>("TRUEPREDICATE").toList();
  }

  Future<void> update(Task task,
      {String? summary, bool? isComplete, DateTime? deadline }) async {
    realm.write(() {
      if (summary != null) {
        task.task = summary;
      }
      if (isComplete != null) {
        task.isComplete = isComplete;

        if(!isComplete && !task.hasReminder){
          NotificationService.cancel(task.id.timestamp.hashCode);
        } else {
          NotificationService.scheduleForTask(task);
        }
      }
      task.deadline = deadline;
    });
    notifyListeners();
  }

  Future<void> updateReminder(Task task, DateTime? reminder, int reminderMode) async {
    if(reminder != null){
      reminder = NotificationService.getNextReminder(reminder, reminderMode);
    }

    realm.write(() {
      task.reminder = reminder;
      task.reminderRepeatMode = reminderMode;
    });
    notifyListeners();
  }
}