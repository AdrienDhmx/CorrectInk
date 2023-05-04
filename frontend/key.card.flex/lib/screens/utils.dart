import 'dart:io';

class Utils{
  static bool isOnPhone(){
    return Platform.isAndroid || Platform.isIOS;
  }
}