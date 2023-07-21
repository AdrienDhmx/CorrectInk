import 'dart:math';

import 'package:correctink/learn/helper/text_distance.dart';
import 'package:correctink/realm/schemas.dart';

class LearnUtils{
  static const lowestBox = 1;
  static const highestBox = 6;

  static const multipleValuesSeparator = ',';
  static const secondaryValuesSeparator = '/';

  static const digits = <String>['1', '2', '3', '4', '5', '6', '7', '8', '9'];

  static const dontKnowBoxChange = -1;
  static const knowBoxChange = 1;

  static int getNextBox(int currentBox, bool know){
    if(know){
      currentBox = currentBox + knowBoxChange;
      return currentBox <= highestBox ? currentBox : highestBox;
    } else {
      currentBox = currentBox + dontKnowBoxChange;
      return currentBox >= lowestBox ? currentBox : lowestBox;
    }
  }

  static int daysPerBox(int box, {int? seed}){
    switch(box){
      case 1:
        return 0; // can be seen everyday
      case 2: // can be seen everyday or every 2 days
        return Random(seed ?? DateTime.now().millisecondsSinceEpoch).nextInt(box);
      case 3: // can be seen every 2 - 3 days
        return Random(seed ??DateTime.now().millisecondsSinceEpoch).nextInt(box) + 1;
      case 4: // can be seen every 4 - 6 days
        return Random(seed ??DateTime.now().millisecondsSinceEpoch).nextInt(box) + 3;
      case 5: // can be seen every 8 - 12 days
        return Random(seed ??DateTime.now().millisecondsSinceEpoch).nextInt(box) + 7;
      case 6: // can be seen every 15 - 19 days
        return Random(seed ?? DateTime.now().millisecondsSinceEpoch).nextInt(box) + 14;
    }
    return 0;
  }

  static bool shouldBeSeen(KeyValueCard card){
    final millisecondsSinceEpoch = DateTime.now().millisecondsSinceEpoch;
    final daysForCurrentBox = daysPerBox(card.currentBox, seed: millisecondsSinceEpoch);

    return card.lastKnowDate == null ||
        card.lastKnowDate!.add(Duration(days: daysForCurrentBox)).millisecondsSinceEpoch < millisecondsSinceEpoch;
  }

  static List<KeyValueCard> getLearningCards(List<KeyValueCard> cards){
    List<KeyValueCard> learningCards = <KeyValueCard>[];

    for(int i = 0; i < cards.length; i++){
      if(shouldBeSeen(cards[i])){
        learningCards.add(cards[i]);
      }
    }

    if(learningCards.isEmpty){
      return cards;
    }
    return learningCards;
  }

  static (bool, String) hasMultipleValues(String input, {String separator = multipleValuesSeparator}) {
    if(!input.contains(separator)){
      if(input.contains(secondaryValuesSeparator)){
        return hasMultipleValues(input, separator: secondaryValuesSeparator);
      }
      return (false, '');
    }

    List<String> values = input.split(separator);
    String value1 = values[0].trim();
    String value2 = values[1].trim();

    if(value1.isNotEmpty && value2.isNotEmpty){
      // if the input is a sentence then try again with a separator that's not a ,
      if(separator == multipleValuesSeparator && (value1.split(' ').length > 4 || value2.split(' ').length > 4)){
        return hasMultipleValues(input, separator: secondaryValuesSeparator);
      }
      return (true, separator);
    } else {
      return (false, separator);
    }
  }

  static (bool, int, List<String>) checkWrittenAnswer({required KeyValueCard card, required String input, required bool inputIsValue, required bool getAllAnswersRight, required lenientMode}){
    bool isUserInputCorrect = true;
    int distance = 0;
    String correctAnswer = inputIsValue ? card.back.trim().toLowerCase() : card.front.trim().toLowerCase();
    bool correctAnswerHasMultipleValues = inputIsValue ? card.allowBackMultipleValues : card.allowFrontMultipleValues;
    List<int> foundAnswers = <int>[];
    List<String> wrongAnswers = <String>[];

    if(correctAnswerHasMultipleValues){

      bool inputHasMultipleValues  = false;
      String inputMultipleValuesSeparator = '';

      (inputHasMultipleValues, inputMultipleValuesSeparator) = hasMultipleValues(input);

      String correctAnswerSeparator = '';
      (_, correctAnswerSeparator) = hasMultipleValues(correctAnswer);

      final correctValues = correctAnswer.split(correctAnswerSeparator);
      final userSeparatedInput = inputHasMultipleValues ? input.split(inputMultipleValuesSeparator) : <String>[input];

      // trim all correct values to compare them to the user inputs afterward
      for (int i = 0; i < correctValues.length; i++) {
        correctValues[i] = correctValues[i].trim().toLowerCase();
      }

      if(!inputHasMultipleValues && getAllAnswersRight){
        isUserInputCorrect = false;
        distance = 100; // over the roof
      } else {
        for(int i = 0; i < correctValues.length; i++){
          if(i == userSeparatedInput.length) {
            // missing answers
            if(getAllAnswersRight){
              distance = 100; // over the roof
            }
            break;
          }

          String userInputElement = userSeparatedInput[i].trim().toLowerCase();
          final index = correctValues.indexOf(userInputElement);

          // exact match AND the string that matched has not already been found
          if(index != -1 && !foundAnswers.contains(index)){
            // exact match => distance is 0
            print("exact match!");
            foundAnswers.add(index);
          } else {
            // even if lenient is disabled calculate the best distance
            // init min distance against first correct value
            int minDistance = TextDistance.calculateDistance(correctValues[0], userInputElement);
            int minDistanceIndex = 0;
            for(int j = 1; j < correctValues.length; j++){
              final tempDistance = TextDistance.calculateDistance(correctValues[j], userInputElement);

              // update the min distance is smaller found
              if(minDistance > tempDistance){
                minDistance = tempDistance;
                minDistanceIndex = j;
              }
            }

            bool accepted = false;
            if(!foundAnswers.contains(minDistanceIndex)){
              // update the max distance found
              if(distance < minDistance) {
                distance = minDistance;
              }

              // only way to change accepted is here with lenient mode enabled
              if(lenientMode) {
                accepted = minDistance <= 1;
              }
            }

            // answer is wrong
            if(!accepted){
              // add the index to the list
              wrongAnswers.add(userInputElement);

              // the answer was not all correct
              if(getAllAnswersRight){
                isUserInputCorrect = false;
              }
            } else {
              foundAnswers.add(minDistanceIndex);
            }

            // an answer was not correct and the total distance is already too high
            if(!isUserInputCorrect && distance > 1){
              break;
            }
          }
        }

      }

      if(!getAllAnswersRight){
        isUserInputCorrect = foundAnswers.isNotEmpty;
      }
    } else {
      distance = TextDistance.calculateDistance(correctAnswer, input);
      isUserInputCorrect = _checkDistance(correctAnswer, input, distance, lenientMode);
    }

    return (isUserInputCorrect, distance, wrongAnswers);
  }

  static bool _checkDistance(String str1, String str2, int distance, bool lenientMode){
    if(lenientMode){
      return str1 == str2 || distance <= 1;
    } else {
      return str1 == str2;
    }
  }

  static List<String> splitValues(String str1){
    bool multipleValues = false;
    String separator = '';
    (multipleValues, separator) = hasMultipleValues(str1);
    if(multipleValues){
      return str1.split(separator).toList();
    } else {
      return <String>[];
    }
  }
}