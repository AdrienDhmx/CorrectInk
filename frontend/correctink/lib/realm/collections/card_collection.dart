import 'package:flutter/cupertino.dart';
import 'package:realm/realm.dart';

import '../../learn/helper/learn_utils.dart';
import '../realm_services.dart';
import '../schemas.dart';

class CardCollection extends ChangeNotifier {
  final RealmServices _realmServices;
  Realm get realm => _realmServices.realm;

  CardCollection(this._realmServices);

  Future<void> update(KeyValueCard card,
      { List<String>? keys, List<String>? values }) async{
    realm.write(() {
      if(keys != null){
        card.keys.first = keys.first;
      }
      if(values != null){
        card.values.first = values.first;
      }
    });
    notifyListeners();
  }

  Future<void> increaseKnowCount(KeyValueCard card, {int increase = 1}) async {
    realm.write(() => {
      card.knowCount = card.knowCount + increase,
      card.lastKnowDate = DateTime.now(),
      card.lastSeenDate = DateTime.now(),
      card.currentBox = LearnUtils.getNextBox(card.currentBox, increase > 0)
    });
    notifyListeners();
  }

  Future<void> increaseLearningCount(KeyValueCard card, {int increase = 1}) async {
    realm.write(() => {
      card.dontKnowCount = card.dontKnowCount + increase,
      card.lastSeenDate = DateTime.now(),
      card.currentBox = LearnUtils.getNextBox(card.currentBox, increase < 0)
    });
    notifyListeners();
  }

  void delete(KeyValueCard card){
    realm.write(() => realm.delete(card));
    notifyListeners();
  }

}