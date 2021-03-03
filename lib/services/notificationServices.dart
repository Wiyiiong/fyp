import 'package:expiry_reminder/utils/constants.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static BuildContext myContext;

  static void initNotification(BuildContext context) {
    myContext = context;

    var initAndroid = AndroidInitializationSettings('icon');

    /// Note: permissions aren't requested here just to demonstrate that can be
    /// done later
    var initIOS = IOSInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
        onDidReceiveLocalNotification:
            (int id, String title, String body, String payload) async {
          return showDialog(
              context: context,
              builder: (context) => AlertDialog(
                    title: Text(title),
                    content: Text(body),
                    actions: [
                      FlatButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text('OKAY'))
                    ],
                  ));
        });

    var initSettings =
        InitializationSettings(android: initAndroid, iOS: initIOS);
    flutterLocalNotificationsPlugin.initialize(initSettings,
        onSelectNotification: onSelectNotification);
  }

  static Future onSelectNotification(String payload) async {
    if (payload != null) {
      print('Notification Payload:' + payload);
    }
  }
}
