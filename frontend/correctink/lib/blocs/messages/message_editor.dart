import 'package:correctink/app/services/inbox_service.dart';
import 'package:correctink/blocs/icon_picker_dialog.dart';
import 'package:correctink/blocs/markdown_editor.dart';
import 'package:correctink/utils/message_utils.dart';
import 'package:correctink/widgets/snackbars_widgets.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:localization/localization.dart';
import 'package:objectid/objectid.dart';
import 'package:provider/provider.dart';

import '../../app/data/models/schemas.dart';
import '../../widgets/buttons.dart';
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
  late List<Icon> icons;
  late String messageContent = "";
  late InboxService inboxService;
  late bool preview = false;

  late bool dataInit = false;
  late bool update = false;

  late MessageIcons messageIcon = MessageIcons.none;
  late MessageDestination messageDestination = MessageDestination.admin;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    inboxService = Provider.of(context);
    update = widget.message != null;

    icons = [];
    for(MessageIcons messageIcon in MessageIcons.values) {
      icons.add(messageIcon.getIcon(context));
    }

    if(update && !dataInit) {
      dataInit = true;
      titleController.text = widget.message!.title;
      messageContent = widget.message!.message;
      messageIcon = MessageIcons.values[widget.message!.icon + 1];
    }
  }

  void send() {
      inboxService.broadcast(titleController.text, messageContent, messageIcon.type, messageDestination.destination);
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
                SafeArea(
                  child: Padding(
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
                                    label: destination.translatedName,
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
                            const FractionallySizedBox(
                                widthFactor: 0.6,
                                child: Divider()
                            ),
                          ],
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                            child: Row(
                              children: [
                                Padding(
                                    padding: const EdgeInsets.fromLTRB(0, 8, 12, 0),
                                    child: IconButton(onPressed: () {
                                      showDialog(context: context,
                                          builder: (context) {
                                            return IconPickerDialog(icons: icons,
                                                selectedIconIndex: messageIcon.type + 1,
                                                onIconSelected: (iconIndex) {
                                                  setState(() {
                                                    messageIcon = MessageIcons.values[iconIndex];
                                                  });
                                                  GoRouter.of(context).pop();
                                                }
                                              );
                                            }
                                        );
                                      },
                                      icon: messageIcon.getIcon(context, big: true),
                                    ),
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
                ),
                MarkdownEditor(
                  maxHeight: MediaQuery.of(context).size.height - 140 - (update ? 0 : 80),
                  hint: "Write message".i18n(),
                  validateHint: 'Preview'.i18n(),
                  text: messageContent,
                  onValidate: (text) {
                    setState(() {
                      messageContent = text;
                      preview = _formKey.currentState!.validate() && messageContent.trim().isNotEmpty;
                    });
                  },
                  autoFocus: false,
                  allowEmpty: false,
                )
              ]
              else ...[
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            labeledAction(
                                context: context,
                                label: "Back to edit".i18n(),
                                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                labelFirst: false,
                                infiniteWidth: false,
                                center: true,
                                height: 40,
                                child: Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  color: Theme.of(context).colorScheme.error,
                                ),
                                onTapAction: () {
                                  setState(() {
                                    preview = false;
                                  });
                                }
                            ),
                            labeledAction(
                                context: context,
                                label: update ? "Update".i18n() : "Send".i18n(),
                                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                labelFirst: true,
                                infiniteWidth: false,
                                center: true,
                                height: 40,
                                child: Icon(
                                  Icons.send_rounded,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                onTapAction: () {
                                  if(update) {
                                    inboxService.update(widget.message!, titleController.text, messageContent, messageIcon.type);
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
                            maxHeight: MediaQuery.of(context).size.height - 100,
                          ),
                          child: MessageReader(
                            message: Message(
                              ObjectId(),
                              titleController.text,
                              messageContent,
                              messageIcon.type,
                              DateTime.now(),
                              DateTime.now(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ]
            ],
          ),
        );
  }

}