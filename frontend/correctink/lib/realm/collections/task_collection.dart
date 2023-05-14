import 'package:flutter/cupertino.dart';
import 'package:realm/realm.dart';

import '../../sorting/task_sorting.dart';
import '../realm_services.dart';
import '../schemas.dart';

class TaskCollection extends ChangeNotifier {
  final RealmServices _realmServices;
  Realm get realm => _realmServices.realm;

  TaskCollection(this._realmServices);

  void create(String summary, bool isComplete, DateTime? deadline) {
    final newTask =
    Task(ObjectId(), summary, _realmServices.currentUser!.id, isComplete: isComplete, deadline: deadline?.add(const Duration(hours: 2)));
    realm.write<Task>(() => realm.add<Task>(newTask));
    notifyListeners();
  }

  void delete(Task task) {
    realm.write(() => realm.delete(task));
    notifyListeners();
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

  Future<void> update(Task task,
      {String? summary, bool? isComplete, DateTime? deadline}) async {
    realm.write(() {
      if (summary != null) {
        task.task = summary;
      }
      if (isComplete != null) {
        task.isComplete = isComplete;
      }
      if (deadline != null) {
        task.deadline = deadline;
      }
    });
    notifyListeners();
  }
}