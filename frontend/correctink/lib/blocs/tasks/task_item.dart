import 'dart:async';

import 'package:correctink/blocs/tasks/popups_menu.dart';
import 'package:correctink/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/data/models/schemas.dart';
import '../../app/data/repositories/realm_services.dart';
import '../../app/screens/edit/modify_task.dart';
import '../../utils/router_helper.dart';

class TaskItem extends StatefulWidget {
  final Task task;
  final bool border;

  const TaskItem(this.task, {Key? key, required this.border}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TaskItem();
}


class _TaskItem extends State<TaskItem> {
  late bool? completed = false;
  late bool updateCompleted = false;

  @override
  void didChangeDependencies(){
    super.didChangeDependencies();

    completed = widget.task.isComplete;
  }

  @override
  Widget build(BuildContext context) {
    final realmServices = Provider.of<RealmServices>(context);
    if(updateCompleted) {
      completed = widget.task.isComplete;
      updateCompleted = false;
    }
    return widget.task.isValid
        ? ListTile(
            horizontalTitleGap: 8,
            onTap: (){
              GoRouter.of(context).push(RouterHelper.buildTaskRoute(widget.task.id.hexString));
            },
            onLongPress: () {
              showModalBottomSheet(
                useRootNavigator: true,
                context: context,
                isScrollControlled: true,
                builder: (_) => Wrap(children: [ModifyTaskForm(widget.task)]),
              );
            },
            contentPadding: const EdgeInsets.symmetric(horizontal: 4),
            leading: Checkbox(
              shape: taskCheckBoxShape(),
              value: completed,
              onChanged: (bool? value) {
                setState(() {
                  completed = value;
                });
                Timer(const Duration(milliseconds: 800),
                  () {
                    realmServices.taskCollection.update(widget.task,isComplete: value ?? false, deadline: widget.task.deadline);
                    setState(() {
                      updateCompleted = true;
                    });
                  }
                );
              },
            ),
            title: Text.rich(
              TextSpan(
                  children: [
                    TextSpan(text: '${widget.task.task}  '),
                    if(widget.task.note.trim().isNotEmpty)
                      WidgetSpan(child: Icon(
                          Icons.sticky_note_2_outlined,
                          color: Theme.of(context).colorScheme.onSurface,
                          size: 18),
                      ),
                  ],
              ),
              softWrap: true,
              style: TextStyle(
                color: widget.task.isComplete ? Theme.of(context).colorScheme.onBackground.withAlpha(200) : Theme.of(context).colorScheme.onBackground,
                decoration: widget.task.isComplete ? TextDecoration.lineThrough : TextDecoration.none,
              ),
            ),
          subtitle: (widget.task.hasDeadline && !widget.task.isComplete) || widget.task.hasReminder || widget.task.steps.isNotEmpty
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    if(widget.task.steps.isNotEmpty)...[
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.task_alt_rounded, color: Theme.of(context).colorScheme.onSurface, size: 14,),
                          const SizedBox(width: 4,),
                          Text(
                            '${widget.task.steps.where((step) => step.isComplete).length} / ${widget.task.steps.length}',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface),
                          ),
                        ],
                      ),
                      const SizedBox(width: 18,),
                    ],
                    deadlineInfo(context: context, task: widget.task),
                    reminderInfo(context: context, task: widget.task),
                  ],
              )
              : null,
            trailing: TaskPopupOption(realmServices, widget.task),
            shape: widget.border ? Border(bottom: BorderSide(
              color: Theme.of(context).colorScheme.onBackground.withAlpha(100)
            )) : null,
          )
        : Container();
  }
}
