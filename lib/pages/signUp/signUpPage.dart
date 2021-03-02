import 'package:expiry_reminder/pages/SignUp/verifyEmail.dart';
import 'package:expiry_reminder/pages/SignUp/verifyPhonePage.dart';
import 'package:expiry_reminder/pages/logInPage.dart';
import 'package:expiry_reminder/services/userAuthServices.dart';
import 'package:expiry_reminder/utils/constants.dart';
import 'package:expiry_reminder/utils/functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormBuilderState>();

  /// Controller
  TextEditingController userNameController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();
  TextEditingController confirmPasswordController = new TextEditingController();
  TextEditingController emailController = new TextEditingController();
  TextEditingController phoneNumberController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(children: [
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
                  Padding(padding: EdgeInsets.symmetric(vertical: 25.0)),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 20.0),
                    child: Center(
                      child: Column(children: [
                        Text('Sign Up',
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
                      ]),
                    ),
                  ),
                  Padding(padding: EdgeInsets.symmetric(vertical: 10.0)),
                  Container(
                      child: Center(
                    child: FormBuilder(
                        key: _formKey,
                        child: Container(
                          padding: EdgeInsets.all(30.0),
                          child: Column(children: [
                            /// username
                            FormBuilderTextField(
                              name: 'username',
                              controller: userNameController,
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
                                labelText: 'Username',
                                labelStyle: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 22.0,
                                    fontWeight: FontWeight.w500),
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                                contentPadding: EdgeInsets.all(20.0),
                              ),
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 20.0),
                              cursorColor: Colors.white70,
                              keyboardType: TextInputType.name,
                              validator: FormBuilderValidators.compose([
                                FormBuilderValidators.required(context,
                                    errorText: emptyFieldErrorMsg.replaceAll(
                                        '{i}', 'Username')),
                                FormBuilderValidators.minLength(context, 8,
                                    errorText: lengthErrorMsg
                                        .replaceAll('{i}', 'Username')
                                        .replaceAll('{x}', '8')
                                        .replaceAll('{y}', '32')),
                                FormBuilderValidators.maxLength(context, 32),
                              ]),
                              textInputAction: TextInputAction.next,
                            ),

                            /// Padding
                            Padding(
                                padding: EdgeInsets.symmetric(vertical: 10.0)),

                            /// Email
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
                                  errorMaxLines: 3,
                                  labelText: 'Email Address',
                                  labelStyle: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 22.0,
                                      fontWeight: FontWeight.w500),
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.always,
                                  contentPadding: EdgeInsets.all(20.0),
                                  helperText: 'Example: abc@example.com',
                                  helperStyle:
                                      TextStyle(color: Colors.white70)),
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
                              textInputAction: TextInputAction.next,
                            ),

                            /// Padding
                            Padding(
                                padding: EdgeInsets.symmetric(vertical: 10.0)),

                            /// Passwords
                            FormBuilderTextField(
                              name: 'password',
                              controller: passwordController,
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
                                labelText: 'Password',
                                labelStyle: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 22.0,
                                    fontWeight: FontWeight.w500),
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                                contentPadding: EdgeInsets.all(20.0),
                                errorMaxLines: 5,
                              ),
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 20.0),
                              cursorColor: Colors.white70,
                              obscureText: true,
                              enableSuggestions: false,
                              autocorrect: false,
                              keyboardType: TextInputType.visiblePassword,
                              validator: FormBuilderValidators.compose([
                                FormBuilderValidators.required(context,
                                    errorText: emptyFieldErrorMsg.replaceAll(
                                        '{i}', 'Password')),
                                FormBuilderValidators.match(context,
                                    "^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])[a-zA-Z0-9]{8,}",
                                    errorText: passwordErrorMsg)
                              ]),
                              textInputAction: TextInputAction.next,
                            ),

                            /// Padding
                            Padding(
                                padding: EdgeInsets.symmetric(vertical: 10.0)),

                            /// Confirm Password
                            FormBuilderTextField(
                              name: 'confirmPassword',
                              controller: confirmPasswordController,
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
                                errorMaxLines: 3,
                                labelText: 'Confirm Password',
                                labelStyle: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 22.0,
                                    fontWeight: FontWeight.w500),
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                                contentPadding: EdgeInsets.all(20.0),
                              ),
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 20.0),
                              cursorColor: Colors.white70,
                              obscureText: true,
                              enableSuggestions: false,
                              autocorrect: false,
                              keyboardType: TextInputType.visiblePassword,
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return emptyFieldErrorMsg.replaceAll(
                                      '{i}', 'Confirm Password');
                                }
                                if (val !=
                                    _formKey.currentState.fields['password']
                                        ?.value) {
                                  return confirmPasswordErrorMsg;
                                }
                                return null;
                              },

                              // FormBuilderValidators.compose([
                              //   FormBuilderValidators.required(context,
                              //       errorText: emptyFieldErrorMsg.replaceAll(
                              //           '{i}', 'Confirm Password')),
                              //   FormBuilderValidators.equal(
                              //       context, _formKey.currentState.fields['password']?.value ?? "",
                              //       errorText: confirmPasswordErrorMsg)

                              // ]),
                              textInputAction: TextInputAction.next,
                            ),

                            /// Padding
                            Padding(
                                padding: EdgeInsets.symmetric(vertical: 10.0)),

                            /// Phone Number
                            FormBuilderTextField(
                              name: 'phone',
                              controller: phoneNumberController,
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
                                  errorMaxLines: 3,
                                  labelText: 'Phone Number',
                                  labelStyle: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 22.0,
                                      fontWeight: FontWeight.w500),
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.always,
                                  contentPadding: EdgeInsets.all(20.0),
                                  helperText: 'Example: 60123456789',
                                  helperStyle:
                                      TextStyle(color: Colors.white70)),
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 20.0),
                              cursorColor: Colors.white70,
                              keyboardType: TextInputType.phone,
                              validator: FormBuilderValidators.compose([
                                FormBuilderValidators.match(context,
                                    "^(601)[0|1|2|3|4|6|7|8|9]\-*[0-9]{7,8}",
                                    errorText: phoneErrorMsg),
                                FormBuilderValidators.required(context,
                                    errorText: emptyFieldErrorMsg.replaceAll(
                                        '{i}', 'Phone Number')),
                              ]),
                              textInputAction: TextInputAction.next,
                            ),

                            /// Padding
                            Padding(
                                padding: EdgeInsets.symmetric(vertical: 10.0)),

                            /// Next Button
                            SizedBox(
                              width: double.infinity,
                              child: RaisedButton(
                                  visualDensity: VisualDensity(
                                      horizontal: VisualDensity.maximumDensity,
                                      vertical:
                                          VisualDensity.standard.vertical),
                                  padding: EdgeInsets.all(8.0),
                                  color: Colors.white,
                                  child: Text(
                                    'Next',
                                    style: TextStyle(
                                        color: Colors.orange[700],
                                        fontSize: 18.0),
                                  ),
                                  onPressed: () async {
                                    if (_formKey.currentState.validate()) {
                                      var user_id =
                                          await UserAuthService.signUpEmail(
                                              userNameController.text,
                                              emailController.text,
                                              passwordController.text,
                                              phoneNumberController.text);
                                      if (user_id != null) {
                                        showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                                  title: Text(
                                                      'Account Created Successfully'),
                                                  content: Text(
                                                      'Please log in to your account.'),
                                                  actions: [
                                                    FlatButton(
                                                      child: Text('OKAY'),
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                        Navigator.pushAndRemoveUntil(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        LogInPage()),
                                                            (route) => false);
                                                      },
                                                    )
                                                  ],
                                                ));
                                      } else {
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: Text('Account Exist'),
                                                content: Text(
                                                  'Account with the email address/ phone number exists. Please log in',
                                                ),
                                                actions: [
                                                  FlatButton(
                                                      child: Text('OKAY'),
                                                      onPressed: () {
                                                        Navigator.pop(
                                                            context); //pop dialog
                                                        Navigator.pop(
                                                            context); // pop page
                                                      })
                                                ],
                                              );
                                            });
                                      }
                                    }
                                  }

                                  // if (_formKey.currentState
                                  //     .saveAndValidate()) {
                                  //   String userId =
                                  //       await UserAuthService.signUpEmail(
                                  //           userNameController.text,
                                  //           emailController.text,
                                  //           passwordController.text,
                                  //           phoneNumberController.text);
                                  //   Navigator.push(
                                  //     context,
                                  //     MaterialPageRoute(
                                  //         builder: (context) =>
                                  //             VerifyPhone(
                                  //                 userId: userId)),
                                  //   );
                                  // } else {
                                  //   print('Error');
                                  // }

                                  ),
                            ),
                          ]),
                        )),
                  )),
                  Padding(padding: EdgeInsets.symmetric(vertical: 30.0))
                ]),
          ),
        ),
      ),
    ]));
  }
}
