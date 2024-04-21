import 'package:correctink/blocs/sets/popups_menu.dart';
import 'package:correctink/utils/learn_utils.dart';
import 'package:correctink/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:localization/localization.dart';
import 'package:provider/provider.dart';

import '../../app/data/models/schemas.dart';
import '../../app/data/repositories/realm_services.dart';
import '../../utils/router_helper.dart';

class CardItem extends StatefulWidget {

  const CardItem(
      {required this.card, required this.canEdit, required this.usingSpacedRepetition, required this.cardIndex, required this.set, Key? key, required this.selectedChanged, required this.easySelect, required this.selectAll})
      : super(key: key);
  final Flashcard card;
  final bool canEdit;
  final int cardIndex;
  final bool usingSpacedRepetition;
  final FlashcardSet set;
  final bool selectAll;
  final bool easySelect;
  final Function(Flashcard) selectedChanged;

  @override
  State<StatefulWidget> createState() => _CardItem();
}

class _CardItem extends State<CardItem> {
  late bool isSelected = false;

  void select() {
    widget.selectedChanged(widget.card);
    setState(() {
      isSelected = !isSelected;
    });
  }

  @override
  Widget build(BuildContext context) {
    if(widget.selectAll || !widget.easySelect) {
      isSelected = false;
    }
    final realmServices = Provider.of<RealmServices>(context);

    Color progressColor = widget.card.currentBoxColor(context);

    int daysBeforeNextReview = 0;
    bool nextStudyDatePassed = false;
    if(widget.card.lastKnowDate != null){
      DateTime nextStudyDate = widget.card.getNextStudyDate();
      daysBeforeNextReview = nextStudyDate.difference(DateTime.now().toDateOnly()).inDays;
      nextStudyDatePassed = daysBeforeNextReview <= 0;
    }

    return Stack(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 14.0),
          horizontalTitleGap: 6,
          onTap: widget.easySelect ? select : () {
            GoRouter.of(context).push(RouterHelper.buildLearnCarouselRoute(widget.set.id.hexString, widget.cardIndex.toString()));
          },
          onLongPress: select,
          title: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Column(
              children: [
                  Align(
                      alignment: Alignment.centerLeft,
                      child: Text(widget.card.frontValue, style: Theme.of(context).textTheme.bodyLarge)
                  ),
                  const SizedBox(height: 8.0),
                  Align(
                      alignment: Alignment.centerLeft,
                      child: Text(widget.card.backValue, style: Theme.of(context).textTheme.bodyLarge)
                  ),
                ],
            ),
          ),
          shape: RoundedRectangleBorder(
            side: BorderSide(
                    color: isSelected || widget.selectAll ? Theme.of(context).colorScheme.primary : Colors.transparent,
                    width: 2,
                  ),
            borderRadius: BorderRadius.circular(6),

          ),
          textColor: Theme.of(context).colorScheme.onSecondaryContainer,
          tileColor: Theme.of(context).colorScheme.secondaryContainer,
          trailing: CardPopupOption(realmServices, widget.card, widget.canEdit, set: widget.set),
      ),
        if(widget.canEdit && progressColor != Colors.transparent && widget.card.seenCount > 0)
          Tooltip(
            waitDuration: Duration.zero,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onBackground.withAlpha(240),
              borderRadius: const BorderRadius.all(Radius.circular(6)),
            ),
            showDuration: Utils.isOnPhone() ? const Duration(seconds: 5) : null,
            triggerMode: Utils.isOnPhone() ? TooltipTriggerMode.tap : null,
            richMessage: TextSpan(
              style: TextStyle(
                color: Theme.of(context).colorScheme.background
              ),
                children: [
                  TextSpan(text: widget.card.knowCount.toString(), style: const TextStyle(color: Colors.green)),
                  const TextSpan(text: ' / '),
                  TextSpan(text: widget.card.dontKnowCount.toString(), style: const TextStyle(color: Colors.red)),

                  TextSpan(text: "  -  ${"Card know ratio".i18n(["${(widget.card.knowCount * 100 / widget.card.seenCount).round()}"])}"),
                  if(widget.card.lastKnowDate != null && widget.usingSpacedRepetition)
                    if(nextStudyDatePassed)
                      TextSpan(text: "\n${"Card ready to be studied".i18n()}", style: const TextStyle(fontWeight: FontWeight.w500, height: 2))
                    else
                      TextSpan(text: "\n${"Card next study date".i18n([daysBeforeNextReview.toString()])}",
                          style: const TextStyle(fontWeight: FontWeight.w500, height: 2)
                      ),
                  if(widget.card.lastSeenDate != null)
                      TextSpan(text: "\n${"Card last seen".i18n()} ${widget.card.lastSeenDate!.format()}"),
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