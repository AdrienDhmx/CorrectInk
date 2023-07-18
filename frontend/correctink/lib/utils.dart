import 'dart:io';

import 'package:correctink/localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:localization/localization.dart';

class Utils{
  static bool isOnPhone(){
    return Platform.isAndroid || Platform.isIOS;
  }
}

extension DateComparison on DateTime  {
  bool isToday(){
    toLocal();
    final now = DateTime.now().toLocal();

    return year == now.year &&
        month == now.month &&
        day == now.day;
  }

  bool isNotToday(){
    toLocal();
    final now = DateTime.now().toLocal();

    return year != now.year ||
        month != now.month ||
        day != now.day;
  }

  bool isYesterday(){
    DateTime now = DateTime.now();
    DateTime tomorrow = now.add(const Duration(days: -1));

    return year == tomorrow.year &&
        month == tomorrow.month &&
        day == tomorrow.day;
  }

  bool isTomorrow(){
      DateTime now = DateTime.now();
      DateTime tomorrow = now.add(const Duration(days: 1));

      return year == tomorrow.year &&
          month == tomorrow.month &&
          day == tomorrow.day;
  }

  String format({String? formatting, String? prefix}){
    return '${prefix?? ''}${DateFormat(formatting ?? 'yyyy-MM-dd – kk:mm', LocalizationProvider.locale.languageCode).format(this)}';
  }

  Color getDeadlineColor(BuildContext context, bool completed, {Color? defaultColor}){
    DateTime now = DateTime.now();
    if(isBefore(now) && !completed){
      return Theme.of(context).colorScheme.error;
    } else if(isToday()){
      return Theme.of(context).colorScheme.primary;
    }
    return defaultColor ?? Theme.of(context).colorScheme.onBackground;
  }
  TextStyle? getDeadlineStyle(BuildContext context, bool completed, {Color? defaultColor}){
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
    return TextStyle(
      color: defaultColor
    );
  }

  String getWrittenFormat({String? formatting, String? prefix}){
    if(isToday()){
        return "${"Today".i18n()} - ${DateFormat('kk:mm').format(this)}";
    } else if(isTomorrow()){
        return "${"Tomorrow".i18n()} - ${DateFormat('kk:mm').format(this)}";
    } else if(isYesterday()){
        return "${"Yesterday".i18n()} - ${DateFormat('kk:mm').format(this)}";
    }
    return format(formatting: formatting);
  }
}
