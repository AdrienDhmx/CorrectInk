import 'package:correctink/blocs/messages/message_reader.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/models/schemas.dart';
import '../data/repositories/realm_services.dart';

class InboxMessagePage extends StatefulWidget {
  const InboxMessagePage({super.key, required this.messageId, required this.userMessage});

  final String messageId;
  final bool userMessage;

  @override
  State<StatefulWidget> createState() => _InboxMessagePage();
}

class _InboxMessagePage extends State<InboxMessagePage> {
  late RealmServices realmServices;
  late Inbox inbox;
  late UserMessage? userMessage;
  late Message? message;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    realmServices = Provider.of(context);
    inbox = realmServices.userService.currentUserData!.inbox!;
    if(widget.userMessage) {
      userMessage = inbox.receivedMessages.firstWhere((m) => m.userMessageId.hexString == widget.messageId);
      message = userMessage!.message;
    } else {
      message = inbox.sendMessages.firstWhere((m) => m.messageId.hexString == widget.messageId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: MessageReader(message: message!,)
    );
  }
}