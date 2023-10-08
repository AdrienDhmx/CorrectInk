import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:correctink/widgets/widgets.dart';
import 'package:provider/provider.dart';
import 'package:realm/realm.dart';

import '../../app/data/models/schemas.dart';
import '../../app/data/repositories/realm_services.dart';
import 'card_item.dart';

class CardList extends StatefulWidget{
  const CardList(this.setId, this.isMine, {super.key});

  final ObjectId setId;
  final bool isMine;

  @override
  State<StatefulWidget> createState() => _CardList();
}

class _CardList extends State<CardList>{
  late CardSet? set;

  @override
  void didChangeDependencies(){
    super.didChangeDependencies();
    final realmServices = Provider.of<RealmServices>(context);

    set = realmServices.setCollection.get(widget.setId.hexString);
  }

  @override
  Widget build(BuildContext context) {
    final realmServices = Provider.of<RealmServices>(context);
    ScrollController controller = ScrollController();
    return Stack(
      children: [
        StreamBuilder<RealmListChanges<KeyValueCard>>(
          stream: set!.cards.changes,
          builder: (context, snapshot) {
            final data = snapshot.data;
            if (data == null) return waitingIndicator();
            final results = data.list;

            final cards = results.toList();
            cards.sort((c1, c2) {
              return c1.currentBox.compareTo(c2.currentBox);
            });

            return ListView.builder(
              shrinkWrap: true,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 22),
              semanticChildCount: results.realm.isClosed ? 0 : results.length,
              controller: controller,
              scrollDirection: Axis.vertical,
              itemCount: results.realm.isClosed ? 0 : results.length,
              itemBuilder: (context, index) =>  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: CardItem(cards[index], widget.isMine, usingSpacedRepetition: set!.studyMethod == 0,),
                  ),
            );
          },
        ),
        realmServices.isWaiting ? waitingIndicator() : Container(),
      ],
    );
  }

}