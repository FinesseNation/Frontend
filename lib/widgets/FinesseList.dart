import 'package:finesse_nation/Finesse.dart';
import 'package:finesse_nation/Network.dart';
import 'package:finesse_nation/widgets/FinesseCard.dart';
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

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void _onRefresh() async {
    setState(() {
      _finesses = Network.fetchFinesses();
    });
    if (_finesses != null) {
      _refreshController.refreshCompleted();
    }
  }

  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
      ),
      child: FutureBuilder(
        future: Network.fetchFinesses(),
        builder: (context, snapshot) {
          return snapshot.data != null
              ? listViewWidget(snapshot.data, context)
              : Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget listViewWidget(List<Finesse> _finesses, BuildContext context) {
    return Container(
      color: Colors.black,
      child: Center(
        key: Key("refresher"),
        child: SmartRefresher(
          enablePullDown: true,
          enablePullUp: false,
          header: WaterDropHeader(),
          controller: _refreshController,
          onRefresh: _onRefresh,
          child: ListView.builder(
              key: Key("listview"),
              itemCount: _finesses.length * 2,
              itemBuilder: (context, i) {
                _finesses = _finesses.reversed.toList();
                if (i.isOdd) return Divider();
                final index = i ~/ 2;
                Finesse fin = _finesses[index];
                List<bool> votes = [
                  User.currentUser.upvoted.contains(fin.eventId),
                  User.currentUser.downvoted.contains(fin.eventId)
                ];
                return FinesseCard(fin, votes);
              }),
        ),
      ),
    );
  }
}
