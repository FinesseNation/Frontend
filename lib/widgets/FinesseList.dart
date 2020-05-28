import 'package:finesse_nation/Finesse.dart';
import 'package:finesse_nation/Network.dart';
import 'package:finesse_nation/Styles.dart';
import 'package:finesse_nation/widgets/FinesseCard.dart';
import 'package:flutter/cupertino.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter/material.dart';
import 'package:finesse_nation/User.dart';

/// Returns a [ListView] containing a [Card] for each [Finesse].
class FinesseList extends StatefulWidget {
  FinesseList({Key key}) : super(key: key);

  @override
  _FinesseListState createState() => _FinesseListState();
}

class _FinesseListState extends State<FinesseList> {
  Future<List<Finesse>> _finesses;
  RefreshController _refreshController;
  List<Finesse> localList;

  void _onRefresh() async {
    _finesses = Network.fetchFinesses();
    await Future.delayed(Duration(seconds: 1));
    _refreshController.refreshCompleted();
//    await Future.delayed(Duration(seconds: 1));
    setState(() {});

//    _finesses.whenComplete(() {
//      _refreshController.refreshCompleted();
//      setState(() => {});
//    });
  }

  @override
  void initState() {
    super.initState();
    _finesses = Network.fetchFinesses();
    _refreshController = RefreshController(initialRefresh: false);
  }

  Widget build(BuildContext context) {
    return Container(
      color: primaryBackground,
      child: FutureBuilder(
        initialData: localList,
        future: _finesses,
        builder: (context, snapshot) {
          if (snapshot.hasData &&
              snapshot.connectionState == ConnectionState.done) {
            localList = snapshot.data.reversed.toList();
            return listViewWidget(localList, context);
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget listViewWidget(List<Finesse> finesses, BuildContext context) {
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
        itemBuilder: (context, i) {
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
