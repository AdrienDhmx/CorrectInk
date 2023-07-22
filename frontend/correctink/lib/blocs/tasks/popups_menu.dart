import 'package:correctink/utils/delete_helper.dart';
import 'package:flutter/material.dart';
import 'package:localization/localization.dart';

import '../../app/data/models/schemas.dart';
import '../../app/data/repositories/realm_services.dart';
import '../../app/screens/edit/modify_task.dart';
import '../../app/screens/edit/modify_todo.dart';
import '../../utils/popups_menu_options.dart';

class TaskPopupOption extends StatelessWidget{

  const TaskPopupOption(this.realmServices, this.task, {Key? key}) : super(key: key);

  final RealmServices realmServices;
  final Task task;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      child: PopupMenuButton<MenuOption>(
        onSelected: (menuItem) =>
            handleTaskMenuClick(context, menuItem, realmServices),
        itemBuilder: (context) => [
          PopupMenuItem<MenuOption>(
            value: MenuOption.edit,
            child: ListTile(
                leading: const Icon(Icons.edit), title: Text("Edit task".i18n())),
          ),
          PopupMenuItem<MenuOption>(
            value: MenuOption.delete,
            child: ListTile(
                leading: const Icon(Icons.delete),
                title: Text("Delete task".i18n())),
          ),
        ],
      ),
    );
  }
  void handleTaskMenuClick(BuildContext context, MenuOption menuItem, RealmServices realmServices) {
    switch (menuItem) {
      case MenuOption.edit:
        showModalBottomSheet(
          useRootNavigator: true,
          context: context,
          isScrollControlled: true,
          builder: (_) => Wrap(children: [ModifyTaskForm(task)]),
        );
        break;
      case MenuOption.delete:
          DeleteUtils.deleteTask(context, realmServices, task);
        break;
    }
  }
}

class TodoPopupOption extends StatelessWidget{

  const TodoPopupOption(this.realmServices, this.step, {Key? key}) : super(key: key);

  final RealmServices realmServices;
  final TaskStep step;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      child: PopupMenuButton<MenuOption>(
        onSelected: (menuItem) =>
            handleTaskMenuClick(context, menuItem, realmServices),
        itemBuilder: (context) => [
          PopupMenuItem<MenuOption>(
            value: MenuOption.edit,
            child: ListTile(
                leading: const Icon(Icons.edit), title: Text("Edit step".i18n())),
          ),
          PopupMenuItem<MenuOption>(
            value: MenuOption.delete,
            child: ListTile(
                leading: const Icon(Icons.delete),
                title: Text("Delete step".i18n())),
          ),
        ],
      ),
    );
  }
  void handleTaskMenuClick(BuildContext context, MenuOption menuItem, RealmServices realmServices) {
    switch (menuItem) {
      case MenuOption.edit:
        showModalBottomSheet(
          useRootNavigator: true,
          context: context,
          isScrollControlled: true,
          builder: (_) => Wrap(children: [ModifyTodoForm(step)]),
        );
        break;
      case MenuOption.delete:
        DeleteUtils.deleteStep(context, realmServices, step);
        break;
    }
  }
}