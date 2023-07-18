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

  late Task? task;
  late RealmServices realmServices;

  @override
  void didChangeDependencies(){
    super.didChangeDependencies();
    realmServices = Provider.of<RealmServices>(context);

    task = realmServices.taskCollection.get(widget.taskId.hexString);
  }

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
                borderRadius: BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(12), bottomRight: Radius.circular(6), bottomLeft: Radius.circular(12))
            ),
            shadowColor: Theme.of(context).colorScheme.tertiary,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: child,
            ),
          );
        },
        child: child,
      );
    }

    return Stack(
      children: [
        StreamBuilder<RealmListChanges<TaskStep>>(
          stream: task!.steps.changes,
          builder: (context, snapshot) {
              final data = snapshot.data;

              if (data == null) return waitingIndicator();

              final results = data.list;
              final sortedSteps = results.freeze().toList();
              sortedSteps.sort((step1, step2) => step2.index.compareTo(step1.index));
              return results.isEmpty
                  ? const SizedBox()
                  : ReorderableListView.builder(
                      shrinkWrap: true,
                      primary: false,
                      proxyDecorator: proxyDecorator,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(8, 8, 8, 18),
                      scrollDirection: Axis.vertical,
                      itemCount: results.realm.isClosed ? 0 : results.length,
                      itemBuilder: (context, index) => sortedSteps[index].isValid
                          ? Padding(
                            key: Key('$index'),
                            padding: const EdgeInsets.symmetric(vertical: 2.0),
                            child: TodoItem(results[index], key: Key('$index'),),
                          )
                          : Container(key: Key('$index')),
                  onReorder: (int oldIndex, int newIndex) {
                        if(oldIndex < newIndex){
                          newIndex -= 1;
                        }
                        realmServices.taskCollection.updateStepsOrder(task!, oldIndex, newIndex);
                  },
                );
          }
        ),
        realmServices.isWaiting ? waitingIndicator() : Container(),
      ],
    );
  }
}