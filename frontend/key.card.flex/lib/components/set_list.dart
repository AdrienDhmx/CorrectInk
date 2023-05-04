import 'package:flutter/material.dart';
import 'package:key_card/components/set_item.dart';
import 'package:key_card/components/widgets.dart';
import 'package:provider/provider.dart';
import 'package:realm/realm.dart';

import '../realm/realm_services.dart';
import '../realm/schemas.dart';

class SetList extends StatefulWidget{
  const SetList({super.key});

  @override
  State<StatefulWidget> createState() => _SetList();
}

class _SetList extends State<SetList>{
  @override
  Widget build(BuildContext context) {
    final realmServices = Provider.of<RealmServices>(context);

    return Stack(
      children: [
        Column(
          children: [
            styledBox(
              context,
              isHeader: true,
              child: Row(
                children: [
                  const Expanded(
                    child: Text("Show public sets", textAlign: TextAlign.right),
                  ),
                  const SizedBox(width: 4,),
                  Switch(
                    value: realmServices.showAllSets,
                    onChanged: (value) async {
                      if (realmServices.offlineModeOn) {
                        infoMessageSnackBar(context,
                            "You need to be online to see public sets")
                            .show(context);
                      }
                      await realmServices.switchSetSubscription(value);
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: StreamBuilder<RealmResultsChanges<CardSet>>(
                  stream: realmServices.realm
                      .query<CardSet>("TRUEPREDICATE SORT(_id ASC)")
                      .changes,
                  builder: (context, snapshot) {
                    final data = snapshot.data;

                    if (data == null) return waitingIndicator();

                    final results = data.results;
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: results.realm.isClosed ? 0 : results.length,
                      itemBuilder: (context, index) => results[index].isValid
                          ? SetItem(results[index])
                          : null,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
        realmServices.isWaiting ? waitingIndicator() : Container(),
      ],
    );
  }

}