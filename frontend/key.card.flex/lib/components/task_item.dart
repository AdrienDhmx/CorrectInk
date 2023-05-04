import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:key_card/components/item_popup_option.dart';
import 'package:key_card/components/widgets.dart';
import 'package:provider/provider.dart';

import '../realm/realm_services.dart';
import '../realm/schemas.dart';

enum MenuOption { edit, delete }

class TodoItem extends StatelessWidget {
  final Task item;

  const TodoItem(this.item, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final realmServices = Provider.of<RealmServices>(context);
    bool isMine = (item.ownerId == realmServices.currentUser?.id);
    return item.isValid
        ? ListTile(
            horizontalTitleGap: 4,
            leading: Checkbox(
              value: item.isComplete,
              onChanged: (bool? value) async {
                if (isMine) {
                  await realmServices.updateTask(item,
                      isComplete: value ?? false);
                } else {
                  errorMessageSnackBar(context, "Change not allowed!",
                          "You are not allowed to change the status of \n tasks that don't belong to you.")
                      .show(context);
                }
              },
            ),
            title: Text(
                item.task,
              style: TextStyle(
                color: item.isComplete ? Theme.of(context).colorScheme.onBackground.withAlpha(200) : Theme.of(context).colorScheme.onBackground,
                decoration: item.isComplete ? TextDecoration.lineThrough : TextDecoration.none,
              ),
            ),
            subtitle: item.deadline != null ? Text(getTaskDateFormated(item), style: getTaskDateStyle(context, item),) : null,
            trailing: TaskPopupOption(realmServices, item),
            shape: const Border(bottom: BorderSide()),
          )
        : Container();
  }

  String getTaskDateFormated(Task task){
    if(!task.hasDeadline) return '';

    DateTime now = DateTime.now().add(const Duration(hours: 2));
    if(task.deadline!.year == now.year && task.deadline!.month == now.month){
      if(task.deadline!.day == now.day) {
        return "Today - ${DateFormat('kk:mm').format(task.deadline!)}";
      } else if(task.deadline!.day == now.day + 1){
        return "Tomorrow - ${DateFormat('kk:mm').format(task.deadline!)}";
      }
    }
    return DateFormat('yyyy-MM-dd – kk:mm').format(item.deadline!);
  }

  TextStyle? getTaskDateStyle(BuildContext context, Task task){
    if(!task.hasDeadline) return null;

    DateTime now = DateTime.now().add(const Duration(hours: 2));
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
