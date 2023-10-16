import 'package:correctink/blocs/sets/popups_menu.dart';
import 'package:correctink/utils/learn_utils.dart';
import 'package:correctink/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:localization/localization.dart';
import 'package:objectid/objectid.dart';
import 'package:provider/provider.dart';

import '../../app/data/models/schemas.dart';
import '../../app/data/repositories/realm_services.dart';
import '../../utils/router_helper.dart';

class CardItem extends StatefulWidget {

  const CardItem(
      {required this.card, required this.canEdit, required this.usingSpacedRepetition, required this.cardIndex, required this.setId, Key? key, required this.selectedChanged, required this.isSelected, required this.easySelect,})
      : super(key: key);
  final KeyValueCard card;
  final bool canEdit;
  final bool usingSpacedRepetition;
  final int cardIndex;
  final ObjectId setId;
  final bool easySelect;
  final bool isSelected;
  final Function(bool, KeyValueCard) selectedChanged;

  @override
  State<StatefulWidget> createState() => _CardItem();
}

class _CardItem extends State<CardItem> {
  late bool isSelected;

  @override
  void initState() {
    super.initState();
    isSelected = widget.isSelected;
  }

  void select() {
    setState(() {
      isSelected = !isSelected;
    });
    widget.selectedChanged(isSelected, widget.card);
  }

  @override
  Widget build(BuildContext context) {
    final realmServices = Provider.of<RealmServices>(context);
    Color progressColor = LearnUtils.getBoxColor(widget.card.lastSeenDate == null ? 0 : widget.card.currentBox);

    DateTime nextStudyDate = DateTime.now();
    bool nextStudyDatePassed = false;
    if(widget.card.lastKnowDate != null){
      nextStudyDate = widget.card.lastKnowDate!.add(Duration(days: LearnUtils.daysPerBox(widget.card.currentBox)));
      nextStudyDatePassed = nextStudyDate.isBeforeOrToday();
    }

    return Stack(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
          horizontalTitleGap: 6,
          onTap: widget.easySelect ? select : () {
            GoRouter.of(context).push(RouterHelper.buildLearnCarouselRoute(widget.setId.hexString, widget.cardIndex.toString()));
          },
          onLongPress: select,
          title: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Column(
              children: [
                  Align(
                      alignment: Alignment.centerLeft,
                      child: Text(widget.card.front, style: Theme.of(context).textTheme.bodyLarge)
                  ),
                  const SizedBox(height: 8.0),
                  Align(
                      alignment: Alignment.centerLeft,
                      child: Text(widget.card.back, style: Theme.of(context).textTheme.bodyLarge)
                  ),
                ],
            ),
          ),
          shape: RoundedRectangleBorder(
            side: widget.isSelected
                ? BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  )
                : BorderSide.none,
            borderRadius: BorderRadius.circular(6),

          ),
          textColor: Theme.of(context).colorScheme.onSecondaryContainer,
          tileColor: Theme.of(context).colorScheme.secondaryContainer,
          trailing: CardPopupOption(realmServices, widget.card, widget.canEdit),
      ),
        if(widget.canEdit && progressColor != Colors.transparent)
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
                      TextSpan(text: "\n${"Card next study date".i18n()} ${widget.card.lastKnowDate!.add(Duration(days: LearnUtils.daysPerBox(widget.card.currentBox))).format(formatting: "yyyy-MM-dd")}",
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