import 'dart:async';
import 'dart:math';

import 'package:correctink/learn/flashcards.dart';
import 'package:correctink/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:correctink/realm/realm_services.dart';
import 'package:correctink/realm/schemas.dart';
import 'package:correctink/theme.dart';
import 'package:go_router/go_router.dart';
import 'package:localization/localization.dart';
import 'package:provider/provider.dart';

import '../components/snackbars_widgets.dart';
import '../components/widgets.dart';
import '../learn/helper/learn_utils.dart';
import '../learn/written_mode.dart';
import '../utils.dart';

class LearnPage extends StatefulWidget{
  const LearnPage(this.setId, this.learningMode, {Key? key}) : super(key: key);
  final String setId;
  final String learningMode;

  @override
  State<StatefulWidget> createState() => _LearnPage();
}

class _LearnPage extends State<LearnPage>{
  int currentCardIndex = 0;
  int knownCount = 0;
  int passedCount = 0;
  int totalCount = 0;
  late bool isOwner;
  late bool frontIsTop = false;
  late String top = '';
  late String bottom;
  late List<bool> previousSwapKnow = <bool>[];
  late List<bool> previousFrontIsTop = <bool>[];
  late RealmServices realmServices;
  late List<KeyValueCard> cards = <KeyValueCard>[];
  late List<KeyValueCard> cardsToRepeat = <KeyValueCard>[];
  late CardSet? set;
  late StreamSubscription stream;
  late bool streamInit = false;
  late bool noCardsToStudy = false;

  void restart(){
    prepareCards();

    setState(() {
      currentCardIndex = 0;
      passedCount = 0;
      knownCount = 0;
      totalCount = cards.length;
      decideTopBottom();
    });
  }

  void prepareCards(){
    if(set!.studyMethod == 0) {
      cards = LearnUtils.getLearningCards(set!.cards.toList());
      if(cards.isEmpty){
        noCardsToStudy = true;
        return;
      }
    } else {
      cards = set!.cards.toList();
    }

    cards =  LearnUtils.shuffleCards(cards);
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    if(cards.isEmpty){
      realmServices = Provider.of<RealmServices>(context);
      set = realmServices.setCollection.get(widget.setId);

       if(!streamInit) {
         stream = set!.changes.listen((event) {
            setState(() {
              set = event.object;
              decideTopBottom();
            });
          });
        }

        isOwner = set!.owner!.userId.hexString == realmServices.currentUser!.id;

        prepareCards();

        totalCount = cards.length;
        decideTopBottom();
      }
  }

  @override
  void dispose(){
    super.dispose();
    stream.cancel();
  }

  void decideTopBottom(){
    if(cards.isEmpty){
      totalCount = 1; // avoid dividing by 0
      return;
    }

    if(set!.sideToGuess == 1){
      bottom = cards[currentCardIndex].front;
      top = cards[currentCardIndex].back;
    } else if(set!.sideToGuess == -1){
      final rand = Random(DateTime.now().millisecondsSinceEpoch);
      if(rand.nextBool()){
        top = cards[currentCardIndex].front;
        bottom = cards[currentCardIndex].back;
      } else {
        top = cards[currentCardIndex].back;
        bottom = cards[currentCardIndex].front;
      }
    } else {
      top = cards[currentCardIndex].front;
      bottom = cards[currentCardIndex].back;
    }
    print("top: $top ---- bottom: $bottom");
  }

  void swap(bool know) async {
    previousSwapKnow.add(know);

    setState(() {
      if(know){
        knownCount++;
      } else if(set!.repeatUntilKnown){
        cardsToRepeat.add(cards[currentCardIndex]);
        totalCount++;
      }

      if(currentCardIndex + 1 == cards.length && set!.repeatUntilKnown && cardsToRepeat.isNotEmpty){
        // add the incorrect cards to the pile
        cards.addAll(LearnUtils.shuffleCards(cardsToRepeat));
        // reset the incorrect list of cards
        cardsToRepeat = <KeyValueCard>[];
      }

      if(currentCardIndex + 1 < totalCount) {
        previousFrontIsTop.add(top == cards[currentCardIndex].front);
        currentCardIndex += 1;
        decideTopBottom();
      }
      passedCount++;
    });

    if(know){
      if(isOwner) realmServices.cardCollection.increaseKnowCount(cards[currentCardIndex - 1]);
    }else{
      if(isOwner) realmServices.cardCollection.increaseLearningCount(cards[currentCardIndex-1]);
    }

    if(passedCount == totalCount){
        if(await realmServices.usersCollection.updateStudyStreak()){
          if(context.mounted) studyStreakMessageSnackBar(context, 'Study Streak'.i18n(), 'Study Streak congrats'.i18n([realmServices.usersCollection.currentUserData!.studyStreak.toString()])).show(context);
        }
    }
  }

  void undo(){
    if(previousSwapKnow.isEmpty) return;

    setState(() {
      currentCardIndex--;
      passedCount--;

      top = previousFrontIsTop.last ? cards[currentCardIndex].front : cards[currentCardIndex].back;
      bottom = previousFrontIsTop.last ? cards[currentCardIndex].back : cards[currentCardIndex].front;
      previousFrontIsTop.removeLast();

      if(previousSwapKnow.last){
        knownCount--;
        realmServices.cardCollection.increaseKnowCount(cards[currentCardIndex], increase: -1);
      } else {
        realmServices.cardCollection.increaseLearningCount(cards[currentCardIndex], increase: -1);
      }
    });

    previousSwapKnow.removeLast();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: Utils.isOnPhone() ? 80 : 60,
            color: set!.color == null ? Theme.of(context).colorScheme.surface : HexColor.fromHex(set!.color!).withAlpha(40),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0.0, 0, 5.0, 0),
              child: SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.navigate_before)),
                    ),
                    Text(set!.name, style: listTitleTextStyle(),),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          onPressed: (){
                            GoRouter.of(context).push(RouterHelper.buildLearnSetSettingsRoute(set!.id.hexString));
                            /*showModalBottomSheet(
                              isScrollControlled: true,
                                context: context,
                                builder: (context){
                                if(widget.learningMode == 'flashcards') {
                                  return Wrap(
                                    children:[
                                      Padding(
                                        padding: const EdgeInsets.all(20.0),
                                        child: flashcardsHelp(context)
                                      ),
                                    ] ,
                                  );
                                } else {
                                  return Wrap(
                                    children:[
                                      Padding(
                                          padding: const EdgeInsets.all(20.0),
                                          child: writtenModeHelp(context)
                                      ),
                                    ] ,
                                  );
                                }
                              }
                            );*/
                          },
                          icon: const Icon(Icons.settings)
                        )
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            height: 4,
            child: Row(
              children: [
                Expanded(
                  flex: (passedCount - knownCount) * 100 ~/ totalCount,
                    child: Container(
                      color: Colors.red.withAlpha(100),
                    ),
                ),
                Expanded(
                  flex: knownCount * 100 ~/ totalCount,
                  child: Container(
                    color: Colors.green.withAlpha(100),
                  ),
                ),
                Expanded(
                  flex: (totalCount - passedCount) * 100 ~/ totalCount,
                  child: Container(
                    color: Theme.of(context).colorScheme.onBackground.withAlpha(100),
                  ),
                ),
              ],
            ),
          ),
          if(!noCardsToStudy)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                      color: Colors.red.withAlpha(50),
                    ),
                    child: Center(child: Text((passedCount - knownCount).toString(), style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w700),)),
                  ),
                  Text("x of y".i18n([passedCount.toString(), totalCount.toString()])),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                      color: Colors.green.withAlpha(50),
                    ),
                    child: Center(child: Text(knownCount.toString(), style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w700),)),
                  ),
                ],
              ),
            ),

          if(noCardsToStudy)
            Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        children: [
                          Text("No cards to study".i18n(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8,),
                          Text("No cards to study info".i18n(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.onSurfaceVariant
                            ),
                          ),
                          const SizedBox(height: 8,),
                          Text("No cards to study how to disable".i18n(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                                color: Theme.of(context).colorScheme.onSurfaceVariant
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18,),
                    TextButton(
                        onPressed: () {
                          setState(() {
                            cards = LearnUtils.shuffleCards(set!.cards.toList());
                            totalCount = cards.length;
                            decideTopBottom();
                            noCardsToStudy = false;
                          });
                        },
                        style: flatTextButton(Theme.of(context).colorScheme.primaryContainer, Theme.of(context).colorScheme.onPrimaryContainer),
                        child: Text(
                          "Study now".i18n(),
                        )
                    ),
                  ],
                )
            )
          else if(passedCount == totalCount)
            Expanded(child: CallbackShortcuts(
              bindings: <ShortcutActivator, VoidCallback>{
                const SingleActivator(LogicalKeyboardKey.enter): () {
                  restart();
                },
              },
              child: Focus(
                autofocus: true,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('set finished congrats'.i18n(), textScaleFactor: 1.5, textAlign: TextAlign.center,),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15.0),
                        child: SizedBox(
                          width: 150,
                          height: 40,
                          child: ElevatedButton(
                              onPressed: restart,
                              style: primaryTextButtonStyle(context),
                              child: Text('Restart'.i18n()),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ))
          else if(passedCount < totalCount && widget.learningMode == 'flashcards')
              Expanded(child: Flashcards(set!, cards[currentCardIndex], currentCardIndex, swap, undo, top: top, bottom: bottom,))
          else if(passedCount < totalCount && widget.learningMode == 'written')
              Expanded(child: WrittenMode(set!, cards[currentCardIndex], currentCardIndex, swap, undo, top: top, bottom: bottom,)),
        ],
      ),
    );
  }
}