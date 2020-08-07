import 'package:custom_switch/custom_switch.dart';
import 'package:finesse_nation/Network.dart';
import 'package:finesse_nation/Pages/LeaderboardPage.dart';
import 'package:finesse_nation/Pages/LoginScreen.dart';
import 'package:finesse_nation/Pages/SettingsPage.dart';
import 'package:finesse_nation/Pages/addEventPage.dart';
import 'package:finesse_nation/Styles.dart';
import 'package:finesse_nation/widgets/FinesseList.dart';
import 'package:finesse_nation/widgets/PopUpBox.dart';
import 'package:flutter/material.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unicorndial/unicorndial.dart';

/// The entrypoint for the app.
void main() async {
  // Move this after runApp()
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  _prefs.getBool('activeFilter') ?? _prefs.setBool('activeFilter', true);
  _prefs.getBool('typeFilter') ?? _prefs.setBool('typeFilter', true);
  String _currentUser = _prefs.get('currentUser');
  if (_currentUser != null) {
    await updateCurrentUser(email: _currentUser);
  }
  runApp(_MyApp(_currentUser));
}

// This is the type used by the popup menu below.
enum DotMenu { settings }

class _MyApp extends StatelessWidget {
  final String _currentUser;

  _MyApp(this._currentUser);



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
    return _MyHomePageState();
  }
}

class _MyHomePageState extends State<MyHomePage> {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future<bool> _activeFilter;
  Future<bool> _typeFilter;

  bool localActive;
  bool localType;

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
    return Scaffold(
      floatingActionButton: UnicornDialer(
        hasBackground: false,
        finalButtonIcon: Icon(Icons.close),
        parentButtonBackground: primaryHighlight,
        orientation: UnicornOrientation.VERTICAL,
        parentButton: Icon(
          Icons.add,
          color: secondaryBackground,
        ),
        childButtons: [
          UnicornButton(
            hasLabel: true,
            labelText: "Ongoing",
            labelColor: secondaryBackground,
            labelHasShadow: false,
            labelBackgroundColor: primaryHighlight,
            currentButton: FloatingActionButton(
              heroTag: "ongoing",
              backgroundColor: primaryHighlight,
              mini: true,
              child: Icon(
                Icons.fastfood,
                color: secondaryBackground,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddEvent(true),
                  ),
                );
              },
            ),
          ),
          UnicornButton(
            hasLabel: true,
            labelText: "Future",
            labelColor: secondaryBackground,
            labelHasShadow: false,
            labelBackgroundColor: primaryHighlight,
            currentButton: FloatingActionButton(
              heroTag: "future",
              backgroundColor: primaryHighlight,
              mini: true,
              child: Icon(
                Icons.calendar_today,
                color: secondaryBackground,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddEvent(false),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body:  DefaultTabController(
        length: 3,
        child: Scaffold(
          drawer: Drawer(
            child: ListView(
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
                  leading: Icon(
                    Icons.format_list_numbered,
                    color: primaryHighlight,
                  ),
                  title: Text(
                    'Leaderboard',
                    style: TextStyle(color: primaryHighlight),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LeaderboardPage()),
                    );
                  },
                ),
              ],
            ),
          ),
          appBar: AppBar(
            bottom: TabBar(
              tabs: [
                Tab(icon: Icon(Icons.directions_car)),
                Tab(icon: Icon(Icons.directions_transit)),
                Tab(icon: Icon(Icons.directions_bike)),
              ],
            ),
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
          body: TabBarView(
            children: [
              FinesseList(),
              Icon(Icons.directions_transit),
              Icon(Icons.directions_bike),
            ],
          ),
        ),
      ),
    );
  }
}
