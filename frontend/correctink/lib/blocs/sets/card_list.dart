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

  final CardSet set;
  final bool isMine;
  final List<KeyValueCard> selectedCards;
  final bool easySelect;
  final String searchText;
  final bool sortDir;
  final CardSortingField sortBy;
  final Function(bool, KeyValueCard) onSelectedCardsChanged;
  
  @override
  Widget build(BuildContext context) {
    final realmServices = Provider.of<RealmServices>(context);
    return set.cards.isEmpty
        ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
        )
        : Stack(
          children: [
            StreamBuilder<RealmResultsChanges<KeyValueCard>>(
              stream: buildQuery(realmServices.realm),
              builder: (context, snapshot) {
                final data = snapshot.data;
                if (data == null) return waitingIndicator();
                final cards = data.results.toList();

                if(sortBy == CardSortingField.seenCount) {
                  cards.sort((c1, c2) => sortDir ? c1.seenCount.compareTo(c2.seenCount) : c2.seenCount.compareTo(c1.seenCount));
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
                            usingSpacedRepetition: set.studyMethod == 0,
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
        );
  }

  Stream<RealmResultsChanges<KeyValueCard>> buildQuery(Realm realm){
    String query = "";
    String sortDirString = sortDir ? "ASC" : "DESC";
    int paramIndex = 0;
    List<String> params = <String>[];

    if(searchText.isNotEmpty) {
      query += "front CONTAINS[c] \$$paramIndex OR back CONTAINS[c] \$$paramIndex";
      paramIndex++;
      params.add(searchText.trim());
    } else {
      query = "TRUEPREDICATE";
    }

    if(sortBy != CardSortingField.seenCount) {
      query += " SORT(";

      if(sortBy == CardSortingField.currentBox) {
        query += "currentBox";
      } else if(sortBy == CardSortingField.creationDate) {
        query += "_id";
      } else if(sortBy == CardSortingField.front) {
        query += "front";
      } else if(sortBy == CardSortingField.back) {
        query += "back";
      } else if(sortBy == CardSortingField.lastSeen) {
        query += "lastSeenDate";
      }

      query += " $sortDirString)";
    }

    return set.cards.query(query, params).changes;
  }
}