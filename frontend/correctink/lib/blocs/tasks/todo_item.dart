import 'package:correctink/blocs/tasks/popups_menu.dart';
import 'package:correctink/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/data/models/schemas.dart';
import '../../app/data/repositories/realm_services.dart';
import '../../app/screens/edit/modify_step.dart';
import '../../utils/utils.dart';

class TodoItem extends StatelessWidget {
  final TaskStep step;

  const TodoItem(this.step, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final realmServices = Provider.of<RealmServices>(context);
    return step.isValid
        ? Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondaryContainer,
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(12), bottomRight: Radius.circular(6), bottomLeft: Radius.circular(12))
          ),
          child: ListTile(
              onTap: () async{
                await realmServices.todoCollection.update(step, isComplete: !step.isComplete);
              },
               onLongPress: !Utils.isOnPhone() ? () {
                showModalBottomSheet(
                  useRootNavigator: true,
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => Wrap(children: [ModifyTodoForm(step)]),
                );
              } : null, // the long press is used to drag on phones
              horizontalTitleGap: 6,
              contentPadding: Utils.isOnPhone() ? const EdgeInsets.fromLTRB(6, 0, 6, 0) : const EdgeInsets.fromLTRB(6, 0, 32, 0),
              leading: Checkbox(
                shape: stepCheckBoxShape(),
                side: BorderSide(
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                  width: 2,
                  strokeAlign: BorderSide.strokeAlignCenter
                ),
                value: step.isComplete,
                onChanged: (bool? value) async {
                  await realmServices.todoCollection.update(step, isComplete: value ?? false);
                },
              ),
              title: Text(
                step.todo,
                style: TextStyle(
                  color: step.isComplete ? Theme.of(context).colorScheme.onSecondaryContainer.withAlpha(200) : Theme.of(context).colorScheme.onSecondaryContainer,
                  decoration: step.isComplete ? TextDecoration.lineThrough : TextDecoration.none,
                ),
              ),
              trailing: TodoPopupOption(realmServices, step),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(12), bottomRight: Radius.circular(6), bottomLeft: Radius.circular(12))
              ),
          ),
        )
        : const SizedBox();
  }
}
