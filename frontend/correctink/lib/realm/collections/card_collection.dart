import 'package:flutter/cupertino.dart';
import 'package:realm/realm.dart';

import '../realm_services.dart';
import '../schemas.dart';

class CardCollection extends ChangeNotifier {
  final RealmServices _realmServices;
  Realm get realm => _realmServices.realm;

  CardCollection(this._realmServices);

  Future<void> update(KeyValueCard card,
      { String? key, String? value }) async{
    realm.write(() {
      if(key != null){
        card.key = key;
      }
      if(value != null){
        card.value = value;
      }
    });
    notifyListeners();
  }

  Future<void> increaseKnowCount(KeyValueCard card, {int increase = 1}) async {
    realm.write(() => {
      card.knowCount = card.knowCount + increase,
      card.lastSeen = DateTime.now(),
    });
    notifyListeners();
  }

  Future<void> increaseLearningCount(KeyValueCard card, {int increase = 1}) async {
    realm.write(() => {
      card.learningCount = card.learningCount + increase,
      card.lastSeen = DateTime.now(),
    });
    notifyListeners();
  }

  void delete(KeyValueCard card){
    realm.write(() => realm.delete(card));
    notifyListeners();
  }

}