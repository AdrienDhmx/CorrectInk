import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:localization/localization.dart';

import '../app/data/models/schemas.dart';
import '../app/data/repositories/realm_services.dart';
import '../widgets/widgets.dart';

class DeleteUtils {
  static void deleteTask(BuildContext context, RealmServices realmServices, Task task){
    deleteConfirmationDialog(context,
        title: "Delete task confirmation title".i18n(),
        content: "Delete task confirmation content".i18n(),
        onDelete:() {
          realmServices.taskCollection.delete(task);
          GoRouter.of(context).pop();
        });
  }

  static void deleteStep(BuildContext context, RealmServices realmServices, TaskStep step){
    deleteConfirmationDialog(context,
        title: "Delete step confirmation title".i18n(),
        content: "Delete step confirmation content".i18n(),
        onDelete: () {
          realmServices.todoCollection.delete(step);
          GoRouter.of(context).pop();
        });
  }

  static void deleteSet(BuildContext context, RealmServices realmServices, CardSet set){
    deleteConfirmationDialog(context,
        title: "Delete set confirmation title".i18n(),
        content: "Delete set confirmation content".i18n(),
        onDelete: () {
          realmServices.setCollection.delete(set);
          GoRouter.of(context).pop();
        });
  }

  static void deleteCard(BuildContext context, RealmServices realmServices, KeyValueCard card){
    deleteConfirmationDialog(context,
        title: "Delete card confirmation title".i18n(),
        content: "Delete card confirmation content".i18n(),
        onDelete: () {
          realmServices.cardCollection.delete(card);
          GoRouter.of(context).pop();
        });
  }
}