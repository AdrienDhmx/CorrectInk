import 'package:correctink/blocs/sets/card_sorting.dart';
import 'package:correctink/utils/card_helper.dart';
import 'package:flutter/material.dart';
import 'package:correctink/widgets/widgets.dart';
import 'package:localization/localization.dart';
import 'package:provider/provider.dart';

import '../../app/data/models/schemas.dart';
import '../../app/data/repositories/realm_services.dart';
import '../../widgets/buttons.dart';
import 'card_item.dart';

class CardList extends StatelessWidget{

  const CardList(this.cards, this.isMine, {super.key, required this.selectedCards, required this.onSelectedCardsChanged, required this.easySelect, required this.searchText, required this.sortDir, required this.sortBy, required this.set});

  final FlashcardSet set;
  final List<Flashcard> cards;
  final bool isMine;
  final List<Flashcard> selectedCards;
  final bool easySelect;
  final String searchText;
  final bool sortDir;
  final CardSortingField sortBy;
  final Function(bool, Flashcard) onSelectedCardsChanged;
  
  @override
  Widget build(BuildContext context) {
    final realmServices = Provider.of<RealmServices>(context);
    return placeHolder(condition: cards.isNotEmpty,
        placeholder: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24,),
            if(searchText.isEmpty) ...[
              Text("Set empty".i18n(), style: Theme.of(context).textTheme.titleLarge,),
              const SizedBox(height: 6,),
              Text("Set empty description".i18n()),
              const SizedBox(height: 12,),
              labeledAction(context: context,
                  child: Icon(Icons.download_rounded, color: Theme.of(context).colorScheme.primary,),
                  label: "Import cards".i18n(),
                  labelFirst: false,
                  infiniteWidth: false,
                  center: true,
                  height: 40,
                  fontSize: 16,
                  fontWeigh: FontWeight.w500,
                  color: Theme.of(context).colorScheme.primary,
                  onTapAction: () {
                    CardHelper.importCards(context: context, realmServices: realmServices, set: set);
                  }
              ),
            ] else ...[
              Text("Set empty filter".i18n(), style: Theme.of(context).textTheme.titleMedium,),
            ]
          ],
        ),
        child: Stack(
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 22),
              semanticChildCount: cards.length,
              scrollDirection: Axis.vertical,
              addAutomaticKeepAlives: false,
              addSemanticIndexes: false,
              itemCount: cards.length,
              itemBuilder: (context, index) {
                bool selected = easySelect ? selectedCards.any((card) => card.id == cards[index].id) : false;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: CardItem(
                    card: cards[index],
                    canEdit: isMine,
                    usingSpacedRepetition: set.studyMethod == 1,
                    cardIndex: index,
                    set: set,
                    easySelect: easySelect,
                    isSelected: selected,
                    selectedChanged: onSelectedCardsChanged,
                  ),
                );
              }
            ),
            realmServices.isWaiting ? waitingIndicator() : Container(),
          ],
        ),
    );
  }
}