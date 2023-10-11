
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class AppConfigHandler{
  static const _configDirectory = 'CorrectInk';
  static const _configFileName = 'appConfig.json';

  static const String firstTimeOpened = 'first_time_opened';
  static const String themeKey = 'theme';
  static const String themeModeKey = 'dark';
  static const String taskMyDay = "task_my_day";
  static const String taskSortBy = 'task_sort_by';
  static const String taskSortDir = 'task_sort_dir';
  static const String setSortBy = 'set_sort_by';
  static const String setSortDir = 'set_sort_dir';
  static const String language = "language";

  dynamic configObject;
  late bool isFirstTimeOpened = false;

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<String> get _configDirectoryPath async{
    final path = await _localPath;
    return '$path/$_configDirectory/';
  }

  Future<String> get _configFilePath async{
    final path = await _localPath;
    return '$path/$_configDirectory/$_configFileName';
  }

  Future<File> get _configFile async {
    return File(await _configFilePath);
  }

  Future<void> init() async{
    bool exist = await (await _configFile).exists();
    // if the file does not exist copy the original
    if(!exist){
      Directory(await _configDirectoryPath).create();
      final config = (await rootBundle.loadString('assets/config/appConfig.json'));
      (await _configFile).writeAsString(config);
      configObject = json.decode(config);
      isFirstTimeOpened = getConfigValue(firstTimeOpened) == "1";
    } else {
      configObject ??= await getConfigObject();

      if(configObject.keys.length < 9) { // file not up to date (missing settings)
        await (await _configFile).delete(); // delete file
        return init();
      }

      isFirstTimeOpened = getConfigValue(firstTimeOpened) == "1";
    }
  }

  Future<dynamic> getConfigObject() async{
    return json.decode(await (await _configFile).readAsString());
  }

  dynamic getConfigValue(String key) {
    return configObject[key];
  }

  void setConfigValue(String key, String value) async {
    configObject[key] = value; // save in cache

    // save in json file
    final config = await getConfigObject();
    config[key] = value;
    (await _configFile).writeAsString(json.encode(config));
  }
}