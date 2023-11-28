import 'package:correctink/blocs/report_dialog.dart';
import 'package:correctink/utils/card_helper.dart';
import 'package:correctink/utils/delete_helper.dart';
import 'package:correctink/widgets/widgets.dart';
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
  final Flashcard card;
  final bool canEdit;
  final FlashcardSet set;

  @override
  Widget build(BuildContext context){
    return SizedBox(
      width: 40,
      child: PopupMenuButton<CardMenuOption>(
        onSelected: (menuItem) => handleCardMenuClick(context, menuItem, card, realmServices),
        itemBuilder: (context) => [
          if(canEdit)
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
          if(canEdit)
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
  void handleCardMenuClick(BuildContext context, CardMenuOption menuItem, Flashcard card, RealmServices realmServices) {
    switch (menuItem) {
      case CardMenuOption.edit:
        if(canEdit){
          showBottomSheetModal(context, ModifyCardForm(card));
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

  const SetPopupOption(this.realmServices, this.set, this.canEdit, {Key? key, required this.canReport, required this.like, this.horizontalIcon = false}) : super(key: key);

  final RealmServices realmServices;
  final FlashcardSet set;
  final bool canEdit;
  final bool canReport;
  final bool like;
  final bool horizontalIcon;

  @override
  Widget build(BuildContext context){
    return SizedBox(
      width: 40,
      child: PopupMenuButton<SetMenuOption>(
        onSelected: (option) => handleSetMenuClick(context, option, realmServices),
        icon: horizontalIcon ? const Icon(Icons.more_horiz_rounded) :  const Icon(Icons.more_vert_rounded) ,
        itemBuilder: (context) => [
          if(canEdit)...[
            PopupMenuItem<SetMenuOption>(
              value: SetMenuOption.edit,
              child: ListTile(
                  leading: const Icon(Icons.edit), title: Text("Edit set".i18n())),
            ),
            PopupMenuItem<SetMenuOption>(
              value: SetMenuOption.delete,
              child: ListTile(
                  leading: const Icon(Icons.delete),
                  title: Text("Delete set".i18n())),
            ),
          ]
          else ...[
            PopupMenuItem<SetMenuOption>(
              value: SetMenuOption.like,
              child: ListTile(
                  leading: like ? const Icon(Icons.thumb_up_alt_rounded) : const Icon(Icons.thumb_up_off_alt_outlined),
                  title: Text(like ? "Unlike set".i18n() : "Like set".i18n())
              ),
            ),
            if(canReport)
              PopupMenuItem<SetMenuOption>(
                value: SetMenuOption.report,
                child: ListTile(
                  leading: const Icon(Icons.report_rounded),
                  title: Text("Report set".i18n())
                ),
              ),
          ]
        ]
      ),
    );
  }
  void handleSetMenuClick(BuildContext context, SetMenuOption menuItem, RealmServices realmServices) {
    switch (menuItem) {
      case SetMenuOption.edit:
        showBottomSheetModal(context, ModifySetForm(set));
        break;
      case SetMenuOption.delete:
        DeleteUtils.deleteSet(context, realmServices, set);
        break;
      case SetMenuOption.like:
        realmServices.setCollection.likeSet(set, !like);
        realmServices.userService.likeSet(set, !like);
        break;
      case SetMenuOption.report:
        showDialog(context: context, builder: (context) {
          return ReportSetDialog(set: set);
        });
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
        showBottomSheetModal(context, MessageEditor(message: message,),
          isDismissible: false,
          constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width
          ),
        );
        break;
      case MenuOption.delete:
        DeleteUtils.deleteMessage(context, message, inboxService);
        break;
    }
  }
}