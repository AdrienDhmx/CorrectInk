import 'package:correctink/components/snackbars_widgets.dart';
import 'package:flutter/material.dart';
import 'package:correctink/modify/modify_card.dart';
import 'package:correctink/modify/modify_set.dart';
import 'package:localization/localization.dart';

import '../modify/modify_todo.dart';
import '../realm/realm_services.dart';
import '../realm/schemas.dart';
import '../modify/modify_task.dart';


enum MenuOption { edit, delete }

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
    bool isMine = (task.ownerId == realmServices.currentUser?.id);
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
        if (isMine) {
          realmServices.taskCollection.delete(task);
        } else {
          errorMessageSnackBar(context, "Error delete".i18n(),
              "Error delete message".i18n(["Tasks".i18n()]))
              .show(context);
        }
        break;
    }
  }
}

class TodoPopupOption extends StatelessWidget{

  const TodoPopupOption(this.realmServices, this.todo, {Key? key}) : super(key: key);

  final RealmServices realmServices;
  final ToDo todo;

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
          builder: (_) => Wrap(children: [ModifyTodoForm(todo)]),
        );
        break;
      case MenuOption.delete:
          realmServices.todoCollection.delete(todo);
        break;
    }
  }
}


class CardPopupOption extends StatelessWidget{

  const CardPopupOption(this.realmServices, this.card, this.canEdit, {Key? key}) : super(key: key);

  final RealmServices realmServices;
  final KeyValueCard card;
  final bool canEdit;

  @override
  Widget build(BuildContext context){
    return SizedBox(
      width: 40,
      child: PopupMenuButton<MenuOption>(
        onSelected: (menuItem) =>
            handleCardMenuClick(context, menuItem, card, realmServices),
        itemBuilder: (context) => [
          PopupMenuItem<MenuOption>(
            value: MenuOption.edit,
            child: ListTile(
                leading: const Icon(Icons.edit), title: Text("Edit card".i18n())),
          ),
          PopupMenuItem<MenuOption>(
            value: MenuOption.delete,
            child: ListTile(
                leading: const Icon(Icons.delete),
                title: Text("Delete card".i18n())),
          ),
        ],
      ),
    );
  }
  void handleCardMenuClick(BuildContext context, MenuOption menuItem, KeyValueCard card,
      RealmServices realmServices) {
    switch (menuItem) {
      case MenuOption.edit:
        if(canEdit){
          showModalBottomSheet(
            useRootNavigator: true,
            context: context,
            isScrollControlled: true,
            builder: (_) => Wrap(children: [ModifyCardForm(card)]),
          );
        }else{
          errorMessageSnackBar(context, "Error edit".i18n(),
              "Error edit message".i18n(["Cards".i18n()]))
              .show(context);
        }
        break;
      case MenuOption.delete:
        if(canEdit) {
          realmServices.cardCollection.delete(card);
        }else {
          errorMessageSnackBar(context, "Error delete".i18n(),
              "Error delete message".i18n(["Cards".i18n()]))
              .show(context);
        }
        break;
    }
  }
}

class SetPopupOption extends StatelessWidget{

  const SetPopupOption(this.realmServices, this.set, this.canEdit, {Key? key}) : super(key: key);

  final RealmServices realmServices;
  final CardSet set;
  final bool canEdit;

  @override
  Widget build(BuildContext context){
    return SizedBox(
      width: 40,
      child: PopupMenuButton<MenuOption>(
        onSelected: (menuItem) =>
            handleSetMenuClick(context, menuItem, realmServices),
        itemBuilder: (context) => [
          PopupMenuItem<MenuOption>(
            value: MenuOption.edit,
            child: ListTile(
                leading: const Icon(Icons.edit), title: Text("Edit set".i18n())),
          ),
          PopupMenuItem<MenuOption>(
            value: MenuOption.delete,
            child: ListTile(
                leading: const Icon(Icons.delete),
                title: Text("Delete set".i18n())),
          ),
        ],
      ),
    );
  }
  void handleSetMenuClick(BuildContext context, MenuOption menuItem, RealmServices realmServices) {
    switch (menuItem) {
      case MenuOption.edit:
        if(canEdit){
          showModalBottomSheet(
            useRootNavigator: true,
            context: context,
            isScrollControlled: true,
            builder: (_) => Wrap(children: [ModifySetForm(set)]),
          );
        }else{
          errorMessageSnackBar(context, "Error edit".i18n(),
              "Error edit message".i18n(["Sets".i18n()]))
              .show(context);
        }
        break;
      case MenuOption.delete:
        if(canEdit) {
          realmServices.setCollection.delete(set);
        }else {
          errorMessageSnackBar(context, "Error delete".i18n(),
              "Error delete message".i18n(["Sets".i18n()]))
              .show(context);
        }
        break;
    }
  }
}




