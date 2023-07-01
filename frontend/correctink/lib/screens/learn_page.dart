import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:correctink/learn/learn_card.dart';
import 'package:correctink/realm/realm_services.dart';
import 'package:correctink/realm/schemas.dart';
import 'package:correctink/theme.dart';
import 'package:localization/localization.dart';
import 'package:provider/provider.dart';

import '../components/snackbars_widgets.dart';
import '../utils.dart';

class LearnPage extends StatefulWidget{
  const LearnPage(this.setId, {Key? key}) : super(key: key);
  final String setId;

  @override
  State<StatefulWidget> createState() => _LearnPage();
}

class _LearnPage extends State<LearnPage>{
  int currentCardIndex = 0;
  int knownCount = 0;
  int passedCount = 0;
  int totalCount = 0;
  late bool owner;
  late List<bool> previousSwapKnow = <bool>[];
  late RealmServices realmServices;
  late List<KeyValueCard> cards = <KeyValueCard>[];
  late CardSet? set;

  void restart(){
    cards = shuffle(cards);
    setState(() {
      currentCardIndex = 0;
      passedCount = 0;
      knownCount = 0;
    });
  }

  List<KeyValueCard> shuffle(List<KeyValueCard> items) {
    var random = Random();
    for (var i = items.length - 1; i > 0; i--) {
      var n = random.nextInt(i + 1);
      var temp = items[i];
      items[i] = items[n];
      items[n] = temp;
    }
    return items;
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    if(cards.isEmpty){
      realmServices = Provider.of<RealmServices>(context);
      set = realmServices.setCollection.get(widget.setId);

      if(set != null){
        owner = set!.ownerId == realmServices.currentUser!.id;
        cards = set!.cards.toList();

        cards = shuffle(cards);
        setState(() {
          totalCount = cards.length;
        });
      }
    }

  }

  void swap(bool know) async {
    previousSwapKnow.add(know);

    if(know){
      setState(() {
        knownCount++;
      });
      if(owner) realmServices.cardCollection.increaseKnowCount(cards[currentCardIndex]);
    }else{
      if(owner) realmServices.cardCollection.increaseLearningCount(cards[currentCardIndex]);
    }

    setState(() {
      if(currentCardIndex + 1 < totalCount) {
        currentCardIndex++;
      }
      passedCount++;
    });
    
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
                            showModalBottomSheet(
                              isScrollControlled: true,
                                context: context,
                                builder: (context){
                                  TextTheme myTextTheme = Theme.of(context).textTheme;
                                  return Wrap(
                                    children:[
                                      Padding(
                                        padding: const EdgeInsets.all(20.0),
                                        child: Column(
                                          children: [
                                            Text('Info'.i18n(), style: myTextTheme.headlineMedium,),
                                            Padding(
                                              padding: const EdgeInsets.all(4.0),
                                              child: Text('Info tap card'.i18n(), style: myTextTheme.bodyLarge, textAlign: TextAlign.center,),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(4.0),
                                              child: Text('Info swipe card'.i18n(), style: myTextTheme.bodyLarge, textAlign: TextAlign.center),
                                            ),
                                            if(!Platform.isAndroid && !Platform.isIOS)
                                              const Divider(),
                                            if(!Platform.isAndroid && !Platform.isIOS)
                                              Center(
                                                  child: Column(
                                                    children: [
                                                      Padding(
                                                        padding: const EdgeInsets.all(8.0),
                                                        child: Text('Keyboard shortcuts'.i18n(), style: myTextTheme.headlineMedium ),
                                                      ),
                                                      Table(
                                                        columnWidths: const <int, TableColumnWidth>{
                                                          0: FixedColumnWidth(100),
                                                          1: FixedColumnWidth(260),
                                                        },
                                                        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                                                        border: TableBorder.symmetric(inside: BorderSide(width: 1.0, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                                                        children: [
                                                            TableRow(
                                                              children: [
                                                                Padding(
                                                                  padding: const EdgeInsets.all(8.0),
                                                                  child: Text('Keyboard space'.i18n()),
                                                                ),
                                                                Padding(
                                                                  padding: const EdgeInsets.all(8.0),
                                                                  child: Text('Info tap card'.i18n()),
                                                                ),
                                                              ],
                                                            ),
                                                          TableRow(
                                                            children: [
                                                              Padding(
                                                                padding: const EdgeInsets.all(8.0),
                                                                child: Text('Keyboard left arrow'.i18n()),
                                                              ),
                                                              Padding(
                                                                padding: const EdgeInsets.all(8.0),
                                                                child: Text("Info swipe left card".i18n()),
                                                              ),
                                                            ],
                                                          ),
                                                          TableRow(
                                                            children: [
                                                              Padding(
                                                                padding: const EdgeInsets.all(8.0),
                                                                child: Text('Keyboard right arrow'.i18n()),
                                                              ),
                                                              Padding(
                                                                padding: const EdgeInsets.all(8.0),
                                                                child: Text("Info swipe right card".i18n()),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                          ],
                                        ),
                                      ),
                                    ] ,
                                  );
                                }
                            );
                          },
                          icon: const Icon(Icons.info)
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
                  child: Center(child: Text((passedCount - knownCount).toString())),
                ),
                Text("x of y".i18n([passedCount.toString(), totalCount.toString()])),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                    color: Colors.green.withAlpha(50),
                  ),
                  child: Center(child: Text(knownCount.toString())),
                ),
              ],
            ),
          ),
          if(passedCount == totalCount)
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
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: SizedBox(
                          width: 140,
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
            )),
          if(passedCount < totalCount)
            Expanded(
              child: FlipCard(cards[currentCardIndex],0, set!.color == null ? Theme.of(context).colorScheme.surface : HexColor.fromHex(set!.color!), swap)
            ),
          if(passedCount < totalCount)
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
              child: SizedBox(
                height: 60,
                child: FractionallySizedBox(
                  widthFactor: 0.9,
                  heightFactor: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if(!Platform.isAndroid && !Platform.isIOS)
                        Expanded(
                          child: TextButton(
                              style: flatTextButton(Colors.red.withAlpha(50), Theme.of(context).colorScheme.onBackground),
                              onPressed: () { swap(false); },
                              child: Text('Learning'.i18n())
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18.0),
                        child:IconButton(
                            disabledColor: Theme.of(context).colorScheme.onSurfaceVariant.withAlpha(100),
                            onPressed: currentCardIndex != 0 ? () { undo(); } : null,
                            icon: const Icon(Icons.undo_rounded),
                        ),
                      ),
                      if(!Platform.isAndroid && !Platform.isIOS)
                        Expanded(
                          child: TextButton(
                              style: flatTextButton(Colors.green.withAlpha(50), Theme.of(context).colorScheme.onBackground),
                              onPressed: () { swap(true); },
                              child: Text('Know'.i18n())
                          ),
                        ),
                    ],
                  ),
              ),
            ),
            ),
        ],
      ),
    );
  }
}