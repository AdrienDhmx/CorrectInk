import 'dart:io';

import 'package:correctink/blocs/tasks/reminder_widget.dart';
import 'package:correctink/app/services/localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:localization/localization.dart';

class Utils{
  static bool isOnPhone(){
    return Platform.isAndroid || Platform.isIOS;
  }

  static String getRepeatString(int days){
    switch (days){
      case 0:
        return '';
      case 1:
        return RepeatMode.daily.name.i18n();
      case 7:
        return RepeatMode.weekly.name.i18n();
      case 30:
        return RepeatMode.monthly.name.i18n();
      case 365:
        return RepeatMode.yearly.name.i18n();
      default:
        return getCustomRepeat(days);
    }
  }

  static String getCustomRepeat(int days) {
    int customRepeatFactor = days;
    String time = "days".i18n();

    if(days > 7 && days % 7 == 0) {
      customRepeatFactor = (days / 7).round();
      time = "weeks".i18n();
    }

    if(days > 30 && days % 30 == 0) {
      customRepeatFactor = (days / 30).round();
      time = "months".i18n();
    }

    if(days > 365 && days % 365 == 0) {
      customRepeatFactor = (days / 365).round();
      time = "years".i18n();
    }

    return "Custom repeat".i18n([customRepeatFactor.toString(), time.i18n()]);
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

  bool isBeforeOrToday(){
    DateTime now = DateTime.now();

    if(year > now.year) return false;

    if(month > now.month) return false;

    if(day > now.day) return false;

    return true;
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
