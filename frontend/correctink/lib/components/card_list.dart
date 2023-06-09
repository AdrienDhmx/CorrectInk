import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:correctink/components/widgets.dart';
import 'package:provider/provider.dart';
import 'package:realm/realm.dart';

import '../realm/realm_services.dart';
import '../realm/schemas.dart';
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
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
          child: StreamBuilder<RealmListChanges<KeyValueCard>>(
            stream: set!.cards.changes,
            builder: (context, snapshot) {
              final data = snapshot.data;
              if (data == null) return waitingIndicator();
              final results = data.list;

              return ListView.builder(
                shrinkWrap: true,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(0, 8, 0, 18),
                semanticChildCount: results.realm.isClosed ? 0 : results.length,
                controller: controller,
                scrollDirection: Axis.vertical,
                itemCount: results.realm.isClosed ? 0 : results.length,
                itemBuilder: (context, index) => results[index].isValid
                    ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: CardItem(results[index], widget.isMine),
                    )
                    : Container(),
              );
            },
          ),
        ),
        realmServices.isWaiting ? waitingIndicator() : Container(),
      ],
    );
  }

}