import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  static final ConnectivityService _singleton = ConnectivityService._internal();
  ConnectivityService._internal();

  static ConnectivityService getInstance() => _singleton;

  bool hasConnection = true;
  int lastConnectionChange = 0;
  StreamController connectionChangeController = StreamController.broadcast();
  final Connectivity _connectivity = Connectivity();
  Stream get connectionChange => connectionChangeController.stream;

  void init() {
    _connectivity.onConnectivityChanged.listen(_connectionChange);
    checkConnection();
  }

  void dispose() {
    connectionChangeController.close();
  }

  void _connectionChange(ConnectivityResult result) {
    // the change in connection must be related to internet access
    if(result != ConnectivityResult.none && result != ConnectivityResult.bluetooth
        && lastConnectionChange < DateTime.now().millisecondsSinceEpoch + 200){
      checkConnection();
    }
    lastConnectionChange = DateTime.now().millisecondsSinceEpoch;
  }

  Future<bool> checkConnection() async {
    bool previousConnection = hasConnection;

    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        hasConnection = true;
      } else {
        hasConnection = false;
      }
    } on SocketException catch(_) {
      hasConnection = false;
    }

    if (previousConnection != hasConnection) {
      connectionChangeController.add(hasConnection);
    }

    return hasConnection;
  }
}