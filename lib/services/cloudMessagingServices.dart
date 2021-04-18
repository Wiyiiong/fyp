import 'package:expiry_reminder/services/notificationServices.dart';
import 'package:expiry_reminder/utils/constants.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class CloudMessagingService {
  BuildContext myContext;

  static Future requestPermissions() async {
    await cloudMesaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: false,
      criticalAlert: true,
      provisional: false,
      sound: true,
    );
  }

  static Future<String> getToken() async {
    String token = await cloudMesaging.getToken(
        vapidKey:
            'BOPVI--brkV53gYYVQv9bHqBdHuoUNHgmMTUmlPMwxo2Ji3JtwvhUZoBemLxuEOKmfVVIoYFYF0ClRfWofWQ2mY');

    return token;
  }

  static Future saveTokenToDB() async {
    String token = await getToken();
    String uid = auth.currentUser.uid;

    if (token != null) {
      // save token
      await userRef.doc(uid).update({'fcmToken': token});
    }
  }

  static getNotification(BuildContext context) {
    NotificationService.initNotification(context);
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    ;

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification notification = message.notification;
      AndroidNotification android = message.notification?.android;

      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channel.description,
                icon: android?.smallIcon,
                // other properties...
              ),
            ));
      }
    });
  }
}
