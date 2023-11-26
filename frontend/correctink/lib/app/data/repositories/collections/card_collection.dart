import 'package:flutter/cupertino.dart';
import 'package:realm/realm.dart';

import '../../../../utils/learn_utils.dart';
import '../realm_services.dart';
import '../../models/schemas.dart';

class CardCollection extends ChangeNotifier {
  final RealmServices _realmServices;
  Realm get realm => _realmServices.realm;

  CardCollection(this._realmServices);

  Future<void> update(KeyValueCard card,
      String key, String value, bool keyMultiplesValues, bool valueMultipleValues) async{
    realm.write(() {
      card.front = key;
      card.back = value;
      card.allowFrontMultipleValues = keyMultiplesValues;
      card.allowBackMultipleValues = valueMultipleValues;
    });
    notifyListeners();
  }

  Future<void> increaseKnowCount(KeyValueCard card, {int increase = 1}) async {
    realm.write(() => {
      card.knowCount = card.knowCount + increase,
      card.lastKnowDate = DateTime.now().toUtc(),
      card.lastSeenDate = DateTime.now().toUtc(),
      card.currentBox = LearnUtils.getNextBox(card.currentBox, increase > 0)
    });
    notifyListeners();
  }

  Future<void> increaseLearningCount(KeyValueCard card, {int increase = 1}) async {
    realm.write(() => {
      card.dontKnowCount = card.dontKnowCount + increase,
      card.lastSeenDate = DateTime.now().toUtc(),
      card.currentBox = LearnUtils.getNextBox(card.currentBox, increase < 0)
    });
    notifyListeners();
  }

  void delete(KeyValueCard card){
    realm.write(() => realm.delete(card));
    notifyListeners();
  }

  void deleteAll(List<KeyValueCard> cards){
    realm.write(() => realm.deleteMany(cards));
    notifyListeners();
  }

}