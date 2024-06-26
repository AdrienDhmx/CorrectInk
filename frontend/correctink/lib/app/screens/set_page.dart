import 'dart:async';
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:correctink/app/screens/edit/modify_multiple_cards.dart';
import 'package:correctink/app/screens/error_page.dart';
import 'package:correctink/utils/card_helper.dart';
import 'package:correctink/utils/delete_helper.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:localization/localization.dart';
import 'package:provider/provider.dart';
import 'package:realm/realm.dart';

import '../../blocs/search_field.dart';
import '../../blocs/sets/card_list.dart';
import '../../blocs/sets/card_sorting.dart';
import '../../blocs/sets/popups_menu.dart';
import '../../utils/learn_utils.dart';
import '../../utils/ordered_flashcards.dart';
import '../../utils/router_helper.dart';
import '../../utils/utils.dart';
import '../../widgets/animated_widgets.dart';
import '../../widgets/buttons.dart';
import '../../widgets/snackbars_widgets.dart';
import '../../widgets/widgets.dart';
import '../data/models/schemas.dart';
import '../data/repositories/realm_services.dart';
import '../services/theme.dart';
import 'create/create_card.dart';
import 'edit/modify_set.dart';

class SetPage extends StatefulWidget{
  final String id;

  const SetPage(this.id, {super.key});

  @override
  State<StatefulWidget> createState() => _SetPage();
}

class _SetPage extends State<SetPage> {
  final _animationController = ScrollController();
  double get learningButtonWidth => Utils.isOnPhone() ? 350 : 500;
  static const double learningButtonHeight = 41;
  late RealmServices realmServices;
  late FlashcardSet? set;
  late bool isOwner = false;
  late String ownerText = "";
  late int? descriptionMaxLine = 4;
  late bool extendLearningMenu = false;
  late StreamSubscription stream;
  late double arrowAngle = 0;
  bool streamInit = false;
  TapGestureRecognizer? originalOwnerTapRecognizer;
  TapGestureRecognizer? originalSetTapRecognizer;
  final OrderedFlashcards selectedFlashcards = OrderedFlashcards();
  late bool easySelect = false;
  late String searchText = "";
  late CardSortingField sortBy = CardSortingField.currentBox;
  late bool sortDir = true;
  late bool selectAll = false;

  void updateDescriptionMaxLine(){
    setState(() {
      descriptionMaxLine == 4 ? descriptionMaxLine = null : descriptionMaxLine = 4;
    });
  }

  void resetSelectedCard() {
    setState(() {
      easySelect = false;
      selectedFlashcards.clear();
    });
  }

  void onSearchChange(String search) {
    setState(() {
      searchText = search;
    });
  }

  void onSortByChange(CardSortingField sortByField) {
    setState(() {
      sortBy = sortByField;
    });
  }

  void onSortDirChange(bool value) {
    setState(() {
      sortDir = value;
    });
  }

  void onToggleSelectAll(List<Flashcard> cards) {
    setState(() {
      selectAll = !selectAll;
      easySelect = selectAll;
      if(selectAll) {
        for (Flashcard card in cards) {
          selectedFlashcards.add(card);
        }
      } else {
        selectedFlashcards.clear();
      }
    });
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();

    realmServices = Provider.of<RealmServices>(context);
    set = realmServices.setCollection.get(widget.id);

    if(set == null || !set!.isValid){
      set = realmServices.setCollection.get(widget.id);

      if(set == null || !set!.isValid) {
        return;
      }
    }

    sortBy = isOwner ? CardSortingField.currentBox : CardSortingField.creationDate;
    if(!streamInit){
      stream = set!.changes.listen((event) {
        setState(() {
          set = event.object;
        });
      });
    }

    isOwner = set!.owner!.userId.hexString == realmServices.currentUser!.id;
    if(!isOwner || set!.originalOwner != null){
      originalOwnerTapRecognizer = TapGestureRecognizer()..onTap = goToUserProfile;
      originalSetTapRecognizer = TapGestureRecognizer()..onTap = goToOriginalSet;
      if(set!.originalOwner == null){ // visiting public set
        setState(() {
          ownerText = set!.owner!.name;
        });
      } else { // saved set
        setState(() {
          ownerText = set!.originalOwner!.name;
        });
      }
    }
  }

  @override
  void dispose(){
    super.dispose();
    if(set != null && set!.isValid) {
      stream.cancel();
    }
    originalOwnerTapRecognizer?.dispose();
    originalSetTapRecognizer?.dispose();
  }

  void onSelectedCardsChanged(Flashcard card) {
    setState(() {
      selectedFlashcards.toggle(card);
      easySelect = selectedFlashcards.isNotEmpty;
    });
  }

  void goToUserProfile() {
    String id = set!.originalOwner == null ? set!.owner!.userId.hexString : set!.originalOwner!.userId.hexString;
    GoRouter.of(context).push(RouterHelper.buildProfileRoute(id));
  }

  void goToOriginalSet() async{
      String error = "Error offline sets".i18n();
      if(realmServices.offlineModeOn){
        errorMessageSnackBar(context, 'Error'.i18n(), error).show(context);
        return;
      }

      if(set!.originalSet != null && set!.originalSet!.isPublic){
          if(context.mounted) GoRouter.of(context).push(RouterHelper.buildSetRoute(set!.originalSet!.id.hexString));
          return;
      } else {
        error = 'Error navigate set'.i18n();
      }

      if(context.mounted) errorMessageSnackBar(context, 'Error'.i18n(), error).show(context);
  }

  @override
  Widget build(BuildContext context) {
    if(set == null || !set!.isValid || set!.owner == null){
        return ErrorPage(errorDescription: "Error set null".i18n(),
            tips: [
              "Error set null tip".i18n(),
              "Error set null tip 2".i18n(),
            ]
        );
    }

    int totalKnowCount = 0;
    int totalDontKnowCount = 0;
    (totalKnowCount, totalDontKnowCount) = LearnUtils.getRatio(set!.cards);

    Color progressColor = LearnUtils.getBoxColor(LearnUtils.getMeanBox(set!.cards), Theme.of(context).brightness == Brightness.dark);
    Color setColor = set!.color != null ? HexColor.fromHex(set!.color!) : Theme.of(context).colorScheme.surface;

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: !isOwner
         ? styledFloatingButton(context,
              onPressed: () async {
                // GoRouter.of(context).pop();
                final newSetId = await realmServices.setCollection.copyToCurrentUser(set!);
                if(context.mounted){
                  infoMessageSnackBar(context, "Set saved message".i18n()).show(context);
                  GoRouter.of(context).push(RouterHelper.buildSetRoute(newSetId.hexString));
                }
              },
              icon: Icons.save_rounded,
              tooltip: 'Save set'.i18n(),
          )
         : styledFloatingButton(context,
            onPressed: () => {
                if(isOwner) {
                  showBottomSheetModal(context, CreateCardForm(set!.id)),
                } else {
                  errorMessageSnackBar(context, "Error action not allowed".i18n(), "Error add cards".i18n()).show(context)
                }
            },
            tooltip: 'Add card'.i18n()
          ),
      bottomNavigationBar: LayoutBuilder(
        builder: (context, constraint) {
          return BottomAppBar(
            height: 45,
            child: Align(
              alignment: constraint.maxWidth < 500 ? Alignment.centerLeft : Alignment.center,
              child: Text('Created on'.i18n() + set!.id.timestamp.getFullWrittenDate(),
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500
                ),
              ),
            ),
          );
        }
      ),
      body: StreamBuilder<RealmResultsChanges<Flashcard>>(
        stream: buildQuery(realmServices.realm),
        builder: (context, snapshot) {
          final data = snapshot.data;
          if (data == null) return waitingIndicator();

          final cards = data.results.toList();
          if (sortBy == CardSortingField.currentBox) {
            cards.sort((c1, c2) => sortDir
              ? c1.currentBox.compareTo(c2.currentBox)
              : c2.currentBox.compareTo(c1.currentBox));
          } else if (sortBy == CardSortingField.seenCount) {
            cards.sort((c1, c2) => sortDir
              ? c1.seenCount.compareTo(c2.seenCount)
              : c2.seenCount.compareTo(c1.seenCount));
          } else if (sortBy == CardSortingField.lastSeen) {
            cards.sort((c1, c2) {
              if (c1.lastSeenDate == null) {
                return 1;
              } else if (c2.lastSeenDate == null) {
                return -1;
              }
              if (sortDir) {
                return c1.lastSeenDate!.millisecondsSinceEpoch.compareTo(
                    c2.lastSeenDate!.millisecondsSinceEpoch);
              } else {
                return c2.lastSeenDate!.millisecondsSinceEpoch.compareTo(
                    c1.lastSeenDate!.millisecondsSinceEpoch);
              }
            });
          }

          return Column(
            children: [
              Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(set!.name, style:const TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
                                ),
                                if(set!.description != null && set!.description!.isNotEmpty)
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: AutoSizeText(
                                      set!.description!,
                                      maxLines: 4,
                                      style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onBackground.withAlpha(220)),
                                      maxFontSize: 16,
                                      minFontSize: 14,
                                      overflowReplacement: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          splashFactory: InkRipple.splashFactory,
                                          borderRadius: const BorderRadius.all(Radius.circular(4)),
                                          splashColor: setColor.withAlpha(100),
                                          onTap: (){
                                            updateDescriptionMaxLine();
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(4, 4, 2, 4),
                                            child: Text(set!.description!, style: TextStyle(color: Theme.of(context).colorScheme.onBackground.withAlpha(220)), maxLines: descriptionMaxLine, overflow: TextOverflow.fade,),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Row(
                                    children: [
                                      if(isOwner && set!.lastStudyDate != null && totalKnowCount + totalDontKnowCount > 0)
                                        Tooltip(
                                          waitDuration: Duration.zero,
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).colorScheme.background,
                                            borderRadius: const BorderRadius.all(Radius.circular(6)),
                                            boxShadow: kElevationToShadow.values.elementAt(1),
                                          ),
                                          showDuration: Utils.isOnPhone() ? const Duration(seconds: 5) : null,
                                          triggerMode: Utils.isOnPhone() ? TooltipTriggerMode.tap : null,
                                          richMessage: TextSpan(
                                              style: TextStyle(
                                                  color: Theme.of(context).colorScheme.onBackground
                                              ),
                                              children: [
                                                TextSpan(text: totalKnowCount.toString(), style: const TextStyle(color: Colors.green)),
                                                const TextSpan(text: ' / '),
                                                TextSpan(text: totalDontKnowCount.toString(), style: const TextStyle(color: Colors.red)),
                                                TextSpan(text: "  -  ${"Card know ratio".i18n(["${(totalKnowCount * 100 / (totalKnowCount + totalDontKnowCount)).round()}"])}"),
                                                TextSpan(text: "\n${"Set last studied".i18n()} ${set!.lastStudyDate!.format()}", style: const TextStyle(fontWeight: FontWeight.w500, height: 2))
                                              ]
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.only(right: 8),
                                            child: Container(
                                                width: 6,
                                                height: 6,
                                                decoration: BoxDecoration(
                                                    color: progressColor,
                                                    shape: BoxShape.circle,
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: progressColor.withAlpha(180),
                                                        blurRadius: 0.8,
                                                        spreadRadius: 0.8,
                                                      )
                                                    ])
                                            ),
                                          ),
                                        ),
                                      Text(set!.cards.length <= 1 ? '${set!.cards.length} card' : '${set!.cards.length} cards', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),)
                                    ],
                                  ),
                                ),
                                if(ownerText != "") Align(
                                    alignment: Alignment.centerLeft,
                                    child: RichText(
                                        text: TextSpan(
                                          children: [
                                            if(set!.originalOwner != null)...[
                                              TextSpan(
                                                  style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onBackground),
                                                  text: "${"Set saved from".i18n()}\""
                                              ),
                                              TextSpan(
                                                text: set!.originalSet!.name,
                                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.primary),
                                                recognizer: originalSetTapRecognizer,
                                              ),
                                              TextSpan(
                                                  style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onBackground),
                                                  text: "\" "
                                              ),
                                            ],
                                            TextSpan(
                                              text: "by".i18n(),
                                              style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onBackground),
                                            ),
                                            TextSpan(
                                              text: ownerText,
                                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.primary),
                                              recognizer: originalOwnerTapRecognizer,
                                            )
                                          ],
                                        )
                                    )
                                )
                              ],
                            ),
                          ),
                          if(isOwner)
                            IconButton(
                              onPressed: () => modifySet(context, set!, realmServices),
                              icon: const Icon(Icons.edit),
                            )
                          else
                            SetPopupOption(realmServices,
                              set!,
                              realmServices.currentUser!.id == set!.owner!.userId.hexString,
                              canReport: !realmServices.userService.currentUserData!.reportedSets.contains(set),
                              like: realmServices.userService.currentUserData!.likedSets.contains(set),
                              horizontalIcon: true,
                            ),
                        ],
                      ),
                    ),
                    if(set!.cards.isNotEmpty)
                      Container(
                        constraints: BoxConstraints(maxWidth: learningButtonWidth, minHeight: learningButtonHeight),
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.primary),
                                  foregroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.onPrimary),
                                  fixedSize: const MaterialStatePropertyAll(Size.fromHeight(learningButtonHeight)),
                                  shape: const MaterialStatePropertyAll(RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(topLeft: Radius.circular(25), bottomLeft: Radius.circular(25), topRight: Radius.circular(4), bottomRight: Radius.circular(4)))
                                  ),
                                ),
                                onPressed: () => {
                                  GoRouter.of(context).push(RouterHelper.buildLearnRoute(widget.id, 'flashcards'))
                                },
                                child: iconTextCard(Icons.quiz_rounded, 'Flashcards'.i18n()),
                              ),
                            ),
                            const SizedBox(width: 4,),
                            ElevatedButton(
                              style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.primary),
                                  foregroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.onPrimary),
                                  fixedSize: const MaterialStatePropertyAll(Size(60, learningButtonHeight)),
                                  shape: const MaterialStatePropertyAll(RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(topLeft: Radius.circular(4), bottomLeft: Radius.circular(4), topRight: Radius.circular(25), bottomRight: Radius.circular(25)))
                                  ),
                                  padding: MaterialStateProperty.all(const EdgeInsets.symmetric(vertical: 0, horizontal: 5))
                              ),
                              onPressed: () => {
                                setState(() {
                                  arrowAngle = (arrowAngle + pi) % (2 * pi);
                                  extendLearningMenu = !extendLearningMenu;
                                }),
                              },
                              child:  TweenAnimationBuilder(
                                tween: Tween<double>(begin: 0, end: arrowAngle),
                                duration: const Duration(milliseconds: 300),
                                builder: (BuildContext context, double value, Widget? child) {
                                  return Transform(
                                    alignment: Alignment.center,
                                    transform:  Matrix4.identity()
                                      ..setEntry(3, 2, 0.001)
                                      ..rotateX(value),
                                    child: const Icon(Icons.keyboard_arrow_down_rounded, size: 30,),
                                  );
                                },
                              ),
                            ),

                            if(isOwner)...[
                              const SizedBox(width: 6,),
                              ElevatedButton(
                                style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.primary),
                                    foregroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.onPrimary),
                                    fixedSize: const MaterialStatePropertyAll(Size(learningButtonHeight, learningButtonHeight)),
                                    minimumSize: const MaterialStatePropertyAll(Size(learningButtonHeight, learningButtonHeight)),
                                    shape: const MaterialStatePropertyAll(RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(learningButtonHeight / 2)))
                                    ),
                                    padding: MaterialStateProperty.all(const EdgeInsets.symmetric(vertical: 0, horizontal: 0))
                                ),
                                onPressed: () => {
                                  GoRouter.of(context).push(RouterHelper.buildLearnSetSettingsRoute(set!.id.toString()))
                                },
                                child: const Center(child: Icon(Icons.settings)),
                              ),
                            ],
                          ],
                        ),
                      ),
                    const SizedBox(height: 2),
                    ExpandedSection(expand: extendLearningMenu,
                      duration: 300,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 4.0, 0, 0),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children:[
                              Container(
                                constraints: BoxConstraints(maxWidth: learningButtonWidth - 20, minHeight: learningButtonHeight),
                                margin: const EdgeInsets.symmetric(horizontal: 10),
                                child: ElevatedButton(
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.primary),
                                    foregroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.onPrimary),
                                    shape: const MaterialStatePropertyAll(RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(25)))),
                                  ),
                                  onPressed: () => {
                                    GoRouter.of(context).push(RouterHelper.buildLearnRoute(widget.id, 'written'))
                                  },
                                  child: iconTextCard(Icons.text_fields_rounded, 'Written mode'.i18n()),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8,),
                    Material(
                      elevation: easySelect ? 1 : 0,
                      child: ExpandedSection(
                          expand: selectedFlashcards.isNotEmpty,
                          duration: 200,
                          child: Container(
                            color: set!.getColor(context, defaultColor: Theme.of(context).colorScheme.surfaceVariant).withAlpha(80),
                            height: 50,
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: Utils.isOnPhone() ? 6.0 : 8.0),
                              child: Row(
                                children: [
                                  IconButton(
                                      onPressed: resetSelectedCard,
                                      icon: const Icon(Icons.close_rounded),
                                      tooltip: "Cancel".i18n()
                                  ),
                                  const SizedBox(width: 6,),
                                  Expanded(child:
                                  Text("x selected".i18n([selectedFlashcards.length.toString()]),
                                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w500),)
                                  ),
                                  if(isOwner)
                                    IconButton(
                                        onPressed: () async {
                                          await showBottomSheetModal(context, ModifyMultipleCardsForm(selectedFlashcards.toList()));
                                          resetSelectedCard();
                                        },
                                        icon: const Icon(Icons.edit_rounded),
                                        tooltip: "Edit".i18n()
                                    ),
                                  IconButton(
                                      onPressed: () async {
                                        await CardHelper.copyCardsToSet(context, set!, selectedFlashcards.toList(), realmServices);
                                        resetSelectedCard();
                                      },
                                      icon: const Icon(Icons.copy_all_rounded),
                                      tooltip: "Copy".i18n()
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      CardHelper.exportCards(context, selectedFlashcards.toList(), set!.name);
                                      resetSelectedCard();
                                    },
                                    icon: const Icon(Icons.download_rounded),
                                    tooltip: "Export to CSV".i18n(),
                                  ),
                                  if(isOwner) ... [
                                    const SizedBox(width: 6,),
                                    IconButton(
                                      onPressed: () {
                                        if(isOwner) {
                                          selectedFlashcards.length > 1
                                              ? DeleteUtils.deleteCards(context, realmServices, selectedFlashcards.toList(), onDelete: resetSelectedCard)
                                              : DeleteUtils.deleteCard(context, realmServices, selectedFlashcards[0], onDelete: resetSelectedCard);
                                        } else {
                                          errorMessageSnackBar(context, "Error".i18n(), "Error delete message".i18n(["Sets".i18n()])).show(context);
                                        }
                                      },
                                      icon: const Icon(Icons.delete_rounded),
                                      color: Theme.of(context).colorScheme.error,
                                      tooltip:  "Delete".i18n(),
                                    )
                                  ]
                                ],
                              ),
                            ),
                          )
                      ),
                    ),
                  ]
              ).animate(adapter: ScrollAdapter(_animationController, end: 1000)).custom(
                  builder: (context, value, child) {
                    return Material(
                      shadowColor: setColor.withAlpha(200),
                      surfaceTintColor: setColor,
                      elevation: 1 + 3 * value,
                      child: child,
                    );
                  }
              ),
              Expanded(
                child: SingleChildScrollView(
                    controller: _animationController,
                    child: Column(
                      children: [
                      Padding(
                        padding: Utils.isOnPhone() ? const EdgeInsets.fromLTRB(10, 6, 10 , 0) : const EdgeInsets.fromLTRB(16, 6, 16 , 0),
                        child: Row(
                        children: [
                            Expanded(
                              child: SearchField(
                                onSearchTextUpdated: onSearchChange,
                              ),
                            ),
                            IconButton(
                              onPressed: (){
                              showDialog(context: context, builder: (context) {
                                return SortCard(
                                    onUpdate: onSortByChange,
                                    sortedBy: sortBy,
                                    isOwner: isOwner,
                                  );
                                });
                              },
                              icon: Icon(Icons.sort_rounded, color: Theme.of(context).colorScheme.onSurface,),
                            ),
                            SortDirectionButton(
                              sortDir: sortDir,
                              onChange: onSortDirChange,
                              initAngle: 0,
                              iconColor: Theme.of(context).colorScheme.onSurface,
                            ),
                            IconButton(
                              onPressed: () {
                                onToggleSelectAll(cards);
                              },
                              icon: const Icon(Icons.select_all_rounded),
                              color: selectAll ? Theme.of(context).colorScheme.primary : null,
                              tooltip: "Select all".i18n(),
                            ),
                          ],
                        ),
                      ),
                        CardList(
                          cards,
                          isOwner,
                          easySelect: easySelect,
                          onSelectedCardsChanged: onSelectedCardsChanged,
                          searchText: searchText,
                          sortBy: sortBy,
                          sortDir: sortDir,
                          set: set!,
                          selectAll: selectAll,
                        ),
                      ],
                    )
                  ),
              ),
            ],
          );
        }
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

    return set!.cards.query(query, params).changes;
  }
}