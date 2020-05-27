import 'package:finesse_nation/Finesse.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:finesse_nation/User.dart';
import 'package:finesse_nation/Network.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:math';
import 'package:finesse_nation/Comment.dart';
import 'package:finesse_nation/Util.dart';
import 'package:finesse_nation/Styles.dart';

enum DotMenu { markEnded }

bool _commentIsEmpty;

/// Displays details about a specific [Finesse].
class FinessePage extends StatelessWidget {
  final Finesse fin;
  final List<bool> isSelected;

  FinessePage(this.fin, this.isSelected);

  Widget build(BuildContext context) {
    _commentIsEmpty = true;
    final title = fin.eventTitle;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: <Widget>[
          PopupMenuButton<DotMenu>(
            key: Key("threeDotButton"),
            onSelected: (DotMenu result) {
              _markAsEnded(fin);
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<DotMenu>>[
              const PopupMenuItem<DotMenu>(
                key: Key("markAsEndedButton"),
                value: DotMenu.markEnded,
                child: Text('Mark as inactive'),
              ),
            ],
          )
        ],
      ),
      body: Container(child: _FinesseDetails(fin, isSelected)),
      backgroundColor: Colors.black,
    );
  }
}

// Create the details widget.
class _FinesseDetails extends StatefulWidget {
  final Finesse fin;
  final List<bool> isSelected;

  _FinesseDetails(this.fin, this.isSelected);

  @override
  _FinesseDetailsState createState() {
    return _FinesseDetailsState(fin, isSelected);
  }
}

// Create a corresponding State class.
class _FinesseDetailsState extends State<_FinesseDetails> {
  Finesse fin;
  List<bool> isSelected;

  bool active;
  Stream<List<Comment>> commentStream;

  final TextEditingController _controller = TextEditingController();

  _FinesseDetailsState(Finesse fin, List<bool> isSelected) {
    this.fin = fin;
    this.isSelected = isSelected;
  }

  @override
  void initState() {
    super.initState();
    active = true;
    commentStream = (() async* {
      while (active) {
        yield await Network.getComments(fin.eventId);
        await Future<void>.delayed(Duration(seconds: 1));
      }
    })();
  }

  @override
  void dispose() {
    active = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return mainCard(context);
  }

  Widget mainCard(BuildContext context) {
    Widget imageSection = InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FullImage(
            fin,
          ),
        ),
      ),
      child: Hero(
        tag: fin.eventId,
        child: Image.memory(
          fin.convertedImage,
          width: 600,
          height: 240,
          fit: BoxFit.cover,
        ),
      ),
    );

    Widget titleSection = Container(
      padding: const EdgeInsets.all(20),
      child: Text(
        fin.eventTitle,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 30,
          color: Styles.brightOrange,
        ),
      ),
    );

    Widget descriptionSection = Container(
      padding: const EdgeInsets.only(left: 20, bottom: 20),
      child: Row(
//        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(right: 10),
            child: Icon(
              Icons.info,
              color: Styles.darkOrange,
            ),
          ),
          Flexible(
            child: Text(
              fin.description,
              style: TextStyle(
                fontSize: 16,
                color: Styles.brightOrange,
              ),
            ),
          ),
        ],
      ),
    );

    Widget timeSection = Container(
      padding: const EdgeInsets.only(left: 20, bottom: 20),
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.only(right: 10),
            child: Icon(
              Icons.calendar_today,
              color: Styles.darkOrange,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                fin.isActive.length < 3 && !fin.isActive.contains(fin.emailId)
                    ? 'Ongoing'
                    : 'Inactive',
                style: TextStyle(
                  fontSize: 16,
                  color: Styles.brightOrange,
                ),
              ),
              fin.duration != "" &&
                      (fin.isActive.length < 3 &&
                          !fin.isActive.contains(fin.emailId))
                  ? Text("Duration: ${fin.duration}",
                      style: TextStyle(
                        fontSize: 15,
                        color: Styles.darkOrange,
                      ))
                  : Container(),
            ],
          ),
        ],
      ),
    );

    Widget votingSection = Container(
      padding: const EdgeInsets.only(left: 20, bottom: 20),
      child: Row(
        children: [
          Row(children: [
            Padding(
              padding: EdgeInsets.only(right: 10),
              child: Icon(
                Icons.thumbs_up_down,
                color: Styles.darkOrange,
              ),
            ),
            Text(
              '${fin.points} ${(fin.points == 1) ? "point" : "points"}',
              style: TextStyle(
                fontSize: 16,
                color: Styles.brightOrange,
              ),
            ),
          ]),
          SizedBox(
            height: 24,
            child: ToggleButtons(
              fillColor: Styles.darkGrey,
              renderBorder: false,
              selectedColor: Styles.brightOrange,
              color: Styles.darkOrange,
              children: <Widget>[
                Icon(
                  Icons.arrow_upward,
                ),
                Icon(
                  Icons.arrow_downward,
                ),
              ],
              onPressed: (index) {
                setState(() {
                  Util.handleVote(index, isSelected, fin);
                });
              },
              isSelected: isSelected,
            ),
          ),
        ],
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
      ),
    );

    Widget userSection = Container(
      padding: const EdgeInsets.only(left: 20, bottom: 20),
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.only(right: 10),
            child: Icon(
              Icons.account_circle,
              color: getColor(fin.emailId),
            ),
          ),
          Text(
            fin.emailId,
            style: TextStyle(
              fontSize: 16,
              color: Styles.brightOrange,
            ),
          ),
        ],
      ),
    );

    Widget locationSection = Container(
      padding: const EdgeInsets.only(left: 20, bottom: 20),
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.only(right: 10),
            child: Icon(
              Icons.place,
              color: Styles.darkOrange,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                child: Text(
                  fin.location,
                  style: TextStyle(
                    fontSize: 16,
                    color: Styles.brightOrange,
                    decoration: TextDecoration.underline,
                  ),
                ),
                onTap: () => launch(
                    'https://www.google.com/maps/search/${fin.location}'),
              ),
            ],
          ),
        ],
      ),
    );

    Widget addCommentSection = TextFormField(
      controller: _controller,
      autovalidate: true,
      validator: (comment) {
        bool isEmpty = comment.isEmpty;
        if (isEmpty != _commentIsEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              _commentIsEmpty = isEmpty;
            });
          });
        }
        return null;
      },
      decoration: InputDecoration(
        hintText: 'Add a comment...',
        hintStyle: TextStyle(color: Styles.darkOrange),
        prefixIcon: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Icon(
            Icons.account_circle,
            color: getColor(User.currentUser.email),
            size: 45,
          ),
        ),
        suffixIcon: IconButton(
            color: Styles.brightOrange,
            disabledColor: Colors.grey[500],
            icon: Icon(
              Icons.send,
            ),
            onPressed: (_commentIsEmpty)
                ? null
                : () {
                    FocusScopeNode currentFocus = FocusScope.of(context);
                    if (!currentFocus.hasPrimaryFocus) {
                      currentFocus.unfocus();
                    }
                    String comment = _controller.value.text;
                    Comment newComment = Comment.post(comment);
                    setState(() => fin.comments.add(newComment));
                    Network.addComment(newComment, fin.eventId);
                    fin.numComments++;
                    _controller.clear();
                  }),
      ),
      style: TextStyle(color: Colors.grey[100]),
      onFieldSubmitted: (comment) {
        if (comment.isNotEmpty) {
          Comment newComment = Comment.post(comment);
          setState(() => fin.comments.add(newComment));
          Network.addComment(newComment, fin.eventId);
          fin.numComments++;
          _controller.clear();
        }
      },
    );

    Widget getCommentView(Comment comment) {
      Widget commentView = Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(
                  Icons.account_circle,
                  color: getColor(comment.emailId),
                  size: 45,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 4, bottom: 1),
                      child: Row(
                        children: [
                          Text(
                            comment.emailId,
                            style: TextStyle(
                              color: Styles.brightOrange,
                            ),
                          ),
                          Text(
                            " · ${Util.timeSince(comment.postedDateTime)}",
                            style: TextStyle(
                              color: Styles.darkOrange,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      comment.comment,
                      style: TextStyle(
                        color: Colors.grey[100],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
//          Divider(thickness: 0.5,color: Colors.black,)
        ],
      );
      commentView = Padding(
        padding: EdgeInsets.only(
          top: 5,
          bottom: 5,
          right: 10,
        ),
        child: commentView,
      );
      return commentView;
    }

    Widget viewCommentSection = StreamBuilder(
      initialData: fin.comments,
      stream: commentStream,
      builder: (BuildContext context, AsyncSnapshot<List<Comment>> snapshot) {
        if (snapshot.hasData &&
            snapshot.connectionState == ConnectionState.active) {
          fin.comments = snapshot.data;
          fin.numComments = fin.comments.length;
        }
        List<Widget> children =
            fin.comments.map((comment) => getCommentView(comment)).toList();
        Widget commentsHeader = Padding(
          padding: EdgeInsets.only(
            left: 12,
            bottom: 10,
          ),
          child: Row(
            children: [
              Text(
                'Comments  ',
                style: TextStyle(
                  fontSize: 16,
                  color: Styles.brightOrange,
                ),
              ),
              Text(
                '${fin.numComments}',
                style: TextStyle(
                  fontSize: 15,
                  color: Styles.darkOrange,
                ),
              ),
            ],
          ),
        );
        children.insert(0, commentsHeader);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        );
      },
    );

    return ListView(
      children: [
        Card(
          color: Styles.darkGrey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              fin.image != "" ? imageSection : Container(),
              titleSection,
              locationSection,
              fin.description != "" ? descriptionSection : Container(),
              timeSection,
              userSection,
              votingSection,
              viewCommentSection,
              addCommentSection,
            ],
          ),
        ),
      ],
    );
  }

  Color getColor(String email) {
    int min = 0xff000000;
    int max = 0xffffffff;
    int seed = email.codeUnits.fold(0, (i, j) => i + j);
    int val = min + Random(seed).nextInt(max - min + 1);
    return Color(val);
  }
}

/// Displays the full image for the [Finesse].
class FullImage extends StatelessWidget {
  final Finesse fin;

  FullImage(this.fin);

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: InkWell(
        onTap: () => Navigator.pop(context),
        child: Center(
          child: Hero(
            tag: fin.eventId,
            child: Image.memory(
              fin.convertedImage,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}

_markAsEnded(Finesse fin) {
  List activeList = fin.isActive;
  if (activeList.contains(User.currentUser.email)) {
    Fluttertoast.showToast(
      msg: "Already marked as inactive",
      toastLength: Toast.LENGTH_SHORT,
      backgroundColor: Styles.darkGrey,
      textColor: Styles.brightOrange,
    );
    return;
  }
  activeList.add(User.currentUser.email);
  fin.isActive = activeList;
  Network.updateFinesse(fin);
  Fluttertoast.showToast(
    msg: "Marked as inactive",
    toastLength: Toast.LENGTH_SHORT,
    backgroundColor: Styles.darkGrey,
    textColor: Styles.brightOrange,
  );
}
