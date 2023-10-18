import 'package:correctink/app/services/theme.dart';
import 'package:flutter/material.dart';

enum MessageIcons{
  none(type: -1),
  congrats(type: 0),
  notes(type: 1),
  tip(type: 2),
  person(type: 3),
  release(type: 4),
  chat(type: 5),
  mail(type: 6);

  const MessageIcons({required this.type});

  final int type;
}

enum MessageDestination {
  everyone(destination: 0, name: "Everyone"),
  moderator(destination: 8, name: "Moderator"),
  admin(destination: 10, name: "Admin");

  const MessageDestination({required this.destination, required this.name});

  final int destination;
  final String name;
}

class MessageHelper {
  static Icon getIcon(int type, Color? color, {bool big = false}) {
    double size = big ? 32 : 22;
    switch (type) {
      case -1:
        return Icon(Icons.not_interested_rounded, color: color, size: size,);
      case 0:
        return Icon(Icons.celebration_rounded, color: color, size: size,);
      case 1:
        return Icon(Icons.notes_rounded, color: ThemeProvider.whiskey, size: size,);
      case 2:
        return Icon(Icons.tips_and_updates_rounded, color: ThemeProvider.tacha, size: size,);
      case 3:
        return Icon(Icons.person_rounded, color: ThemeProvider.moodyBlue, size: size,);
      case 4:
        return Icon(Icons.new_releases_rounded, color: ThemeProvider.chestnutRose, size: size,);
      case 5:
        return Icon(Icons.chat_rounded, color: ThemeProvider.azure, size: size,);
      case 6:
        return Icon(Icons.mail_rounded, color: ThemeProvider.japaneseLaurel, size: size,);
      default:
        return Icon(Icons.mail_rounded, color: ThemeProvider.japaneseLaurel, size: size,);
    }
  }
}