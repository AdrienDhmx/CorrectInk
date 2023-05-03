import 'package:flutter/material.dart';
import 'package:key_card/components/item_popup_option.dart';
import 'package:key_card/components/widgets.dart';
import 'package:provider/provider.dart';

import '../realm/realm_services.dart';
import '../realm/schemas.dart';
import '../theme.dart';

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
                  await realmServices.updateItem(item,
                      isComplete: value ?? false);
                } else {
                  errorMessageSnackBar(context, "Change not allowed!",
                          "You are not allowed to change the status of \n tasks that don't belong to you.")
                      .show(context);
                }
              },
            ),
            title: Text(
                item.summary,
              style: TextStyle(
                decoration: item.isComplete ? TextDecoration.lineThrough : TextDecoration.none,
              ),
            ),
            subtitle:isMine && realmServices.showAllTasks ?  Text( '(mine) ', style: boldTextStyle(context)) : null,
            trailing: TaskPopupOption(realmServices, item),
            shape: const Border(bottom: BorderSide()),
          )
        : Container();
  }
}
