import 'package:correctink/blocs/sets/card_sorting.dart';
import 'package:correctink/utils/card_helper.dart';
import 'package:flutter/material.dart';
import 'package:correctink/widgets/widgets.dart';
import 'package:localization/localization.dart';
import 'package:provider/provider.dart';
import 'package:realm/realm.dart';

import '../../app/data/models/schemas.dart';
import '../../app/data/repositories/realm_services.dart';
import '../../widgets/buttons.dart';
import 'card_item.dart';

class CardList extends StatelessWidget{

  const CardList(this.set, this.isMine, {super.key, required this.selectedCards, required this.onSelectedCardsChanged, required this.easySelect, required this.searchText, required this.sortDir, required this.sortBy});

  final FlashcardSet set;
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
    return placeHolder(condition: set.cards.isNotEmpty,
        placeholder: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 12,),
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
          ],
        ),
        child: Stack(
          children: [
            StreamBuilder<RealmResultsChanges<Flashcard>>(
              stream: buildQuery(realmServices.realm),
              builder: (context, snapshot) {
                final data = snapshot.data;
                if (data == null) return waitingIndicator();
                final cards = data.results.toList();

                if(sortBy == CardSortingField.currentBox) {
                  cards.sort((c1, c2) => sortDir ? c1.currentBox.compareTo(c2.currentBox) : c2.currentBox.compareTo(c1.currentBox));
                } else if(sortBy == CardSortingField.seenCount) {
                  cards.sort((c1, c2) => sortDir ? c1.seenCount.compareTo(c2.seenCount) : c2.seenCount.compareTo(c1.seenCount));
                } else if(sortBy == CardSortingField.lastSeen) {
                  cards.sort((c1, c2) {
                    if(c1.lastSeenDate == null) {
                      return 1;
                    } else if(c2.lastSeenDate == null) {
                      return -1;
                    }
                    if(sortDir) {
                      return c1.lastSeenDate!.millisecondsSinceEpoch.compareTo(c2.lastSeenDate!.millisecondsSinceEpoch);
                    } else {
                      return c2.lastSeenDate!.millisecondsSinceEpoch.compareTo(c1.lastSeenDate!.millisecondsSinceEpoch);
                    }
                  });
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 22),
                  semanticChildCount: cards.length,
                  scrollDirection: Axis.vertical,
                  addAutomaticKeepAlives: false,
                  addSemanticIndexes: false,
                  itemCount: cards.length,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: CardItem(
                      card: cards[index],
                      canEdit: isMine,
                      usingSpacedRepetition: set.studyMethod == 1,
                      cardIndex: index,
                      set: set,
                      easySelect: easySelect,
                      isSelected: easySelect ? selectedCards.any((card) => card.id == cards[index].id) : false,
                      selectedChanged: onSelectedCardsChanged,
                    ),
                  ),
                );
              },
            ),
            realmServices.isWaiting ? waitingIndicator() : Container(),
          ],
        ),
    );
  }

  Stream<RealmResultsChanges<Flashcard>> buildQuery(Realm realm){
    String query = "";
    String sortDirString = sortDir ? "ASC" : "DESC";
    int paramIndex = 0;
    List<String> params = <String>[];

    if(searchText.isNotEmpty) {
      query += "front.value CONTAINS[c] \$$paramIndex OR back.value CONTAINS[c] \$$paramIndex";
      paramIndex++;
      params.add(searchText.trim());
    } else {
      query = "TRUEPREDICATE";
    }

    if(sortBy == CardSortingField.creationDate || sortBy == CardSortingField.front || sortBy == CardSortingField.back) {
      query += " SORT(";

      if(sortBy == CardSortingField.creationDate) {
        query += "_id";
      } else if(sortBy == CardSortingField.front) {
        query += "front.value";
      } else if(sortBy == CardSortingField.back) {
        query += "back.value";
      }

      query += " $sortDirString)";
    }

    return set.cards.query(query, params).changes;
  }
}