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

    if(card.lastSeen != null){
      if(card.learningProgress < -2){
        progressColor = Colors.red;
      }else if(card.learningProgress < 6){
        progressColor = Colors.orange;
      }else{
        progressColor = Colors.green;
      }
    }

    return Stack(
      children: [
        if(canEdit) Padding(
          padding: const EdgeInsets.all(4.0),
          child: CircleAvatar(
            radius: 5,
            backgroundColor: progressColor,
          ),
        ),
        ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
        horizontalTitleGap: 6,
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