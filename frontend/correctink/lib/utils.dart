import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
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

  String format({String? prefix}){
    return '${prefix?? ''}${DateFormat('yyyy-MM-dd – kk:mm').format(this)}';
  }

  TextStyle? getDeadlineStyle(BuildContext context){
    DateTime now = DateTime.now();
    if(isBefore(now)){
      return TextStyle(
          color: Theme.of(context).colorScheme.error,
          fontWeight: FontWeight.w600
      );
    } else if(isToday()){
      return TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w600
      );
    }
    return null;
  }

  String getWrittenFormat({String? prefix}){
    DateTime now = DateTime.now();
    if(isToday()){
        return "Today - ${DateFormat('kk:mm').format(this)}";
    } else if(day == now.day + 1){
        return "Tomorrow - ${DateFormat('kk:mm').format(this)}";
    } else if(day == now.day - 1){
        return "Yesterday - ${DateFormat('kk:mm').format(this)}";
    }
    return format();
  }
}
