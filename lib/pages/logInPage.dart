import 'package:expiry_reminder/pages/homePage.dart';
import 'package:expiry_reminder/pages/signUp/signUpPage.dart';
import 'package:expiry_reminder/services/userAuthServices.dart';
import 'package:expiry_reminder/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';

class LogInPage extends StatefulWidget {
  @override
  _LogInPageState createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> {
  final _formKey = GlobalKey<FormBuilderState>();
  TextEditingController emailController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();

  bool isLoading = false;

  Widget _buildAlertDialog(String errorMsg) {
    return AlertDialog(
      title: Center(
        child: Row(mainAxisSize: MainAxisSize.max, children: [
          Icon(Icons.error_outline, color: Colors.red),
          Padding(padding: EdgeInsets.symmetric(horizontal: 10.0)),
          Text('Error!')
        ]),
      ),
      content: Text(errorMsg),
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
                    Text('Sign In',
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
            // Padding(padding: EdgeInsets.symmetric(vertical: 20.0)),
            Expanded(
              flex: 4,
              child: SizedBox.expand(
                child: Center(
                  child: FormBuilder(
                    key: _formKey,
                    child: Container(
                      padding: EdgeInsets.all(30.0),
                      child: Column(
                        children: <Widget>[
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
                                      width: 2, color: Colors.redAccent[700])),
                              errorStyle: TextStyle(
                                  color: Colors.redAccent[700], fontSize: 14.0),
                              labelText: 'Email Address',
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

                          /// Password
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
                                      width: 2, color: Colors.redAccent[700])),
                              errorStyle: TextStyle(
                                  color: Colors.redAccent[700], fontSize: 14.0),
                              labelText: 'Password',
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
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required(context,
                                  errorText: emptyFieldErrorMsg.replaceAll(
                                      '{i}', 'Password')),
                            ]),
                            textInputAction: TextInputAction.done,
                          ),

                          /// Padding
                          Padding(
                              padding: EdgeInsets.symmetric(vertical: 10.0)),

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
                                    'Sign In',
                                    style: TextStyle(
                                        color: Colors.orange[700],
                                        fontSize: 18.0),
                                  ),
                                  onPressed: () async {
                                    if (_formKey.currentState
                                        .saveAndValidate()) {
                                      Map<int, String> userId =
                                          await UserAuthService.signInEmail(
                                              emailController.text,
                                              passwordController.text);
                                      if (userId.keys.first == successCode) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => HomePage(
                                              currentUserId:
                                                  userId[successCode],
                                            ),
                                          ),
                                        );
                                      } else {
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) =>
                                                _buildAlertDialog(
                                                    userId.values.first));
                                      }
                                    }
                                  })),
                          SizedBox(
                              width: double.infinity,
                              child: RaisedButton(
                                  visualDensity: VisualDensity(
                                      horizontal: VisualDensity.maximumDensity,
                                      vertical:
                                          VisualDensity.standard.vertical),
                                  padding: EdgeInsets.all(8.0),
                                  color: Colors.orange[700],
                                  child: Text(
                                    'Sign Up',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 18.0),
                                  ),
                                  onPressed: () async {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SignUpPage(),
                                      ),
                                    );
                                  })),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: SizedBox.expand(
                child: Center(
                  child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(children: [
                        Text('Sign in with:',
                            style: TextStyle(color: Colors.white)),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              SignInButton(
                                Buttons.Facebook,
                                mini: true,
                                onPressed: () {},
                              ),
                              SignInButtonBuilder(
                                  backgroundColor: Colors.white,
                                  onPressed: () {
                                    UserAuthService.signInGoogle()
                                        .then((result) => {
                                              if (result != null)
                                                {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          HomePage(
                                                        currentUserId: result,
                                                      ),
                                                    ),
                                                  )
                                                }
                                            });
                                  },
                                  text: 'Sign in with Google',
                                  mini: true,
                                  image: Image.asset(
                                      'assets/image/google_icon.png')),
                              SignInButton(
                                Buttons.Twitter,
                                mini: true,
                                onPressed: () {},
                              ),
                            ]),
                      ])),
                ),
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
