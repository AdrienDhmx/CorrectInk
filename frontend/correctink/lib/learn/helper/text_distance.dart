
import 'dart:math';

import 'package:flutter/foundation.dart';

class TextDistance {
  static int calculateDistance(String str1,  String str2){
    const int wordCountCosineThreshold = 6;
    final int lengthDiff = (str1.length - str2.length).abs();
    final int str1WordCount = str1.split(' ').length;
    final int str2WordCount = str2.split(' ').length;
    int distance = 0;
    double cosineD = 0;

    if(str1WordCount > wordCountCosineThreshold || str2WordCount > wordCountCosineThreshold){
      cosineD = cosineDistance(str1, str2);
      if (kDebugMode) {
        print('cosine distance: $cosineD');
      }
      distance = (cosineD * 10).round();

      // cosine distance ignore the order of the words, it only calculates how often the words appear in each string and compare them
      // so if the words have similar appearance rate we need check for their order
      if(distance <= 1) {
        List<String> str1Words = wordsInString(str1);
        List<String> str2Words = wordsInString(str2);

        int orderDistance = levenshteinWordDistance(str1Words, str2Words);
        if (kDebugMode) {
          print(' levenshtein word distance: $orderDistance');
        }

        if((str1Words.length - str2Words.length).abs() > 1){
          return orderDistance;
        } else {
          // fix the 1 word count dif by adding a space at end of the shorter list
          if(str1Words.length > str2Words.length){
            str2Words.add(' ');
          } else if(str2Words.length > str1Words.length) {
            str1Words.add(' ');
          }

          return min(orderDistance, hammingWordDistance(str1Words, str2Words));
        }
      } else {
        return distance;
      }

    } else {
      distance = levenshteinDistance(str1, str2);
      if(lengthDiff > 1){
        return distance;
      } else {
        // fix the 1 letter count dif by adding a space at end of the shorter word
        if(str1.length > str2.length){
          str2 += ' ';
        } else if(str2.length > str1.length) {
          str1 += ' ';
        }

        return min(distance, hammingDistance(str1, str2));
      }
    }

  }

  static int hammingDistance(String str1, String str2) {
    int distance = 0;
    for (int i = 0; i < str1.length; i++){
      if (str1[i] != str2[i]) {
        distance++;
      }
    }

    return distance;
  }

  static int hammingWordDistance(List<String> str1, List<String> str2) {
    int distance = 0;
    for (int i = 0; i < str1.length; i++){
      if (str1[i] != str2[i]) {
        distance += calculateDistance(str1[i], str2[i]) - 1;
      }
    }

    return distance;
  }

  static int levenshteinDistance(String str1, String str2){
    List<List<int>> distance = <List<int>>[];

    for (var i = 0; i <= str1.length; i++) {
      List<int> list = <int>[];

      for (var j = 0; j <= str2.length; j++) {
        list.add(0);
      }

      distance.add(list);
    }

    for (int i = 0; i <= str1.length; i++) {
      distance[i][0] = i;
    }
    for (int j = 0; j <= str2.length; j++) {
      distance[0][j] = j;
    }

    for (int j = 1; j <= str2.length; j++)
    {
      for (int i = 1; i <= str1.length; i++)
      {
        if (str1[i - 1] == str2[j - 1]) {
          distance[i][j] = distance[i - 1][j - 1];
        } else {
          distance[i][j] = min(
              min(
                  distance[i - 1][j] + 1, // deletion (forgot a letter ?)
                  distance[i][j - 1] + 2 // insertion (count more since it's less likely to be unintentional
              ),
              distance[i - 1][j - 1] + 1 // substitution (mistype ?)
          );
        }
      }
    }

    // Return the minimum edit distance
    return distance[str1.length][ str2.length];
  }

  static int levenshteinWordDistance(List<String> str1, List<String> str2){
    List<List<int>> distance = <List<int>>[];

    for (var i = 0; i <= str1.length; i++) {
      List<int> list = <int>[];

      for (var j = 0; j <= str2.length; j++) {
        list.add(0);
      }

      distance.add(list);
    }

    for (int i = 0; i <= str1.length; i++) {
      distance[i][0] = i;
    }
    for (int j = 0; j <= str2.length; j++) {
      distance[0][j] = j;
    }

    for (int j = 1; j <= str2.length; j++)
    {
      for (int i = 1; i <= str1.length; i++)
      {
        if (str1[i - 1] == str2[j - 1]) {
          distance[i][j] = distance[i - 1][j - 1];
        } else {
          distance[i][j] = min(
              min(
                  distance[i - 1][j] + str1[i - 1].length > 4 ? 4 : 1, // deletion, if the word is more than 4 letters long
                                                                      // then it's an important word
                  distance[i][j - 1] + str2[j - 1].length > 4 ? 4 : 1  // insertion, if the word is more than 4 letters long
                                                                      // then it's an important word
              ),
              distance[i - 1][j - 1] + (calculateDistance(str1[i - 1], str2[j - 1]) - 1)  // substitution (mistype ?), accept 1 letter wrong
          );
        }
      }
    }

    // Return the minimum edit distance
    return distance[str1.length][ str2.length];
  }



  static double cosineDistance(String str1, String str2) {
    // Create word frequency maps for each text
    Map<String, int> counter1 = _getWordFrequencies(str1);
    Map<String, int> counter2 = _getWordFrequencies(str2);

    // Get the set of all unique words in both texts
    Set<String> allWords = Set<String>.from(counter1.keys).union(Set<String>.from(counter2.keys));

    // Calculate the dot product
    double dotProduct = allWords.fold(0, (sum, word) =>
    sum + (counter1[word] ?? 0) * (counter2[word] ?? 0));

    // Calculate the magnitudes
    double magnitude1 = sqrt(allWords.fold(0, (sum, word) =>
    sum + pow(counter1[word] ?? 0, 2)));
    double magnitude2 = sqrt(allWords.fold(0, (sum, word) =>
    sum + pow(counter2[word] ?? 0, 2)));

    // Calculate the cosine similarity
    double similarity = dotProduct / (magnitude1 * magnitude2);

    // Calculate the cosine distance
    double distance = 1 - similarity;

    return distance;
  }

  static Map<String, int> _getWordFrequencies(String text) {
    // split at any punctuation
    List<String> words = wordsInString(text);
    Map<String, int> counter = {};

    for (String word in words) {
      counter.update(word, (value) => value + 1, ifAbsent: () => 1);
    }

    return counter;
  }

  static List<String> wordsInString(String text){
    return text.split(RegExp(r"""[ \t\n\r.,;:!?\[\](){}<>'"\/|=_+*&^%$#@~]"""));
  }
}