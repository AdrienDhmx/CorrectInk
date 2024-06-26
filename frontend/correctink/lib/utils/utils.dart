import 'dart:io';

import 'package:correctink/app/services/theme.dart';
import 'package:http/http.dart' as http;
import 'package:correctink/blocs/tasks/reminder_widget.dart';
import 'package:correctink/app/services/localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:localization/localization.dart';

import '../app/data/models/schemas.dart';
import 'learn_utils.dart';

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

  static bool isURL(String input) {
    final regex = RegExp(
      r'^(http|https|ftp)://[^\s/$.?#].[^\s]*$',
      caseSensitive: false,
    );
    return regex.hasMatch(input);
  }

  static Future<bool> validateImage(String imageUrl) async {
    http.Response res;
    try {
      res = await http.get(Uri.parse(imageUrl));
    } catch (e) {
      return false;
    }

    if (res.statusCode != 200) return false;
    Map<String, dynamic> data = res.headers;
    return _checkIfImage(data['content-type']);
  }

  static bool _checkIfImage(String param) {
    if (param == 'image/jpeg' || param == 'image/png' || param == 'image/gif') {
      return true;
    }
    return false;
  }
}

extension IterableModifier<E> on Iterable<E> {
  E? firstWhereOrNull(bool Function(E) test) =>
      cast<E?>().firstWhere((v) => v != null && test(v), orElse: () => null);
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
  String toTitleCase() {
    return replaceAll(RegExp(' +'), ' ').split(' ').map((str) => str.capitalize()).join(' ');
  }
}

extension SetExtension on FlashcardSet {
  Color getColor(BuildContext context, {Color? defaultColor}) {
    return color == null ? defaultColor ?? Theme.of(context).colorScheme.surface : HexColor.fromHex(color!);
  }
}

extension DateComparison on DateTime  {
  bool equal(DateTime date) {
    return year == date.year &&
           month == date.month &&
           day == date.day;
  }

  bool isToday(){
    return toUtc().equal(DateTime.now().toUtc());
  }

  bool isNotToday(){
    return !isToday();
  }
  bool isYesterday(){
    return toUtc().equal(DateTime.now().add(const Duration(days: -1)).toUtc());
  }
  bool isTomorrow(){
    return toUtc().equal(DateTime.now().add(const Duration(days: 1)).toUtc());
  }
  bool isBeforeOrToday(){
    return toDateOnly().difference(DateTime.now().toDateOnly()).inDays <= 0;
  }

  DateTime toDateOnly() {
    return DateTime(year, month, day);
  }

  bool isBeforeToday(){
    return toDateOnly().difference(DateTime.now().toDateOnly()).inDays < 0;
  }

  DateTime nextStudyDate(int currentBox) {
    return toDateOnly().add(Duration(days: LearnUtils.daysPerBox(currentBox))).toLocal();
  }

  TextStyle getDeadlineStyle(BuildContext context,bool completed, {Color? defaultColor}){
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
    } else if(isTomorrow()){
      return TextStyle(
          color: Theme.of(context).colorScheme.tertiary,
          fontWeight: FontWeight.w600
      );
    }
    return TextStyle(
        color: defaultColor ?? Theme.of(context).colorScheme.onSurface,
        fontWeight: FontWeight.w500
    );
  }

  TextStyle getReminderStyle(BuildContext context, {Color? defaultColor}){
    if(isToday()){
      if(isBefore(DateTime.now())) {
        return TextStyle(
            color: Theme.of(context).colorScheme.primary.withAlpha(160),
            fontWeight: FontWeight.normal
        );
      } else {
        return TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w600
        );
      }
    } else if(isTomorrow()){
      return TextStyle(
          color: Theme.of(context).colorScheme.tertiary,
          fontWeight: FontWeight.w600
      );
    }
    return TextStyle(
        color: defaultColor ?? Theme.of(context).colorScheme.onSurface,
        fontWeight: FontWeight.w500
    );
  }

}

extension FormatDate on DateTime {
  String format({String? formatting, String? prefix}){
    return '${prefix?? ''}${DateFormat(formatting ?? 'yyyy-MM-dd – kk:mm', LocalizationProvider.locale.languageCode).format(this)}';
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

  String getFullWrittenDate() {
    final DateFormat dateFormat = DateFormat.yMMMMEEEEd(LocalizationProvider.locale.languageCode);

    return dateFormat.format(this).toTitleCase();
  }
}
