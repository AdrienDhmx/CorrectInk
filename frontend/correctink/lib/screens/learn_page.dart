import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:correctink/learn/learn_card.dart';
import 'package:correctink/realm/realm_services.dart';
import 'package:correctink/realm/schemas.dart';
import 'package:correctink/theme.dart';
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    if(cards.isEmpty){
      realmServices = Provider.of<RealmServices>(context);
      set = realmServices.getSet(widget.setId);

      if(set != null){
        owner = set!.ownerId == realmServices.currentUser!.id;
        cards = realmServices.getKeyValueCards(widget.setId);

        cards = shuffle(cards);
        setState(() {
          totalCount = cards.length;
        });
      }
    }

  }

  void swap(bool know) async {
    int progress = cards[currentCardIndex].learningProgress;
    previousSwapKnow.add(know);

    if(know){
      progress++;
      setState(() {
        knownCount++;
      });
    }else{
      progress--;
    }

    if(owner) realmServices.updateKeyValueCard(cards[currentCardIndex], lastSeen: DateTime.now(), learningProgress: progress);

    setState(() {
      if(currentCardIndex + 1 < totalCount) {
        currentCardIndex++;
      }
      passedCount++;
    });
    
    if(passedCount == totalCount){
      if(await realmServices.updateStudyStreak()){
        if(context.mounted) studyStreakMessageSnackBar(context, 'Study Streak!', 'Congratulation you have been studying for ${realmServices.currentUserData!.studyStreak} days in a row');
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
      }
    });

    int oldProgress = previousSwapKnow.last ? cards[currentCardIndex].learningProgress - 1 :  cards[currentCardIndex].learningProgress + 1;
    realmServices.updateKeyValueCard(cards[currentCardIndex], learningProgress: oldProgress);
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
                                            Text('Info', style: myTextTheme.headlineMedium,),
                                            Padding(
                                              padding: const EdgeInsets.all(4.0),
                                              child: Text('You can tap the card to discover its other side.', style: myTextTheme.bodyLarge, textAlign: TextAlign.center,),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(4.0),
                                              child: Text('You can swipe left (learning) or right (know) and go to the next card.', style: myTextTheme.bodyLarge, textAlign: TextAlign.center),
                                            ),
                                            if(!Platform.isAndroid && !Platform.isIOS)
                                              const Divider(),
                                            if(!Platform.isAndroid && !Platform.isIOS)
                                              Center(
                                                  child: Column(
                                                    children: [
                                                      Padding(
                                                        padding: const EdgeInsets.all(8.0),
                                                        child: Text('Keyboard Shortcuts', style: myTextTheme.headlineMedium ),
                                                      ),
                                                      Table(
                                                        columnWidths: const <int, TableColumnWidth>{
                                                          0: FixedColumnWidth(100),
                                                          1: FixedColumnWidth(260),
                                                        },
                                                        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                                                        border: TableBorder.symmetric(inside: BorderSide(width: 1.0, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                                                        children: const [
                                                            TableRow(
                                                              children: [
                                                                Padding(
                                                                  padding: EdgeInsets.all(8.0),
                                                                  child: Text('Space'),
                                                                ),
                                                                Padding(
                                                                  padding: EdgeInsets.all(8.0),
                                                                  child: Text('Discover the other side of the card'),
                                                                ),
                                                              ],
                                                            ),
                                                          TableRow(
                                                            children: [
                                                              Padding(
                                                                padding: EdgeInsets.all(8.0),
                                                                child: Text('Left arrow'),
                                                              ),
                                                              Padding(
                                                                padding: EdgeInsets.all(8.0),
                                                                child: Text('You are still learning card'),
                                                              ),
                                                            ],
                                                          ),
                                                          TableRow(
                                                            children: [
                                                              Padding(
                                                                padding: EdgeInsets.all(8.0),
                                                                child: Text('Right arrow'),
                                                              ),
                                                              Padding(
                                                                padding: EdgeInsets.all(8.0),
                                                                child: Text('You know the card'),
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
                Text('$passedCount of $totalCount'),
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
                      const Text('Congratulation, you finished the set!', textScaleFactor: 1.5, textAlign: TextAlign.center,),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: SizedBox(
                          width: 100,
                          height: 40,
                          child: ElevatedButton(
                              onPressed: restart,
                              style: primaryTextButtonStyle(context),
                              child: const Text('Restart'),
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
                              child: const Text('Learning')
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
                              child: const Text('Know')
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