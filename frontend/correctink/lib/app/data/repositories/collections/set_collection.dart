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

    final newSet = FlashcardSet(ObjectId(), name, isPublic, _realmServices.app.app.currentUser!.id,  owner: _realmServices.userService.currentUserData, description: description, color: color, originalSet: null);
    realm.write<FlashcardSet>(() => realm.add<FlashcardSet>(newSet));

    notifyListeners();
  }

  void delete(FlashcardSet set) {
    realm.write(() => {
      realm.deleteMany(set.cards),
      realm.delete(set),
    });

    notifyListeners();
  }

  Future<ObjectId> copyToCurrentUser(FlashcardSet set) async {
    final copiedCards = <Flashcard>[];
    for(Flashcard card in set.cards){
      copiedCards.add(Flashcard(ObjectId(),
      ));
    }

    // copy set with the public prop set to false
    FlashcardSet copiedSet = FlashcardSet(ObjectId(),
        set.name,
        false,
        _realmServices.app.app.currentUser!.id,
        owner: _realmServices.userService.currentUserData,
        description: set.description,
        color: set.color,
        cards: copiedCards,
        originalSet: set,
        originalOwner: set.owner!,
    );

    realm.write<FlashcardSet>(() => realm.add<FlashcardSet>(copiedSet));

/*    // revert subscription back to public
    _realmServices.switchSetSubscription(true);*/
    return copiedSet.id;
  }

  void deleteAsync(FlashcardSet set){
    Timer(const Duration(seconds: 1),() { delete(set); });
  }

  Future<void> addCard(FlashcardSet set, String frontValue, String backValue,
      bool frontMultipleValues, bool backMultipleValues, bool canBeReversed) async {
    CardSide front = CardSide(ObjectId(), frontValue, '', allowMultipleValues:frontMultipleValues);
    CardSide back = CardSide(ObjectId(), backValue, '', allowMultipleValues:backMultipleValues);
    Flashcard newCard = Flashcard(ObjectId(), front: front, back: back, canBeReversed: canBeReversed);

    realm.write(() => {
      set.cards.add(newCard),
    });
  }

  Future<void> deleteCard(FlashcardSet set, Flashcard card) async {
    realm.write(() => {
      set.cards.remove(card),
    });
  }

  Future<void> update(FlashcardSet set,
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

  void updateSettings(FlashcardSet set, {bool? lenientMode, int? guessSide, bool? getAllAnswersRight, int? studyMethod, bool? repeatUntilKnown}){
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

  void updateLastStudyDate(FlashcardSet set){
    realm.write(() {
      set.lastStudyDate = DateTime.now().toUtc();
    });
    notifyListeners();
  }

  void reportSet(FlashcardSet set, ReportMessage reportMessage) {
    realm.writeAsync(() {
      set.reportCount += 1;
      set.lastReport = reportMessage;
    });
  }

  void likeSet(FlashcardSet set, bool like) {
    realm.writeAsync(() {
        set.likes += like ? 1 : -1;
    });
  }

  FlashcardSet? get(String id) {
    final sets = realm.query<FlashcardSet>(r'_id == $0', [ObjectId.fromHexString(id)]);

    if(sets.isEmpty){
      return null;
    } else {
      return sets.first;
    }
  }

  Future<List<FlashcardSet>> getAll(String userId) async {
    return realm.query<FlashcardSet>(r'owner_id == $0', [userId]).toList();
  }

  Future<FlashcardSet?> getAsync(String id, { bool public = false }) async {
    final sets = realm.query<FlashcardSet>(r'_id == $0', [ObjectId.fromHexString(id)]);
    _realmServices.isWaiting = false;

    if(sets.isEmpty){
      return null;
    } else {
      return sets.first;
    }
  }
}