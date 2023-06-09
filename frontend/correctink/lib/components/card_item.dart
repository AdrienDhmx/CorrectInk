import 'package:correctink/modify/modify_card.dart';
import 'package:flutter/material.dart';
import 'package:correctink/realm/schemas.dart';
import 'package:provider/provider.dart';

import '../realm/realm_services.dart';
import 'item_popup_option.dart';

class CardItem extends StatelessWidget{

  const CardItem(this.card, this.canEdit, {Key? key}) : super(key: key);
  final KeyValueCard card;
  final bool canEdit;


  @override
  Widget build(BuildContext context) {
    final realmServices = Provider.of<RealmServices>(context);
    Color progressColor = Colors.transparent;

    if (card.lastSeen != null) {
      if (card.isKnown) {
        progressColor = Colors.green;
      } else if (card.isLearning) {
        progressColor = Colors.orange;
      } else {
        progressColor = Colors.red;
      }
    }

    return Stack(
      children: [
        if(canEdit && progressColor != Colors.transparent) Padding(
          padding: const EdgeInsets.all(5.0),
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: progressColor,
                shape: BoxShape.circle,
                 boxShadow: [
                  BoxShadow(
                    color: progressColor.withAlpha(180),
                  blurRadius: 1.0,
                  spreadRadius: 1.0,
              )
            ])
          )
        ),
        ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
        horizontalTitleGap: 6,
        onLongPress: () {
          showModalBottomSheet(
            useRootNavigator: true,
            context: context,
            isScrollControlled: true,
            builder: (_) => Wrap(children: [ModifyCardForm(card)]),
          );
        },
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Column(
            children: [
              Align(
                  alignment: Alignment.centerLeft,
                  child: Text(card.key, style: Theme.of(context).textTheme.bodyMedium)
              ),
              const SizedBox(height: 8.0),
              Align(
                  alignment: Alignment.centerLeft,
                  child: Text(card.value, style: Theme.of(context).textTheme.bodyMedium)
              ),
            ],
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        textColor: Theme.of(context).colorScheme.onSecondaryContainer,
        tileColor: Theme.of(context).colorScheme.secondaryContainer,
        trailing: CardPopupOption(realmServices, card, canEdit),
      ),
      ],
    );
  }

}