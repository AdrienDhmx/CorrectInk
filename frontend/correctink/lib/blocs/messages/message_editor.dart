import 'package:correctink/app/services/inbox_service.dart';
import 'package:correctink/blocs/markdown_editor.dart';
import 'package:correctink/utils/message_helper.dart';
import 'package:correctink/widgets/snackbars_widgets.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:localization/localization.dart';
import 'package:objectid/objectid.dart';
import 'package:provider/provider.dart';

import '../../app/data/models/schemas.dart';
import '../../widgets/widgets.dart';
import 'message_reader.dart';

class MessageEditor extends StatefulWidget {
  const MessageEditor({super.key, this.message});
  final Message? message;

  @override
  State<StatefulWidget> createState() => _MessageEditor();
}

class _MessageEditor extends State<MessageEditor> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final TextEditingController titleController = TextEditingController();
  late String messageContent = "";
  late InboxService inboxService;
  late bool preview = false;

  late bool update = false;

  late MessageIcons messageType = MessageIcons.none;
  late MessageDestination messageDestination = MessageDestination.admin;



  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    inboxService = Provider.of(context);
    update = widget.message != null;

    if(update) {
      titleController.text = widget.message!.title;
      messageContent = widget.message!.message;
      messageType = MessageIcons.values.firstWhere((type) => type.type == widget.message!.type);
    }
  }

  void send() {
      inboxService.send(titleController.text, messageContent, messageType.type, messageDestination.destination);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Theme.of(context).colorScheme.surface,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if(!preview) ... [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        if(!update) ...[
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Center(
                              child: Text("Recipient".i18n(),
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Theme.of(context).colorScheme.secondary
                                ),
                              ),
                            ),
                          ),
                          Wrap(
                            runAlignment: WrapAlignment.center,
                            alignment: WrapAlignment.center,
                            children: [
                              for(MessageDestination destination in MessageDestination.values)
                                customRadioButton(context,
                                  label: destination.name.i18n(),
                                  isSelected: messageDestination == destination,
                                  onPressed: () {
                                    setState(() {
                                      messageDestination = destination;
                                    });
                                  },
                                  infiniteWidth: false,
                                  center: true,
                                ),
                            ],
                          ),
                        ],
                        const FractionallySizedBox(
                            widthFactor: 0.6,
                            child: Divider()
                        ),
                        const SizedBox(height: 6,),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Center(
                            child: Text("Message icon".i18n(),
                              style: TextStyle(
                                fontSize: 16,
                                color: Theme.of(context).colorScheme.secondary
                              ),
                            ),
                          ),
                        ),
                        Material(
                          elevation: 0,
                          child: Wrap(
                            runAlignment: WrapAlignment.center,
                            alignment: WrapAlignment.center,
                            children: [
                              for(MessageIcons type in MessageIcons.values)
                                Tooltip(
                                  message: type.name,
                                  verticalOffset: 24.0,
                                  preferBelow: true,
                                  waitDuration: const Duration(milliseconds: 600),
                                  child: iconPickerButton(context,
                                    icon: MessageHelper.getIcon(type.type,
                                                    type.type == -1
                                                        ? Theme.of(context).colorScheme.onSurfaceVariant.withAlpha(200)
                                                        :  Theme.of(context).colorScheme.primary,
                                                    big: false),
                                    isSelected: messageType == type,
                                    onPressed: () {
                                      setState(() {
                                        messageType = type;
                                      });
                                    },
                                    width: 40,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Row(
                            children: [
                              if(messageType.type != -1)
                                Padding(
                                    padding: const EdgeInsets.fromLTRB(0, 12, 12, 0),
                                    child: MessageHelper.getIcon(messageType.type, Theme.of(context).colorScheme.primary, big: true),
                                ),
                              Expanded(
                                child: TextFormField(
                                  controller: titleController,
                                  autofocus: true,
                                  validator: (value) => (value ?? "").isEmpty ? "Title required".i18n() : null,
                                  decoration: InputDecoration(
                                    labelText: "Title".i18n(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                MarkdownEditor(maxHeight: MediaQuery.of(context).size.height - 210 - (update ? 0 : 80),
                  hint: "Write message".i18n(),
                  validateHint: 'Preview'.i18n(),
                  text: messageContent,
                  onValidate: (text) {
                    setState(() {
                      messageContent = text;
                      preview = _formKey.currentState!.validate() && messageContent.isNotEmpty;
                    });
                  },
                  autoFocus: false,
                  allowEmpty: false,
                )
              ]
              else ...[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          labeledAction(
                              context: context,
                              label: "Leave preview".i18n(),
                              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              labelFirst: false,
                              infiniteWidth: false,
                              center: true,
                              height: 40,
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(0, 0, 4.0, 0),
                                child: Icon(
                                  Icons.close_rounded,
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                              onTapAction: () {
                                setState(() {
                                  preview = false;
                                });
                              }
                          ),
                          labeledAction(
                              context: context,
                              label: " ${update ? "Update".i18n() : "Send".i18n()}",
                              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              labelFirst: true,
                              infiniteWidth: false,
                              center: true,
                              height: 40,
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(6, 0, 0, 0),
                                child: Icon(
                                  Icons.send_rounded,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              onTapAction: () {
                                if(update) {
                                  inboxService.update(widget.message!, titleController.text, messageContent, messageType.type);
                                  successMessageSnackBar(context, "Message updated".i18n(), icon: Icons.check_rounded).show(context);
                                } else {
                                  send();
                                }
                                GoRouter.of(context).pop();
                              }
                          ),
                        ],
                      ),
                      const Divider(
                        indent: 6,
                        endIndent: 6,
                      ),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height - 80,
                        ),
                        child: MessageReader(
                          message: Message(
                            ObjectId(),
                            titleController.text,
                            messageContent,
                            messageType.type,
                            DateTime.now(),
                            DateTime.now(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ]
            ],
          ),
        );
  }

}