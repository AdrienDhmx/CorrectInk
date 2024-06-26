import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:localization/localization.dart';
import 'package:provider/provider.dart';

import '../app/data/repositories/realm_services.dart';
import '../utils/markdown_extension.dart';
import '../utils/utils.dart';
import '../widgets/animated_widgets.dart';
import '../widgets/buttons.dart';
import '../widgets/widgets.dart';
import 'link_dialog.dart';

class MarkdownEditor extends StatefulWidget{
  final double maxHeight;
  final String hint;
  final String text;
  final bool autoFocus;
  final bool allowEmpty;
  final String validateHint;
  final Function(String) onValidate;

  const MarkdownEditor({super.key, required this.maxHeight, required this.hint, required this.validateHint, required this.onValidate, required this.text, this.autoFocus = true, this.allowEmpty = true});

  @override
  State<StatefulWidget> createState() => _MarkdownEditor();
}

class _MarkdownEditor extends State<MarkdownEditor>{
  late TextEditingController textController;
  late FocusNode textFocusNode;
  late RealmServices realmServices;
  late bool expandHeader = false;
  late bool triedToValidateAndFailed = false;

  @override
  void initState(){
    super.initState();
    textController = TextEditingController(text: widget.text);
    textFocusNode = FocusNode();
    if(widget.autoFocus) {
      textFocusNode.requestFocus();
    }
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

    if(startOfLine + 1 <= textController.text.length) {
      startOfLine++;
    }

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

    // --->start<selection>end---->
    // --->markdown<selection>markdown---->
    textController.text = '${textController.text.substring(0, start)}$markdown${textController.text.substring(start, end)}$markdown${textController.text.substring(end, textController.text.length)}';

    int newPosition = end;
    if(end != start) {
      newPosition += markdown.length * 2;
    } else {
      newPosition += markdown.length;
    }

    focusBackOnText(newPosition);
  }

  void insertAtStartOfLine(String markdown, {bool reverse = false}){
    int start = 0;
    int end = 0;
    (start, end) = getSafeCursorPositions();

    if(start == end) {
      print("HERE");
      // no text selected it's easy
      insertInText(start, markdown);
      //focusBackOnText(start + markdown.length);
      return;
    } else {
      print('$start vs $end');
      // text selected, need to insert '> ' at the start of every line in the selected text

      // -1 to get the '\n' of the first line if selection start at a new line
      String selectedText = getSubString(start - 1, end);

      String patternToReplace = '\n';
      String replacementString = markdown;

      // remove markdown if allowed
      if(reverse && selectedText.contains(markdown)){
        patternToReplace = markdown;
        replacementString = '\n';
      }

      // find by how much the character count change per replacement
      int difLength = (patternToReplace.length - replacementString.length);

      String updatedText = selectedText.replaceAll(patternToReplace, replacementString);
      textController.text = textController.text.replaceRange(start, end, updatedText);
      textController.text = textController.text.replaceRange(start - 1, start, '');
      focusBackOnText((end + selectedText.split(patternToReplace).length * difLength - 1).toInt());
    }
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
      return (0, 0);
    }

    // if there is no selection they are equal
    return (textController.value.selection.start, textController.value.selection.end);
  }

  (int, int) getSafeCursorPositions() {
    int start = 0;
    int end = 0;
    (start, end) = getCursorPosition();

    if(start >= textController.text.length){
      start = textController.text.length -1;
    }
    if(start < 0) {
      start = 0;
    }

    if(end >= textController.text.length){
      end = textController.text.length -1;
    }
    if(end < 0) {
      end = 0;
    }

    return (start, end);
  }

  void enterLink(BuildContext context, {bool image = false}){
    final selection = textController.value.selection;
    String link = "";
    String selectedPlaceholder = "";

    int start = selection.start;
    int end = selection.end;

    if(start != end) {
      String selectedText = getSubString(start, end);

      if(Utils.isURL(selectedText)){
        link = selectedText;
      } else {
        selectedPlaceholder = selectedText;
      }
    }

    showDialog(context: context, builder: (context){
      return LinkForm(link: link, placeholder: selectedPlaceholder, position: start, image: image,
        onCancel: (position) => focusBackOnText(position!),
        onConfirm: (link, placeholder, position, imageLink) {
          if(image){
            return insertImage(link, placeholder, position ?? textController.text.length, link: imageLink?? "");
          }else {
            return insertLink(link, placeholder, position ?? textController.text.length, textToReplace: selectedPlaceholder.isEmpty ? null : selectedPlaceholder);
          }
        },
      );
    });
  }

  void insertLink(String link, String placeholder, int position, {String? textToReplace}){
    if(placeholder.isNotEmpty) {
      if(textToReplace != null) {
        return replaceInText(position, textToReplace.length, "[$placeholder]($link) ");
      }
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
      if(startOfLine == 0){
        // there is no \n at the first line of the text
        remove = concernedText.contains(pattern);
      } else {
        remove = concernedText.contains('\n$pattern');
      }
    }

    for(int i = 0; i < linesConcerned.length; i++){
      if(i != 0){
        // start of new line
        modifiedText += '\n';
      }

      if(remove){
        // if there is already a tab
        if(linesConcerned[i].startsWith(pattern)){
          // remove the tab
          modifiedText += linesConcerned[i].substring(pattern.length, linesConcerned[i].length);
        } else { // no tab => no changes
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
    if(textController.selection.start != textController.selection.end) {
      focusBackOnTextWithSelection(startOfLine, startOfLine + modifiedText.length);
    } else {
      focusBackOnText(startOfLine + modifiedText.length);
    }
  }

  (int, int) getCurrentLine(){
    int start = 0;
    int end = 0;
    (start, end) = getSafeCursorPositions();

    int startOfLine = findStartOfLine(start);
    int endOfLine = findEndOfLine(end);

    if(endOfLine == startOfLine && start != 0 && start != textController.text.length - 1){
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
    if(triedToValidateAndFailed) {
      setState(() {
        triedToValidateAndFailed = (!widget.allowEmpty && textController.text.trim().isEmpty);
      });
    }

    if(event.isKeyPressed(LogicalKeyboardKey.tab)){
      handleTab(event);
      return KeyEventResult.handled;
    } else if (HardwareKeyboard.instance.isAltPressed){
      if(event.isKeyPressed(LogicalKeyboardKey.arrowUp)){
        moveCurrentSelection(true);
      } else if(event.isKeyPressed(LogicalKeyboardKey.arrowDown)){
        moveCurrentSelection(false);
      }
    } else if(event.isKeyPressed(LogicalKeyboardKey.enter)) {
      int start;
      int end;
      (start, end) = getCurrentLine();
      String currentLine = getSubString(start, end);
      if(currentLine.startsWith(" - ") || currentLine.startsWith("- ")) {
       textController.text = "${textController.text}\n - ";
       return KeyEventResult.handled;
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

        Timer(const Duration(milliseconds: 5), (){
          focusBackOnTextWithSelection(newStartLinePosition, newEndOfLine);
        });
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
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Material(
          elevation: 0,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          color: colorScheme.surface,
          child: Container(
            padding: Utils.isOnPhone() ? const EdgeInsets.fromLTRB(4, 0, 4, 4) : const EdgeInsets.fromLTRB(14, 0, 6, 0),
            child: Column(
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(
                      maxHeight: Utils.isOnPhone()
                          ? widget.maxHeight - MediaQuery.of(context).viewInsets.bottom - 70
                          : widget.maxHeight - 60
                  ),
                  child: Focus(
                    onKey: (node, event) {
                      return onKeyDown(event);
                    },
                    child: TextField(
                      controller: textController,
                      scribbleEnabled: true,
                      scrollPhysics: const AlwaysScrollableScrollPhysics(),
                      minLines: 3,
                      focusNode: textFocusNode,
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.newline,
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText: widget.hint,
                        labelText: triedToValidateAndFailed ? "Message required".i18n() : null,
                        labelStyle: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 14,
                          fontWeight: FontWeight.w500
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    cancelButton(context),
                    okButton(context, widget.validateHint,
                        onPressed: () {
                          setState(() {
                            triedToValidateAndFailed = (!widget.allowEmpty && textController.text.trim().isEmpty);
                          });

                          bool callbackValidation = widget.onValidate(textController.text)?? false;
                          if(!triedToValidateAndFailed && callbackValidation) {
                            GoRouter.of(context).pop();
                          }
                        }
                    )
                  ],
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