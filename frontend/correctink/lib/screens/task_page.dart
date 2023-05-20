import 'dart:async';

import 'package:correctink/create/create_todo.dart';
import 'package:correctink/realm/realm_services.dart';
import 'package:correctink/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/todo_list.dart';
import '../modify/modify_task.dart';
import '../realm/schemas.dart';


class TaskPage extends StatefulWidget{
  const TaskPage(this.taskId, {Key? key}) : super(key: key);

  final String taskId;

  @override
  State<StatefulWidget> createState() => _TaskPage();
}

class _TaskPage extends State<TaskPage>{
  late RealmServices realmServices;
  late Task? task;
  late StreamSubscription stream;
  bool isStreamInit = false;

  @override
  void didChangeDependencies(){
    super.didChangeDependencies();
    realmServices = Provider.of<RealmServices>(context);
    task = realmServices.taskCollection.get(widget.taskId);

    if(!isStreamInit){
      stream = task!.changes.listen((event) {
        setState(() {
          task = event.object;
        });
      });
    }
  }

  @override
  void dispose(){
    stream.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
    return task == null ? Container()
        : Scaffold(
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          floatingActionButton: CreateTodoAction(task!.id),
          bottomNavigationBar: BottomAppBar(
            height: 40,
            shape: const CircularNotchedRectangle(),
            child: Container(
              height: 0,
            ),
          ),
          body: Column(
            children: [
              Material(
                elevation: 1,
                color: Theme.of(context).colorScheme.secondaryContainer,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListTile(
                                leading: Checkbox(
                                  value: task!.isComplete,
                                  onChanged: (value) {
                                    realmServices.taskCollection.update(task!, isComplete: value);
                                    setState(() {
                                      task!.isComplete = value?? !task!.isComplete;
                                    });
                                  },
                                ),
                                horizontalTitleGap: 6,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                                title: Text(task!.task, style: Theme.of(context).textTheme.titleLarge, softWrap: true,),
                                subtitle: task!.deadline != null
                                    ? Padding(
                                        padding: const EdgeInsets.fromLTRB(0, 8.0, 0, 2),
                                        child: Text(task!.deadline!.getWrittenFormat(), style: task!.deadline?.getDeadlineStyle(context),),
                                    )
                                    : null
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => {
                            showModalBottomSheet(
                              useRootNavigator: true,
                              context: context,
                              isScrollControlled: true,
                              builder: (_) => Wrap(children: [ModifyTaskForm(task!)]),
                            )
                          },
                          icon: const Icon(Icons.edit),
                        ),
                      ],
                    ),
                ),
              ),
              Expanded(child: TodoList(task!.id)),
            ],
          ),
    );
  }
}