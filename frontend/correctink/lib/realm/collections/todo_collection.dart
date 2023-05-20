
import 'package:flutter/cupertino.dart';
import 'package:realm/realm.dart';

import '../realm_services.dart';
import '../schemas.dart';

class TodoCollection extends ChangeNotifier {
  final RealmServices _realmServices;
  Realm get realm => _realmServices.realm;

  TodoCollection(this._realmServices);

  void create(String summary, ObjectId taskId, bool isComplete) {
    final newTodo = ToDo(ObjectId(), summary, taskId, isComplete: isComplete);
    realm.write<ToDo>(() => realm.add<ToDo>(newTodo));
    notifyListeners();
  }

  void delete(ToDo todo) {
    realm.write(() => realm.delete(todo));
    notifyListeners();
  }

  RealmResults<ToDo> get(String taskId){
    return realm.query<ToDo>(r'task_id = $0', [ObjectId.fromHexString(taskId)]);
  }

  Future<void> update(ToDo todo,
      {String? summary, bool? isComplete}) async {
    realm.write(() {
      if (summary != null) {
        todo.todo = summary;
      }
      if (isComplete != null) {
        todo.isComplete = isComplete;
      }
    });
    notifyListeners();
  }
}