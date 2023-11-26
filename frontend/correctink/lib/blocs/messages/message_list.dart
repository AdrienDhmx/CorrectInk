import 'package:correctink/app/data/repositories/realm_services.dart';
import 'package:correctink/utils/sorting_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/data/models/schemas.dart';
import '../../app/services/inbox_service.dart';
import '../../utils/message_utils.dart';
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
      return m2.message!.sendDate.millisecondsSinceEpoch - m1.message!.sendDate.millisecondsSinceEpoch;
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
            leading: message.message!.icon != -1 ? MessageIcons.values[message.message!.icon + 1].getIcon(context) : null,
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
      return m2.sendDate.millisecondsSinceEpoch - m1.sendDate.millisecondsSinceEpoch;
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
            leading: message.icon != -1 ? MessageIcons.values[message.icon + 1].getIcon(context) : null,
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

class ReportMessageList extends StatelessWidget {
  final List<ReportMessage> messages;
  final InboxService inboxService;
  final Function(ReportMessage) onTap;

  const ReportMessageList({super.key, required this.messages, required this.inboxService, required this.onTap});

  @override
  Widget build(BuildContext context) {
    List<ReportMessage> sortedMessages = messages.toList();
    sortedMessages.sort((m1, m2) {
      return m2.reportDate.millisecondsSinceEpoch.compareTo(m1.reportDate.millisecondsSinceEpoch);
    });
    return ListView.builder(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
        itemCount: sortedMessages.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          ReportMessage message = sortedMessages[index];
          return ListTile(
            horizontalTitleGap: 16,
            contentPadding: const EdgeInsets.fromLTRB(8, 0, 4, 0),
            leading: MessageIcons.report.getIcon(context),
            title: Text(message.getTitle(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: message.resolved || message.reportedSet == null || message.reportedUser == null
                ? IconButton(icon: const Icon(Icons.delete_rounded), onPressed: () {
                      RealmServices realmServices = Provider.of(context, listen: false);
                      realmServices.realm.writeAsync((){
                        // remove the message from the list of the moderator
                        // don't delete it as it may still be used for a next report...
                        realmServices.userService.currentUserData!.inbox!.reports.remove(message);
                      });
                    },
                  )
              : null,
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