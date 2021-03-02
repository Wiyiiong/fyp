import 'package:expiry_reminder/pages/introScreen.dart';
import 'package:expiry_reminder/utils/ThemeData.dart';
import 'package:expiry_reminder/utils/constants.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// import pages
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");
}

Future<void> main() async {
  ErrorWidget.builder = (FlutterErrorDetails details) {
    bool inDebug = false;
    assert(() {
      inDebug = true;
      return true;
    }());
    // In debug mode, use the normal error widget which shows
    // the error message:
    if (inDebug) return ErrorWidget(details.exception);
    // In release builds, show a yellow-on-blue message instead:
    return Container(
      alignment: Alignment.center,
      child: Text(
        'Error!',
        style: TextStyle(color: Colors.yellow),
        textDirection: TextDirection.ltr,
      ),
    );
  };
  WidgetsFlutterBinding.ensureInitialized();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await Firebase.initializeApp();
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Expiry Reminder App',
        theme: buildLightTheme(),
        debugShowCheckedModeBanner: false,
        home: IntroScreen());
    // routes: {
    //   '/': (context) => HomePage(),
    //   '/add_products': (context) => ProductActionPage(),
    //   '/view_products': (context) => ViewProductPage(),
    // });
  }
}
