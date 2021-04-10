import 'package:expiry_reminder/services/userAuthServices.dart';
import 'package:expiry_reminder/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class ForgotPassword extends StatefulWidget {
  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final _formKey = GlobalKey<FormBuilderState>();

  TextEditingController emailController = new TextEditingController();

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

  Widget _buildAlertDialog({@required String title, @required String msg}) {
    return AlertDialog(
      title: Center(child: Text(title)),
      content: Text(msg),
      actions: [
        FlatButton(
            onPressed: () => Navigator.of(context).pop(), child: Text('OKAY'))
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    return Scaffold(
      body: SingleChildScrollView(
        physics: ClampingScrollPhysics(),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
              image: DecorationImage(
            image: AssetImage('assets/image/Background.png'),
            fit: BoxFit.fill,
            colorFilter: ColorFilter.mode(
                Colors.white.withOpacity(0.2), BlendMode.softLight),
          )),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Expanded(flex: 1, child: SizedBox.expand()),
                Expanded(
                    flex: 1,
                    child: SizedBox.expand(
                      child: Center(
                          child: Column(children: [
                        Text('Forgot Password',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 40.0,
                                fontWeight: FontWeight.bold)),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 3.0),
                        ),
                        Text('Expiry Reminder Mobile App',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.0,
                            ))
                      ])),
                    )),
                Expanded(
                  flex: 5,
                  child: SizedBox.expand(
                    child: Center(
                      child: FormBuilder(
                        key: _formKey,
                        child: Container(
                          padding: EdgeInsets.all(30.0),
                          child: Column(children: <Widget>[
                            // Instruction
                            Text(
                              'Please enter your email address',
                              style: TextStyle(
                                  color: Theme.of(context).backgroundColor,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.w500),
                            ),

                            // Padding
                            Padding(
                                padding: EdgeInsets.symmetric(vertical: 10)),

                            /// Email Address
                            FormBuilderTextField(
                              name: 'email',
                              controller: emailController,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.white70)),
                                enabledBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.white70)),
                                focusedBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.white70)),
                                errorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        width: 2,
                                        color: Colors.redAccent[700])),
                                errorStyle: TextStyle(
                                    color: Colors.redAccent[700],
                                    fontSize: 14.0),
                                // labelText: 'Email Address',
                                // labelStyle: TextStyle(
                                //     color: Colors.white70,
                                //     fontSize: 22.0,
                                //     fontWeight: FontWeight.w500),
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                                contentPadding: EdgeInsets.all(20.0),
                              ),
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 20.0),
                              cursorColor: Colors.white70,
                              keyboardType: TextInputType.emailAddress,
                              validator: FormBuilderValidators.compose([
                                FormBuilderValidators.email(context,
                                    errorText: emailErrorMsg),
                                FormBuilderValidators.required(context,
                                    errorText: emptyFieldErrorMsg.replaceAll(
                                        '{i}', 'Email Address')),
                              ]),
                              textInputAction: TextInputAction.done,
                            ),

                            /// Padding
                            Padding(
                                padding: EdgeInsets.symmetric(vertical: 10.0)),
                            // Submit Button
                            SizedBox(
                                width: double.infinity,
                                child: RaisedButton(
                                    visualDensity: VisualDensity(
                                        horizontal:
                                            VisualDensity.maximumDensity,
                                        vertical:
                                            VisualDensity.standard.vertical),
                                    padding: EdgeInsets.all(8.0),
                                    color: Colors.white,
                                    child: Text(
                                      'Send Reset Password Link',
                                      style: TextStyle(
                                          color: Colors.orange[700],
                                          fontSize: 18.0),
                                    ),
                                    onPressed: () async {
                                      if (_formKey.currentState
                                          .saveAndValidate()) {
                                        _showLoadingDialog(context);
                                        var status = await UserAuthService
                                            .resetPasswords(
                                                emailController.text);
                                        if (status == '$successCode') {
                                          Navigator.of(context).pop();
                                          showDialog(
                                              context: context,
                                              builder: (BuildContext context) =>
                                                  _buildAlertDialog(
                                                      title:
                                                          'Reset Password Email Sent',
                                                      msg:
                                                          'A reset password email had sent to your email address, please check. If the email does not appear, please search in your spam inbox.')).then(
                                              (value) =>
                                                  Navigator.of(context).pop());
                                        } else {
                                          Navigator.of(context).pop();
                                          showDialog(
                                              context: context,
                                              builder: (BuildContext context) =>
                                                  _buildAlertDialog(
                                                      title:
                                                          'Email Address Not Valid',
                                                      msg: status));
                                        }
                                      }
                                    })),
                          ]),
                        ),
                      ),
                    ),
                  ),
                ),
              ]),
        ),
      ),
    );
  }
}
