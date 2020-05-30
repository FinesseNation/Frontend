import 'package:custom_switch/custom_switch.dart';
import 'package:finesse_nation/Network.dart';
import 'package:finesse_nation/Pages/LoginScreen.dart';
import 'package:finesse_nation/Pages/SettingsPage.dart';
import 'package:finesse_nation/Pages/addEventPage.dart';
import 'package:finesse_nation/Styles.dart';
import 'package:finesse_nation/widgets/FinesseList.dart';
import 'package:finesse_nation/widgets/PopUpBox.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The entrypoint for the app.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  _prefs.getBool('activeFilter') ?? _prefs.setBool('activeFilter', true);
  _prefs.getBool('typeFilter') ?? _prefs.setBool('typeFilter', true);
  String _currentUser = _prefs.get('currentUser');
  if (_currentUser != null) {
    updateCurrentUser(email: _currentUser);
  }
  runApp(_MyApp(_currentUser));
}

// This is the type used by the popup menu below.
enum DotMenu { settings }
bool _fcmAlreadySetup = false;
GlobalKey<ScaffoldState> _scaffoldKey;

class _MyApp extends StatelessWidget {
  final String _currentUser;

  _MyApp(this._currentUser);

  static changeStatusColor(Color color) async {
    try {
      await FlutterStatusbarcolor.setStatusBarColor(color, animate: true);
      if (useWhiteForeground(color)) {
        FlutterStatusbarcolor.setStatusBarWhiteForeground(true);
        FlutterStatusbarcolor.setNavigationBarWhiteForeground(true);
      } else {
        FlutterStatusbarcolor.setStatusBarWhiteForeground(false);
        FlutterStatusbarcolor.setNavigationBarWhiteForeground(false);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  static changeNavigationColor(Color color) async {
    try {
      await FlutterStatusbarcolor.setNavigationBarColor(color, animate: true);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    changeStatusColor(primaryBackground);
    changeNavigationColor(primaryBackground);
    return MaterialApp(
      title: 'Finesse Nation',
      theme: ThemeData(
        primaryColor: primaryBackground,
        canvasColor: secondaryBackground,
        accentColor: primaryHighlight,
      ),
      home: _currentUser != null ? MyHomePage() : LoginScreen(),
    );
  }
}

/// Displays the [FinesseList].
class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() {
    _scaffoldKey = GlobalKey<ScaffoldState>();
    return _MyHomePageState();
  }
}

class _MyHomePageState extends State<MyHomePage> {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  Future<bool> _activeFilter;
  Future<bool> _typeFilter;

  bool localActive;
  bool localType;

  void showSnackBar(var message) {
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message['notification']['title'],
              style: TextStyle(
                color: primaryHighlight,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              message['notification']['body'],
              style: TextStyle(
                color: primaryHighlight,
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          label: 'RELOAD',
          onPressed: () => reload(),
        ),
      ),
    );
  }

  Future<void> _setActiveFilter(val) async {
    final SharedPreferences prefs = await _prefs;
    final bool activeFilter = val;

    setState(() {
      _activeFilter =
          prefs.setBool("activeFilter", activeFilter).then((bool success) {
        return activeFilter;
      });
    });
  }

  Future<void> _setTypeFilter(val) async {
    final SharedPreferences prefs = await _prefs;
    final bool typeFilter = val;

    setState(() {
      _typeFilter =
          prefs.setBool("typeFilter", typeFilter).then((bool success) {
        return typeFilter;
      });
    });
  }

  Future<void> reload() async {
    Fluttertoast.showToast(
      msg: "Reloading...",
      toastLength: Toast.LENGTH_LONG,
      backgroundColor: secondaryBackground,
      textColor: primaryHighlight,
    );
    setState(() {
      print('reloading');
    });
  }

  @override
  void initState() {
    super.initState();
    _activeFilter = _prefs.then((SharedPreferences prefs) {
      return (prefs.getBool('activeFilter') ?? true);
    });
    _typeFilter = _prefs.then((SharedPreferences prefs) {
      return (prefs.getBool('typeFilter') ?? true);
    });
  }

  Future<void> showFilterMenu() async {
    await PopUpBox.showPopupBox(
      context: context,
      button: FlatButton(
        key: Key("FilterOK"),
        onPressed: () {
          if (localActive != null) {
            _setActiveFilter(localActive);
          }
          if (localType != null) {
            _setTypeFilter(localType);
          }

          Navigator.of(context, rootNavigator: true).pop('dialog');
        },
        child: Text(
          "OK",
          style: TextStyle(
            color: primaryHighlight,
          ),
        ),
      ),
      willDisplayWidget: Row(
        children: <Widget>[
          Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(right: 10, bottom: 30),
                child: Text(
                  'Show inactive posts',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: 10, bottom: 10),
                child: Text(
                  'Show non food posts',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(right: 10, bottom: 10),
                child: FutureBuilder<bool>(
                  future: _activeFilter,
                  builder:
                      (BuildContext context, AsyncSnapshot<bool> snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                        return const CircularProgressIndicator();
                      default:
                        if (snapshot.hasError) {
                          print(snapshot.error);
                          return Wrap(children: <Widget>[Text('')]);
                        } else {
                          return CustomSwitch(
                            key: Key("activeFilter"),
                            activeColor: primaryHighlight,
                            value: snapshot.data,
                            onChanged: (value) {
                              localActive = value;
                            },
                          );
                        }
                    }
                  },
                ),
              ),
              Padding(
                  padding: EdgeInsets.only(right: 10, bottom: 10),
                  child: FutureBuilder<bool>(
                      future: _typeFilter,
                      builder:
                          (BuildContext context, AsyncSnapshot<bool> snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.waiting:
                            return const CircularProgressIndicator();
                          default:
                            if (snapshot.hasError) {
                              print(snapshot.error);
                              return Wrap(children: <Widget>[Text('')]);
                            } else {
                              return CustomSwitch(
                                  key: Key("typeFilter"),
                                  activeColor: primaryHighlight,
                                  value: snapshot.data,
                                  onChanged: (value) {
                                    localType = value;
                                  });
                            }
                        }
                      })),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_fcmAlreadySetup) {
      _firebaseMessaging.subscribeToTopic(ALL_TOPIC);
      _firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
          print("onMessage: $message");
          showSnackBar(message);
        },
        onLaunch: (Map<String, dynamic> message) async {
          print("onLaunch: $message");
          setState(() {
            print('reloading');
          });
        },
        onResume: (Map<String, dynamic> message) async {
          print("onResume: $message");
          setState(() {
            print('reloading');
          });
        },
      );
    }
    _fcmAlreadySetup = true;
    if (!kIsWeb) {
      _firebaseMessaging.requestNotificationPermissions();
    }
    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Text('Drawer Header'),
              decoration: BoxDecoration(
                color: secondaryHighlight,
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.settings,
                color: primaryHighlight,
              ),
              title: Text(
                'Settings',
                style: TextStyle(color: primaryHighlight),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Settings()),
                );
              },
            ),
            ListTile(
              title: Text('Item 2'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title
        title: Hero(
          tag: 'logo',
          child: Image.asset(
            'images/logo.png',
            height: 35,
          ),
        ),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.filter_list,
            ),
            key: Key("Filter"),
            color: Colors.white,
            onPressed: () async {
              showFilterMenu();
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddEvent(),
            ),
          );
        },
        key: Key('add event'),
        child: Icon(
          Icons.add,
          color: secondaryBackground,
        ),
        backgroundColor: primaryHighlight,
      ),
      body: FinesseList(),
    );
  }
}
