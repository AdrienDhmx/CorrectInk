import 'package:correctink/app/services/inbox_service.dart';
import 'package:correctink/blocs/messages/message_editor.dart';
import 'package:correctink/blocs/messages/message_reader.dart';
import 'package:correctink/utils/message_helper.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:localization/localization.dart';
import 'package:provider/provider.dart';

import '../../blocs/messages/message_list.dart';
import '../../utils/router_helper.dart';
import '../../widgets/widgets.dart';
import '../data/models/schemas.dart';
import '../data/repositories/collections/users_collection.dart';
import '../data/repositories/realm_services.dart';

class InboxPage extends StatefulWidget {
  const InboxPage({super.key});

  @override
  State<StatefulWidget> createState() => _InboxPage();
}

class _InboxPage extends State<InboxPage> with TickerProviderStateMixin  {
  late InboxService? inboxService;
  late RealmServices realmServices;
  late bool showUnreadMessages = true;
  late bool showSendMessages = false;
  late Message? selectedMessage;
  late ReportMessage? selectedReportMessage;
  late bool canSenMessage = false;
  late TabController _tabController;
  final List<String> tabs = ["Received messages", "Sent messages", "Received Reports", "Passed Reports"];

  @override
    void initState() {
      super.initState();
      initTabController(tabs.length);
    }

  @override
  void didChangeDependencies()  {
    super.didChangeDependencies();

    inboxService = Provider.of(context);
    realmServices = Provider.of(context);

    canSenMessage = realmServices.userService.currentUserData!.role >= UserService.moderator;
    inboxService!.checkReceivedMessagesValidity();

    int nbTab = canSenMessage ? tabs.length : 1;
    if(_tabController.length != nbTab) {
      _tabController.dispose();
      initTabController(nbTab);
    }

    selectedReportMessage = null;
    if(inboxService!.readMessagesCount > 0) {
        selectedMessage = inboxService!.readMessages.last.message!;
    } else {
      selectedMessage = null;
    }
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  void initTabController(int nbTab) {
    _tabController = TabController(length: nbTab, vsync: this);
    if(nbTab > 1) {
      _tabController.addListener(() {
      switch(_tabController.index) {
        case 0:
          setState(() {
            selectedReportMessage = null;
            if(inboxService!.readMessagesCount > 0) {
              selectedMessage = inboxService!.readMessages.last.message!;
            } else {
              selectedMessage = null;
            }
          });
          break;
        case 1:
          setState(() {
            selectedReportMessage = null;
            selectedMessage = inboxService!.inbox.sendMessages.lastOrNull;
          });
          break;
        case 2:
          setState(() {
            selectedReportMessage = inboxService!.inbox.reports.where((report) => !report.resolved).lastOrNull;
            selectedMessage = selectedReportMessage?.toMessage();
          });
          break;
        case 3:
          setState(() {
            selectedReportMessage = inboxService!.inbox.reports.where((report) => report.resolved).lastOrNull;
            selectedMessage = selectedReportMessage?.toMessage();
          });
          break;
        default:
          break;
      }
    });
    }
  }

  void selectMessage(Message message) {
    setState(() {
      selectedMessage = message;
    });
  }

  void goToMessagePage(Message message, {isReport = false}) {
    GoRouter.of(context).push(RouterHelper.buildInboxMessageRoute(message.messageId.hexString, false, isReportMessage: isReport));
  }

  void goToUserMessagePage(UserMessage message) {
    GoRouter.of(context).push(RouterHelper.buildInboxMessageRoute(message.userMessageId.hexString, true));
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraint) {
        return Scaffold(
          floatingActionButton: canSenMessage
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
                    isDismissible: false,
                    useSafeArea: true,
                    enableDrag: false,
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
          body: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                   Material(
                     color: ElevationOverlay.applySurfaceTint(Theme.of(context).colorScheme.surface, Theme.of(context).colorScheme.surfaceTint, 5),
                     elevation: 1,
                     child: TabBar(
                       controller: _tabController,
                        indicatorSize: TabBarIndicatorSize.tab,
                        isScrollable: canSenMessage,
                        tabs: [
                          Tab(
                            text: tabs[0].i18n(),
                          ),
                          if(canSenMessage) ... [
                            Tab(
                              text: tabs[1].i18n(),
                            ),
                            Tab(
                              text: tabs[2].i18n(),
                            ),
                            Tab(
                              text: tabs[3].i18n(),
                            )
                          ]
                        ],
                      ),
                   ),

                  if(constraint.maxWidth >= 850) ...[
                     Expanded(
                       child: TabBarView(
                         controller: _tabController,
                         children: [
                          Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                              SizedBox(
                                width: constraint.maxWidth * 0.3,
                                child: textPlaceHolder(context,
                                    condition: inboxService!.inbox.receivedMessages.isNotEmpty,
                                    placeholder: "Received messages empty".i18n(),
                                    child: SingleChildScrollView(
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
                                ),
                              ),
                            const VerticalDivider(
                              indent: 24,
                              endIndent: 24,
                            ),
                            if(selectedMessage != null)
                              Expanded(
                                  child: MessageReader(message: selectedMessage!)
                              )
                            ],
                          ),

                          if(canSenMessage)... [
                            Row(
                               crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               SizedBox(
                                 width: constraint.maxWidth * 0.3,
                                 child: textPlaceHolder(context,
                                     condition: inboxService!.inbox.sendMessages.isNotEmpty,
                                     placeholder: "Send messages empty".i18n(),
                                     child: MessageList(
                                       messages: inboxService!.inbox.sendMessages,
                                       inboxService: inboxService!,
                                       onTap: selectMessage,
                                     ),
                                 ),
                               ),
                               const VerticalDivider(
                                 indent: 24,
                                 endIndent: 24,
                               ),
                               if(selectedMessage != null)
                                 Expanded(
                                   child: MessageReader(message: selectedMessage!)
                                 )
                             ],
                           ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: constraint.maxWidth * 0.3,
                                  child: textPlaceHolder(context,
                                      condition: inboxService!.inbox.reports.where((report) => !report.resolved).isNotEmpty,
                                      placeholder: "No reports".i18n(),
                                      child: ReportMessageList(
                                        messages: inboxService!.inbox.reports.where((report) => !report.resolved).toList(),
                                        inboxService: inboxService!,
                                        onTap: (report) {
                                          setState(() {
                                            selectedReportMessage = report;
                                          });
                                          selectMessage(report.toMessage());
                                        },
                                      ),
                                  ),
                                ),
                                const VerticalDivider(
                                  indent: 24,
                                  endIndent: 24,
                                ),
                                if(selectedMessage != null)
                                  Expanded(
                                      child: MessageReader(message: selectedMessage!, report: selectedReportMessage,)
                                  )
                              ],
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: constraint.maxWidth * 0.3,
                                  child: textPlaceHolder(context,
                                    condition: inboxService!.inbox.reports.where((report) => report.resolved).isNotEmpty,
                                    placeholder: "No passed reports".i18n(),
                                    child: ReportMessageList(
                                      messages: inboxService!.inbox.reports.where((report) => report.resolved).toList(),
                                      inboxService: inboxService!,
                                      onTap: (report) {
                                        setState(() {
                                          selectedReportMessage = report;
                                        });
                                        selectMessage(report.toMessage());
                                      },
                                    ),
                                  ),
                                ),
                                const VerticalDivider(
                                  indent: 24,
                                  endIndent: 24,
                                ),
                                if(selectedMessage != null)
                                  Expanded(
                                      child: MessageReader(message: selectedMessage!, report: selectedReportMessage,)
                                  )
                              ],
                            )
                          ]
                        ]
                       ),
                     ),
                  ]
                  else ... [
                    Expanded(
                      child: TabBarView(
                          controller: _tabController,
                          children: [
                            textPlaceHolder(context,
                                condition: inboxService!.inbox.receivedMessages.isNotEmpty,
                                placeholder: "Received messages empty".i18n(),
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
                                        textPlaceHolder(context,
                                          condition: inboxService!.unreadMessages.isNotEmpty,
                                          placeholder: "Unread messages empty".i18n(),
                                          child: UserMessageList(
                                            messages: inboxService!.unreadMessages,
                                            inboxService: inboxService!,
                                            onTap: (message) {
                                              goToUserMessagePage(message);
                                            },
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
                                        textPlaceHolder(context,
                                            condition: inboxService!.readMessages.isNotEmpty,
                                            placeholder: "Read messages empty".i18n(),
                                            child: UserMessageList(
                                              messages: inboxService!.readMessages,
                                              inboxService: inboxService!,
                                              onTap: (message) {
                                                goToUserMessagePage(message);
                                              },
                                            )
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                            ),

                            if(canSenMessage) ... [
                              textPlaceHolder(context,
                                condition: inboxService!.inbox.sendMessages.isNotEmpty,
                                placeholder: "Send messages empty".i18n(),
                                child: MessageList(
                                  messages: inboxService!.inbox.sendMessages,
                                  inboxService: inboxService!,
                                  onTap: selectMessage,
                                ),
                              ),
                              textPlaceHolder(context,
                                condition: inboxService!.inbox.reports.where((report) => !report.resolved).isNotEmpty,
                                placeholder: "No reports".i18n(),
                                child: ReportMessageList(
                                  messages: inboxService!.inbox.reports.where((report) => !report.resolved).toList(),
                                  inboxService: inboxService!,
                                  onTap: (report) {
                                    goToMessagePage(report.toMessage(), isReport: true);
                                  },
                                ),
                              ),
                              textPlaceHolder(context,
                                condition: inboxService!.inbox.reports.where((report) => report.resolved).isNotEmpty,
                                placeholder: "No passed reports".i18n(),
                                child: ReportMessageList(
                                  messages: inboxService!.inbox.reports.where((report) => report.resolved).toList(),
                                  inboxService: inboxService!,
                                  onTap: (report) {
                                    goToMessagePage(report.toMessage(), isReport: true);
                                  },
                                ),
                              ),
                            ]
                        ]
                      ),
                    ),
                  ],
                ],
              ),
          );
      }
    );
  }

}
