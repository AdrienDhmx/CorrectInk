import 'dart:async';

import 'package:correctink/realm/realm_services.dart';
import 'package:correctink/realm/schemas.dart';
import 'package:flutter/cupertino.dart';
import 'package:realm/realm.dart';

class SetCollection extends ChangeNotifier{
  final RealmServices _realmServices;
  Realm get realm => _realmServices.realm;

  SetCollection(this._realmServices);

  void create(String name, String description, bool isPublic, String? color){
    bool revertSubscription = false;
    if(_realmServices.showAllPublicSets && !isPublic) {
      _realmServices.switchSetSubscription(false);
      revertSubscription = true;
    }

    final newSet = CardSet(ObjectId(), name, isPublic, _realmServices.currentUser!.id, description: description, color: color, originalSetId: null);
    realm.write<CardSet>(() => realm.add<CardSet>(newSet));

    if(revertSubscription){
      _realmServices.switchSetSubscription(true);
    }
    notifyListeners();
  }

  void delete(CardSet set) {
    ObjectId id = set.id;
    realm.write(() => realm.delete(set));

    final cards = _realmServices.cardCollection.getFromSet(id.hexString);
    for(var card in cards){
      _realmServices.cardCollection.delete(card);
    }

    notifyListeners();
  }

  ObjectId copyToCurrentUser(CardSet set){

    // when copying a set the user is looking at all the public sets
    // meaning the current subscription won't accept a write for a set that's not public
    _realmServices.switchSetSubscription(false);
    // copy set with the public prop set to false
    CardSet copiedSet = CardSet(ObjectId(), set.name, false, _realmServices.currentUser!.id, description: set.description, color: set.color, originalSetId: set.id, originalOwnerId: ObjectId.fromHexString(set.ownerId));
    realm.write<CardSet>(() => realm.add<CardSet>(copiedSet));

    // copy all cards
    List<KeyValueCard> cards = _realmServices.cardCollection.getFromSet(set.id.hexString);
    for(KeyValueCard card in cards){
      _realmServices.cardCollection.create(card.key, card.value, copiedSet.id);
    }

    // revert subscription back
    _realmServices.switchSetSubscription(true);
    return copiedSet.id;
  }

  void deleteAsync(CardSet set){
    Timer(const Duration(seconds: 1),() { delete(set); });
  }

  Future<void> update(CardSet set,
      { String? name, String? description, bool? isPublic, String? color }) async{
    realm.write(() {
      if(name != null){
        set.name = name;
      }
      if(description != null){
        set.description = description;
      }
      if(isPublic != null){
        set.isPublic = isPublic;
      }
      set.color = color;
    });
    notifyListeners();
  }

  CardSet? get(String id) {
    final sets = realm.query<CardSet>(r'_id == $0', [ObjectId.fromHexString(id)]);

    if(sets.isEmpty){
      return null;
    } else {
      return sets.first;
    }
  }

  Future<CardSet?> getAsync(String id, { bool public = false }) async {

    if(public && _realmServices.currentSetSubscription != RealmServices.queryAllSets){
      _realmServices.isWaiting = true;
      await _realmServices.queryAllSetSubscription();
    }

    final sets = realm.query<CardSet>(r'_id == $0', [ObjectId.fromHexString(id)]);
    _realmServices.isWaiting = false;

    if(sets.isEmpty){
      return null;
    } else {
      return sets.first;
    }
  }

  Future<ObjectId> getSetOwnerId(CardSet set) async {
    if(set.originalSetId == null){
      throw Exception('The set original id is null');
    }

    String userId = realm.query<CardSet>(r'_id == $0', [set.originalSetId]).first.ownerId;

    return ObjectId.fromHexString(userId);
  }
}