import 'package:correctink/app/data/models/schemas.dart';
import 'package:correctink/blocs/sets/card_exist_dialog.dart';
import 'package:correctink/utils/learn_utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app/data/repositories/realm_services.dart';

class CardHelper {

  static void _onExistingCardConfirm(BuildContext context, CardExistChoice choice, {required Function create, required Function update}) {
    if(choice == CardExistChoice.cancel) {
      GoRouter.of(context).pop();
    } else if(choice == CardExistChoice.create) {
      create();
      GoRouter.of(context).pop();
    } else {
      update();
      GoRouter.of(context).pop();
    }
  }

  static void addCard(BuildContext context, {required RealmServices realmServices, required KeyValueCard card, required CardSet set}) {
    int index = set.cards.toList().indexWhere((c) => c.front.toLowerCase().trim() == card.front.toLowerCase().trim());

    if(index != -1) { // there already exist a card with the same front
      KeyValueCard foundCard = set.cards.toList()[index];
      String backAdded = findDifference(foundCard.back, card.back, foundCard.allowBackMultipleValues, card.allowBackMultipleValues);
      bool sameBack = backAdded == '';

      showDialog(context: context,
          useRootNavigator: true,
          builder: (context) {
            return CardExistDialog(card: foundCard, backAlreadyExists: sameBack, originalBack: card.back, newBack: backAdded,
                onConfirm: (choice) {
                  _onExistingCardConfirm(context, choice,
                      create: () {
                        realmServices.setCollection.addCard(set, card.front, card.back, card.allowFrontMultipleValues, card.allowBackMultipleValues);
                      },
                      update: () {
                        realmServices.cardCollection.update(foundCard, foundCard.front, '${foundCard.back}$backAdded', foundCard.allowFrontMultipleValues, true);
                      }
                    );
                }
            );
        }
      );
    } else {
      realmServices.setCollection.addCard(set, card.front, card.back, card.allowFrontMultipleValues, card.allowBackMultipleValues);
    }
  }

  static String findDifference(String card1, String card2, bool allowMultipleValues1, bool allowMultipleValues2) {
    bool multipleValues1;
    String separator1;
    bool multipleValues2;
    String separator2;

    (multipleValues1, separator1) = LearnUtils.hasMultipleValues(card1);
    (multipleValues2, separator2) = LearnUtils.hasMultipleValues(card2);

    if((multipleValues1 && allowMultipleValues1)|| (multipleValues2 && allowMultipleValues2)) {

      // the user choice is more important
      multipleValues1 = allowMultipleValues1;
      multipleValues2 = allowMultipleValues2;

      List<String> values1 = multipleValues1 ? card1.split(separator1) : [card1];
      List<String> values2 = multipleValues2 ? card2.split(separator2) : [card2];
      String separator = separator1;

      if(!multipleValues1) {
        if(multipleValues2) {
          separator = separator2;
        } else {
          bool containComa = card1.contains(",") || card2.contains(",");
          separator = card1.split(' ').length > 4 || containComa ? " ${LearnUtils.secondaryValuesSeparator}" : LearnUtils.multipleValuesSeparator;
        }
      }

      String differences = "";
      for(int i = 0; i < values2.length; i++) {
        String value2 = values2[i];
        for(String value1 in values1) {
          if(value1.toLowerCase().trim() == value2.toLowerCase().trim()) {
            i++;
            break;
          }
        }

        if(i < values2.length) {
          differences += '$separator ${values2[i].trim()}';
        }
      }
      return differences;
    } else {
      bool containComa = card1.contains(",") || card2.contains(",");
      String separator = card1.split(' ').length > 4 || containComa ? " ${LearnUtils.secondaryValuesSeparator}" : LearnUtils.multipleValuesSeparator;
      return card1.toLowerCase().trim() == card2.toLowerCase().trim() ? "" : "$separator $card2";
    }
  }
}