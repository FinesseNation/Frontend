import 'package:flutter/material.dart';
import 'package:finesse_nation/Pages/addEventPage.dart';
import 'package:finesse_nation/Pages/SettingsPage.dart';
import 'package:finesse_nation/widgets/FinesseList.dart';
import 'package:finesse_nation/widgets/PopUpBox.dart';
import 'package:custom_switch/custom_switch.dart';
import 'package:finesse_nation/Pages/LoginScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:finesse_nation/Network.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:finesse_nation/Styles.dart';

/// The entrypoint for the app.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  _prefs.getBool('activeFilter') ?? _prefs.setBool('activeFilter', true);
  _prefs.getBool('typeFilter') ?? _prefs.setBool('typeFilter', true);
  String _currentUser = _prefs.get('currentUser');
  if (_currentUser != null) {
    Network.updateCurrentUser(email: _currentUser);
  }
  runApp(_MyApp(_currentUser));
}

// This is the type used by the popup menu below.
enum DotMenu { settings }
bool _fcmAlreadySetup = false;
GlobalKey<ScaffoldState> _scaffoldKey;

class _MyApp extends StatelessWidget {
// This widget is the root of your application.
  final String _currentUser;

  _MyApp(this._currentUser);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finesse Nation',
      theme: ThemeData(
        primaryColor: Colors.black,
        canvasColor: Styles.darkGrey,
        accentColor: Styles.brightOrange,
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
                color: Styles.brightOrange,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              message['notification']['body'],
              style: TextStyle(
                color: Styles.brightOrange,
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
      backgroundColor: Styles.darkGrey,
      textColor: Styles.brightOrange,
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
            color: Styles.brightOrange,
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
                            activeColor: Styles.brightOrange,
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
                                  activeColor: Styles.brightOrange,
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
      _firebaseMessaging.subscribeToTopic(Network.ALL_TOPIC);
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
              icon: Image.asset("images/baseline_filter_list_black_18dp.png",
                  key: Key("Filter"), color: Colors.white),
              onPressed: () async {
                showFilterMenu();
              },
            ),
            PopupMenuButton<DotMenu>(
              key: Key("dropdownButton"),
              onSelected: (DotMenu result) {
                setState(() {
                  switch (result) {
                    case DotMenu.settings:
                      {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Settings()),
                        );
                      }
                      break;
                  }
                });
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<DotMenu>>[
                const PopupMenuItem<DotMenu>(
                  key: Key("settingsButton"),
                  value: DotMenu.settings,
                  child: Text('Settings'),
                ),
              ],
            )
          ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddEvent()),
          );
        },
        key: Key('add event'),
        child: Icon(
          Icons.add,
          color: Styles.darkGrey,
        ),
        backgroundColor: Styles.brightOrange,
      ),
      body: FinesseList(),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
