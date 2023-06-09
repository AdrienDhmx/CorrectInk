import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:localization/localization.dart';

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

  TextStyle? getDeadlineStyle(BuildContext context, bool completed){
    DateTime now = DateTime.now();
    if(isBefore(now) && !completed){
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
        return "${"Today".i18n()} - ${DateFormat('kk:mm').format(this)}";
    } else if(day == now.day + 1){
        return "${"Tomorrow".i18n()} - ${DateFormat('kk:mm').format(this)}";
    } else if(day == now.day - 1){
        return "${"Yesterday".i18n()} - ${DateFormat('kk:mm').format(this)}";
    }
    return format();
  }
}
