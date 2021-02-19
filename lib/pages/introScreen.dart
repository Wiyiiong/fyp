import 'package:expiry_reminder/services/userAuthServices.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:splashscreen/splashscreen.dart';

import 'homePage.dart';
import 'logInPage.dart';

class IntroScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    User user = UserAuthService.getCurrentUser();
    return SplashScreen(
        navigateAfterSeconds: user != null
            ? HomePage(
                currentUserId: user.uid,
              )
            : LogInPage(),
        seconds: 5,
        title: Text(
          'Expiry Reminder App',
          style: Theme.of(context).primaryTextTheme.headline5,
        ));
  }
}
