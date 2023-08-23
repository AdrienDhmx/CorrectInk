import 'dart:async';

import 'package:correctink/app/services/notification_service.dart';
import 'package:correctink/utils/markdown_extension.dart';
import 'package:correctink/widgets/animated_widgets.dart';
import 'package:correctink/widgets/buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:correctink/widgets/widgets.dart';
import 'package:localization/localization.dart';
import 'package:provider/provider.dart';

import '../../../blocs/link_dialog.dart';
import '../../../blocs/tasks/reminder_widget.dart';
import '../../../utils/task_helper.dart';
import '../../../utils/utils.dart';
import '../../data/models/schemas.dart';
import '../../data/repositories/realm_services.dart';

class ModifyTaskForm extends StatefulWidget {
  final Task task;
  const ModifyTaskForm(this.task, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ModifyTaskFormState();
}
class _ModifyTaskFormState extends State<ModifyTaskForm> {
  final _formKey = GlobalKey<FormState>();
  final completeGroup = <bool>[true, false];
  late bool isComplete = widget.task.isComplete;
  late TextEditingController _summaryController;
  late DateTime? deadline = widget.task.deadline;
  late DateTime? reminder = widget.task.reminder;
  late int reminderMode = widget.task.reminderRepeatMode;

  _ModifyTaskFormState();

  @override
  void initState() {
    _summaryController = TextEditingController(text: widget.task.task);
    super.initState();
  }

  @override
  void dispose() {
    _summaryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final realmServices = Provider.of<RealmServices>(context, listen: false);
    return modalLayout(
        context,
        Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  controller: _summaryController,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.done,
                  maxLines: 1,
                  validator: (value) =>
                  (value ?? "").isEmpty
                      ? "Task name hint".i18n()
                      : null,
                  decoration: InputDecoration(
                    labelText: "Task".i18n(),
                  ),
                  onFieldSubmitted: (value) => update(context, realmServices, widget.task, value, isComplete, deadline),
                ),
                const SizedBox(height: 8,),
                Wrap(
                  children: [
                    customRadioButton(context,
                        label: 'Complete'.i18n(),
                        isSelected: isComplete,
                        onPressed: () {
                          setState(() {
                            isComplete = true;
                          });
                        },
                      width: 130,
                    ),
                    customRadioButton(context,
                      label: 'Incomplete'.i18n(),
                      isSelected: !isComplete,
                      onPressed: () {
                        setState(() {
                          isComplete = false;
                        });
                      },
                      width: 140,
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:[
                      labeledAction(
                        context: context,
                        height: 35,
                        infiniteWidth: false,
                        center: true,
                        labelFirst: false,
                        onTapAction: () async {
                          final date = await showDateTimePicker(
                            context: context,
                            initialDate: deadline,
                            firstDate: DateTime.now(),
                          );
                          if (date != null) {
                            setState(() {
                              deadline = date;
                            });
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(0,0,8,0),
                          child: Icon(Icons.calendar_month_rounded, color: Theme.of(context).colorScheme.primary,),
                        ),
                        label: deadline == null ? 'Pick deadline'.i18n() : DateFormat('yyyy-MM-dd – kk:mm').format(deadline!),
                      ),
                      if(deadline != null) IconButton(
                          onPressed: () {
                            setState(() {
                              deadline = null;
                            });
                          },
                          tooltip: 'Remove deadline'.i18n(),
                          icon: Icon(Icons.clear_rounded, color: Theme.of(context).colorScheme.error,)
                      ),
                    ],
                  ),
                ),
                ReminderWidget(reminder, reminderMode, (remind, remindMode) => {
                  setState(() => {
                    reminder = remind,
                    reminderMode = remindMode,
                  })
                }),
                Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      cancelButton(context),
                      okButton(context, "Update".i18n(),
                          onPressed: () async =>
                          await update(context, realmServices, widget.task,
                              _summaryController.text, isComplete, deadline)),
                    ],
                  ),
                ),
              ],
            )));
  }

  Future<void> update(BuildContext context, RealmServices realmServices,
      Task task, String summary, bool isComplete, DateTime? deadline) async {
    if (_formKey.currentState!.validate()) {
      TaskHelper.scheduleForTask(
        Task(task.id, summary, task.ownerId, isComplete: isComplete, deadline: deadline, reminder: reminder, reminderRepeatMode: reminderMode),
        oldDeadline: task.deadline,
        oldReminder: task.reminder,
        oldRepeat: task.reminderRepeatMode,
      );

      await realmServices.taskCollection.update(task, summary: summary,
          isComplete: isComplete == task.isComplete ? null : isComplete,
          deadline: deadline != task.deadline ? deadline : task.deadline,
      );

      if(reminder != task.reminder || reminderMode != task.reminderRepeatMode){
        await realmServices.taskCollection.updateReminder(task, reminder, reminderMode);
      }

      if (context.mounted) Navigator.pop(context);
    }
  }

  void cancelNotification(DateTime? deadline){
    if(deadline != null) {
      NotificationService.cancel(deadline.millisecondsSinceEpoch);
    }
  }
}

class EditTaskDetails extends StatefulWidget{
  final Task task;
  final double maxHeight;

  const EditTaskDetails({super.key, required this.task, required this.maxHeight});

  @override
  State<StatefulWidget> createState() => _EditTaskDetails();
}

class _EditTaskDetails extends State<EditTaskDetails>{
  late TextEditingController textController;
  late FocusNode textFocusNode;
  late RealmServices realmServices;
  late bool expandHeader = false;

  @override
  void initState(){
    super.initState();
    textController = TextEditingController(text: widget.task.note);
    textFocusNode = FocusNode();
    textFocusNode.requestFocus();
  }

  @override
  void didChangeDependencies(){
    super.didChangeDependencies();

    realmServices = Provider.of<RealmServices>(context);
  }

  void insertHeader(String header){
    int start = 0;
    int end = 0;
    (start, end) = getSafeCursorPositions();

    int startOfLine = findStartOfLine(start);

    if(startOfLine != 0) startOfLine++;

    String markdownToInsert = MarkdownUtils.getHeaderMarkdown(header);
    textController.text = '${textController.text.substring(0, startOfLine)}$markdownToInsert ${textController.text.substring(startOfLine, textController.text.length)}';

    if(end + markdownToInsert.length + 1 == textController.text.length - 1){
      // the cursor was at the end of the text => its index is the length of the text
      // => outside of range so when retrieving it the index is decremented by 1 to stay in range
      // but here we lack that 1 character when placing back the cursor
      end++;
    }

    focusBackOnText(end + markdownToInsert.length + 1);
  }

  void surroundSelectedText(String markdown){
    int start = 0;
    int end = 0;
    (start, end) = getSafeCursorPositions();
    bool removed = false;

    if(getSubString(start, end).startsWith(markdown)) {
      textController.text = '${textController.text.substring(0, start)}${textController.text.substring(start + markdown.length, end - markdown.length)}${textController.text.substring(end, textController.text.length)}';
      removed = true;
    } else {
      // --->start<selection>end---->
      // --->markdown<selection>markdown---->
      textController.text = '${textController.text.substring(0, start)}$markdown${textController.text.substring(start, end)}$markdown${textController.text.substring(end, textController.text.length)}';
    }


    int newPosition = end;
    if(removed){
      newPosition = end - markdown.length;
      if(end != start) {
        newPosition -= markdown.length;
      }
    } else {
      // selection, move after the markdown
      if(end != start) {
        newPosition += markdown.length * 2;
      } else {
        // no selection, just move in between the markdown
        newPosition += markdown.length;
      }
    }


    focusBackOnText(newPosition);
  }

  void focusBackOnText(int position){
    textFocusNode.requestFocus();
    textController.selection = TextSelection.fromPosition(TextPosition(offset: position));
  }

  void focusBackOnTextWithSelection(int start, int end){
    textFocusNode.requestFocus();
    textController.selection = TextSelection(baseOffset: start, extentOffset: end);
  }

  String getSubString(int start, int end) {
    return textController.text.substring(start, end < start ? textController.text.length : end);
  }

  void insertInText(int position, String text) {
    textController.text = '${textController.text.substring(0, position)}$text${textController.text.substring(position, textController.text.length)}';
  }

  void replaceInText(int position, int length, String replacement){
    textController.text = textController.text.replaceRange(position, position + length, replacement);
  }

  int findStartOfLine(int index){
    if(index >= textController.text.length) index = textController.text.length - 1;
    for(int i = index; i > 0; i--){
      if(textController.text[i] == '\n'){
        return i;
      }
    }
    return 0;
  }

  int findEndOfLine(int index){
    for(int i = index; i < textController.text.length; i++){
      if(textController.text[i] == '\n'){
        return i;
      }
    }
    return textController.text.length;
  }

  (int, int) getCursorPosition(){
    if(textController.value.selection.start == -1 || textController.value.selection.end == -1){
      // only the current cursor position interest us here
      return (textController.value.composing.end, textController.value.composing.end);
    }

    // if there is no selection they are equal
    return (textController.value.selection.start, textController.value.selection.end);
  }

  (int, int) getSafeCursorPositions() {
    int start = 0;
    int end = 0;
    (start, end) = getCursorPosition();

    if(start >= textController.text.length && start == 1){
      start = textController.text.length - 1;
    } else if (start < 0) {
      start = 0;
    }

    if(end > textController.text.length){
      end = textController.text.length;
    } else if (end < 0) {
      end = 0;
    }

    return (start, end);
  }

  void enterLink(BuildContext context, {bool image = false}){
    final selection = textController.value.selection;
    String link = "";
    String placeholder = "";

    int start = selection.start;
    int end = selection.end;

    if(start != end) {
      String selectedText = getSubString(start, end);

      if(Utils.isURL(selectedText)){
        link = selectedText;
      } else {
        placeholder = selectedText;
      }
    }

    showDialog(context: context, builder: (context){
      return LinkForm(link: link, placeholder: placeholder, position: start, image: image,
          onCancel: (position) => focusBackOnText(position!),
          onConfirm: (link, placeholder, position, imageLink) {
            if(image){
              return insertImage(link, placeholder, position ?? textController.text.length, link: imageLink?? "");
            }else {
                return insertLink(link, placeholder, position ?? textController.text.length);
            }
          },
      );
    });
  }

  void insertLink(String link, String placeholder, int position){
    if(placeholder.isNotEmpty) {
      insertInText(position, "[$placeholder]($link) ");
    } else {
      insertInText(position, "<$link> ");
    }
  }

  void insertImage(String image, String placeholder, int position, {String link = ""}){
    if(link.isNotEmpty){
      insertLink(link, "![$placeholder]($image)\n", position);
    } else {
      insertInText(position, "![$placeholder]($image)\n");
    }
  }

  void editStartOfSelectedLines(String pattern, {bool remove = false, bool autoRemove = false}){
    int endOfLine = 0;
    int startOfLine = 0;
    (startOfLine, endOfLine) = getCurrentLine();

    String concernedText = getSubString(startOfLine, endOfLine);
    List<String> linesConcerned = concernedText.split('\n');

    String modifiedText = "";

    if(autoRemove){
      remove = concernedText.contains(pattern);
    }

    for(int i = 0; i < linesConcerned.length; i++){
      if(i != 0){
        // start of new line
        modifiedText += '\n';
      }

      if(remove){
        // if there is already the patter
        if(linesConcerned[i].startsWith(pattern)){
          // remove the pattern
          modifiedText += linesConcerned[i].substring(pattern.length, linesConcerned[i].length);
        } else { // pattern not found => no changes
          // add the original content of the line
          modifiedText += linesConcerned[i];
        }
      } else {
        // add the tab (4 spaces)
        modifiedText += pattern;

        // add the original content of the line
        modifiedText += linesConcerned[i];
      }
    }

    // replace and focus back at the end of the selection or the end of the line
    replaceInText(startOfLine, concernedText.length, modifiedText);
    focusBackOnTextWithSelection(startOfLine, startOfLine + modifiedText.length);
  }

  (int, int) getCurrentLine(){
    int start = 0;
    int end = 0;
    (start, end) = getSafeCursorPositions();

    int startOfLine = findStartOfLine(start);
    int endOfLine = findEndOfLine(end);

    if(endOfLine == startOfLine && start != 0){
      // the cursor is at the end of a line
      start--;
      startOfLine = findStartOfLine(start);
    }

    // move after the \n
    if(startOfLine != 0){
      startOfLine++;
    }
    return (startOfLine, endOfLine);
  }


  KeyEventResult onKeyDown(RawKeyEvent event) {

    if(event.isKeyPressed(LogicalKeyboardKey.tab)){
      handleTab(event);
      return KeyEventResult.handled;
    } else if (event.isAltPressed){
      if(event.isKeyPressed(LogicalKeyboardKey.arrowUp)){
        moveCurrentSelection(true);
      } else if(event.isKeyPressed(LogicalKeyboardKey.arrowDown)){
        moveCurrentSelection(false);
      }
    }
    return KeyEventResult.ignored;
  }

  void handleTab(RawKeyEvent event) {
    // insert or remove tab (4 spaces)
    editStartOfSelectedLines("    ", remove: event.isShiftPressed);
  }

  void moveCurrentSelection(bool up){
    int endOfLine = 0;
    int startOfLine = 0;
    (startOfLine, endOfLine) = getCurrentLine();

    String concernedText = getSubString(startOfLine, endOfLine);

    if(up){
      // can't move selection up if it's already at the top
      if(startOfLine != 0){
        // need to find the start of the previous line
        int previousLineStart = findStartOfLine(startOfLine - 2);

        String newStart = '';

        if(previousLineStart != 0){
          newStart = '${getSubString(0, previousLineStart)}\n$concernedText';
        } else {
          newStart = '$concernedText\n';
        }

        textController.text = newStart + getSubString(previousLineStart, startOfLine - 1) + // previous line
                               getSubString(endOfLine, textController.text.length); // end doesn't change

        int newStartLinePosition = previousLineStart == 0 ? 0 : previousLineStart + 1;
        int newEndOfLine = newStartLinePosition + concernedText.length;

        Timer(
          const Duration(milliseconds: 5), (){
            focusBackOnTextWithSelection(newStartLinePosition, newEndOfLine);
          }
        );
      }
    } else {
      if(endOfLine != textController.text.length){
        // need to find the end of the next line
        int nextLineEnd = findEndOfLine(endOfLine + 1);

        String newStart = '';

        if(startOfLine != 0){
          newStart = getSubString(0, startOfLine - 1) + getSubString(endOfLine, nextLineEnd);
        } else {
          // +1 to avoid the \n
          newStart = getSubString(endOfLine + 1, nextLineEnd);
        }

        textController.text = '$newStart\n$concernedText${getSubString(nextLineEnd, textController.text.length)}'; // end doesn't change

        int newStartLinePosition = startOfLine + (nextLineEnd - endOfLine).toInt();
        Timer(
            const Duration(milliseconds: 5), (){
              focusBackOnTextWithSelection(newStartLinePosition, newStartLinePosition + concernedText.length);
          }
        );
      }
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Material(
          elevation: 1,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          color: Theme.of(context).colorScheme.surface,
          child: Container(
              padding: Utils.isOnPhone() ? const EdgeInsets.fromLTRB(4, 8, 4, 4) : const EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: Utils.isOnPhone() ? widget.maxHeight - MediaQuery.of(context).viewInsets.bottom - 80  : widget.maxHeight - 80),
                      child: Focus(
                        onKey: (node, event) {
                          return onKeyDown(event);
                        },
                        child: TextField(
                          controller: textController,
                          minLines: 3,
                          focusNode: textFocusNode,
                          keyboardType: TextInputType.multiline,
                          textInputAction: TextInputAction.newline,
                          maxLines: null,
                          decoration: InputDecoration(
                            hintText: "Add note".i18n(),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 40,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        cancelButton(context),
                        okButton(context, "Update".i18n(),
                            onPressed: () {
                              if(textController.text.trim().isEmpty) {
                                // if there are only spaces or new line empty the text
                                textController.text = "";
                              }

                              realmServices.taskCollection.update(widget.task, note: textController.text);
                              GoRouter.of(context).pop();
                            }
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0.0, 6, 0, 0),
                    child: SizedBox(
                      height: 40,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                border: expandHeader ? Border.all(
                                  color: Theme.of(context).colorScheme.primary,
                                ) : null,
                            ),
                            child: Row(
                              children: [
                                inkButton(
                                    onTap: () {
                                      setState(() {
                                        expandHeader = !expandHeader;
                                      });
                                    },
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                          color: expandHeader ? Theme.of(context).colorScheme.primary : Colors.transparent,
                                          borderRadius: BorderRadius.circular(4)
                                      ),
                                      child: Center(
                                        child: Text('H',
                                          style: TextStyle(
                                              color: expandHeader ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.primary,
                                              fontSize: 18, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                    width: 40
                                ),
                                ExpandedSection(
                                  axis: Axis.horizontal,
                                  expand: expandHeader,
                                  duration: 300,
                                  child: Row(
                                    children: [
                                      for(int i = 0; i < MarkdownUtils.headers.length; i++)
                                        inkButton(
                                            child: Padding(
                                              padding: const EdgeInsets.all(6.0),
                                              child: Text(MarkdownUtils.headers[i],
                                                style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: (18-i).toDouble(), fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                            onTap: () => insertHeader(MarkdownUtils.headers[i]),
                                            width: 40
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          inkButton(
                              onTap: () => surroundSelectedText("_"),
                              child: Icon(Icons.format_italic_rounded, color: Theme.of(context).colorScheme.primary,),
                              width: 40
                          ),
                          inkButton(
                              onTap: () => surroundSelectedText("**"),
                              child: Icon(Icons.format_bold_rounded, color: Theme.of(context).colorScheme.primary,),
                              width: 40
                          ),
                          inkButton(
                              onTap: () => surroundSelectedText("~~"),
                              child: Icon(Icons.format_strikethrough_rounded, color: Theme.of(context).colorScheme.primary,),
                              width: 40
                          ),
                          inkButton(
                              onTap: () => surroundSelectedText("\n```\n"),
                              child: Icon(Icons.code_rounded, color: Theme.of(context).colorScheme.primary,),
                              width: 40
                          ),
                          inkButton(
                              onTap: () => editStartOfSelectedLines(" - ", autoRemove: true),
                              child: Icon(Icons.format_list_bulleted_rounded, color: Theme.of(context).colorScheme.primary,),
                              width: 40
                          ),
                          inkButton(
                              onTap: () => editStartOfSelectedLines("> "),
                              onLongPress: () => editStartOfSelectedLines("> ", remove: true),
                              child: Icon(Icons.format_quote_rounded, color: Theme.of(context).colorScheme.primary,),
                              width: 40
                          ),
                          inkButton(
                              onTap: () => enterLink(context),
                              child: Icon(Icons.link_rounded, color: Theme.of(context).colorScheme.primary,),
                              width: 40
                          ),
                          inkButton(
                              onTap: () => enterLink(context, image: true),
                              child: Icon(Icons.image_rounded, color: Theme.of(context).colorScheme.primary,),
                              width: 40
                          ),
                          inkButton(
                              onTap: () => moveCurrentSelection(true),
                              child: Icon(Icons.keyboard_arrow_up_rounded, color: Theme.of(context).colorScheme.primary,),
                              width: 40
                          ),
                          inkButton(
                              onTap: () => moveCurrentSelection(false),
                              child: Icon(Icons.keyboard_arrow_down_rounded, color: Theme.of(context).colorScheme.primary,),
                              width: 40
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
          ),
        ));
  }
}