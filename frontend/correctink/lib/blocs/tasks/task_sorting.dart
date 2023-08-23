import 'package:flutter/material.dart';
import 'package:correctink/widgets/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:localization/localization.dart';


enum TaskSortingField {
  _id,
  task,
  deadline,
  reminder,
  creationDate,
}

class SortTask extends StatefulWidget{
  const SortTask({required this.onChange, required this.startingValue, super.key});

  final Function(String value) onChange;
  final String startingValue;

  @override
  State<StatefulWidget> createState() => _SortTask();
}

class _SortTask extends State<SortTask>{
  late TaskSortingField? sortedBy;

  void updateValue(TaskSortingField? value){
    setState(() {
      sortedBy = value;
    });
    if(sortedBy != null){
      widget.onChange(sortedBy!.name);
      GoRouter.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    switch(widget.startingValue){
      case '_id':
        sortedBy = TaskSortingField._id;
        break;
      case 'task':
        sortedBy = TaskSortingField.task;
        break;
      case 'deadline':
        sortedBy = TaskSortingField.deadline;
        break;
      case 'reminder':
        sortedBy = TaskSortingField.reminder;
        break;
      case 'creationDate':
        sortedBy = TaskSortingField.creationDate;
        break;
      default:
        sortedBy = TaskSortingField._id;
        break;
    }
    return AlertDialog(
      title: Text("Sort by".i18n()),
      titleTextStyle: Theme.of(context).textTheme.headlineMedium,
      content: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            customRadioButton(context,
              label: 'Creation Date'.i18n(),
              isSelected: sortedBy == TaskSortingField.creationDate,
              onPressed: () {
                updateValue(TaskSortingField.creationDate);
              },
              center: false,
              infiniteWidth: false
            ),
            customRadioButton(context,
                label: 'Task'.i18n(),
                isSelected: sortedBy == TaskSortingField.task,
                onPressed: () {
                  updateValue(TaskSortingField.task);
                },
                center: false,
              infiniteWidth: false
            ),
            customRadioButton(context,
              label: 'Deadline'.i18n(),
              isSelected: sortedBy == TaskSortingField.deadline,
              onPressed: () {
                updateValue(TaskSortingField.deadline);
              },
              center: false,
              infiniteWidth: false
            ),
            customRadioButton(context,
              label: 'Reminder'.i18n(),
              isSelected: sortedBy == TaskSortingField.reminder,
              onPressed: () {
                updateValue(TaskSortingField.reminder);
              },
                center: false,
              infiniteWidth: false
            ),
          ],
        ),
      ),
    );
  }

}