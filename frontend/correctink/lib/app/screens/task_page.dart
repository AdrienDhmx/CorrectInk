import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:correctink/main.dart';
import 'package:correctink/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:localization/localization.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../blocs/markdown_editor.dart';
import '../../blocs/tasks/todo_list.dart';
import '../../utils/markdown_extension.dart';
import '../../widgets/widgets.dart';
import '../data/models/schemas.dart';
import '../data/repositories/realm_services.dart';
import 'create/create_step.dart';
import 'edit/modify_task.dart';



class TaskPage extends StatefulWidget{
  const TaskPage(this.taskId, {Key? key}) : super(key: key);

  final String taskId;

  @override
  State<StatefulWidget> createState() => _TaskPage();
}

class _TaskPage extends State<TaskPage>{
  late RealmServices realmServices;
  late Task? task;
  late StreamSubscription stream;
  late TextEditingController detailsController;
  late FocusNode detailsFocusNote;
  bool isInit = false;

  @override
  void didChangeDependencies(){
    super.didChangeDependencies();
    realmServices = Provider.of<RealmServices>(context);
    task = realmServices.taskCollection.get(widget.taskId);

    detailsController = TextEditingController(text: task!.note);
    detailsFocusNote = FocusNode();

    if(!isInit){
      stream = task!.changes.listen((event) {
        setState(() {
          task = event.object;
        });
      });
    }

  }

  @override
  void dispose(){
    stream.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
    return task == null ? Container()
        : LayoutBuilder(
          builder: (context, constraint) {
            return Scaffold(
              floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
              floatingActionButton: CreateTodoAction(task!.id, task!.steps.length),
              bottomNavigationBar: BottomAppBar(
                height: 45,
                child: Align(
                    alignment: constraint.maxWidth < 500 ? Alignment.centerLeft : Alignment.bottomCenter,
                    child: Text(
                      task!.isComplete
                          ? 'Completed on'.i18n() + task!.completionDate!.getFullWrittenDate()
                          : 'Created on'.i18n() + task!.id.timestamp.getFullWrittenDate(),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500
                      ),
                    ),
                  ),
              ),
              appBar: AppBar(
                toolbarHeight: 80,
                primary: false,
                shadowColor: Theme.of(context).colorScheme.shadow,
                surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
                elevation: 2,
                titleSpacing: Utils.isOnPhone() ? 4 : null,
                scrolledUnderElevation: 4,
                automaticallyImplyLeading: false,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            leading: Checkbox(
                              shape: taskCheckBoxShape(),
                              side: BorderSide(
                                  color: Theme.of(context).colorScheme.onBackground,
                                  width: 2
                              ),
                              value: task!.isComplete,
                              onChanged: (value) {
                                realmServices.taskCollection.update(task!, isComplete: value, deadline: task!.deadline);
                              },
                            ),
                            horizontalTitleGap: Utils.isOnPhone() ? 4 : 8,
                            contentPadding: const EdgeInsets.all(0),
                            title: AutoSizeText(task!.task,
                              maxLines: 3,
                              presetFontSizes: const [18, 16, 14, 12],
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.onBackground,
                                  decoration: task!.isComplete ? TextDecoration.lineThrough : null
                              ),
                            ),
                            subtitle: (task!.hasDeadline && !task!.isComplete) || task!.hasReminder
                                ? Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                deadlineInfo(context: context, task: task!),
                                reminderInfo(context: context, task: task!),
                              ],
                            )
                            : null,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => {
                        showBottomSheetModal(context, ModifyTaskForm(task!)),
                      },
                      icon: Icon(Icons.edit, color: Theme.of(context).colorScheme.onBackground,),
                    ),
                  ],
                ),
              ),
              body: TodoList(task!.id,
                header: Padding(
                  padding: const EdgeInsets.all(8),
                  child: InkWell(
                    onTap: () {},
                    onLongPress: () => showBottomSheetModal(context,
                      MarkdownEditor(maxHeight: constraint.maxHeight,
                        hint: "Add note".i18n(), validateHint: 'Update'.i18n(),
                        text: task!.note,
                        onValidate: (text) {
                          realmServices.taskCollection.updateNote(task!, text);
                          return true;
                        },
                      ),
                      constraints: BoxConstraints(
                          maxWidth: MediaQuery.sizeOf(context).width
                      ),
                    ),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 12),
                        child: MarkdownBody(
                          data: task!.note.isEmpty
                              ? "Add note".i18n()
                              : task!.note,
                          builders: MarkdownUtils.styleSheet(),
                          styleSheetTheme: MarkdownStyleSheetBaseTheme.material,
                          styleSheet: MarkdownUtils.getStyle(context),
                          onTapLink: (i, link, _) => {
                            launchUrl(Uri.parse(link ?? ""))
                          },
                        )
                    ),
                  ),
                ),
              ),
            );
          }
        );
  }
}