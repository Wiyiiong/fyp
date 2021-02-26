import 'package:expiry_reminder/pages/introScreen.dart';
import 'package:expiry_reminder/utils/ThemeData.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

// import pages
import './pages/homePage.dart';
import 'pages/Product/productActionPage.dart';
import 'pages/Product/viewProductPage.dart';

void main() async {
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
  await Firebase.initializeApp();
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
