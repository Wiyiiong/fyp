import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final flutterLocalNotificationsPlugin =
      new FlutterLocalNotificationsPlugin();

  static BuildContext myContext;

  static void initNotification(BuildContext context) {
    myContext = context;

    var initAndroid = AndroidInitializationSettings('icon');

    var initSettings = InitializationSettings(android: initAndroid);
    flutterLocalNotificationsPlugin.initialize(initSettings,
        onSelectNotification: onSelectNotification);
  }

  static Future onSelectNotification(String payload) async {
    if (payload != null) {
      print('Notification Payload:' + payload);
    }
  }
}
