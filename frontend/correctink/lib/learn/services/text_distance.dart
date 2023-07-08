
import 'dart:math';

class TextDistance {
  static int distance(String str1,  String str2){
    final int lengthDiff = (str1.length - str2.length).abs();

    int distance = levenshteinDistance(str1, str2);
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

  static int hammingDistance(String str1, String str2) {
    int distance = 0;
    for (int i = 0; i < str1.length; i++){
      if (str1[i] != str2[i]) {
        distance++;
      }
    }

    return distance;
  }

  static int levenshteinDistance(String str1, String str2){
    List<List<int>> distance = <List<int>>[];

    for (var i = 0; i < 10; i++) {
      List<int> list = <int>[];

      for (var j = 0; j < 10; j++) {
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

  static String addStringToString(String str, String addString, {int repeat = 1}){
    for(int i = 0; i < repeat; i++){
      str += addString;
    }
    return str;
  }
}