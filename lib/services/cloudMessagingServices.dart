import 'package:expiry_reminder/services/notificationServices.dart';
import 'package:expiry_reminder/utils/constants.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

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
}
