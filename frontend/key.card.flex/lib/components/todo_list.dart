import 'package:flutter/material.dart';
import 'package:key_card/components/todo_item.dart';
import 'package:key_card/components/widgets.dart';
import 'package:provider/provider.dart';
import 'package:realm/realm.dart';

import '../realm/realm_services.dart';
import '../realm/schemas.dart';

class TodoList extends StatefulWidget {
  const TodoList({Key? key}) : super(key: key);

  @override
  State<TodoList> createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final realmServices = Provider.of<RealmServices>(context);
    return Stack(
      children: [
        Column(
          children: [
            styledBox(
              context,
              isHeader: true,
              child: Row(
                children: [
                  const Expanded(
                    child: Text("Show All Tasks", textAlign: TextAlign.right),
                  ),
                  Switch(
                    value: realmServices.showAllTasks,
                    onChanged: (value) async {
                      if (realmServices.offlineModeOn) {
                        infoMessageSnackBar(context,
                                "Switching subscriptions does not affect Realm data when the sync is offline.")
                            .show(context);
                      }
                      await realmServices.switchTaskSubscription(value);
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: StreamBuilder<RealmResultsChanges<Task>>(
                  stream: realmServices.realm
                      .query<Task>("TRUEPREDICATE SORT(_id ASC)")
                      .changes,
                  builder: (context, snapshot) {
                    final data = snapshot.data;

                    if (data == null) return waitingIndicator();

                    final results = data.results;
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: results.realm.isClosed ? 0 : results.length,
                      itemBuilder: (context, index) => results[index].isValid
                          ? TodoItem(results[index])
                          : Container(),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
        realmServices.isWaiting ? waitingIndicator() : Container(),
      ],
    );
  }
}
