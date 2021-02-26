import 'package:expiry_reminder/models/userModel.dart';
import 'package:expiry_reminder/pages/introScreen.dart';
import 'package:expiry_reminder/services/userAuthServices.dart';
import 'package:expiry_reminder/services/userServices.dart';
import 'package:expiry_reminder/utils/ThemeData.dart';
import 'package:expiry_reminder/utils/functions.dart';
import 'package:expiry_reminder/widgets/MyDrawer.dart';
import 'package:flutter/material.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  String uid = UserAuthService.getCurrentUser().uid;
  User _user;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _setupSettings();
  }

  _setupSettings() async {
    User user = await UserService.getUserDetails(uid);

    if (mounted) {
      setState(() {
        _user = user;
      });
    }
  }

  _getTimePicker(BuildContext context, TimeOfDay initialTime) async {
    var time = await showTimePicker(
        context: context,
        initialTime: initialTime,
        initialEntryMode: TimePickerEntryMode.input);
    if (time != null) {
      await UserService.changeAlertTime(uid, time);
      _setupSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: Text("Settings"),
          ),
          body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text("Settings"),
      ),
      body: Container(
        padding: EdgeInsets.all(20.0),
        child: ListView(
          children: [
            Text(
              'My Account',
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
            Divider(
              color: Theme.of(context).primaryColor,
              thickness: 1,
            ),
            Container(
                child: Wrap(
              children: [
                /// Username
                ListTile(title: Text('Username'), subtitle: Text(_user.name)),

                /// Divider
                Divider(height: 1),

                /// Verify Phone
                ListTile(
                  title: Text('Verified Phone Number'),
                  subtitle:
                      Text(_user.phoneNumber ?? 'Phone number isn\'t verify'),
                  trailing: _user.isPhoneVerify
                      ? Icon(Icons.check_circle, color: safe)
                      : Icon(
                          Icons.error,
                          color: danger,
                        ),
                ),

                /// Divider
                Divider(
                  height: 1,
                ),

                /// Verify Email
                ListTile(
                    title: Text('Verified Email'),
                    subtitle:
                        Text(_user.email ?? 'Email address isn\'t verify'),
                    trailing: _user.isEmailVerify
                        ? Icon(Icons.check_circle, color: safe)
                        : Icon(
                            Icons.error,
                            color: danger,
                          ),
                    onTap: () {
                      if (!_user.isEmailVerify) {}
                    })
              ],
            )),

            /// Padding
            Padding(padding: EdgeInsets.symmetric(vertical: 10.0)),
            Text(
              'Alert Settings',
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
            Divider(
              color: Theme.of(context).primaryColor,
              thickness: 1,
            ),
            Container(
                child: Wrap(
              children: [
                /// Username
                ListTile(
                    title: Text('Preferred Alert Time'),
                    subtitle: Text(
                        UtilFunctions.convertStrToTime(_user.preferredAlertTime)
                            .format(context)),
                    trailing: Icon(Icons.chevron_right),
                    onTap: () async {
                      var initialTime = UtilFunctions.convertStrToTime(
                          _user.preferredAlertTime);
                      _getTimePicker(context, initialTime);
                    }),

                /// Divider
                Divider(height: 1),
              ],
            )),

            /// Padding
            Padding(padding: EdgeInsets.symmetric(vertical: 10.0)),
            FlatButton.icon(
                onPressed: () async {
                  await UserAuthService.signOut();
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => IntroScreen()),
                      (route) => false);
                },
                icon: Icon(Icons.logout, color: danger),
                label: Text('Logout from Account',
                    style: TextStyle(color: danger)))
          ],
        ),
      ),
      drawer: (MyDrawer(isSettings: true)),
    );
  }
}
