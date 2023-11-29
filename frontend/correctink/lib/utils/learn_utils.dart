import 'dart:math';

import 'package:correctink/app/services/theme.dart';
import 'package:correctink/utils/text_distance.dart';
import 'package:correctink/utils/utils.dart';
import 'package:flutter/material.dart';

import '../app/data/models/schemas.dart';
import '../app/data/models/learning_models.dart';
import '../app/screens/learn_page.dart';

enum SideToGuessEnum {
  back,
  front,
  random,
  spacedRepetition,
}

extension FlashcardsUtils on Flashcard {
  DateTime getNextStudyDate() {
    if(back!.lastKnowDate == null && (front!.lastKnowDate == null || !canBeReversed)) {
      DateTime.now().toDateOnly();
    }

    if(back!.lastKnowDate == null) {
      return front!.lastKnowDate!.nextStudyDate(front!.currentBox).toDateOnly();
    } else if(front!.lastKnowDate == null) {
      return back!.lastKnowDate!.nextStudyDate(back!.currentBox).toDateOnly();
    }

    DateTime frontNextStudyDate = front!.lastKnowDate!.nextStudyDate(front!.currentBox).toDateOnly();
    DateTime backNextStudyDate = back!.lastKnowDate!.nextStudyDate(back!.currentBox).toDateOnly();
    return backNextStudyDate.isAfter(frontNextStudyDate) ? frontNextStudyDate : backNextStudyDate;
  }

  CardSide? getNextCardSideToStudy() {
    if(canBeReversed) {
      bool canReviewBack = canBackBeReviewed();
      bool canReviewFront = canFrontBeReviewed();

      if(canReviewFront && canReviewBack) {
        if(back!.lastKnowDate == null) {
          return back!;
        } else if(front!.lastKnowDate == null) {
          return front!;
        }
        DateTime frontNextStudyDate = front!.lastKnowDate!.nextStudyDate(front!.currentBox).toDateOnly();
        DateTime backNextStudyDate = back!.lastKnowDate!.nextStudyDate(back!.currentBox).toDateOnly();
        return backNextStudyDate.isAfter(frontNextStudyDate) ? front : back;
      } else if(canReviewFront) {
        return front;
      } else if(canReviewBack) {
        return back;
      }
      return null;
    }

    return canBackBeReviewed() ? back : null;
  }

  bool canBackBeReviewed() {
    return back!.lastKnowDate == null ||
        back!.lastKnowDate!.nextStudyDate(back!.currentBox).isBeforeOrToday();
  }

  bool canFrontBeReviewed() {
    return canBeReversed && (front!.lastKnowDate == null ||
        front!.lastKnowDate!.nextStudyDate(front!.currentBox).isBeforeOrToday());
  }

  Color currentBoxColor() {
    return LearnUtils.getBoxColor(currentBox);
  }
}

class LearnUtils{
  static const lowestBox = 1;
  static const highestBox = 10;

  static const multipleValuesSeparator = ',';
  static const secondaryValuesSeparator = '/';

  static const knowBoxChange = 1;
  static const dontKnowBoxChange = -2;

  static final random = Random(DateTime.now().millisecondsSinceEpoch);

  static double get biggestFontSizeForCards => Utils.isOnPhone() ? 30 : 34;

  static Color getBoxColor(int box){
    if(box == 0) return Colors.transparent;

    if(box < 6){
      if(box < 4){
        if(box == 1){ // 1
          return HexColor.fromHex("#ea2d1f");
        } else { // 2 & 3
          return HexColor.fromHex("#e75c00");
        }
      } else { // 4 & 5
        return HexColor.fromHex("#da8200");
      }
    } else {
      if(box < 8){ // 6 & 7
        return HexColor.fromHex("#c1a400");
      } else if(box <= 9){ // 8 & 9
        return HexColor.fromHex("#84d000");
      }
      // 10
      return HexColor.fromHex("#1fea2d");
    }
  }

  static int getMeanBox(List<Flashcard> cards){
    if(cards.isEmpty) return 0;

    int total = 0;

    for(Flashcard card in cards){
      total += card.currentBox;
    }

    return (total/cards.length).round();
  }

  static int getNextBox(int currentBox, bool know){
    if(know){
      currentBox = currentBox + knowBoxChange;
      return currentBox <= highestBox ? currentBox : highestBox;
    } else {
      currentBox = currentBox + dontKnowBoxChange;
      return currentBox >= lowestBox ? currentBox : lowestBox;
    }
  }

  static int daysPerBox(int box){
    if(box <= 2){
      return 0;
    }

    // increase more and more the number of days between the boxes
    // box => days before showing card again
    // 3 => 1
    // 4 => 2
    // 5 => 4
    // 6 => 8
    // 7 => 16
    // 8 => 32
    // 9 => 64
    // 10 => 128
    return pow(2, box - 3).toInt();
  }

  static List<CardToStudy> getCardsToStudy(List<Flashcard> cards,
      {int studyMethod = 0, SideToGuessEnum sideToGuess = SideToGuessEnum.back}){
    List<CardToStudy> learningCards = <CardToStudy>[];

    if(studyMethod == 1) { // spaced repetition
      for(int i = 0; i < cards.length; i++){
        Flashcard card = cards[i];
        bool canBackBeReviewed = card.canBackBeReviewed();
        bool canFrontBeReviewed = card.canFrontBeReviewed();
        // pick the side that needs to be studied first
        if(sideToGuess == SideToGuessEnum.spacedRepetition) {
          CardSide? sideToStudy = card.getNextCardSideToStudy();
          if(sideToStudy != null) {
            if(sideToStudy.value == card.backValue) {
              learningCards.add(CardToStudy(card.frontValue, card.backValue, i, true));
            } else {
              learningCards.add(CardToStudy(card.backValue, card.frontValue, i, false));
            }
          }
        } else if(sideToGuess == SideToGuessEnum.random) { // random
          if(canBackBeReviewed && canFrontBeReviewed) {
            if(random.nextBool()) {
              learningCards.add(CardToStudy(card.frontValue, card.backValue, i, true));
            } else {
              learningCards.add(CardToStudy(card.backValue, card.frontValue, i, false));
            }
          } else if(canBackBeReviewed){
            learningCards.add(CardToStudy(card.frontValue, card.backValue, i, true));
          } else {
            learningCards.add(CardToStudy(card.backValue, card.frontValue, i, false));
          }
        } else if(sideToGuess == SideToGuessEnum.back && canBackBeReviewed) { // guess back
          learningCards.add(CardToStudy(card.frontValue, card.backValue, i, true));
        } else if(sideToGuess == SideToGuessEnum.front && canFrontBeReviewed) { // guess front
          learningCards.add(CardToStudy(card.backValue, card.frontValue, i, false));
        }
      }
    } else {
      for(int i = 0; i < cards.length; i++){
        Flashcard card = cards[i];
        if(sideToGuess == SideToGuessEnum.back) {
          learningCards.add(CardToStudy(card.frontValue, card.backValue, i, true));
        } else if(card.canBeReversed) {
          if(sideToGuess == SideToGuessEnum.front) {
            learningCards.add(CardToStudy(card.backValue, card.frontValue, i, false));
          } else { // random
            if(random.nextBool()) {
              learningCards.add(CardToStudy(card.frontValue, card.backValue, i, true));
            } else {
              learningCards.add(CardToStudy(card.backValue, card.frontValue, i, false));
            }
          }
        }
      }
    }

    return learningCards;
  }

  static (int, int) getRatio(List<Flashcard> cards){
    if(cards.isEmpty) return (0, 0);
    int know = 0;
    int dontKnow = 0;

    for(Flashcard card in cards){
     know += card.knowCount;
     dontKnow += card.dontKnowCount;
    }

    return (know, dontKnow);
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

  static LearningWrittenReport checkWrittenAnswer({required String userInput, required String correctAnswer, required bool getAllAnswersRight, required lenientMode}){
    LearningWrittenReport report = LearningWrittenReport();
    bool isUserInputCorrect = true;
    List<int> foundAnswers = <int>[];
    List<String> wrongAnswers = <String>[];

    correctAnswer = correctAnswer.trim().toLowerCase();
    userInput = userInput.trim(); // keep the case

    bool correctAnswerHasMultipleValues = false;
    String correctAnswerSeparator = '';
    (correctAnswerHasMultipleValues, correctAnswerSeparator) = hasMultipleValues(correctAnswer);

    if(correctAnswerHasMultipleValues){
      bool inputHasMultipleValues  = false;
      String inputMultipleValuesSeparator = '';
      (inputHasMultipleValues, inputMultipleValuesSeparator) = hasMultipleValues(userInput);

      final correctValues = correctAnswer.split(correctAnswerSeparator);
      final userSeparatedInput = inputHasMultipleValues ? userInput.split(inputMultipleValuesSeparator) : <String>[userInput];

      // trim all correct values to compare them to the user inputs afterward
      for (int i = 0; i < correctValues.length; i++) {
        correctValues[i] = correctValues[i].trim(); // already lower case
      }

      // loop through all correct answers to compare them with the user's answers
      for(int i = 0; i < correctValues.length; i++){
        // all user answers have been verified
        if(i == userSeparatedInput.length) {
          if(getAllAnswersRight) {  // missing answers
            report.distance = 100;
          }
          break;
        }

        String userInputElement = userSeparatedInput[i].trim().toLowerCase(); // need lower case for comparison
        final index = correctValues.indexOf(userInputElement);

        // exact match AND the string that matched has not already been found
        if(index != -1 && !foundAnswers.contains(index)){
          // exact match => distance is 0
          foundAnswers.add(index);
          report.payload.add(ReportPayload(userSeparatedInput[i], true));
        } else {
          // even if lenient is disabled calculate the best distance
          // init min distance against first correct value
          LearningWrittenReport tempReport = TextDistance.calculateDistance(correctValues[0], userInputElement);
          int minDistanceIndex = 0;
          for(int j = 1; j < correctValues.length; j++){
            LearningWrittenReport newTempReport = TextDistance.calculateDistance(correctValues[j], userInputElement);

            // update the min distance is smaller found
            if(tempReport.distance > newTempReport.distance){
              tempReport = newTempReport;
              minDistanceIndex = j;
            }
          }

          bool accepted = false;
          if(!foundAnswers.contains(minDistanceIndex)){
            // update the max distance found
            if(report.distance < tempReport.distance) {
              report.distance = tempReport.distance;
            }

            // only way to change accepted is here with lenient mode enabled
            if(lenientMode) {
              accepted = tempReport.distance <= 1;
            }
          }
          report.noError = accepted;

          // answer is wrong
          if(!accepted){
            if(getAllAnswersRight) { // all the answer are not correct as required per the set's settings
              isUserInputCorrect = false;
            }

            wrongAnswers.add(userInputElement);  // add the wrong input to the list
            if(tempReport.payload.isNotEmpty) {
              report.payload.addAll(tempReport.payload);
            } else {
              report.payload.add(ReportPayload(userSeparatedInput[i], false));
            }
          } else {
            foundAnswers.add(minDistanceIndex);
            if(tempReport.payload.isNotEmpty) {
              report.payload.addAll(tempReport.payload);
            } else {
              report.payload.add(ReportPayload(userSeparatedInput[i], true));
            }
          }
        }

        if(i < userSeparatedInput.length - 1 && i < correctValues.length - 1) {
          report.payload.add(ReportPayload(', ', true)); // add a separator between answers
        }
      }

      if(getAllAnswersRight) {
        isUserInputCorrect = foundAnswers.length == correctValues.length;
        report.noError = isUserInputCorrect;
      }

    } else {
      report = TextDistance.calculateDistance(correctAnswer, userInput);
      isUserInputCorrect = _checkDistance(correctAnswer, userInput, report.distance, lenientMode);
      report.noError = report.distance == 0;

      if(report.payload.isEmpty) {
        if(report.noError){
          report.payload.add(ReportPayload(userInput, true));
        } else {
          report.payload.add(ReportPayload(userInput, false));
        }
      }
    }
    report.correct = isUserInputCorrect; // conclude
    return report;
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