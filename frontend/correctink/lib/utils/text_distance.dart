import 'dart:math';

import 'package:correctink/app/data/models/learning_models.dart';

class TextDistance {
  static LearningWrittenReport calculateDistance(String str1,  String str2){
    LearningWrittenReport report = LearningWrittenReport();
    report.payload = <ReportPayload>[];
    const int wordCountCosineThreshold = 6;
    final int lengthDiff = (str1.length - str2.length).abs();
    final int str1WordCount = str1.split(' ').length;
    final int str2WordCount = str2.split(' ').length;
    double cosineD = 0;

    // cosine distance works for sentences only
    if(str1WordCount > wordCountCosineThreshold || str2WordCount > wordCountCosineThreshold){
      cosineD = cosineDistance(str1, str2);
      report.distance = (cosineD * 10).round();

      // cosine distance ignore the order of the words, it only calculates how often the words appear in each string and compare them
      // so if the words have similar appearance rate we need to check their order
      if(report.distance <= 1) {
        List<String> str1Words = wordsInString(str1);
        List<String> str2Words = wordsInString(str2);
        report.distance = levenshteinWordDistance(str1Words, str2Words);

        // the sentences have different word count
        if((str1Words.length - str2Words.length).abs() > 1){
          return report;
        } else {
          // fix the 1 word count dif by adding a space at end of the shorter list
          if(str1Words.length > str2Words.length){
            str2Words.add(' ');
          } else if(str2Words.length > str1Words.length) {
            str1Words.add(' ');
          }
          // since the word count is similar also calculate the hamming distance
          // and return the smallest calculated distance
          final hammingReport = hammingDistance(str1, str2);
          report.distance = min(report.distance, hammingReport.distance);
          report.payload.addAll(hammingReport.payload);
          return report;
        }
      } else {
        return report;
      }
    } else {
      report.distance = levenshteinDistance(str1, str2);
      if(lengthDiff > 1){
        return report;
      } else {
        // fix the 1 letter count dif by adding a space at end of the shorter word
        if(str1.length > str2.length){
          str2 += ' ';
        } else if(str2.length > str1.length) {
          str1 += ' ';
        }

        final hammingReport = hammingDistance(str1, str2);
        report.distance = min(report.distance, hammingReport.distance);
        report.payload.addAll(hammingReport.payload);
        return report;
      }
    }

  }

  static LearningWrittenReport hammingDistance(String str1, String str2) {
    LearningWrittenReport report = LearningWrittenReport();
    report.payload = <ReportPayload>[];
    String correctLetters = '';
    bool letterMissing = str2.endsWith(' '); // text is trimmed, but ' ' added when 1 letter is missing
    bool letterMissingPassed = false; // there can only be 1 missing letter otherwise this method is not called
    for (int i = 0; i < str1.length; i++){
      if (str1[i] != str2[i]) {
        if(letterMissingPassed && (i >= str1.length - 1 || str2[i] == str1[i + 1])) {
          correctLetters += str2[i];
          continue;
        }

        report.payload.add(ReportPayload(correctLetters, true));
        correctLetters = '';

        // letter missing replace with _
        if(letterMissing && !letterMissingPassed && i < str1.length - 1 && str2[i] == str1[i + 1]) {
          report.payload.add(ReportPayload('_', false));
          correctLetters += str2[i]; // add to correct letter because it's the next correct letter
          letterMissingPassed = true;
        } else if(str2[i] == ' ') { // space where a letter should be ? replace with '_'
          report.payload.add(ReportPayload('_', false));
        } else {
          report.payload.add(ReportPayload(str2[i], false));
        }

        report.distance++;
      } else {
        correctLetters += str2[i];
      }
    }

    if(correctLetters.isNotEmpty){
      report.payload.add(ReportPayload(correctLetters, true));
    }
    return report;
  }

  static LearningWrittenReport hammingWordDistance(List<String> str1, List<String> str2) {
    LearningWrittenReport report = LearningWrittenReport();
    report.payload = <ReportPayload>[];
    for (int i = 0; i < str1.length; i++){
      if (str1[i] != str2[i]) {
        LearningWrittenReport newReport = calculateDistance(str1[i], str2[i]);
        report.distance += newReport.distance - 1;
        report.payload.addAll(newReport.payload);
      }
    }

    return report;
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
                  distance[i][j - 1] + 1 // insertion (typed 2 keys at the same time ?)
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
              distance[i - 1][j - 1] + (calculateDistance(str1[i - 1], str2[j - 1]).distance - 1)  // substitution (mistype ?), accept 1 letter wrong
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
    double dotProduct = allWords.fold(0, (sum, word) => sum + (counter1[word] ?? 0) * (counter2[word] ?? 0));

    // Calculate the magnitudes
    double magnitude1 = sqrt(allWords.fold(0, (sum, word) => sum + pow(counter1[word] ?? 0, 2)));
    double magnitude2 = sqrt(allWords.fold(0, (sum, word) => sum + pow(counter2[word] ?? 0, 2)));

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