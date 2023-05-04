
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class AppConfigHandler{
  static const _configDirectory = 'keycard';
  static const _configFileName = 'appConfig.json';

  static const String themeKey = 'theme';
  static const String themeModeKey = 'dark';
  static const taskSortBy = 'task_sort_by';
  static const taskSortDir = 'task_sort_dir';


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
  }

  Future<dynamic> getConfigObject() async{
    return json.decode((await _configFile).readAsStringSync());
  }

  Future<dynamic> getConfigValue(String key) async{
    return (await getConfigObject())[key];
  }

  void setConfigValue(String key, String value) async {
    final config = await getConfigObject();
    config[key] = value;
    (await _configFile).writeAsString(json.encode(config));
  }
}