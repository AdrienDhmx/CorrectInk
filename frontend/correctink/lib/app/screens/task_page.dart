import 'dart:async';

import 'package:correctink/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:localization/localization.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

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
                shape: const CircularNotchedRectangle(),
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
              body: Column(
                children: [
                  Material(
                    elevation: 1,
                    color: Theme.of(context).colorScheme.primaryContainer.withAlpha(220),
                    child: Padding(
                      padding: constraint.maxWidth > 500 ? const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8) : const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
                      child: Row(
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
                                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                                        width: 2
                                      ),
                                      value: task!.isComplete,
                                      onChanged: (value) {
                                        realmServices.taskCollection.update(task!, isComplete: value, deadline: task!.deadline);
                                        setState(() {
                                          task!.isComplete = value?? !task!.isComplete;
                                        });
                                      },
                                    ),
                                    horizontalTitleGap: 8,
                                    contentPadding: const EdgeInsets.all(0),
                                    title: Text(task!.task,
                                      style: TextStyle(
                                          fontSize: Utils.isOnPhone() ? 19 : 22,
                                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                                          decoration: task!.isComplete ? TextDecoration.lineThrough : null
                                      ),
                                      softWrap: true,),
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
                                showModalBottomSheet(
                                  useRootNavigator: true,
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (_) => Wrap(children: [ModifyTaskForm(task!)]),
                                )
                              },
                              icon: Icon(Icons.edit, color: Theme.of(context).colorScheme.onPrimaryContainer,),
                            ),
                          ],
                        ),
                    ),
                  ),
                  Expanded(
                      child: ListView(
                        children:[
                          Padding(
                            padding: Utils.isOnPhone() ? const EdgeInsets.fromLTRB(12, 12, 12, 8) :  const EdgeInsets.fromLTRB(20, 12, 20, 8),
                            child: InkWell(
                                onTap: () {},
                                onLongPress: () => showModalBottomSheet(
                                useRootNavigator: true,
                                context: context,
                                isScrollControlled: true,
                                constraints: BoxConstraints(
                                    maxWidth: constraint.maxWidth
                                ),
                                builder: (_) => Wrap(children: [EditTaskDetails(task: task!, maxHeight: constraint.maxHeight)]),
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
                          TodoList(task!.id),
                        ]
                    )),
                ],
              ),
    );
          }
        );
  }
}