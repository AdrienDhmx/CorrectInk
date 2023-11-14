import 'package:flutter/material.dart';
import 'package:correctink/app/services/config.dart';

class ThemeProvider extends ChangeNotifier {

  // red is a set only color because red is used for errors in the themes
  static const Color chestnutRose = Color.fromRGBO(209, 104, 106, 1.0);
  static const Color copper = Color.fromRGBO(193, 108, 54, 1.0);

  static const Color whiskey = Color.fromRGBO(209, 170, 104, 1.0);
  static const Color tacha = Color.fromRGBO(209, 199, 104, 1.0);
  static const Color conifer = Color.fromRGBO(166, 213, 85, 1.0);
  static const Color japaneseLaurel = Color.fromRGBO(33, 141, 45, 1.0);
  static const Color eden = Color.fromRGBO(18, 102, 82, 1.0);
  static const Color downy = Color.fromRGBO(104, 191, 209, 1.0);
  static const Color azure = Color.fromRGBO(44, 94, 167, 1.0);
  static const Color moodyBlue = Color.fromRGBO(107, 104, 209, 1.0);
  static const Color amethyst = Color.fromRGBO(136, 77, 207, 1.0);
  static const Color wisteria = Color.fromRGBO(163, 89, 185, 1.0);

  static const List<Color> setColors = <Color>[ chestnutRose, copper, whiskey, tacha, conifer, japaneseLaurel, eden, downy, azure, moodyBlue, amethyst, wisteria];
  static const List<Color> themeColors = <Color>[  conifer, japaneseLaurel, eden, downy, azure, moodyBlue, amethyst, wisteria, whiskey, tacha, ];
  static const List<String> themes = <String>[ 'Conifer', 'Japanese Laurel', 'Eden', 'Downy', 'Azure', 'Moody Blue' , 'Amethyst', 'Wisteria', 'Whiskey', 'Tacha',];

  late String theme;
  late ThemeMode themeMode;
  bool get isDarkMode => themeMode == ThemeMode.dark;
  Brightness get themeBrightness => isDarkMode ? Brightness.dark : Brightness.light;
  late bool themeChanged = false;

  final AppConfigHandler appConfigHandler;

  ThemeProvider(this.appConfigHandler);

  Future<void> init() async{
    theme = await appConfigHandler.getConfigValue(AppConfigHandler.themeKey);
    bool dark = await _getThemeMode();
    themeMode = dark ? ThemeMode.dark : ThemeMode.light;
  }

  ThemeData get lightAppThemeData => ThemeData(
     useMaterial3: true,
     colorSchemeSeed: _getThemeColor(),
     brightness: Brightness.light,
  );

  ThemeData get darkAppThemeData => ThemeData(
     useMaterial3: true,
     colorSchemeSeed: _getThemeColor(),
     brightness: Brightness.dark,
    );

  ColorScheme getColorSchemeFromSeed(Color seedColor){
    return ColorScheme.fromSeed(seedColor: seedColor, brightness: themeBrightness);
  }

  void toggleTheme() {
    themeMode = isDarkMode ? ThemeMode.light : ThemeMode.dark;
    _saveThemeMode(isDarkMode);
    themeChanged = true;
    notifyListeners();
  }

  Future<void> changeTheme(String newTheme) async{
    if(theme == newTheme) return;

    theme = newTheme;
    appConfigHandler.setConfigValue(AppConfigHandler.themeKey, theme);

    themeChanged = true;
    notifyListeners();
  }

  Color _getThemeColor(){
    for(int i = 0; i < themes.length; i++){
      if(themes[i] == theme){
        return themeColors[i];
      }
    }
    return japaneseLaurel;
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
