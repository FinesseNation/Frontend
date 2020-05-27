import 'package:flutter/material.dart';
import 'package:custom_switch/custom_switch.dart';
import 'package:finesse_nation/Network.dart';
import 'package:finesse_nation/User.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:finesse_nation/Pages/LoginScreen.dart';
import 'package:finesse_nation/Styles.dart';
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
      ),
      backgroundColor: Styles.darkGrey,
      body: SettingsPage(),
    );
  }
}

/// Class to subscribe and unsubscribe from notifications.
class Notifications {
  ///Set the notifications for the current user
  static Future<void> notificationsSet(toggle, {updateUser: true}) async {
    final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
    if (User.currentUser.email.contains('@test.com') ||
        User.currentUser.email.contains('@test.edu')) {
      return;
    }
    if (toggle) {
      _firebaseMessaging.subscribeToTopic(Network.ALL_TOPIC);
    } else {
      _firebaseMessaging.unsubscribeFromTopic(Network.ALL_TOPIC);
    }
    if (updateUser) {
      Network.changeNotifications(toggle);
    }
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
  void dispose() {
    if (toggle != initialToggle) {
      Notifications.notificationsSet(toggle);
    }
    super.dispose();
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
                          activeColor: Styles.brightOrange,
                          value: toggle,
                          onChanged: (value) {
                            toggle = !toggle;
                          }),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
        Divider(color: Colors.black),
        Row(
          children: <Widget>[
            Padding(
                padding:
                    EdgeInsets.only(right: 15, bottom: 10, top: 10, left: 10),
                child: Column(
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
                        color: Styles.brightOrange,
                        child: Text(
                          'LOGOUT',
                          style: TextStyle(color: Styles.darkGrey),
                        ),
                        onPressed: () {
                          Notifications.notificationsSet(false,
                              updateUser: false);
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
        Divider(color: Colors.black),
      ],
    );
  }
}
