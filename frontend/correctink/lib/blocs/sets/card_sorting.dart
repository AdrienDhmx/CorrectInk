import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:localization/localization.dart';

import '../../widgets/buttons.dart';

enum CardSortingField {
  creationDate("Creation Date"),
  front("Front"),
  back("Back"),
  seenCount("Seen count"),
  lastSeen("Last seen date"),
  currentBox("Current box");

  const CardSortingField(this.name);

  final String name;
  String get i18nName => name.i18n();
}

class SortCard extends StatelessWidget{
  final Function(CardSortingField value) onUpdate;
  final CardSortingField sortedBy;
  final bool isOwner;

  const SortCard({super.key, required this.onUpdate, required this.sortedBy, required this.isOwner});

  @override
  Widget build(BuildContext context) {
    final sortChoices = isOwner ? CardSortingField.values : [CardSortingField.creationDate, CardSortingField.front, CardSortingField.back];
    return AlertDialog(
      title: Text("Sort by".i18n()),
      titleTextStyle: Theme.of(context).textTheme.headlineMedium,
      content: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for(CardSortingField cardSortItem in sortChoices)
              customRadioButton(context,
                label: cardSortItem.i18nName,
                isSelected: sortedBy == cardSortItem,
                onPressed: () {
                  onUpdate(cardSortItem);
                  GoRouter.of(context).pop();
                },
                center: false,
              ),
          ],
        ),
      ),
    );
  }

}