
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:localization/localization.dart';

import '../../widgets/widgets.dart';

enum SetSortingField {
  creationDate,
  setTitle,
  studyDate,
  setColor,
  popularity,
}

class SortSet extends StatefulWidget{
  const SortSet({required this.onUpdate, required this.startingValue, super.key, required this.publicSets});

  final Function(String value) onUpdate;
  final String startingValue;
  final bool publicSets;

  @override
  State<StatefulWidget> createState() => _SortSet();
}

class _SortSet extends State<SortSet>{
  late SetSortingField? sortedBy;

  void updateValue(SetSortingField? value){
    setState(() {
      sortedBy = value;
    });
    if(sortedBy != null){
      widget.onUpdate(sortedBy!.name);
      GoRouter.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    switch(widget.startingValue){
      case 'setTitle':
        sortedBy = SetSortingField.setTitle;
        break;
      case 'studyDate':
        if(widget.publicSets) {
          sortedBy = SetSortingField.creationDate;
        } else {
          sortedBy = SetSortingField.studyDate;
        }
        break;
      case 'creationDate':
        sortedBy = SetSortingField.creationDate;
        break;
      case 'setColor':
        sortedBy = SetSortingField.setColor;
        break;
      case 'popularity':
        sortedBy = SetSortingField.popularity;
      default:
        sortedBy = SetSortingField.creationDate;
        break;
    }
    return AlertDialog(
      title: Text("Sort by".i18n()),
      titleTextStyle: Theme.of(context).textTheme.headlineMedium,
      content: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            customRadioButton(context,
              label: 'Creation Date'.i18n(),
              isSelected: sortedBy == SetSortingField.creationDate,
              onPressed: () {
                updateValue(SetSortingField.creationDate);
              },
              center: false,
            ),
            customRadioButton(context,
              label: 'Name'.i18n(),
              isSelected: sortedBy == SetSortingField.setTitle,
              onPressed: () {
                updateValue(SetSortingField.setTitle);
              },
              center: false,
            ),
            if(!widget.publicSets)
              customRadioButton(context,
                label: 'Study date'.i18n(),
                isSelected: sortedBy == SetSortingField.studyDate,
                onPressed: () {
                  updateValue(SetSortingField.studyDate);
                },
                center: false,
              ),
            customRadioButton(context,
              label: 'Color'.i18n(),
              isSelected: sortedBy == SetSortingField.setColor,
              onPressed: () {
                updateValue(SetSortingField.setColor);
              },
              center: false,
            ),
            customRadioButton(context,
              label: 'Popularity'.i18n(),
              isSelected: sortedBy == SetSortingField.popularity,
              onPressed: () {
                updateValue(SetSortingField.popularity);
              },
              center: false,
            ),
          ],
        ),
      ),
    );
  }

}