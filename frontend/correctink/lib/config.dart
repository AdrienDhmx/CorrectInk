
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class AppConfigHandler{
  static const _configDirectory = 'CorrectInk';
  static const _configFileName = 'appConfig.json';

  static const String themeKey = 'theme';
  static const String themeModeKey = 'dark';
  static const String taskSortBy = 'task_sort_by';
  static const String taskSortDir = 'task_sort_dir';

  dynamic configObject;

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
    }

    configObject ??= await getConfigObject();
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