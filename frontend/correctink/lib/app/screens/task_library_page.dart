import 'package:flutter/material.dart';

import '../../blocs/tasks/task_list.dart';

class TasksView extends StatefulWidget{
  const TasksView({super.key});

  @override
  State<StatefulWidget> createState() => _TaskView();

}

class _TaskView extends State<TasksView>{
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: TaskList());
  }

}