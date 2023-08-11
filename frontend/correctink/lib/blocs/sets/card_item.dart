import 'package:correctink/blocs/sets/popups_menu.dart';
import 'package:correctink/utils/learn_utils.dart';
import 'package:correctink/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:localization/localization.dart';
import 'package:provider/provider.dart';

import '../../app/data/models/schemas.dart';
import '../../app/data/repositories/realm_services.dart';
import '../../app/screens/edit/modify_card.dart';


class CardItem extends StatelessWidget{

  const CardItem(this.card, this.canEdit, {Key? key, required this.usingSpacedRepetition}) : super(key: key);
  final KeyValueCard card;
  final bool canEdit;
  final bool usingSpacedRepetition;

  @override
  Widget build(BuildContext context) {
    final realmServices = Provider.of<RealmServices>(context);
    Color progressColor = LearnUtils.getBoxColor(card.lastSeenDate == null ? 0 : card.currentBox);

    DateTime nextStudyDate = DateTime.now();
    bool nextStudyDatePassed = false;
    if(card.lastKnowDate != null){
      nextStudyDate = card.lastKnowDate!.add(Duration(days: LearnUtils.daysPerBox(card.currentBox)));

      nextStudyDatePassed = nextStudyDate.isBeforeOrToday();
    }

    return Stack(
      children: [
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
                      child: Text(card.front, style: Theme.of(context).textTheme.bodyLarge)
                  ),
                  const SizedBox(height: 8.0),
                  Align(
                      alignment: Alignment.centerLeft,
                      child: Text(card.back, style: Theme.of(context).textTheme.bodyLarge)
                  ),
                ],
            ),
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          textColor: Theme.of(context).colorScheme.onSecondaryContainer,
          tileColor: Theme.of(context).colorScheme.secondaryContainer,
          trailing: CardPopupOption(realmServices, card, canEdit),
      ),
        if(canEdit && progressColor != Colors.transparent)
          Tooltip(
            waitDuration: Duration.zero,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onBackground.withAlpha(225),
              borderRadius: const BorderRadius.all(Radius.circular(6)),
            ),
            showDuration: Utils.isOnPhone() ? const Duration(seconds: 5) : null,
            triggerMode: Utils.isOnPhone() ? TooltipTriggerMode.tap : null,
            richMessage: TextSpan(
              style: TextStyle(
                color: Theme.of(context).colorScheme.background
              ),
                children: [
                  TextSpan(text: card.knowCount.toString(), style: const TextStyle(color: Colors.green)),
                  const TextSpan(text: ' / '),
                  TextSpan(text: card.dontKnowCount.toString(), style: const TextStyle(color: Colors.red)),

                  TextSpan(text: "  -  ${"Card know ratio".i18n(["${(card.knowCount * 100 / card.seenCount).round()}"])}"),
                  if(card.lastKnowDate != null && usingSpacedRepetition)
                    if(nextStudyDatePassed)
                      TextSpan(text: "\n${"Card ready to be studied".i18n()}", style: const TextStyle(fontWeight: FontWeight.w500, height: 2))
                    else
                      TextSpan(text: "\n${"Card next study date".i18n()} ${card.lastKnowDate!.add(Duration(days: LearnUtils.daysPerBox(card.currentBox))).format(formatting: "yyyy-MM-dd")}",
                          style: const TextStyle(fontWeight: FontWeight.w500, height: 2)
                      ),
                  if(card.lastSeenDate != null)
                      TextSpan(text: "\n${"Card last seen".i18n()} ${card.lastSeenDate!.format()}"),
                ]
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
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
              ),
            ),
        ),
      ],
    );
  }

}