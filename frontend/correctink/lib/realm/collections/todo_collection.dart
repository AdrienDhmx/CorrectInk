
import 'package:flutter/cupertino.dart';
import 'package:realm/realm.dart';

import '../realm_services.dart';
import '../schemas.dart';

class TodoCollection extends ChangeNotifier {
  final RealmServices _realmServices;
  Realm get realm => _realmServices.realm;

  TodoCollection(this._realmServices);

  void delete(TaskStep todo) {
    realm.write(() => realm.delete(todo));
    notifyListeners();
  }

  Future<void> update(TaskStep todo,
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

  void updateToDoIndex(List<TaskStep> todos){
    realm.write(() {
        for(int i = 0; i < todos.length; i++){
          todos[i].index = i;
        }
    });
    notifyListeners();
  }
}