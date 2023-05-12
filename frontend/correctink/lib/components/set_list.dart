import 'package:correctink/components/snackbars_widgets.dart';
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
  late RealmServices realmServices;
  bool hide = false;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();

    realmServices = Provider.of<RealmServices>(context);

    if(realmServices.currentSetSubscription == RealmServices.queryAllSets){

      hide = true; // avoid showing non public set even if just for half a seconds
      await realmServices.updateSetSubscriptions(realmServices.showAllPublicSets ? RealmServices.queryAllPublicSets : RealmServices.queryMySets);

      setState(() {
        hide = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return hide
      ? Container()
      : Stack(
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
                          value: realmServices.showAllPublicSets,
                          onChanged: (value) async {
                            if (realmServices.offlineModeOn && value) {
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
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                child: StreamBuilder<RealmResultsChanges<CardSet>>(
                  stream: buildQuery(realmServices.realm).changes,
                  builder: (context, snapshot) {
                    final data = snapshot.data;

                    if (data == null) return waitingIndicator();

                    final results = data.results;
                    return ListView.builder(
                      shrinkWrap: true,
                      padding: Utils.isOnPhone() ? const EdgeInsets.fromLTRB(0, 0, 0, 18) : const EdgeInsets.fromLTRB(0, 0, 0, 60),
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