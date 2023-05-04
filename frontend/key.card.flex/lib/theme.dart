import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:key_card/config.dart';
import 'package:key_card/themes/blue_theme.dart';
import 'package:key_card/themes/default_theme.dart';

headerFooterBoxDecoration(BuildContext context, bool isHeader) {
  final theme = Theme.of(context);
  return BoxDecoration(
    color: theme.colorScheme.surfaceVariant,
    border: Border(
        top: isHeader
            ? BorderSide.none
            : BorderSide(width: 2, color: theme.primaryColor),
        bottom: isHeader
            ? BorderSide(width: 2, color: theme.primaryColor)
            : BorderSide.none),
  );
}

errorBoxDecoration(BuildContext context) {
  final theme = Theme.of(context);
  return BoxDecoration(
      border: Border.all(color: theme.colorScheme.error),
      color: theme.colorScheme.errorContainer,
      borderRadius: const BorderRadius.all(Radius.circular(8)));
}

infoBoxDecoration(BuildContext context) {
  final theme = Theme.of(context);
  return BoxDecoration(
      border: Border.all(color: Colors.black),
      color: theme.colorScheme.background,
      borderRadius: const BorderRadius.all(Radius.circular(8)));
}

errorTextStyle(BuildContext context, {bool bold = false}) {
  final theme = Theme.of(context);
  return TextStyle(
      color: theme.colorScheme.error,
      fontWeight: bold ? FontWeight.bold : FontWeight.normal);
}

infoTextStyle(BuildContext context, {bool bold = false}) {
  return TextStyle(
      color: Colors.black,
      fontWeight: bold ? FontWeight.bold : FontWeight.normal);
}

boldTextStyle(BuildContext context) {
  return TextStyle(color: Theme.of(context).colorScheme.onBackground, fontWeight: FontWeight.bold);
}

listTitleTextStyle(){
  return const TextStyle(fontSize: 18, fontWeight: FontWeight.w500);
}

primaryTextButtonStyle(BuildContext context) {
  return ButtonStyle(
      backgroundColor: MaterialStatePropertyAll(Theme.of(context).colorScheme.primary),
      foregroundColor: MaterialStatePropertyAll(Theme.of(context).colorScheme.onPrimary),
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),)),
  );
}

surfaceTextButtonStyle(BuildContext context) {
  return ButtonStyle(
    backgroundColor: MaterialStatePropertyAll(Theme.of(context).colorScheme.surfaceVariant),
    foregroundColor: MaterialStatePropertyAll(Theme.of(context).colorScheme.onSurfaceVariant),
    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),)),
  );
}

flatTextButton(Color bgColor, Color foreground){
return TextButton.styleFrom(
    backgroundColor: bgColor,
    foregroundColor: foreground,
    minimumSize: const Size(100, 50),
    maximumSize: const Size(340, 60),
    shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(10.0)),
    ));
}

iconTextCard(IconData icon, String text){
  return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon),
        const SizedBox(width: 10.0,),
        Text(text, style: const TextStyle(fontSize: 16)),
      ]);
}

Widget backButton(BuildContext context){
  return IconButton(
    onPressed: () { GoRouter.of(context).pop(); },
    icon: const Icon(Icons.navigate_before),
  );
}

class ThemeProvider extends ChangeNotifier {

  static const Color chestnutRose = Color.fromRGBO(209, 104, 106, 1.0);
  static const Color whiskey = Color.fromRGBO(209, 170, 104, 1.0);
  static const Color moodyBlue = Color.fromRGBO(107, 104, 209, 1.0);
  static const Color downy = Color.fromRGBO(104, 191, 209, 1.0);
  static const Color emerald = Color.fromRGBO(104, 209, 126, 1.0);
  static const Color wildWillow = Color.fromRGBO(156, 209, 104, 1.0);

  static const List<Color> setColors = <Color>[ chestnutRose, whiskey, moodyBlue, downy, emerald, wildWillow, ];
  static const List<String> themes = <String>['Green', 'Blue', ];

  late String theme;
  late ThemeMode themeMode;
  bool get isDarkMode => themeMode == ThemeMode.dark;

  final AppConfigHandler appConfigHandler;

  ThemeProvider(this.appConfigHandler);

  Future<void> init() async{
    theme = await appConfigHandler.getConfigValue(AppConfigHandler.themeKey);
    bool dark = await _getThemeMode();
    themeMode = dark ? ThemeMode.dark : ThemeMode.light;
  }

  lightAppThemeData() {
   return ThemeData(
     useMaterial3: true,
     colorScheme: _getTheme(false),
     brightness: Brightness.light,
    );
  }

  darkAppThemeData() {
   return ThemeData(
     useMaterial3: true,
     colorScheme: _getTheme(true),
     brightness: Brightness.dark,
    );
  }

  void toggleTheme() {
    themeMode = isDarkMode ? ThemeMode.light : ThemeMode.dark;
    _saveThemeMode(isDarkMode);
    notifyListeners();
  }

  Future<void> changeTheme(String newTheme) async{
    if(theme == newTheme) return;

    theme = newTheme;
    appConfigHandler.setConfigValue(AppConfigHandler.themeKey, theme);
    notifyListeners();
  }

  ColorScheme _getTheme(bool dark){
    switch(theme){
      case 'Green':
        if(dark){
          return DefaultTheme.darkColorScheme;
        }
        return DefaultTheme.lightColorScheme;
      case 'Blue':
        if(dark){
          return BlueTheme.darkColorScheme;
        }else{
          return BlueTheme.lightColorScheme;
        }
      default:
        if(dark){
          return DefaultTheme.darkColorScheme;
        }
        return DefaultTheme.lightColorScheme;
    }
  }

  Future<void> _saveThemeMode(bool dark) async{
    appConfigHandler.setConfigValue(AppConfigHandler.themeModeKey, dark ? "1" : "0");
  }

  Future<bool> _getThemeMode() async{
    return (await appConfigHandler.getConfigValue(AppConfigHandler.themeModeKey)) == "1";
  }
}

extension HexColor on Color {
  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}
