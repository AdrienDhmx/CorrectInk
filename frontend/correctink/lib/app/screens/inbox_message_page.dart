import 'package:correctink/app/screens/error_page.dart';
import 'package:correctink/blocs/messages/message_reader.dart';
import 'package:correctink/utils/message_utils.dart';
import 'package:flutter/material.dart';
import 'package:localization/localization.dart';
import 'package:objectid/objectid.dart';
import 'package:provider/provider.dart';

import '../data/models/schemas.dart';
import '../data/repositories/realm_services.dart';

class InboxMessagePage extends StatefulWidget {
  const InboxMessagePage({super.key, required this.messageId, required this.userMessage, required this.isReportMessage});

  final String messageId;
  final bool userMessage;
  final bool isReportMessage;

  @override
  State<StatefulWidget> createState() => _InboxMessagePage();
}

class _InboxMessagePage extends State<InboxMessagePage> {
  late RealmServices realmServices;
  late Inbox inbox;
  late UserMessage? userMessage;
  late Message? message;
  late ReportMessage? report;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    realmServices = Provider.of(context);
    inbox = realmServices.userService.currentUserData!.inbox!;
    report = null;
    if(widget.userMessage) {
      userMessage = inbox.receivedMessages.firstWhere((m) => m.userMessageId.hexString == widget.messageId);
      message = userMessage!.message;
    } else if(widget.isReportMessage) {
      report = realmServices.realm.query<ReportMessage>(r"_id == $0", [ObjectId.fromHexString(widget.messageId)]).firstOrNull;
      message = report?.toMessage();
    } else {
      message = inbox.sendMessages.firstWhere((m) => m.messageId.hexString == widget.messageId, orElse: () {
        return realmServices.realm.query<Message>(r"_id == $0", [ObjectId.fromHexString(widget.messageId)]).first;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if(message == null) {
      return ErrorPage(errorDescription: "The message was not found !".i18n(), tips: const [],);
    }

    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: MessageReader(message: message!, report: report,)
    );
  }
}