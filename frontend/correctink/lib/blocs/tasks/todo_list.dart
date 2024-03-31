import 'package:correctink/blocs/tasks/todo_item.dart';
import 'package:correctink/widgets/widgets.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realm/realm.dart';

import '../../app/data/models/schemas.dart';
import '../../app/data/repositories/realm_services.dart';

class TodoList extends StatefulWidget{
  final ObjectId taskId;
  final Widget header;

  const TodoList(this.taskId, {required this.header, Key? key}) : super(key: key);

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
            elevation: 1,
            color: Colors.transparent,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(12), bottomRight: Radius.circular(6), bottomLeft: Radius.circular(12))
            ),
            shadowColor: Theme.of(context).colorScheme.surfaceTint,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2.0),
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
                  ? ListView(children: [widget.header])
                  : ReorderableListView.builder(
                      shrinkWrap: true,
                      primary: false,
                      header: widget.header,
                      proxyDecorator: proxyDecorator,
                      padding: const EdgeInsets.fromLTRB(8, 8, 8, 24),
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