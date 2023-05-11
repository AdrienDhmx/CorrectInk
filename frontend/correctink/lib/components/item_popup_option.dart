import 'package:correctink/components/snackbars_widgets.dart';
import 'package:flutter/material.dart';
import 'package:correctink/components/widgets.dart';
import 'package:correctink/modify/modify_card.dart';
import 'package:correctink/modify/modify_set.dart';

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
            handleTaskMenuClick(context, menuItem, task, realmServices),
        itemBuilder: (context) => [
          const PopupMenuItem<MenuOption>(
            value: MenuOption.edit,
            child: ListTile(
                leading: Icon(Icons.edit), title: Text("Edit task")),
          ),
          const PopupMenuItem<MenuOption>(
            value: MenuOption.delete,
            child: ListTile(
                leading: Icon(Icons.delete),
                title: Text("Delete task")),
          ),
        ],
      ),
    );
  }
  void handleTaskMenuClick(BuildContext context, MenuOption menuItem, Task item,
      RealmServices realmServices) {
    bool isMine = (item.ownerId == realmServices.currentUser?.id);
    switch (menuItem) {
      case MenuOption.edit:
        if (isMine) {
          showModalBottomSheet(
            useRootNavigator: true,
            context: context,
            isScrollControlled: true,
            builder: (_) => Wrap(children: [ModifyTaskForm(item)]),
          );
        } else {
          errorMessageSnackBar(context, "Edit not allowed!",
              "You are not allowed to edit tasks \nthat don't belong to you.")
              .show(context);
        }
        break;
      case MenuOption.delete:
        if (isMine) {
          realmServices.deleteTask(item);
        } else {
          errorMessageSnackBar(context, "Delete not allowed!",
              "You are not allowed to delete tasks \n that don't belong to you.")
              .show(context);
        }
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
          const PopupMenuItem<MenuOption>(
            value: MenuOption.edit,
            child: ListTile(
                leading: Icon(Icons.edit), title: Text("Edit card")),
          ),
          const PopupMenuItem<MenuOption>(
            value: MenuOption.delete,
            child: ListTile(
                leading: Icon(Icons.delete),
                title: Text("Delete card")),
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
          errorMessageSnackBar(context, "Edit not allowed!",
              "You are not allowed to edit cards \nthat don't belong to you.")
              .show(context);
        }
        break;
      case MenuOption.delete:
        if(canEdit) {
          realmServices.deleteKeyValueCard(card);
        }else {
          errorMessageSnackBar(context, "Delete not allowed!",
              "You are not allowed to edit cards \nthat don't belong to you.")
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
          const PopupMenuItem<MenuOption>(
            value: MenuOption.edit,
            child: ListTile(
                leading: Icon(Icons.edit), title: Text("Edit set")),
          ),
          const PopupMenuItem<MenuOption>(
            value: MenuOption.delete,
            child: ListTile(
                leading: Icon(Icons.delete),
                title: Text("Delete set")),
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
          errorMessageSnackBar(context, "Edit not allowed!",
              "You are not allowed to edit sets \nthat don't belong to you.")
              .show(context);
        }
        break;
      case MenuOption.delete:
        if(canEdit) {
          realmServices.deleteSet(set);
        }else {
          errorMessageSnackBar(context, "Delete not allowed!",
              "You are not allowed to edit sets \nthat don't belong to you.")
              .show(context);
        }
        break;
    }
  }
}




