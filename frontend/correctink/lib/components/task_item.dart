import 'package:correctink/utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:correctink/components/item_popup_option.dart';
import 'package:provider/provider.dart';

import '../realm/realm_services.dart';
import '../realm/schemas.dart';

enum MenuOption { edit, delete }

class TodoItem extends StatelessWidget {
  final Task task;

  const TodoItem(this.task, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final realmServices = Provider.of<RealmServices>(context);
    return task.isValid
        ? ListTile(
            horizontalTitleGap: 4,
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
            subtitle: task.deadline != null ? Text(getTaskDateFormated(), style: getTaskDateStyle(context),) : null,
            trailing: TaskPopupOption(realmServices, task),
            shape: const Border(bottom: BorderSide()),
          )
        : Container();
  }

  String getTaskDateFormated(){
    if(!task.hasDeadline) return '';

    DateTime now = DateTime.now();
    if(task.deadline!.year == now.year && task.deadline!.month == now.month){
      if(task.deadline!.day == now.day) {
        return "Today - ${DateFormat('kk:mm').format(task.deadline!)}";
      } else if(task.deadline!.day == now.day + 1){
        return "Tomorrow - ${DateFormat('kk:mm').format(task.deadline!)}";
      } else if(task.deadline!.day == now.day - 1){
        return "Yesterday - ${DateFormat('kk:mm').format(task.deadline!)}";
      }
    }
    return task.deadline!.format();
  }

  TextStyle? getTaskDateStyle(BuildContext context){
    if(!task.hasDeadline || task.isComplete) return null;

    DateTime now = DateTime.now();
    if(task.deadline!.isBefore(now)){
      return TextStyle(
        color: Theme.of(context).colorScheme.error,
        fontWeight: FontWeight.w600
      );
    } else if(task.deadline!.year == now.year && task.deadline!.month == now.month && task.deadline!.day == now.day){
      return TextStyle(
        color: Theme.of(context).colorScheme.primary,
        fontWeight: FontWeight.w600
      );
    }
    return null;
  }
}
