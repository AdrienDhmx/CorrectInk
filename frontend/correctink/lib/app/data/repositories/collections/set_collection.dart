import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:realm/realm.dart';

import '../../models/schemas.dart';
import '../realm_services.dart';

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

    final newSet = CardSet(ObjectId(), name, isPublic, _realmServices.currentUser!.id,  owner: _realmServices.usersCollection.currentUserData, description: description, color: color, originalSet: null);
    realm.write<CardSet>(() => realm.add<CardSet>(newSet));

    if(revertSubscription){
      _realmServices.switchSetSubscription(true);
    }
    notifyListeners();
  }

  void delete(CardSet set) {
    realm.write(() => {
      realm.deleteMany(set.cards),
      realm.delete(set),
    });

    notifyListeners();
  }

  ObjectId copyToCurrentUser(CardSet set){

    // when copying a set the user is looking at all the public sets
    // meaning the current subscription won't accept a write for a set that's not public
    _realmServices.switchSetSubscription(false);
    // copy set with the public prop set to false
    CardSet copiedSet = CardSet(ObjectId(),
        set.name,
        false,
        _realmServices.currentUser!.id,
        owner: _realmServices.usersCollection.currentUserData,
        description: set.description,
        color: set.color,
        originalSet: set,
        originalOwner: set.owner!,
        tags: set.tags,
        cards: set.cards,
    );
    realm.write<CardSet>(() => realm.add<CardSet>(copiedSet));

    // revert subscription back
    _realmServices.switchSetSubscription(true);
    return copiedSet.id;
  }

  void deleteAsync(CardSet set){
    Timer(const Duration(seconds: 1),() { delete(set); });
  }

  Future<void> addCard(CardSet set, String key, String value,
      bool multipleKeys, bool multipleValues) async {
    final newCard = KeyValueCard(ObjectId(), key, value,
          allowFrontMultipleValues: multipleKeys, allowBackMultipleValues: multipleValues,
    );

    realm.write(() => {
      set.cards.add(newCard),
    });
  }

  Future<void> deleteCard(CardSet set, KeyValueCard card) async {
    realm.write(() => {
      set.cards.remove(card),
    });
  }

  Future<void> update(CardSet set,
      { String? name, String? description, bool? isPublic, String? color }) async {
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

  void updateSettings(CardSet set, {bool? lenientMode, int? guessSide, bool? getAllAnswersRight, int? studyMethod, bool? repeatUntilKnown}){
    realm.write(() {
      if(lenientMode != null){
        set.lenientMode = lenientMode;
      }
      if(guessSide != null){
        set.sideToGuess = guessSide;
      }
      if(getAllAnswersRight != null){
        set.getAllAnswersRight = getAllAnswersRight;
      }
      if(studyMethod != null){
        set.studyMethod = studyMethod;
      }
      if(repeatUntilKnown != null){
        set.repeatUntilKnown = repeatUntilKnown;
      }
    });
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
}