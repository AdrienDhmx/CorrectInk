import 'dart:io';

import 'package:intl/intl.dart';

class Utils{
  static bool isOnPhone(){
    return Platform.isAndroid || Platform.isIOS;
  }
  //extension ShowSnack on SnackBar {

}

extension DateComparison on DateTime  {
  bool isToday(){
    final utc = toUtc();
    final dateUtc = DateTime.now().toUtc();

    return utc.year == dateUtc.year && utc.month == dateUtc.month && utc.day == dateUtc.day;
  }

  bool isNotToday(){
    final utc = toUtc();
    final dateUtc = DateTime.now().toUtc();

    return utc.year != dateUtc.year || utc.month != dateUtc.month || utc.day != dateUtc.day;
  }

  bool isYesterday(){
    final utc = toUtc();
    final dateUtc = DateTime.now().toUtc();

    return utc.year == dateUtc.year && utc.month == dateUtc.month && utc.day == dateUtc.day - 1;
  }

  String format(){
    return DateFormat('yyyy-MM-dd – kk:mm').format(this);
  }
}
