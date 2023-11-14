import 'dart:io';

import 'package:correctink/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final _notifications = FlutterLocalNotificationsPlugin();
  static final onNotifications = BehaviorSubject<String?>();
  static bool isInit = false;
  static bool canSchedule = false;
  static bool notificationAreDenied = false;

  @pragma('vm:entry-point')
  static void _onNotificationResponse(NotificationResponse details) {
    onNotifications.add(details.payload);
  }

  static Future init({bool initScheduled = false}) async {
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
      linux: LinuxInitializationSettings(defaultActionName: ""),
    );

    _notifications.initialize(settings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: _onNotificationResponse,
    );

    if(initScheduled){
      tz.initializeTimeZones();
      late String locationName;
      var locations = tz.timeZoneDatabase.locations;

      int currentTimezoneOffset = DateTime.now().timeZoneOffset.inMilliseconds;

      for (int i = 0; i < locations.values.length; i++){
        final location = locations.values.elementAt(i);
        if (location.currentTimeZone.offset == currentTimezoneOffset) {
            locationName = location.name;
            break;
        }
      }
      tz.setLocalLocation(tz.getLocation(locationName));
      canSchedule = true;
    }
    isInit = true;

    if(Utils.isOnPhone() && await Permission.notification.isDenied){
      notificationAreDenied = true;
    }
  }

  static Future<NotificationDetails> _notificationDetails({StyleInformation? style}) async {
    return NotificationDetails(
      android: AndroidNotificationDetails("CorrectInk", "CorrectInk",
          importance: Importance.high,
          enableLights: true,
          ledColor: Colors.orange,
          ledOnMs: 1000, ledOffMs: 500,
        styleInformation: style,
      ),
      iOS: const DarwinNotificationDetails(),
      macOS: const DarwinNotificationDetails(),
      linux: const LinuxNotificationDetails(),
    );
  }

  static Future show({int id = 0, String? title, String? description, String? payload}) async{
    if(!Platform.isWindows) {
      _notifications.show(id, title, description, await _notificationDetails(), payload: payload);
    }
  }

  static Future schedule({required DateTime date, int id = 0, String? title, String? description, String? payload, Duration addDuration = const Duration(hours: -1)}) async{
    if(!Platform.isAndroid || !canSchedule) return;

    final d =  tz.TZDateTime.from(date.add(addDuration), tz.local);
    if(d.isBefore(DateTime.now())){
      return;
    }

    StyleInformation? bigTextStyleInformation = description != null ?
    BigTextStyleInformation(
      description,
      htmlFormatBigText: true,
      contentTitle: title,
      htmlFormatContentTitle: true,
    ) : null;

    _notifications.zonedSchedule(
        id,
        title,
        description,
        d,
        await _notificationDetails(style: bigTextStyleInformation),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: payload,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<PendingNotificationRequest?> tryGetScheduled(int id) async {
    final allPending = await _notifications.pendingNotificationRequests();
    for(int i = 0; i < allPending.length; i++){
      if(allPending[i].id == id){
        return allPending[i];
      }
    }
    return null;
  }

  static void cancel(int id) {
    if(Platform.isWindows) return;

    _notifications.cancel(id);
  }
}

