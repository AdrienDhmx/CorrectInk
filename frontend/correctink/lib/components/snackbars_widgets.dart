import 'package:flutter/material.dart';

import '../theme.dart';

extension ShowSnack on SnackBar {
  void show(BuildContext context, {int durationInSeconds = 8}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(this);
    Future.delayed(Duration(seconds: durationInSeconds)).then((value) {
      if(context.mounted) ScaffoldMessenger.of(context).hideCurrentSnackBar();
    });
  }
}

SnackBar infoMessageSnackBar(BuildContext context, String message) {
  return SnackBar(
      behavior: SnackBarBehavior.floating,
      elevation: 0,
      backgroundColor: Colors.transparent,
      margin: const EdgeInsets.only(bottom: 100.0),
      dismissDirection: DismissDirection.none,
      content: Center(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: infoBoxDecoration(context),
          child: Text(message,style: infoTextStyle(context), textAlign: TextAlign.center),
        ),
      ));
}

SnackBar errorMessageSnackBar(BuildContext context, String title, String message) {
  return SnackBar(
      behavior: SnackBarBehavior.floating,
      elevation: 0,
      backgroundColor: Colors.transparent,
      margin: const EdgeInsets.only(bottom: 100.0),
      dismissDirection: DismissDirection.vertical,
      content: Center(
        child: Container(
            padding: const EdgeInsets.all(16),
            decoration: errorBoxDecoration(context),
            child: Column(
              children: [
                Text(title, style: errorTextStyle(context, bold: true)),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(message, textAlign: TextAlign.center, style: errorTextStyle(context)),
                ),
              ],
            )),
      ));
}

SnackBar studyStreakMessageSnackBar(BuildContext context, String title, String message) {
  return SnackBar(
      behavior: SnackBarBehavior.floating,
      elevation: 0,
      backgroundColor: Colors.transparent,
      margin: const EdgeInsets.only(bottom: 50.0),
      dismissDirection: DismissDirection.vertical,
      content: Center(
        child: Container(
            padding: const EdgeInsets.all(16),
            decoration: studyStreakBoxDecoration(context),
            child: Column(
              children: [
                Text(title, style: studyStreakTextStyle(context)),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(message, textAlign:TextAlign.center, style: studyStreakTextStyle(context)),
                ),
              ],
            )),
      ));
}