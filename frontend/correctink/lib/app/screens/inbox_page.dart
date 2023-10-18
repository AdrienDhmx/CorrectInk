import 'package:correctink/app/data/repositories/collections/users_collection.dart';
import 'package:correctink/app/services/inbox_service.dart';
import 'package:correctink/blocs/messages/message_editor.dart';
import 'package:correctink/blocs/messages/message_reader.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:localization/localization.dart';
import 'package:provider/provider.dart';

import '../../blocs/messages/message_list.dart';
import '../../utils/router_helper.dart';
import '../../widgets/widgets.dart';
import '../data/models/schemas.dart';
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
  late Message? selectedMessage;

  @override
  void didChangeDependencies()  {
    super.didChangeDependencies();

    inboxService = Provider.of(context);
    realmServices = Provider.of(context);

    inboxService!.checkReceivedMessagesValidity();
    if( inboxService!.readMessagesCount > 0) {
        selectedMessage = inboxService!.readMessages.last.message!;
    } else {
      selectedMessage = null;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void selectMessage(Message message) {
    setState(() {
      selectedMessage = message;
    });
  }

  void goToMessagePage(Message message) {
    GoRouter.of(context).push(RouterHelper.buildInboxMessageRoute(message.messageId.hexString, false));
  }

  void goToUserMessagePage(UserMessage message) {
    GoRouter.of(context).push(RouterHelper.buildInboxMessageRoute(message.userMessageId.hexString, true));
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
                      return Wrap(
                        children: [
                          MessageEditor(),
                        ]
                    );
                    },
                  ),
                )
              : null,
          body: LayoutBuilder(
            builder: (context, constraint) {
              return Column(
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
                        AnimatedOpacity(
                            opacity: showSendMessages ? 0 : 1,
                            duration: const Duration(milliseconds: 200),
                            child: Row(
                              children: [
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
                            ),
                          )
                      ],
                    ),
                  ),

                  if(constraint.maxWidth >= 850) ...[
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if(inboxService!.inbox.receivedMessages.isNotEmpty && !showSendMessages)
                            SizedBox(
                              width: constraint.maxWidth * 0.3,
                              child: Column(
                                children: [
                                  Material(
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
                                            UserMessageList(
                                              messages: inboxService!.unreadMessages,
                                              inboxService: inboxService!,
                                              onTap: (message) {
                                                selectMessage(message.message!);
                                              },
                                            )
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
                                          UserMessageList(
                                            messages: inboxService!.readMessages,
                                            inboxService: inboxService!,
                                            onTap: (message) {
                                              selectMessage(message.message!);
                                            },
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if(showSendMessages)
                            SizedBox(
                              width: constraint.maxWidth * 0.3,
                              child: MessageList(
                                messages: inboxService!.inbox.sendMessages,
                                inboxService: inboxService!,
                                onTap: selectMessage,
                              ),
                            ),

                          Expanded(
                              child: selectedMessage != null
                                ? MessageReader(message: selectedMessage!)
                                : Container(
                                    color: Theme.of(context).colorScheme.surfaceVariant,
                                  ),
                          ),
                        ],
                      ),
                    )
                  ]
                  else ... [
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
                                      UserMessageList(
                                        messages: inboxService!.unreadMessages,
                                        inboxService: inboxService!,
                                        onTap: (message) {
                                          goToUserMessagePage(message);
                                        },
                                      )
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
                                    UserMessageList(
                                      messages: inboxService!.readMessages,
                                      inboxService: inboxService!,
                                      onTap: (message) {
                                        goToUserMessagePage(message);
                                      },
                                    )
                                  ],
                            ),
                          ),
                        ),
                      )
                    else if(showSendMessages)
                      MessageList(
                          messages: inboxService!.inbox.sendMessages,
                          inboxService: inboxService!,
                          onTap: (message) {
                              goToMessagePage(message);
                          },
                      )
                  ],

                ],
              );
            }
          ),
        );
      }
    );
  }

}
