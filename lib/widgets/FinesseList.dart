import 'package:finesse_nation/Finesse.dart';
import 'package:finesse_nation/Network.dart';
import 'package:finesse_nation/Pages/FinessePage.dart';
import 'package:finesse_nation/Styles.dart';
import 'package:finesse_nation/User.dart';
import 'package:finesse_nation/widgets/FinesseCard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

bool _fcmAlreadySetup = false;

/// Returns a [ListView] containing a [Card] for each [Finesse].
class FinesseList extends StatefulWidget {
  FinesseList({Key key}) : super(key: key);

  @override
  _FinesseListState createState() {
    return _FinesseListState();
  }
}

class _FinesseListState extends State<FinesseList>
    with AutomaticKeepAliveClientMixin<FinesseList> {
  Future<List<Finesse>> _finesses;
  RefreshController _refreshController;

  @override
  bool get wantKeepAlive => true;

  void _onRefresh() async {
    _finesses = fetchFinesses();
    await Future.delayed(Duration(milliseconds: 500));
    _refreshController.refreshCompleted();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _finesses = fetchFinesses();
    _refreshController = RefreshController(initialRefresh: false);
  }

  Widget build(BuildContext context) {
    super.build(context);
    if (!_fcmAlreadySetup) {
      if (!kIsWeb) {
        firebaseMessaging.requestNotificationPermissions();
      }
      firebaseMessaging.subscribeToTopic(ALL_TOPIC);
      firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
          print("onMessage: $message");
          String id = message['data']['id'];
          bool isNew = message['data']['isNew'] == 'true';
          SnackBarAction action;
          if (isNew) {
            action = SnackBarAction(
                label: 'RELOAD',
                onPressed: () {
                  setState(() {
                    _finesses = fetchFinesses();
                  });
                });
          } else {
            Finesse target =
            Finesse.finesseList.singleWhere((fin) => fin.eventId == id);
            action = SnackBarAction(
              label: 'VIEW',
              onPressed: () {
                List<bool> votes = [
                  User.currentUser.upvoted.contains(target.eventId),
                  User.currentUser.downvoted.contains(target.eventId)
                ];
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => FinessePage(target, votes)),
                ).whenComplete(() => setState(() => {}));
              },
            );
          }
          Scaffold.of(context).showSnackBar(
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
                      color: secondaryHighlight,
                    ),
                  ),
                ],
              ),
              action: action,
            ),
          );
        },
        onLaunch: (Map<String, dynamic> message) async {
          print("onLaunch: $message");
        },
        onResume: (Map<String, dynamic> message) async {
          print("onResume: $message");
        },
      );
      _fcmAlreadySetup = true;
    }
    return Container(
      color: primaryBackground,
      child: FutureBuilder(
        initialData: Finesse.finesseList,
        future: _finesses,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            Finesse.finesseList = snapshot.data.reversed.toList();
            return listViewWidget(Finesse.finesseList);
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget listViewWidget(List<Finesse> finesses) {
    return SmartRefresher(
      enablePullDown: true,
      enablePullUp: false,
      header: ClassicHeader(
        idleText: 'Pull down to refresh...',
        releaseText: 'Release to refresh...',
      ),
      controller: _refreshController,
      onRefresh: _onRefresh,
      child: ListView.builder(
        itemCount: finesses.length,
        itemBuilder: (_, i) {
          Finesse fin = finesses[i];
          List<bool> votes = [
            User.currentUser.upvoted.contains(fin.eventId),
            User.currentUser.downvoted.contains(fin.eventId)
          ];
          return FinesseCard(fin, votes);
        },
      ),
    );
  }
}
