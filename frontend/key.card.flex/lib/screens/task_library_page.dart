import 'package:flutter/material.dart';
import '../components/todo_list.dart';

class TasksView extends StatefulWidget{
  const TasksView({super.key});

  @override
  State<StatefulWidget> createState() => _TaskView();

}

class _TaskView extends State<TasksView>{
  @override
  Widget build(BuildContext context) {
    return const TodoList();
  }

}