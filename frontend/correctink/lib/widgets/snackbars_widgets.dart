import 'package:correctink/widgets/widgets.dart';
import 'package:flutter/material.dart';


extension ShowSnack on SnackBar {
  void show(BuildContext context, {int durationInSeconds = 5}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(this);
    Future.delayed(Duration(seconds: durationInSeconds)).then((value) {
      if(context.mounted) ScaffoldMessenger.of(context).hideCurrentSnackBar();
    });
  }
}

SnackBar infoMessageSnackBar(BuildContext context, String message) {
  return defaultSnackBar(context,
      content: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: snackBarDecoration(),
        child: Text(message,style: infoTextStyle(context, bold: true), textAlign: TextAlign.start),
      )
  );
}

SnackBar errorMessageSnackBar(BuildContext context, String title, String message) {
  return defaultSnackBar(context,
    background: ElevationOverlay.applySurfaceTint(Theme.of(context).colorScheme.surface, Theme.of(context).colorScheme.error, 5),
    content: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: snackBarDecoration(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: errorTextStyle(context, bold: true)),
            const SizedBox(height: 8,),
            Text(message, textAlign: TextAlign.center, style: errorTextStyle(context)),
          ],
        )),
  );
}

SnackBar studyStreakMessageSnackBar(BuildContext context, String title, String message) {
  return SnackBar(
      behavior: SnackBarBehavior.floating,
      elevation: 1,
      backgroundColor: ElevationOverlay.applySurfaceTint(Theme.of(context).colorScheme.tertiaryContainer, Theme.of(context).colorScheme.primary, 4),
      margin: const EdgeInsets.all(20),
      dismissDirection: DismissDirection.vertical,
      content: Container(
          padding: const EdgeInsets.all(16),
          decoration: studyStreakBoxDecoration(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.school_rounded, size: 20, color: Theme.of(context).colorScheme.onTertiaryContainer,),
                  const SizedBox(width: 8,),
                  Text(title, style: studyStreakTextStyle(context, title: true)),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: Text(message, textAlign:TextAlign.start, style: studyStreakTextStyle(context)),
              ),
            ],
          )));
}

SnackBar defaultSnackBar(BuildContext context, {required Widget content, Color? background}){
  return SnackBar(
      behavior: SnackBarBehavior.floating,
      elevation: 2,
      backgroundColor: background?? ElevationOverlay.applySurfaceTint(Theme.of(context).colorScheme.surface, Theme.of(context).colorScheme.surfaceTint, 4),
      margin: const EdgeInsets.all(16),
      dismissDirection: DismissDirection.vertical,
      content: content,
      );
}