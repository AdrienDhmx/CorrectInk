import 'package:correctink/utils/card_helper.dart';
import 'package:correctink/utils/delete_helper.dart';
import 'package:flutter/material.dart';
import 'package:localization/localization.dart';

import '../../app/data/models/schemas.dart';
import '../../app/data/repositories/realm_services.dart';
import '../../app/screens/edit/modify_card.dart';
import '../../app/screens/edit/modify_set.dart';
import '../../app/services/inbox_service.dart';
import '../../utils/popups_menu_options.dart';
import '../../widgets/snackbars_widgets.dart';
import '../messages/message_editor.dart';

class CardPopupOption extends StatelessWidget{

  const CardPopupOption(this.realmServices, this.card, this.canEdit, {Key? key, required this.set}) : super(key: key);

  final RealmServices realmServices;
  final KeyValueCard card;
  final bool canEdit;
  final CardSet set;

  @override
  Widget build(BuildContext context){
    return SizedBox(
      width: 40,
      child: PopupMenuButton<CardMenuOption>(
        onSelected: (menuItem) => handleCardMenuClick(context, menuItem, card, realmServices),
        itemBuilder: (context) => [
          PopupMenuItem<CardMenuOption>(
            value: CardMenuOption.edit,
            child: ListTile(
                leading: const Icon(Icons.edit), title: Text("Edit card".i18n())),
          ),
          PopupMenuItem<CardMenuOption>(
            value: CardMenuOption.copy,
            child: ListTile(
                leading: const Icon(Icons.copy_all_rounded), title: Text("Copy card".i18n())),
          ),
          PopupMenuItem<CardMenuOption>(
            value: CardMenuOption.delete,
            child: ListTile(
                leading: const Icon(Icons.delete),
                title: Text("Delete card".i18n())),
          ),
        ],
      ),
    );
  }
  void handleCardMenuClick(BuildContext context, CardMenuOption menuItem, KeyValueCard card, RealmServices realmServices) {
    switch (menuItem) {
      case CardMenuOption.edit:
        if(canEdit){
          showModalBottomSheet(
            useRootNavigator: true,
            context: context,
            isScrollControlled: true,
            builder: (_) => Wrap(children: [ModifyCardForm(card)]),
          );
        }else{
          errorMessageSnackBar(context, "Error edit".i18n(), "Error edit message".i18n(["Cards".i18n()])).show(context);
        }
        break;
      case CardMenuOption.copy:
        CardHelper.copyCardToSet(context, set, card, realmServices);
        break;
      case CardMenuOption.delete:
        if(canEdit) {
          DeleteUtils.deleteCard(context, realmServices, card);
        }else {
          errorMessageSnackBar(context, "Error delete".i18n(), "Error delete message".i18n(["Cards".i18n()])).show(context);
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
          DeleteUtils.deleteSet(context, realmServices, set);
        }else {
          errorMessageSnackBar(context, "Error delete".i18n(),
              "Error delete message".i18n(["Sets".i18n()]))
              .show(context);
        }
        break;
    }
  }
}

class UserMessagePopupOption extends StatelessWidget{

  const UserMessagePopupOption(this.message, {Key? key, required this.canMarkAsRead, required this.inboxService}) : super(key: key);

  final UserMessage message;
  final bool canMarkAsRead;
  final InboxService inboxService;

  @override
  Widget build(BuildContext context){
    return SizedBox(
      width: 40,
      child: PopupMenuButton<UserMessageMenuOption>(
        onSelected: (menuItem) => handleSetMenuClick(context, menuItem),
        itemBuilder: (context) => [
          PopupMenuItem<UserMessageMenuOption>(
            value: UserMessageMenuOption.markAsRead,
            child: ListTile(
                leading: Icon(canMarkAsRead ? Icons.visibility_rounded : Icons.visibility_off_rounded),
                title: Text(canMarkAsRead ? "Mark as read".i18n() : "Mark as unread".i18n())
            ),
          ),
          PopupMenuItem<UserMessageMenuOption>(
            value: UserMessageMenuOption.delete,
            child: ListTile(
                leading: const Icon(Icons.delete),
                title: Text("Delete message".i18n())),
          ),
        ],
      ),
    );
  }

  void handleSetMenuClick(BuildContext context, UserMessageMenuOption menuItem) {
    switch (menuItem) {
      case UserMessageMenuOption.markAsRead:
        inboxService.markAsRead(message);
      case UserMessageMenuOption.delete:
        inboxService.delete(message);
        break;
    }
  }
}

class MessagePopupOption extends StatelessWidget{

  const MessagePopupOption(this.message, {Key? key, required this.inboxService}) : super(key: key);

  final Message message;
  final InboxService inboxService;

  @override
  Widget build(BuildContext context){
    return SizedBox(
      width: 40,
      child: PopupMenuButton<MenuOption>(
        onSelected: (menuItem) => handleSetMenuClick(context, menuItem),
        itemBuilder: (context) => [
          PopupMenuItem<MenuOption>(
            value: MenuOption.edit,
            child: ListTile(
                leading: const Icon(Icons.edit_rounded),
                title: Text("Edit message".i18n())
            ),
          ),
          PopupMenuItem<MenuOption>(
            value: MenuOption.delete,
            child: ListTile(
                leading: const Icon(Icons.delete),
                title: Text("Delete message".i18n())),
          ),
        ],
      ),
    );
  }

  void handleSetMenuClick(BuildContext context, MenuOption menuItem) {
    switch (menuItem) {
      case MenuOption.edit:
        showModalBottomSheet(
          useRootNavigator: true,
          context: context,
          isScrollControlled: true,
          constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width
          ),
          builder: (_) => Wrap(
              children: [
                MessageEditor(message: message,),
              ]
          ),
        );
        break;
      case MenuOption.delete:
        DeleteUtils.deleteMessage(context, message, inboxService);
        break;
    }
  }
}