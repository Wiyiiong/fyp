import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:expiry_reminder/services/userAuthServices.dart';
import 'package:expiry_reminder/pages/homePage.dart';

class VerifyEmail extends StatefulWidget {
  @override
  _VerifyEmailState createState() => _VerifyEmailState();
}

class _VerifyEmailState extends State<VerifyEmail> {
  bool emailVerified = false;
  Timer _timer;
  @override
  void initState() {
    super.initState();
    if (mounted) {
      _sendEmail();
      _checkUserVerifyEmail();
    }
  }

  _sendEmail() async {
    await UserAuthService.verifyUserEmail();
  }

  Future _checkUserVerifyEmail() async {
    _timer = new Timer.periodic(Duration(seconds: 3), (timer) async {
      UserAuthService.getCurrentUser()..reload();
      var user = UserAuthService.getCurrentUser();
      if (user.emailVerified) {
        setState(() {
          this.emailVerified = true;
        });
        _timer.cancel();
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (context) => HomePage(
                      currentUserId: user.uid,
                    )),
            (route) => false);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    if (_timer != null) {
      _timer.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                decoration: BoxDecoration(
                    image: DecorationImage(
                  image: AssetImage('assets/image/Background.png'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                      Colors.white.withOpacity(0.2), BlendMode.softLight),
                )),
                child: Padding(
                  padding: EdgeInsets.all(30.0),
                  child: Column(
                    children: [
                      Padding(padding: EdgeInsets.symmetric(vertical: 70.0)),
                      Text(
                        'A verify email is sent to your email address.',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 32.0,
                            fontWeight: FontWeight.w600),
                      ),
                      Padding(padding: EdgeInsets.symmetric(vertical: 20.0)),
                      Text(
                        'Please check your spam inbox if do not receive any verification email.',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
