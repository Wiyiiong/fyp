import 'package:expiry_reminder/pages/SignUp/verifyPhonePage.dart';
import 'package:expiry_reminder/pages/homePage.dart';
import 'package:expiry_reminder/services/userAuthServices.dart';
import 'package:flutter/material.dart';
import 'package:expiry_reminder/services/userServices.dart';
import 'package:expiry_reminder/pages/SignUp/verifyEmail.dart';

class FirstTimeIntro extends StatefulWidget {
  @override
  _FirstTimeIntroState createState() => _FirstTimeIntroState();
}

class _FirstTimeIntroState extends State<FirstTimeIntro> {
  PageController pageViewController = new PageController();

  /// Page 1 - Introduction of app
  Widget _page1() {
    return Container(
      height: MediaQuery.of(context).size.height,
      padding: EdgeInsets.all(40.0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: Column(
              children: [
                Center(
                  child: Image.asset(
                    'assets/image/intro1.jpg',
                    height: 250,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 50),
                ),
                Text("Managing Your Product On The Go",
                    style: Theme.of(context).primaryTextTheme.headline4),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: RaisedButton(
              child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  child: Text('Next')),
              textColor: Theme.of(context).primaryColor,
              color: Theme.of(context).backgroundColor,
              onPressed: () {
                pageViewController.animateToPage(1,
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeIn);
              },
            ),
          )
        ],
      ),
    );
  }

  /// Page 2 - Alert and Notification
  Widget _page2() {
    return Container(
      height: MediaQuery.of(context).size.height,
      padding: EdgeInsets.all(40.0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: Column(
              children: [
                Center(
                  child: Image.asset(
                    'assets/image/intro2.jpg',
                    height: 250,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 50),
                ),
                Text("Gets Notified When Products Expired",
                    style: Theme.of(context).primaryTextTheme.headline4),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: RaisedButton(
              child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  child: Text('Next')),
              textColor: Theme.of(context).primaryColor,
              color: Theme.of(context).backgroundColor,
              onPressed: () {
                pageViewController.animateToPage(2,
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeIn);
              },
            ),
          )
        ],
      ),
    );
  }

  /// Page 3 - Alert and Notification
  Widget _page3() {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(40.0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: Column(
              children: [
                Center(
                  child: Image.asset(
                    'assets/image/intro3.jpg',
                    height: 250,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 50),
                ),
                Text("Getting Started By Adding A New Product",
                    style: Theme.of(context).primaryTextTheme.headline5),
              ],
            ),
          ),
          Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RaisedButton(
                  child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text('Skip')),
                  textColor: Theme.of(context).primaryColor,
                  color: Theme.of(context).backgroundColor,
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (context) => HomePage(
                                  currentUserId:
                                      UserAuthService.getCurrentUser().uid,
                                )),
                        (route) => false);
                  },
                ),
                RaisedButton(
                  child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text('Next')),
                  textColor: Theme.of(context).primaryColor,
                  color: Theme.of(context).backgroundColor,
                  onPressed: () async {
                    var user = await UserService.getUserDetails(
                        UserAuthService.getCurrentUser().uid);
                    if (user.isPhoneVerify) {
                      if (user.isEmailVerify) {
                        Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (context) => HomePage(
                                currentUserId: user.id,
                              ),
                            ),
                            (route) => false);
                      } else {
                        Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (context) => VerifyEmail()),
                            (route) => false);
                      }
                    } else {
                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => VerifyPhone(),
                          ),
                          (route) => false);
                    }
                  },
                ),
              ]),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text('Welcome to Expiry Reminder'),
        ),
        body: PageView(
          controller: pageViewController,
          children: [_page1(), _page2(), _page3()],
        ));
  }
}
