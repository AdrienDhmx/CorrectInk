import 'dart:async';

import 'package:correctink/app/services/inbox_service.dart';
import 'package:correctink/utils/router_helper.dart';
import 'package:correctink/widgets/snackbars_widgets.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:localization/localization.dart';

import '../app/data/models/schemas.dart';
import '../app/data/repositories/realm_services.dart';
import '../widgets/widgets.dart';

class DeleteUtils {
  static void deleteTask(BuildContext context, RealmServices realmServices,
      Task task) {
    deleteConfirmationDialog(context,
        title: "Delete task confirmation title".i18n(),
        content: "Delete task confirmation content".i18n(),
        onDelete: () {
          realmServices.taskCollection.delete(task);
          GoRouter.of(context).pop();
        });
  }

  static void deleteStep(BuildContext context, RealmServices realmServices,
      TaskStep step) {
    deleteConfirmationDialog(context,
        title: "Delete step confirmation title".i18n(),
        content: "Delete step confirmation content".i18n(),
        onDelete: () {
          realmServices.todoCollection.delete(step);
          GoRouter.of(context).pop();
        });
  }

  static void deleteSet(BuildContext context, RealmServices realmServices,
      CardSet set) {
    deleteConfirmationDialog(context,
        title: "Delete set confirmation title".i18n(),
        content: "Delete set confirmation content".i18n(),
        onDelete: () {
          realmServices.setCollection.delete(set);
          GoRouter.of(context).pop();
        });
  }

  static void deleteCard(BuildContext context, RealmServices realmServices,
      KeyValueCard card, {Function? onDelete}) {
    deleteConfirmationDialog(
        context,
        title: "Delete card confirmation title".i18n(),
        content: "Delete card confirmation content".i18n(),
        onDelete: () {
          realmServices.cardCollection.delete(card);
          if (onDelete != null) onDelete();
          GoRouter.of(context).pop();
        }
    );
  }

  static void deleteCards(BuildContext context, RealmServices realmServices,
      List<KeyValueCard> cards, {Function? onDelete}) {
    deleteConfirmationDialog(
        context,
        title: "Delete multiple card confirmation title".i18n(
            [cards.length.toString()]),
        content: "Delete multiple card confirmation content".i18n(
            [cards.length.toString()]),
        onDelete: () {
          realmServices.cardCollection.deleteAll(cards);
          if (onDelete != null) onDelete();
          GoRouter.of(context).pop();
        }
    );
  }

  static void deleteAccount(BuildContext context, RealmServices realmServices) {
    deleteConfirmationDialog(
        context,
        title: "Delete account confirmation title".i18n(),
        content: "Delete account confirmation content".i18n(),
        onDelete: () {
          Timer(const Duration(milliseconds: 200), () {
            realmServices.deleteAccount();
          });
          GoRouter.of(context).go(RouterHelper.loginRoute);
          infoMessageSnackBar(context, "Account Deleted !").show(
              context, durationInSeconds: 4);
          GoRouter.of(context).pop(); // close the dialog
        }
    );
  }


  static void deleteMessage(BuildContext context, Message message,
      InboxService inboxService) {
    deleteConfirmationDialog(
        context,
        title: "Delete message confirmation title".i18n(),
        content: "Delete message confirmation content".i18n([message.title]),
        onDelete: () {
          inboxService.deleteMessage(message);
          GoRouter.of(context).pop(); // close the dialog
        }
    );
  }
}