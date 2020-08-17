import 'package:finesse_nation/Finesse.dart';
import 'package:finesse_nation/Network.dart';
import 'package:finesse_nation/Styles.dart';
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
        itemBuilder: (_, i) => FinesseCard(finesses[i]),
      ),
    );
  }
}
