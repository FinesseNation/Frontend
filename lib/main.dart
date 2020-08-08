import 'package:finesse_nation/Network.dart';
import 'package:finesse_nation/Pages/LeaderboardPage.dart';
import 'package:finesse_nation/Pages/LoginScreen.dart';
import 'package:finesse_nation/Pages/SettingsPage.dart';
import 'package:finesse_nation/Pages/addEventPage.dart';
import 'package:finesse_nation/Styles.dart';
import 'package:finesse_nation/widgets/FinesseList.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unicorndial/unicorndial.dart';

/// The entrypoint for the app.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  String _currentUser = _prefs.get('currentUser');
  if (_currentUser != null) {
    await updateCurrentUser(email: _currentUser);
  }
  runApp(_MyApp(_currentUser));
}

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
      home: _currentUser != null ? HomePage() : LoginScreen(),
    );
  }
}

/// Displays the [FinesseList].
class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
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
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
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
              Tab(
                icon: Icon(Icons.fastfood),
                /*child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.fastfood),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text('ONGOING'),
                    ),
                  ],
                ),*/
              ),
              Tab(
                icon: Icon(Icons.calendar_today),
                /*child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.calendar_today),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text('FUTURE'),
                    ),
                  ],
                ),*/
              ),
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
              onPressed: () {},
            ),
          ],
        ),
        body: TabBarView(
          children: [
            FinesseList(),
            Image.asset('images/rem.png'),
          ],
        ),
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
      ),
    );
  }
}
