import 'dart:math';

import 'package:correctink/realm/schemas.dart';

class LearnUtils{
  static const lowestBox = 1;
  static const highestBox = 6;

  static const dontKnowBoxChange = -1;
  static const knowBoxChange = 1;

  static int getNextBox(int currentBox, bool know){
    if(know){
      currentBox = currentBox + knowBoxChange;
      return currentBox <= highestBox ? currentBox : highestBox;
    } else {
      currentBox = currentBox + dontKnowBoxChange;
      return currentBox >= lowestBox ? currentBox : lowestBox;
    }
  }

  static int daysPerBox(int box, {int? seed}){
    switch(box){
      case 1:
        return 0; // can be seen everyday
      case 2: // can be seen everyday or every 2 days
        return Random(seed ?? DateTime.now().millisecondsSinceEpoch).nextInt(box);
      case 3: // can be seen every 2 - 3 days
        return Random(seed ??DateTime.now().millisecondsSinceEpoch).nextInt(box) + 1;
      case 4: // can be seen every 4 - 6 days
        return Random(seed ??DateTime.now().millisecondsSinceEpoch).nextInt(box) + 3;
      case 5: // can be seen every 8 - 12 days
        return Random(seed ??DateTime.now().millisecondsSinceEpoch).nextInt(box) + 7;
      case 6: // can be seen every 15 - 19 days
        return Random(seed ?? DateTime.now().millisecondsSinceEpoch).nextInt(box) + 14;
    }
    return 0;
  }

  static bool shouldBeSeen(KeyValueCard card){
    final millisecondsSinceEpoch = DateTime.now().millisecondsSinceEpoch;
    final daysForCurrentBox = daysPerBox(card.currentBox, seed: millisecondsSinceEpoch);

    return card.lastKnowDate == null ||
        card.lastKnowDate!.add(Duration(days: daysForCurrentBox)).millisecondsSinceEpoch < millisecondsSinceEpoch;
  }

  static List<KeyValueCard> getLearningCards(List<KeyValueCard> cards){
    List<KeyValueCard> learningCards = <KeyValueCard>[];

    for(int i = 0; i < cards.length; i++){
      if(shouldBeSeen(cards[i])){
        learningCards.add(cards[i]);
      }
    }

    if(learningCards.isEmpty){
      return cards;
    }
    return learningCards;
  }
}