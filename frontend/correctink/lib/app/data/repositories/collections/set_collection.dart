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

    final newSet = CardSet(ObjectId(), name, isPublic, _realmServices.currentUser!.id,  owner: _realmServices.userService.currentUserData, description: description, color: color, originalSet: null);
    realm.write<CardSet>(() => realm.add<CardSet>(newSet));

    notifyListeners();
  }

  void delete(CardSet set) {
    realm.write(() => {
      realm.deleteMany(set.cards),
      realm.delete(set),
    });

    notifyListeners();
  }

  Future<ObjectId> copyToCurrentUser(CardSet set) async {
    final copiedCards = <KeyValueCard>[];
    for(KeyValueCard card in set.cards){
      copiedCards.add(KeyValueCard(ObjectId(),
          card.front,
          card.back,
          allowFrontMultipleValues: card.allowFrontMultipleValues,
          allowBackMultipleValues: card.allowBackMultipleValues,
      ));
    }

    // copy set with the public prop set to false
    CardSet copiedSet = CardSet(ObjectId(),
        set.name,
        false,
        _realmServices.currentUser!.id,
        owner: _realmServices.userService.currentUserData,
        description: set.description,
        color: set.color,
        cards: copiedCards,
        originalSet: set,
        originalOwner: set.owner!,
    );

    realm.write<CardSet>(() => realm.add<CardSet>(copiedSet));

/*    // revert subscription back to public
    _realmServices.switchSetSubscription(true);*/
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

  void updateLastStudyDate(CardSet set){
    realm.write(() {
      set.lastStudyDate = DateTime.now().toUtc();
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

  Future<List<CardSet>> getAll(String userId) async {
    return realm.query<CardSet>(r'owner_id == $0', [userId]).toList();
  }

  Future<CardSet?> getAsync(String id, { bool public = false }) async {
    final sets = realm.query<CardSet>(r'_id == $0', [ObjectId.fromHexString(id)]);
    _realmServices.isWaiting = false;

    if(sets.isEmpty){
      return null;
    } else {
      return sets.first;
    }
  }
}