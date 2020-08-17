import 'package:custom_switch/custom_switch.dart';
import 'package:finesse_nation/Network.dart';
import 'package:finesse_nation/Pages/LoginScreen.dart';
import 'package:finesse_nation/Styles.dart';
import 'package:finesse_nation/User.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Contains functionality that allows the user to
/// logout and change their notification preferences.
class Settings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appTitle = 'Settings';

    return Scaffold(
      appBar: AppBar(
        title: Text(appTitle),
        centerTitle: true,
      ),
      backgroundColor: secondaryBackground,
      body: SettingsPage(),
    );
  }
}

/// Displays settings.
class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  var initialToggle = User.currentUser.notifications;
  var toggle = User.currentUser.notifications;

  _SettingsPageState createState() {
    return _SettingsPageState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Padding(
              padding:
                  EdgeInsets.only(right: 15, bottom: 10, top: 10, left: 10),
              child: Text(
                'Notifications',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(
                          right: 15, bottom: 10, top: 10, left: 10),
                      child: CustomSwitch(
                          key: Key("Notification Toggle"),
                          activeColor: primaryHighlight,
                          value: toggle,
                          onChanged: (value) {
                            toggle = !toggle;
                            notificationsSet(toggle);
                            Fluttertoast.showToast(
                              msg: "Notifications " +
                                  (toggle ? "enabled" : "disabled"),
                              toastLength: Toast.LENGTH_SHORT,
                              backgroundColor: secondaryBackground,
                              textColor: primaryHighlight,
                            );
                          }),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
        Divider(color: primaryBackground),
        Row(
          children: <Widget>[
            Padding(
                padding:
                    EdgeInsets.only(right: 15, bottom: 10, top: 10, left: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Account',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    Text(
                      User.currentUser.email,
                      style: TextStyle(color: Colors.white, fontSize: 15),
                    ),
                  ],
                )),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(
                          right: 15, bottom: 10, top: 10, left: 10),
                      child: RaisedButton(
                        key: Key('logoutButton'),
                        color: primaryHighlight,
                        child: Text(
                          'LOGOUT',
                          style: TextStyle(color: secondaryBackground),
                        ),
                        onPressed: () {
                          notificationsSet(false, updateUser: false);
                          SharedPreferences.getInstance().then((prefs) {
                            prefs.remove('currentUser');
                          });
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    LoginScreen()),
                            (Route<dynamic> route) => false,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
        Divider(color: primaryBackground),
      ],
    );
  }
}
