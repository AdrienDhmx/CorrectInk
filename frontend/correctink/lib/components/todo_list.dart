import 'package:correctink/components/todo_item.dart';
import 'package:correctink/components/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realm/realm.dart';

import '../realm/realm_services.dart';
import '../realm/schemas.dart';

class TodoList extends StatefulWidget{
  final ObjectId taskId;

  const TodoList(this.taskId, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TodoList();
}

class _TodoList extends State<TodoList>{


  @override
  Widget build(BuildContext context) {
    final realmServices = Provider.of<RealmServices>(context);
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
          child: StreamBuilder<RealmResultsChanges<ToDo>>(
            stream: realmServices.todoCollection.get(widget.taskId.hexString).changes,
            builder: (context, snapshot) {
                final data = snapshot.data;

                if (data == null) return waitingIndicator();

                final results = data.results;
                return results.isEmpty
                    ? Center(
                      child: Text("No steps have been added to this task.", style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.primary
                        ),
                      ),
                    )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(0, 8, 0, 18),
                        semanticChildCount: results.realm.isClosed ? 0 : results.length,
                        scrollDirection: Axis.vertical,
                        itemCount: results.realm.isClosed ? 0 : results.length,
                        itemBuilder: (context, index) => results[index].isValid
                            ? Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4.0),
                              child: TodoItem(results[index]),
                            )
                            : Container(),
                  );
            }
          ),
        ),
        realmServices.isWaiting ? waitingIndicator() : Container(),
      ],
    );
  }

}