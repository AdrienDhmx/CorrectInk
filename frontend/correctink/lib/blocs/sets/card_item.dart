import 'package:correctink/blocs/sets/popups_menu.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/data/models/schemas.dart';
import '../../app/data/repositories/realm_services.dart';
import '../../app/screens/edit/modify_card.dart';


class CardItem extends StatelessWidget{

  const CardItem(this.card, this.canEdit, {Key? key}) : super(key: key);
  final KeyValueCard card;
  final bool canEdit;


  @override
  Widget build(BuildContext context) {
    final realmServices = Provider.of<RealmServices>(context);
    Color progressColor = Colors.transparent;

    if (card.lastSeenDate != null) {
        switch(card.currentBox){
          case 1:
            progressColor = Colors.red;
            break;
          case 2:
            progressColor = const Color.fromARGB(255, 232, 138, 56);
            break;
          case 3:
            progressColor = const Color.fromARGB(255, 220, 197, 59);
            break;
          case 4:
            progressColor = const Color.fromARGB(255, 170, 206, 63);
            break;
          case 5:
            progressColor = const Color.fromARGB(255, 112, 192, 68);
            break;
          case 6:
            progressColor = const Color.fromARGB(255, 76, 175, 80);
            break;
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
                  child: Text(card.front, style: Theme.of(context).textTheme.bodyMedium)
              ),
              const SizedBox(height: 8.0),
              Align(
                  alignment: Alignment.centerLeft,
                  child: Text(card.back, style: Theme.of(context).textTheme.bodyMedium)
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