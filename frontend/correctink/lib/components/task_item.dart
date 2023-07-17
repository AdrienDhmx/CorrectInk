import 'package:correctink/components/widgets.dart';
import 'package:correctink/modify/modify_task.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:correctink/components/item_popup_option.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import '../realm/realm_services.dart';
import '../realm/schemas.dart';

enum MenuOption { edit, delete }

class TaskItem extends StatelessWidget {
  final Task task;
  final bool border;

  const TaskItem(this.task, {Key? key, required this.border}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final realmServices = Provider.of<RealmServices>(context);
    return task.isValid
        ? ListTile(
            horizontalTitleGap: 8,
            onTap: (){
              GoRouter.of(context).push(RouterHelper.buildTaskRoute(task.id.hexString));
            },
            onLongPress: () {
              showModalBottomSheet(
                useRootNavigator: true,
                context: context,
                isScrollControlled: true,
                builder: (_) => Wrap(children: [ModifyTaskForm(task)]),
              );
            },
            contentPadding: const EdgeInsets.symmetric(horizontal: 4),
            leading: Checkbox(
              shape: taskCheckBoxShape(),
              value: task.isComplete,
              onChanged: (bool? value) async {
                  await realmServices.taskCollection.update(task,isComplete: value ?? false, deadline: task.deadline);
              },
            ),
            title: Text(
                task.task,
              style: TextStyle(
                color: task.isComplete ? Theme.of(context).colorScheme.onBackground.withAlpha(200) : Theme.of(context).colorScheme.onBackground,
                decoration: task.isComplete ? TextDecoration.lineThrough : TextDecoration.none,
              ),
            ),
          subtitle: (task.hasDeadline && !task.isComplete) || task.hasReminder || task.steps.isNotEmpty
              ? Column(
                mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    deadlineInfo(context: context, task: task),
                    reminderInfo(context: context, task: task),
                    if(task.steps.isNotEmpty) Text('${task.steps.where((step) => step.isComplete).length} / ${task.steps.length}')
                  ],
              )
              : null,
            trailing: TaskPopupOption(realmServices, task),
            shape: border ? const Border(bottom: BorderSide()) : null,
          )
        : Container();
  }
}
