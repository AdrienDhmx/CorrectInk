import 'package:flutter/material.dart';
import 'package:correctink/components/set_item.dart';
import 'package:correctink/components/widgets.dart';
import 'package:provider/provider.dart';
import 'package:realm/realm.dart';

import '../realm/realm_services.dart';
import '../realm/schemas.dart';
import '../utils.dart';

class SetList extends StatefulWidget{
  const SetList({super.key});

  @override
  State<StatefulWidget> createState() => _SetList();
}

class _SetList extends State<SetList>{
  String searchText = "";

  @override
  Widget build(BuildContext context) {
    final realmServices = Provider.of<RealmServices>(context);

    return Stack(
      children: [
        Column(
          children: [
            SizedBox(
              height: 80,
              child: styledBox(
                context,
                isHeader: true,
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: TextField(
                          textAlignVertical: TextAlignVertical.center,
                          decoration: const InputDecoration(
                            filled: true,
                            hintText: 'Search',
                          ),
                          onChanged: (value){
                            setState(() {
                              searchText = value;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 14,),
                    Column(
                      children: [
                        const Text("Public", textAlign: TextAlign.right),
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
                    )
                  ],
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: StreamBuilder<RealmResultsChanges<CardSet>>(
                  stream: buildQuery(realmServices.realm).changes,
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

  RealmResults<CardSet> buildQuery(Realm realm){
    if(searchText.isEmpty){
      return realm.query<CardSet>(r"TRUEPREDICATE SORT(_id ASC)");
    } else{
      return realm.query<CardSet>(r'name CONTAINS[c] $0', [searchText]);
    }
  }
}