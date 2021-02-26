import 'package:flutter/material.dart';

class VerifyPhone extends StatefulWidget {
  final String userId;
  VerifyPhone({@required this.userId});
  @override
  _VerifyPhoneState createState() => _VerifyPhoneState();
}

class _VerifyPhoneState extends State<VerifyPhone> {
  final _formKey = GlobalKey<FormState>();

  FocusNode focusNode1 = FocusNode();
  FocusNode focusNode2 = FocusNode();
  FocusNode focusNode3 = FocusNode();
  FocusNode focusNode4 = FocusNode();
  FocusNode focusNode5 = FocusNode();
  FocusNode focusNode6 = FocusNode();
  String code = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
              height: 10,
              child: LinearProgressIndicator(
                  backgroundColor: Colors.white, value: 0.30)),
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
                    Padding(padding: EdgeInsets.symmetric(vertical: 30.0)),
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
                    Padding(
                        padding: EdgeInsets.all(30),
                        child: Text(
                          'Please enter the code to verify your phone number',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                          ),
                          textAlign: TextAlign.center,
                        )),
                    Padding(padding: EdgeInsets.symmetric(vertical: 10.0)),
                    Padding(
                      padding: EdgeInsets.all(30.0),
                      child: Center(
                        child: Form(
                          key: _formKey,
                          child: TextFormField(
                            decoration:
                                InputDecoration(border: OutlineInputBorder()),
                            maxLengthEnforced: true,
                            maxLength: 6,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
