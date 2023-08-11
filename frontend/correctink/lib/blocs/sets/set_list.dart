import 'package:correctink/blocs/sets/set_item.dart';
import 'package:correctink/widgets/snackbars_widgets.dart';
import 'package:flutter/material.dart';
import 'package:correctink/widgets/widgets.dart';
import 'package:localization/localization.dart';
import 'package:provider/provider.dart';
import 'package:realm/realm.dart';

import '../../app/data/models/schemas.dart';
import '../../app/data/repositories/realm_services.dart';
import '../../utils/utils.dart';

class SetList extends StatefulWidget{
  const SetList({super.key});

  @override
  State<StatefulWidget> createState() => _SetList();
}

class _SetList extends State<SetList>{
  String searchText = "";
  late RealmServices realmServices;
  bool hide = false;
  late TextEditingController searchController;
  late bool publicSets = false;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    realmServices = Provider.of<RealmServices>(context);

    searchController = TextEditingController(text: searchText);
  }

  @override
  Widget build(BuildContext context) {
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
                          controller: searchController,
                          textAlignVertical: TextAlignVertical.center,
                          decoration: InputDecoration(
                            suffixIcon: searchText.isNotEmpty
                                ? IconButton(
                                  onPressed: (){
                                    setState(() {
                                      searchController.text = '';
                                      searchText = '';
                                    });
                                  },
                              color: Theme.of(context).colorScheme.onTertiaryContainer,
                                  icon: const Icon(Icons.clear),
                                )
                                : const SizedBox(),
                            hintText: 'Search'.i18n(),
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
                        Text("Public".i18n(), textAlign: TextAlign.right),
                        const SizedBox(width: 4,),
                        Switch(
                          value: publicSets,
                          onChanged: (value) async {
                            if (realmServices.offlineModeOn && value) {
                              infoMessageSnackBar(context,
                                  "Error offline sets".i18n())
                                  .show(context);
                            } else {
                               setState(() {
                                 publicSets = !publicSets;
                               });
                            }
                          },
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
            hide
            ? Container()
            : Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                child: StreamBuilder<RealmResultsChanges<CardSet>>(
                  stream: buildQuery(realmServices.realm).changes,
                  builder: (context, snapshot) {
                    final data = snapshot.data;

                    if (data == null) return waitingIndicator();

                    final results = data.results;
                    return results.isNotEmpty ? ListView.builder(
                      shrinkWrap: true,
                      padding: Utils.isOnPhone() ? const EdgeInsets.fromLTRB(0, 0, 0, 18) : const EdgeInsets.fromLTRB(0, 0, 0, 60),
                      itemCount: results.realm.isClosed ? 0 : results.length,
                      itemBuilder: (context, index) => results[index].isValid
                          ? SetItem(results[index], border: index != results.length - 1, publicSets: publicSets,)
                          : null,
                    ): Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8),
                      child: Text("No sets found".i18n(), textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 18)),
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
    String query = "";
    int paramIndex = 0;
    List<String> params = <String>[];

    if(!publicSets){
      query += "owner_id = \$$paramIndex ";
      paramIndex++;
      params.add(realmServices.currentUser!.id);
    } else {
      query += r"is_public = true ";
    }

    if(searchText.isNotEmpty){
      query += "AND name CONTAINS[c] \$$paramIndex";
      params.add(searchText.trim());
    }

    return realm.query<CardSet>(query, params);
  }
}