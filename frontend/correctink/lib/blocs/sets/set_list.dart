import 'dart:async';
import 'dart:math';

import 'package:correctink/blocs/sets/set_item.dart';
import 'package:correctink/blocs/sets/set_sorting.dart';
import 'package:correctink/widgets/animated_widgets.dart';
import 'package:correctink/widgets/snackbars_widgets.dart';
import 'package:flutter/material.dart';
import 'package:correctink/widgets/widgets.dart';
import 'package:localization/localization.dart';
import 'package:provider/provider.dart';
import 'package:realm/realm.dart';

import '../../app/data/models/schemas.dart';
import '../../app/data/repositories/realm_services.dart';
import '../../app/services/config.dart';
import '../../utils/utils.dart';

class SetList extends StatefulWidget{
  const SetList({super.key});

  @override
  State<StatefulWidget> createState() => _SetList();
}

class _SetList extends State<SetList>{
  static const int animationDuration = 250;
  late bool extendedSearchField = false;
  late bool showSearchIcon = true;
  String searchText = "";
  final scrollController = ScrollController();
  late TextEditingController searchController;
  late FocusNode searchFieldFocusNode;
  late RealmServices realmServices;
  late bool publicSets = false;
  late AppConfigHandler config;
  late String sortBy = '_id';
  late String sortDir = "ASC";

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    realmServices = Provider.of<RealmServices>(context);
    searchController = TextEditingController(text: searchText);
    searchFieldFocusNode = FocusNode();

    config = Provider.of<AppConfigHandler>(context);
    sortBy = config.getConfigValue(AppConfigHandler.setSortBy);
    sortDir = config.getConfigValue(AppConfigHandler.setSortDir);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            SizedBox(
              height: 80,
              child: styledHeaderFooterBox(
                context,
                isHeader: true,
                child: LayoutBuilder(
                  builder: (context, constraint) {
                    bool alwaysShowSearchField = constraint.maxWidth > 450;
                    if(alwaysShowSearchField){
                      showSearchIcon = false;
                    } else if(!extendedSearchField && !Utils.isOnPhone()){
                      showSearchIcon = true;
                    }

                    return Row(
                      children: [
                        Expanded(
                          child: Center(
                            child: TapRegion(
                              onTapOutside: (event){
                                if(extendedSearchField){
                                  setState(() {
                                    extendedSearchField = false;
                                  });
                                  if(!alwaysShowSearchField && Utils.isOnPhone()) {
                                    Timer(const Duration(milliseconds: animationDuration), (){
                                      setState(() {
                                        showSearchIcon = true;
                                      });
                                    }
                                    );
                                  }
                                  searchFieldFocusNode.unfocus();
                                }
                              },
                              child: Container(
                                width: double.infinity,
                                height: 44,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Theme.of(context).colorScheme.primary
                                  ),
                                  borderRadius: BorderRadius.circular(22)
                                ),
                                child: Stack(
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          extendedSearchField = true;
                                          showSearchIcon = false;
                                        });
                                        searchFieldFocusNode.requestFocus();
                                      },
                                      icon: Padding(
                                        padding: Utils.isOnPhone() ? const EdgeInsets.only(left: 2) : const EdgeInsets.only(left: 4.0),
                                        child: const Align(
                                          alignment: Alignment.centerLeft,
                                            child: Icon(Icons.search_rounded,)
                                        ),
                                      ),
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                    if(extendedSearchField)
                                      Padding(
                                          padding: const EdgeInsets.fromLTRB(40, 0, 40, 0),
                                          child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: TextField(
                                                controller: searchController,
                                                focusNode: searchFieldFocusNode,
                                                style: TextStyle(
                                                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                                                    fontWeight: FontWeight.w500
                                                ),
                                                decoration: null,
                                                onChanged: (value){
                                                  setState(() {
                                                    searchText = value;
                                                  });
                                                },
                                              )
                                          )
                                      ),
                                    if(searchText.isNotEmpty)
                                      Padding(
                                        padding: Utils.isOnPhone() ? const EdgeInsets.only(right: 0.0) : const EdgeInsets.only(right: 4.0),
                                        child: Align(
                                          alignment: Alignment.centerRight,
                                          child: IconButton(
                                            onPressed: (){
                                              setState(() {
                                                searchController.text = '';
                                                searchText = '';
                                              });
                                            },
                                            color: Theme.of(context).colorScheme.primary,
                                            icon: const Icon(Icons.clear, size: 22,),
                                            constraints: const BoxConstraints(maxHeight: 36, maxWidth: 36),
                                          ),
                                        ),
                                      ),
                                    if(!extendedSearchField || (extendedSearchField && searchText.isEmpty))
                                      IgnorePointer(
                                        ignoring: true,
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(41, 0, 40, 0),
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(searchText.isEmpty ? "Search".i18n() : searchText,
                                              style: TextStyle(
                                                  color: Theme.of(context).colorScheme.onPrimaryContainer.withAlpha(200),
                                                  fontWeight: FontWeight.w500
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                  ]
                                ),
                              ),
                            ),
                          ),
                        ),
                        ExpandedSection(
                          expand: showSearchIcon || alwaysShowSearchField,
                          duration: animationDuration,
                          axis: Axis.horizontal,
                          startValue: 2,
                          child: Center(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const SizedBox(width: 8,),
                                IconButton(
                                  onPressed: () {
                                    showDialog(context: context, builder: (context){
                                      return SortSet(
                                        onUpdate: (value) {
                                          setState(() {
                                            sortBy = value;
                                          });
                                          config.setConfigValue(AppConfigHandler.setSortBy, sortBy);
                                        },
                                        startingValue: sortBy,
                                        publicSets: publicSets,
                                      );
                                    });
                                  },
                                  icon: const Icon(Icons.sort_rounded),
                                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                                ),
                                SortDirectionButton(
                                    sortDir: sortDir == 'ASC',
                                    onChange: (dir) {
                                      setState(() {
                                        sortDir = dir ? 'ASC' : 'DESC';
                                      });
                                      config.setConfigValue(AppConfigHandler.setSortDir, sortDir);
                                    },
                                    initAngle: sortDir == 'ASC' ? 0 : pi,
                                ),
                              ],
                            ),
                          )
                        ),
                        const SizedBox(width: 8,),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Public".i18n(), textAlign: TextAlign.right, style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer),),
                            const SizedBox(width: 4,),
                            Switch(
                              value: publicSets,
                              inactiveThumbColor: Theme.of(context).colorScheme.onPrimaryContainer.withAlpha(200),
                              trackOutlineColor: MaterialStateProperty.resolveWith((state) {
                                  if(!state.contains(MaterialState.selected)){
                                    return Theme.of(context).colorScheme.onPrimaryContainer.withAlpha(200);
                                  }
                                  return null;
                                }
                              ),
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
                    );
                  }
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
                    return results.isNotEmpty ? Scrollbar(
                      controller: scrollController,
                      child: ListView.builder(
                        controller: scrollController,
                        shrinkWrap: true,
                        padding: Utils.isOnPhone() ? const EdgeInsets.fromLTRB(0, 0, 0, 18) : const EdgeInsets.fromLTRB(0, 0, 0, 60),
                        itemCount: results.realm.isClosed ? 0 : results.length,
                        itemBuilder: (context, index) => results[index].isValid
                            ? SetItem(results[index], border: index != results.length - 1, publicSets: publicSets,)
                            : null,
                      ),
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
      query += r"is_public = true && cards.@count > 0";
    }

    if(searchText.isNotEmpty){
      query += "AND name CONTAINS[c] \$$paramIndex";
      paramIndex++;
      params.add(searchText.trim());
    }

    if(publicSets) {
      // always sort public sets by ascending report count to have the potentially inappropriate set last
      query += " SORT(reportCount ASC, ";
    } else {
      query += " SORT(";
    }

    if(sortBy == SetSortingField.creationDate.name){
      query += "_id $sortDir)";
    } else if(sortBy == SetSortingField.setTitle.name){
      query += "name $sortDir)";
    } else if(sortBy == SetSortingField.studyDate.name){
      query += "lastStudyDate $sortDir)";
    } else if(sortBy == SetSortingField.setColor.name){
      query += "color $sortDir)";
    }

    return realm.query<CardSet>(query, params);
  }
}