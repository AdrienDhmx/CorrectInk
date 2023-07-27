import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:localization/localization.dart';

import 'config.dart';

class LocalizationProvider extends ChangeNotifier {
  static const friendlySupportedLocales = [
    "English",
    "Français",
  ];

  final AppConfigHandler _appConfigHandler;

  final Iterable<LocalizationsDelegate<dynamic>> localizationsDelegates = [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    LocalJsonLocalization.delegate,
  ];

  final Iterable<Locale> supportedLocales = [
    const Locale('en', 'US'),
    const Locale('fr', 'FR'),
  ];


  static late Locale locale;
  String get localeFriendly => getFriendlyLocale(locale);

  LocalizationProvider(this._appConfigHandler){
    String savedLanguage = _appConfigHandler.getConfigValue("language");
    locale = savedLanguage.toLocale();
  }

  Locale localeResolutionCallback(locale, supportedLocales){
    // first time the app is opened use the device language if supported
    if (supportedLocales.contains(locale) && _appConfigHandler.isFirstTimeOpened) {
      return locale;
    }

    // the current locale found on the config file is either english, the default language (if not changed),
    // or the language selected by the user
    return LocalizationProvider.locale;
  }

  bool changeLocalization(Locale locale){
    if(supportedLocales.contains(locale)){
      // update the language of the app
      LocalizationProvider.locale = locale;
      notifyListeners();

      // save change in the config file
      _appConfigHandler.setConfigValue(AppConfigHandler.language, locale.toLanguageTag());
      return true;
    }
    return false;
  }

  bool changeLocalizationFromFriendly(String locale){
    return changeLocalization(getLocalizationFromFriendly(locale));
  }

  String getFriendlyLocale(Locale locale){
    int index;
    for(index = 0; index < supportedLocales.length; index++){
      if(locale == supportedLocales.elementAt(index)){
        return friendlySupportedLocales[index];
      }
    }
    return "UNKNOWN";
  }

  Locale getLocalizationFromFriendly(String locale){
    int index;
    for(index = 0; index < supportedLocales.length; index++){
      if(locale == friendlySupportedLocales.elementAt(index)){
        return supportedLocales.elementAt(index);
      }
    }
    return const Locale('und');
  }
}

extension Localization on String{
  Locale toLocale({String splitPattern = "-"}){
    if (kDebugMode) {
      print('language: $this');
    }
    List<String> tags = split(splitPattern);
    if(tags.length > 1){
      return Locale(tags[0], tags[1]);
    } else {
      return Locale(tags[0]);
    }
  }
}


