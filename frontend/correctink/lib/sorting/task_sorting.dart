import 'package:flutter/material.dart';
import 'package:correctink/components/widgets.dart';
import 'package:localization/localization.dart';


enum SortingField {
  _id,
  task,
  deadline,
  reminder,
  creationDate,
}

class SortTask extends StatefulWidget{
  const SortTask(this.updateSorting, this.startingValue, {super.key});

  final Function(String value) updateSorting;
  final String startingValue;

  @override
  State<StatefulWidget> createState() => _SortTask();
}

class _SortTask extends State<SortTask>{
  late SortingField? sortedBy;

  void updateValue(SortingField? value){
    setState(() {
      sortedBy = value;
    });
    if(sortedBy != null){
      widget.updateSorting(sortedBy!.name);
    }
  }

  @override
  Widget build(BuildContext context) {
    switch(widget.startingValue){
      case '_id':
        sortedBy = SortingField._id;
        break;
      case 'task':
        sortedBy = SortingField.task;
        break;
      case 'deadline':
        sortedBy = SortingField.deadline;
        break;
      case 'reminder':
        sortedBy = SortingField.reminder;
        break;
      case 'creationDate':
        sortedBy = SortingField.creationDate;
        break;
      default:
        sortedBy = SortingField._id;
        break;
    }
    return Wrap(
      alignment: WrapAlignment.start,
      direction: Axis.horizontal,
      children: [
        customRadioButton(context,
          label: 'Creation Date'.i18n(),
          isSelected: sortedBy == SortingField.creationDate,
          onPressed: () {
            updateValue(SortingField.creationDate);
          },
          width: 180,
        ),
        customRadioButton(context,
            label: 'A-Z',
            isSelected: sortedBy == SortingField.task,
            onPressed: () {
              updateValue(SortingField.task);
            },
          width: 80,
        ),
        customRadioButton(context,
          label: 'Deadline'.i18n(),
          isSelected: sortedBy == SortingField.deadline,
          onPressed: () {
            updateValue(SortingField.deadline);
          },
          width: 125,
        ),
        customRadioButton(context,
          label: 'Reminder'.i18n(),
          isSelected: sortedBy == SortingField.reminder,
          onPressed: () {
            updateValue(SortingField.reminder);
          },
          width: 125,
        ),
      ],
    );
  }

}