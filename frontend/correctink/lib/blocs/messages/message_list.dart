import 'package:flutter/material.dart';

import '../../app/data/models/schemas.dart';
import '../../app/services/inbox_service.dart';
import '../../utils/message_helper.dart';
import '../sets/popups_menu.dart';

class UserMessageList extends StatelessWidget {
  final List<UserMessage> messages;
  final InboxService inboxService;
  final Function(UserMessage) onTap;

  const UserMessageList({super.key, required this.messages, required this.inboxService, required this.onTap});

  @override
  Widget build(BuildContext context) {
    List<UserMessage> sortedMessages = messages;
    sortedMessages.sort((m1, m2) {
      return m2.message!.creationDate.millisecondsSinceEpoch - m1.message!.creationDate.millisecondsSinceEpoch;
    });
    return ListView.builder(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
        itemCount: messages.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          UserMessage message = messages[index];
          return ListTile(
            horizontalTitleGap: 16,
            contentPadding: const EdgeInsets.fromLTRB(8, 0, 4, 0),
            leading: message.message!.type != -1 ? MessageHelper.getIcon(message.message!.type, Theme.of(context).colorScheme.primary,) : null,
            title: Text(message.message!.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: UserMessagePopupOption(
              message,
              canMarkAsRead: !message.read,
              inboxService: inboxService,
            ),
            shape: index != messages.length - 1
                ? Border(bottom: BorderSide(color: Theme.of(context).colorScheme.onBackground.withAlpha(100)))
                : null,
            onTap: () {
              if(!message.read) {
                inboxService.markAsRead(message);
              }
              onTap(message);
            },
          );
        });
  }
}

class MessageList extends StatelessWidget {
  final List<Message> messages;
  final InboxService inboxService;
  final Function(Message) onTap;

  const MessageList({super.key, required this.messages, required this.inboxService, required this.onTap});

  @override
  Widget build(BuildContext context) {
    List<Message> sortedMessages = messages.toList();
    sortedMessages.sort((m1, m2) {
      return m2.creationDate.millisecondsSinceEpoch - m1.creationDate.millisecondsSinceEpoch;
    });
    return ListView.builder(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
        itemCount: messages.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          Message message = messages[index];
          return ListTile(
            horizontalTitleGap: 16,
            contentPadding: const EdgeInsets.fromLTRB(8, 0, 4, 0),
            leading: message.type != -1 ? MessageHelper.getIcon(message.type, Theme.of(context).colorScheme.primary,) : null,
            title: Text(message.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: MessagePopupOption(
              message,
              inboxService: inboxService,
            ),
            shape: index != messages.length - 1
                ? Border(bottom: BorderSide(color: Theme.of(context).colorScheme.onBackground.withAlpha(100)))
                : null,
            onTap: () {
              onTap(message);
            },
          );
        });
  }
}