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

snackBarDecoration({double radius = 4}) {
  return BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(radius)));
}

snackBarTextStyle(BuildContext context, {bool title = false, Color? color}) {
  return TextStyle(
      color: color ?? Theme.of(context).colorScheme.onPrimaryContainer,
      fontSize: title ? 20 : 16,
      fontWeight: title ? FontWeight.normal : FontWeight.w500
  );
}

SnackBar infoMessageSnackBar(BuildContext context, String message) {
  return snackBar(context,
    message,
    icon: Icons.info_rounded,
    background: ElevationOverlay.applySurfaceTint(Theme.of(context).colorScheme.surface, Theme.of(context).colorScheme.surfaceTint, 2),
    color: Theme.of(context).colorScheme.onSurfaceVariant,
  );
}

SnackBar successMessageSnackBar(BuildContext context, String title, {String? description, IconData? icon}) {
  return snackBar(context,
    title,
    description: description,
    icon: icon,
  );
}

SnackBar errorMessageSnackBar(BuildContext context, String title, String message) {
  return snackBar(context,
    title,
    description: message,
    icon: Icons.error_rounded,
    background: ElevationOverlay.applySurfaceTint(Theme.of(context).colorScheme.surface, Theme.of(context).colorScheme.error, 5),
    color: Theme.of(context).colorScheme.error,
  );
}

SnackBar studyStreakMessageSnackBar(BuildContext context, String title, String message) {
  return snackBar(context,
      title,
      description: message,
      icon: Icons.school_rounded,
      background: ElevationOverlay.applySurfaceTint(Theme.of(context).colorScheme.tertiaryContainer, Theme.of(context).colorScheme.primary, 4),
      color: Theme.of(context).colorScheme.onTertiaryContainer,
  );
}

SnackBar snackBar(BuildContext context, String title, {String? description, IconData? icon, Color? background, Color? color}) {
  Color bgColor = background ?? ElevationOverlay.applySurfaceTint(Theme.of(context).colorScheme.primaryContainer, Theme.of(context).colorScheme.primary, 4);
  Color foreground = color ?? Theme.of(context).colorScheme.onPrimaryContainer;
  return SnackBar(
      behavior: SnackBarBehavior.floating,
      elevation: 1,
      backgroundColor: bgColor,
      margin: const EdgeInsets.all(16),
      dismissDirection: DismissDirection.vertical,
      content: Container(
          padding: const EdgeInsets.all(8),
          decoration: snackBarDecoration(radius: description == null ? 4 : 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if(icon != null) ...[
                    Icon(icon, size: 20, color: foreground,),
                    const SizedBox(width: 8,),
                  ],
                  Flexible(child: Text(title, style: snackBarTextStyle(context, title: true, color: color))),
                ],
              ),
              if(description != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6.0),
                  child: Flexible(child: Text(description, textAlign:TextAlign.start, style: snackBarTextStyle(context, color: color))),
                ),
            ],
          )
      )
  );
}