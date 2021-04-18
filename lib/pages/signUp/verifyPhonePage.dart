import 'dart:async';
import 'package:expiry_reminder/pages/SignUp/verifyEmail.dart';
import 'package:expiry_reminder/pages/homePage.dart';
import 'package:expiry_reminder/services/userAuthServices.dart';
import 'package:expiry_reminder/utils/constants.dart';
import 'package:expiry_reminder/utils/functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:expiry_reminder/services/userServices.dart';

class VerifyPhone extends StatefulWidget {
  @override
  _VerifyPhoneState createState() => _VerifyPhoneState();
}

class _VerifyPhoneState extends State<VerifyPhone> {
  String verificationId;

  bool codeSent = false;

  TextEditingController codeController = new TextEditingController();
  TextEditingController phoneNumberController = new TextEditingController();

  // Timer for resend code
  Timer _timer;
  int _start = 60;

  @override
  void initState() {
    super.initState();
    _setupPhoneNumber();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  _setupPhoneNumber() async {
    _showLoadingDialog(context);
    var user =
        await UserService.getUserDetails(UserAuthService.getCurrentUser().uid);
    String phoneNumber = user.phoneNumber;
    if (phoneNumber != null) {
      setState(() {
        phoneNumberController.text =
            UtilFunctions.unformatPhoneNumber(phoneNumber);
      });
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pop();
    }
  }

  _showLoadingDialog(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Theme.of(context).splashColor,
        builder: (context) => AlertDialog(
              elevation: 0.0,
              content: Center(child: CircularProgressIndicator()),
              backgroundColor: Colors.transparent,
            ));
  }

  void _startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(oneSec, (timer) {
      if (_start == 0) {
        setState(() {
          timer.cancel();
        });
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                // width: MediaQuery.of(context).size.width,
                // height: MediaQuery.of(context).size.height,
                decoration: BoxDecoration(
                    image: DecorationImage(
                  image: AssetImage('assets/image/Background.png'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                      Colors.white.withOpacity(0.2), BlendMode.softLight),
                )),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Padding(padding: EdgeInsets.symmetric(vertical: 40.0)),
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 20.0),
                      child: Center(
                        child: Column(children: [
                          Text('Verify Phone Number',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28.0,
                                  fontWeight: FontWeight.bold)),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 1.0),
                          ),
                          Text('Expiry Reminder Mobile App',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.0,
                              ))
                        ]),
                      ),
                    ),
                    Padding(padding: EdgeInsets.symmetric(vertical: 10.0)),
                    Text('Phone Number:',
                        style: TextStyle(color: Colors.white, fontSize: 18)),
                    Padding(padding: EdgeInsets.symmetric(vertical: 10.0)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30.0),
                      child: Row(
                        children: [
                          Text(
                            '+',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 28.0,
                                fontWeight: FontWeight.bold),
                          ),
                          Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10.0)),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.7,
                            height: MediaQuery.of(context).size.height * 0.1,
                            child: TextFormField(
                              controller: phoneNumberController,
                              maxLength: 12,
                              maxLengthEnforced: true,
                              cursorColor: Colors.white,
                              textAlign: TextAlign.center,
                              expands: false,
                              keyboardType: TextInputType.number,
                              maxLines: 1,
                              autofocus: true,
                              style:
                                  TextStyle(fontSize: 28, color: Colors.white),
                              decoration: InputDecoration(
                                counterText: "",
                                focusColor: Colors.white,
                                enabledBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.white)),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.white, width: 2)),
                                border: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.white)),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    // Padding(
                    //     padding: EdgeInsets.all(30),
                    //     child: Text(
                    //       'A verification code is sent to your phone number. \n \nPlease enter the 6-digits code to verify your phone number',
                    //       style: TextStyle(
                    //         color: Colors.white,
                    //         fontSize: 16.0,
                    //       ),
                    //       textAlign: TextAlign.center,
                    //     )),
                    Center(
                      child: FlatButton(
                          textColor: Colors.white,
                          child: Text(
                            'Resend Code ($_start s)',
                          ),
                          onPressed: _start == 0 ? verifyPhone : null),
                    ),
                    Padding(padding: EdgeInsets.symmetric(vertical: 20.0)),
                    Text('6-Digits Verification Code:',
                        style: TextStyle(color: Colors.white, fontSize: 18)),
                    Padding(padding: EdgeInsets.symmetric(vertical: 10.0)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30.0),
                      child: Center(
                          child: TextFormField(
                        controller: codeController,
                        maxLength: 6,
                        maxLengthEnforced: true,
                        cursorColor: Colors.white,
                        textAlign: TextAlign.center,
                        expands: false,
                        keyboardType: TextInputType.number,
                        maxLines: 1,
                        autofocus: true,
                        style: TextStyle(fontSize: 28, color: Colors.white),
                        decoration: InputDecoration(
                          counterText: "",
                          focusColor: Colors.white,
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white)),
                          focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.white, width: 2)),
                          border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white)),
                        ),
                      )),
                    ),
                    Padding(padding: EdgeInsets.symmetric(vertical: 20.0)),

                    /// Submit Code
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: SizedBox(
                        width: double.infinity,
                        child: RaisedButton(
                            visualDensity: VisualDensity(
                                horizontal: VisualDensity.maximumDensity,
                                vertical: VisualDensity.standard.vertical),
                            padding: EdgeInsets.all(8.0),
                            color: Colors.white,
                            child: codeSent
                                ? Text(
                                    'Next',
                                    style: TextStyle(
                                        color: Colors.orange[700],
                                        fontSize: 18.0),
                                  )
                                : Text(
                                    'Send Verification Code',
                                    style: TextStyle(
                                        color: Colors.orange[700],
                                        fontSize: 18.0),
                                  ),
                            onPressed: () async {
                              if (codeSent) {
                                _showLoadingDialog(context);
                                await UserAuthService.verifyOTP(
                                        smsCode: codeController.text,
                                        verificationId: this.verificationId)
                                    .then((value) async {
                                  var verified =
                                      await UserAuthService.phoneVerified(
                                          UserAuthService.getCurrentUser().uid,
                                          phoneNumberController.text);
                                  if (verified) {
                                    Navigator.of(context).pop();
                                    var user = UserAuthService.getCurrentUser();
                                    if (user.emailVerified) {
                                      Navigator.push(
                                        context,
                                        CupertinoPageRoute(
                                          builder: (context) => HomePage(
                                            currentUserId: user.uid,
                                          ),
                                        ),
                                      );
                                    } else {
                                      Navigator.push(
                                        context,
                                        CupertinoPageRoute(
                                          builder: (context) => VerifyEmail(),
                                        ),
                                      );
                                    }
                                  } else {
                                    Navigator.of(context).pop();
                                    showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                              title: Text(
                                                  'Invalid Verfication Code'),
                                              content: Text(
                                                  'The verification code is invalid. Please enter a valid 6-digits validation code.'),
                                              actions: [
                                                FlatButton(
                                                  child: Text('OKAY'),
                                                  onPressed: () =>
                                                      Navigator.of(context)
                                                          .pop(),
                                                )
                                              ],
                                            ));
                                  }
                                }).catchError((e) => showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                              title: Text(
                                                  'Invalid Verfication Code'),
                                              content: Text(
                                                  'The verification code is invalid. Please enter a valid 6-digits validation code.'),
                                              actions: [
                                                FlatButton(
                                                  child: Text('OKAY'),
                                                  onPressed: () =>
                                                      Navigator.of(context)
                                                          .pop(),
                                                )
                                              ],
                                            )));
                              } else {
                                verifyPhone();
                              }
                            }),
                      ),
                    ),
                    Padding(padding: EdgeInsets.all(130))
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  /// Send SMS OTP to Phone Number
  Future<void> verifyPhone() async {
    String phoneNumber = phoneNumberController.text;
    var user = UserAuthService.getCurrentUser();
    String userId = user.uid;
    final PhoneVerificationCompleted verified = (AuthCredential authResult) {
      UserAuthService.phoneVerified(userId, phoneNumber);
      if (user.emailVerified) {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => HomePage(
              currentUserId: user.uid,
            ),
          ),
        );
      } else {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => VerifyEmail(),
          ),
        );
      }
    };

    final PhoneVerificationFailed failed = (e) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Text('Unexpected Error Occured'),
                content: Text(e.message),
                actions: [
                  FlatButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('CANCEL'))
                ],
              ));
    };

    final PhoneCodeSent smsSent = (String verificationId, [int forceResend]) {
      this.verificationId = verificationId;
      setState(() {
        this.codeSent = true;
        this._start = 60;
      });

      _startTimer();
    };

    final PhoneCodeAutoRetrievalTimeout autoTimeout = (String verificationId) {
      this.verificationId = verificationId;
    };

    await auth.verifyPhoneNumber(
        phoneNumber: UtilFunctions.formatPhoneNumber(phoneNumber),
        // phoneNumber: "+" + phoneNumber,
        verificationCompleted: verified,
        verificationFailed: failed,
        codeSent: smsSent,
        codeAutoRetrievalTimeout: autoTimeout,
        timeout: Duration(seconds: 60));
  }
}
