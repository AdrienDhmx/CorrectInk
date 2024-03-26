import 'package:correctink/utils/learn_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:realm/realm.dart';

import '../realm_services.dart';
import '../../models/schemas.dart';

class CardCollection extends ChangeNotifier {
  final RealmServices _realmServices;
  Realm get realm => _realmServices.realm;

  CardCollection(this._realmServices);

  Future<void> update(Flashcard card,
      String frontValue, String backValue, bool frontMultiplesValues, bool backMultipleValues, bool canBeReversed) async{
    realm.write(() {
      card.front!.value = frontValue;
      card.back!.value = backValue;
      card.front!.allowMultipleValues = frontMultiplesValues;
      card.back!.allowMultipleValues = backMultipleValues;
      card.canBeReversed = canBeReversed;
    });
    notifyListeners();
  }

  Future<void> updateAll(List<Flashcard> cards,  bool canBeReversed) async{
    realm.writeAsync(() {
      for(Flashcard card in cards) {
        card.canBeReversed = canBeReversed;
      }
    });
    notifyListeners();
  }

  Future<void> increaseKnowCount(Flashcard card, bool back, {int increase = 1}) async {
    CardSide cardSide = back ? card.back! : card.front!;
    realm.write(() => {
        cardSide.knowCount += increase,
        cardSide.lastSeenDate = DateTime.now().toUtc(),
        cardSide.lastKnowDate = DateTime.now().toUtc(),
        cardSide.currentBox = LearnUtils.getNextBox(cardSide.currentBox, increase > 0),
    });
    notifyListeners();
  }

  Future<void> increaseDontKnowCount(Flashcard card, bool back, {int increase = 1}) async {
    CardSide cardSide = back ? card.back! : card.front!;
    realm.write(() => {
      cardSide.dontKnowCount += increase,
      cardSide.lastSeenDate = DateTime.now().toUtc(),
      cardSide.currentBox = LearnUtils.getNextBox(cardSide.currentBox, increase < 0),
    });
    notifyListeners();
  }

  void delete(Flashcard card){
    realm.write(() => realm.delete(card));
    notifyListeners();
  }

  void deleteAll(List<Flashcard> cards){
    realm.write(() => realm.deleteMany(cards));
    notifyListeners();
  }

}