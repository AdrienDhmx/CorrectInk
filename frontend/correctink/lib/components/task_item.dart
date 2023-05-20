import 'package:correctink/modify/modify_task.dart';
import 'package:correctink/utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:correctink/components/item_popup_option.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import '../realm/realm_services.dart';
import '../realm/schemas.dart';

enum MenuOption { edit, delete }

class TaskItem extends StatelessWidget {
  final Task task;

  const TaskItem(this.task, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final realmServices = Provider.of<RealmServices>(context);
    return task.isValid
        ? ListTile(
            horizontalTitleGap: 4,
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
              value: task.isComplete,
              onChanged: (bool? value) async {
                  await realmServices.taskCollection.update(task,isComplete: value ?? false);
              },
            ),
            title: Text(
                task.task,
              style: TextStyle(
                color: task.isComplete ? Theme.of(context).colorScheme.onBackground.withAlpha(200) : Theme.of(context).colorScheme.onBackground,
                decoration: task.isComplete ? TextDecoration.lineThrough : TextDecoration.none,
              ),
            ),
            subtitle: task.deadline != null ? Text(task.deadline!.getWrittenFormat(), style: task.deadline!.getDeadlineStyle(context),) : null,
            trailing: TaskPopupOption(realmServices, task),
            shape: const Border(bottom: BorderSide()),
          )
        : Container();
  }
}
