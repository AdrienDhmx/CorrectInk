import 'package:correctink/utils/card_helper.dart';
import 'package:flutter/material.dart';
import 'package:correctink/widgets/widgets.dart';
import 'package:localization/localization.dart';
import 'package:provider/provider.dart';
import 'package:realm/realm.dart';

import '../../app/data/models/schemas.dart';
import '../../app/data/repositories/realm_services.dart';
import '../../utils/sorting_helper.dart';
import '../../widgets/buttons.dart';
import 'card_item.dart';

class CardList extends StatelessWidget{

  const CardList(this.set, this.isMine, {super.key, required this.selectedCards, required this.onSelectedCardsChanged, required this.easySelect});

  final CardSet set;
  final bool isMine;
  final List<KeyValueCard> selectedCards;
  final bool easySelect;
  final Function(bool, KeyValueCard) onSelectedCardsChanged;
  
  @override
  Widget build(BuildContext context) {
    final realmServices = Provider.of<RealmServices>(context);
    ScrollController controller = ScrollController();
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
            StreamBuilder<RealmListChanges<KeyValueCard>>(
              stream: set.cards.changes,
              builder: (context, snapshot) {
                final data = snapshot.data;
                if (data == null) return waitingIndicator();
                final results = data.list;

                final cards = results.toList();
                cards.sort((c1, c2) => SortingHelper.compareCards(c1, c2));

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 22),
                  semanticChildCount: results.realm.isClosed ? 0 : results.length,
                  controller: controller,
                  scrollDirection: Axis.vertical,
                  addAutomaticKeepAlives: false,
                  addSemanticIndexes: false,
                  itemCount: results.realm.isClosed ? 0 : results.length,
                  itemBuilder: (context, index) =>  Padding(
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
}