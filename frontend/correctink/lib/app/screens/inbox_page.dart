import 'package:correctink/app/data/repositories/collections/users_collection.dart';
import 'package:correctink/app/services/inbox_service.dart';
import 'package:correctink/blocs/messages/message_editor.dart';
import 'package:flutter/material.dart';
import 'package:localization/localization.dart';
import 'package:provider/provider.dart';

import '../../blocs/messages/message_list.dart';
import '../../widgets/widgets.dart';
import '../data/repositories/realm_services.dart';

class InboxPage extends StatefulWidget {
  const InboxPage({super.key});

  @override
  State<StatefulWidget> createState() => _InboxPage();
}

class _InboxPage extends State<InboxPage> {
  late InboxService? inboxService;
  late RealmServices realmServices;
  late bool showUnreadMessages = true;
  late bool showSendMessages = false;


  @override
  void didChangeDependencies()  {
    super.didChangeDependencies();

    inboxService = Provider.of(context);
    realmServices = Provider.of(context);

    inboxService!.checkReceivedMessagesValidity();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraint) {
        return Scaffold(
          floatingActionButton: realmServices.userService.currentUserData!.role >= UserService.moderator
              ? styledFloatingButton(context,
                  tooltip: 'Write message'.i18n(),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  icon: Icons.edit_rounded,
                  onPressed: () => showModalBottomSheet(
                    useRootNavigator: true,
                    context: context,
                    isScrollControlled: true,
                    constraints: BoxConstraints(
                        maxWidth: constraint.maxWidth
                    ),
                    builder: (_) {
                      return const Wrap(
                        children: [
                          MessageEditor(),
                        ]
                    );
                    },
                  ),
                )
              : null,
          body: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              styledHeaderFooterBox(context,
                isHeader: true,
                child: Row(
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
                          child: realmServices.userService.currentUserData!.role >= UserService.moderator
                                ? labeledAction(context: context,
                                  labelFirst: false,
                                  infiniteWidth: false,
                                  center: true,
                                  height: 40,
                                  onTapAction: (){
                                    setState(() {
                                      showSendMessages = !showSendMessages;
                                    });
                                  },
                                  label: "${showSendMessages ? "Received" : "Sent"} messages".i18n(),
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(0, 0, 6, 0),
                                    child: Icon(showSendMessages ? Icons.mail_rounded : Icons.send_rounded, color:  Theme.of(context).colorScheme.onPrimaryContainer,),
                                  ),
                                )
                                : Text("Inbox header ${inboxService!.inbox.receivedMessages.length > 1 ? "messages" : "message"}".i18n([inboxService!.inbox.receivedMessages.length.toString()]),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: Theme.of(context).colorScheme.onPrimaryContainer
                                  ),
                                ),
                        ),
                      ),
                    ),
                    if(!showSendMessages) ... [
                      IconButton(
                        onPressed: () {
                          inboxService?.markAllAsRead();
                        },
                        icon: const Icon(Icons.visibility_rounded),
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        tooltip: "Mark all as read".i18n(),
                      ),
                      const SizedBox(width: 8,),
                      IconButton(
                          onPressed: () {
                            inboxService?.deleteAll();
                          },
                          icon: const Icon(Icons.delete_rounded),
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        tooltip: "Delete all messages".i18n(),
                      ),
                    ],
                  ],
                ),
              ),
              if(inboxService!.inbox.receivedMessages.isNotEmpty && !showSendMessages)
                Expanded(
                  child: Material(
                    elevation: 0,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: ListView(
                            shrinkWrap: true,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                    border: Border(bottom: BorderSide(color: Theme.of(context).colorScheme.secondary))
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(12, 8, 8, 6),
                                  child: Text("Unread messages".i18n(),
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                      color: Theme.of(context).colorScheme.secondary,
                                    ),
                                  ),
                                ),
                              ),
                              if(inboxService!.unreadMessages.isNotEmpty)
                                UserMessageList(messages: inboxService!.unreadMessages, inboxService: inboxService!,)
                              else
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Text(
                                      "Unread messages empty".i18n(),
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                ),

                              Container(
                                decoration: BoxDecoration(
                                  border: Border(bottom: BorderSide(color: Theme.of(context).colorScheme.secondary))
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(12, 8, 8, 6),
                                  child: Text("Read messages".i18n(),
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                      color: Theme.of(context).colorScheme.secondary,
                                    ),
                                  ),
                                ),
                              ),
                              UserMessageList(messages: inboxService!.readMessages, inboxService: inboxService!,)
                            ],
                      ),
                    ),
                  ),
                )
              else if(showSendMessages)
                MessageList(messages: inboxService!.inbox.sendMessages, inboxService: inboxService!)
            ],
          ),
        );
      }
    );
  }

}
