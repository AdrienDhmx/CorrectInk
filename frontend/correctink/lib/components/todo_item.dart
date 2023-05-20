import 'package:correctink/realm/schemas.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../modify/modify_todo.dart';
import '../realm/realm_services.dart';
import 'item_popup_option.dart';

enum MenuOption { edit, delete }

class TodoItem extends StatelessWidget {
  final ToDo todo;

  const TodoItem(this.todo, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final realmServices = Provider.of<RealmServices>(context);
    return todo.isValid
        ? ListTile(
            onTap: () async{
              await realmServices.todoCollection.update(todo, isComplete: !todo.isComplete);
            },
            onLongPress: () {
              showModalBottomSheet(
                useRootNavigator: true,
                context: context,
                isScrollControlled: true,
                builder: (_) => Wrap(children: [ModifyTodoForm(todo)]),
              );
            },
            tileColor: Theme.of(context).colorScheme.surfaceVariant,
            horizontalTitleGap: 6,
            contentPadding: const EdgeInsets.symmetric(horizontal: 6),
            leading: Checkbox(
              shape: const CircleBorder(side: BorderSide()),
              value: todo.isComplete,
              onChanged: (bool? value) async {
                await realmServices.todoCollection.update(todo, isComplete: value ?? false);
              },
            ),
            title: Text(
              todo.todo,
              style: TextStyle(
                color: todo.isComplete ? Theme.of(context).colorScheme.onSurfaceVariant.withAlpha(200) : Theme.of(context).colorScheme.onSurfaceVariant,
                decoration: todo.isComplete ? TextDecoration.lineThrough : TextDecoration.none,
              ),
            ),
            trailing: TodoPopupOption(realmServices, todo),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8))
            ),
        )
        : Container();
  }
}
