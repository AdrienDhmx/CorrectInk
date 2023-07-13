import 'package:flutter/material.dart';
import 'package:correctink/components/widgets.dart';
import 'package:localization/localization.dart';

import '../utils.dart';

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
        labeledAction(
          context: context,
          label: 'Creation Date'.i18n(),
          child: Radio<SortingField>(
            value: SortingField.creationDate,
            visualDensity: Utils.isOnPhone() ? VisualDensity.compact : VisualDensity.comfortable,
            groupValue: sortedBy,
            onChanged: (value) {
              updateValue(value);
            },
          ),
          width: 168,
          labelFirst: false,
          onTapAction: () {
            updateValue(SortingField.creationDate);
          }
        ),
        labeledAction(
          context: context,
          label: 'A-Z',
          child: Radio<SortingField>(
            value: SortingField.task,
            visualDensity: Utils.isOnPhone() ? VisualDensity.compact : VisualDensity.comfortable,
            groupValue: sortedBy,
            onChanged: (value) {
              updateValue(value);
            },
          ),
          width: 80,
          labelFirst: false,
            onTapAction: () {
              updateValue(SortingField.task);
            }
        ),
        labeledAction(
          context: context,
          label: 'Deadline'.i18n(),
          child: Radio<SortingField>(
            value: SortingField.deadline,
            visualDensity: Utils.isOnPhone() ? VisualDensity.compact : VisualDensity.comfortable,
            groupValue: sortedBy,
            onChanged: (value) {
              updateValue(value);
            },
          ),
          width: 125,
          labelFirst: false,
            onTapAction: () {
              updateValue(SortingField.deadline);
            }
        ),
        labeledAction(
            context: context,
            label: 'Reminder'.i18n(),
            child: Radio<SortingField>(
              value: SortingField.reminder,
              visualDensity: Utils.isOnPhone() ? VisualDensity.compact : VisualDensity.comfortable,
              groupValue: sortedBy,
              onChanged: (value) {
                updateValue(value);
              },
            ),
            width: 125,
            labelFirst: false,
            onTapAction: () {
              updateValue(SortingField.reminder);
            }
        ),
      ],
    );
  }

}