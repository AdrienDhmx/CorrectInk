import 'package:flutter/cupertino.dart';
import 'package:realm/realm.dart';

import '../realm_services.dart';
import '../schemas.dart';

class CardCollection extends ChangeNotifier {
  final RealmServices _realmServices;
  Realm get realm => _realmServices.realm;

  CardCollection(this._realmServices);

  void create(String key, String value, ObjectId setId){
    final newCard = KeyValueCard(ObjectId(), key, value, setId);
    realm.write<KeyValueCard>(() => realm.add<KeyValueCard>(newCard));
    notifyListeners();
  }

  List<KeyValueCard> getFromSet(String setId){
    return realm.query<KeyValueCard>(r'set_id == $0', [ObjectId.fromHexString(setId)]).toList();
  }

  Future<void> update(KeyValueCard card,
      { String? key, String? value, DateTime? lastSeen, int? learningProgress }) async{
    realm.write(() {
      if(key != null){
        card.key = key;
      }
      if(value != null){
        card.value = value;
      }
      if(lastSeen != null){
        card.lastSeen = lastSeen;
      }
      if(learningProgress != null && card.learningProgress != learningProgress){
        card.learningProgress = learningProgress;
      }
    });
    notifyListeners();
  }

  void delete(KeyValueCard card){
    realm.write(() => realm.delete(card));
    notifyListeners();
  }

}