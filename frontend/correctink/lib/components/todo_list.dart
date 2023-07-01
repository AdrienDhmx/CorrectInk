import 'package:correctink/components/todo_item.dart';
import 'package:correctink/components/widgets.dart';
import 'package:flutter/material.dart';
import 'package:localization/localization.dart';
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
    Widget proxyDecorator(
        Widget child, int index, Animation<double> animation) {
      return AnimatedBuilder(
        animation: animation,
        builder: (BuildContext context, Widget? child) {
          return Material(
            elevation: 0.5,
            color: Colors.transparent,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8))
            ),
            shadowColor: Theme
                .of(context)
                .colorScheme
                .primary,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: child,
            ),
          );
        },
        child: child,
      );
    }


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
                      child: Text("Placeholder no steps".i18n(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    )
                    : ReorderableListView.builder(
                        shrinkWrap: true,
                        proxyDecorator: proxyDecorator,
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(0, 8, 0, 18),
                        scrollDirection: Axis.vertical,
                        itemCount: results.realm.isClosed ? 0 : results.length,
                        itemBuilder: (context, index) => results[index].isValid
                            ? Padding(
                              key: Key('$index'),
                              padding: const EdgeInsets.symmetric(vertical: 4.0),
                              child: TodoItem(results[index], key: Key('$index'),),
                            )
                            : Container(key: Key('$index')),
                    onReorder: (int oldIndex, int newIndex) {
                          if(oldIndex < newIndex){
                            newIndex -= 1;
                          }

                          final todos = results.toList();
                          final temp = todos[oldIndex];
                          todos.removeAt(oldIndex);
                          todos.insert(newIndex, temp);

                          realmServices.todoCollection.updateToDoIndex(todos);
                    },
                  );
            }
          ),
        ),
        realmServices.isWaiting ? waitingIndicator() : Container(),
      ],
    );
  }
}