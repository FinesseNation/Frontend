import 'dart:math';
import 'dart:ui';

import 'package:finesse_nation/Comment.dart';
import 'package:finesse_nation/Finesse.dart';
import 'package:finesse_nation/Network.dart';
import 'package:finesse_nation/Styles.dart';
import 'package:finesse_nation/User.dart';
import 'package:finesse_nation/Util.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';

enum DotMenu { markEnded }

bool _commentIsEmpty;

/// Displays details about a specific [Finesse].
class FinessePage extends StatefulWidget {
  final Finesse fin;
  final List<bool> isSelected;

  FinessePage(this.fin, this.isSelected);

  @override
  _FinessePageState createState() => _FinessePageState();
}

class _FinessePageState extends State<FinessePage> {
  Widget build(BuildContext context) {
    _commentIsEmpty = true;
    final title = widget.fin.eventTitle;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: <Widget>[
          if (widget.fin.isActive)
            PopupMenuButton<DotMenu>(
              key: Key("threeDotButton"),
              onSelected: (DotMenu result) {
                setState(() {
                  _markAsEnded(widget.fin);
                });
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
      body: Container(child: _FinesseDetails(widget.fin, widget.isSelected)),
      backgroundColor: primaryBackground,
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
        yield await getComments(fin.eventId);
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
          colorBlendMode: BlendMode.saturation,
          color: fin.isActive ? Colors.transparent : inactiveColor,
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
          color: fin.isActive ? primaryHighlight : inactiveColor,
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
              color: fin.isActive
                  ? fin.isActive ? secondaryHighlight : inactiveColor
                  : inactiveColor,
            ),
          ),
          Flexible(
            child: Text(
              fin.description,
              style: TextStyle(
                fontSize: 16,
                color: fin.isActive ? primaryHighlight : inactiveColor,
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
              color: fin.isActive ? secondaryHighlight : inactiveColor,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                fin.isActive ? 'Ongoing' : 'Inactive',
                style: TextStyle(
                  fontSize: 16,
                  color: fin.isActive ? primaryHighlight : inactiveColor,
                ),
              ),
              if (fin.duration != "" && fin.isActive)
                Text(
                  "Duration: ${fin.duration}",
                  style: TextStyle(
                    fontSize: 15,
                    color: fin.isActive ? secondaryHighlight : inactiveColor,
                  ),
                ),
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
                color: fin.isActive ? secondaryHighlight : inactiveColor,
              ),
            ),
            Text(
              '${fin.points} ${(fin.points == 1) ? "point" : "points"}',
              style: TextStyle(
                fontSize: 16,
                color: fin.isActive ? primaryHighlight : inactiveColor,
              ),
            ),
          ]),
          if (fin.isActive)
            SizedBox(
              height: 24,
              child: ToggleButtons(
                renderBorder: false,
                fillColor: Colors.transparent,
                splashColor: Colors.transparent,
                selectedColor: primaryHighlight,
                color: fin.isActive ? secondaryHighlight : inactiveColor,
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
                    handleVote(index, isSelected, fin);
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
              color: fin.isActive
                  ? getColor(fin.emailId, fin.isActive)
                  : inactiveColor,
            ),
          ),
          Text(
            fin.emailId,
            style: TextStyle(
              fontSize: 16,
              color: fin.isActive ? primaryHighlight : inactiveColor,
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
              color: fin.isActive ? secondaryHighlight : inactiveColor,
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
                    color: fin.isActive ? primaryHighlight : inactiveColor,
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

    Future<void> postComment(String comment) async {
      Comment newComment = Comment.post(comment);
      setState(() => fin.comments.add(newComment));
      addComment(newComment, fin.eventId);
      fin.numComments++;
      _controller.clear();
      firebaseMessaging.unsubscribeFromTopic(fin.eventId);
      await sendToAll(fin.eventTitle, '${User.currentUser.userName}: $comment',
          topic: fin.eventId, id: fin.eventId);
      firebaseMessaging.subscribeToTopic(fin.eventId);
    }

    Widget addCommentSection = Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: TextFormField(
        keyboardAppearance: Brightness.dark,
        textCapitalization: TextCapitalization.sentences,
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
          border: InputBorder.none,
          hintText: 'Add a comment...',
          hintStyle: TextStyle(
              color: fin.isActive ? secondaryHighlight : inactiveColor),
          prefixIcon: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Icon(
              Icons.account_circle,
              color: getColor(User.currentUser.email, fin.isActive),
              size: 45,
            ),
          ),
          suffixIcon: IconButton(
              color: primaryHighlight,
              disabledColor: Colors.grey[500],
              icon: Icon(
                Icons.send,
              ),
              onPressed: (_commentIsEmpty)
                  ? null
                  : () async {
                      FocusScopeNode currentFocus = FocusScope.of(context);
                      if (!currentFocus.hasPrimaryFocus) {
                        currentFocus.unfocus();
                      }
                      String comment = _controller.value.text;
                      await postComment(comment);
                    }),
        ),
        style:
            TextStyle(color: fin.isActive ? primaryHighlight : inactiveColor),
        onFieldSubmitted: (comment) async {
          if (comment.isNotEmpty) {
            await postComment(comment);
          }
        },
      ),
    );

    Widget getCommentView(Comment comment) {
      return Padding(
        padding: EdgeInsets.only(
          top: 5,
          bottom: 5,
          right: 10,
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(
                    Icons.account_circle,
                    color: getColor(comment.emailId, fin.isActive),
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
                              comment.username,
                              style: TextStyle(
                                color: fin.isActive
                                    ? primaryHighlight
                                    : inactiveColor,
                              ),
                            ),
                            Text(
                              " · ${timeago.format(comment.postedDateTime)}",
                              style: TextStyle(
                                color: fin.isActive
                                    ? secondaryHighlight
                                    : inactiveColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        comment.comment,
                        style: TextStyle(
                          color:
                              fin.isActive ? primaryHighlight : inactiveColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
//          Divider(thickness: 0.5,color: primaryBackground,)
          ],
        ),
      );
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
                  color: fin.isActive ? primaryHighlight : inactiveColor,
                ),
              ),
              Text(
                '${fin.numComments}',
                style: TextStyle(
                  fontSize: 15,
                  color: fin.isActive ? secondaryHighlight : inactiveColor,
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

    return SingleChildScrollView(
      child: Card(
        color: secondaryBackground,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (fin.image != "") imageSection,
            titleSection,
            locationSection,
            if (fin.description != "") descriptionSection,
            timeSection,
            userSection,
            votingSection,
            viewCommentSection,
            addCommentSection,
          ],
        ),
      ),
    );
  }

  Color getColor(String email, bool isActive) {
    int min = 0xff000000;
    int max = 0xffffffff;
    int seed = email.codeUnits.fold(0, (i, j) => i + j);
    int val = min + Random(seed).nextInt(max - min + 1);
    Color c = Color(val);
    if (!isActive) {
//      int r = c.red, g = c.green, b = c.blue;
//      int luminosity = (0.299 * r + 0.587 * g + 0.114 * b).round();
      double l = c.computeLuminance();
      val = (l * 255).round();
      return Color.fromARGB(255, val, val, val);
    }
    return Color(val);
  }
}

/// Displays the full image for the [Finesse].
class FullImage extends StatelessWidget {
  final Finesse fin;

  FullImage(this.fin);

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryBackground,
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

void _markAsEnded(Finesse fin) {
  List activeList = fin.markedInactive;
  if (activeList.contains(User.currentUser.email)) {
    Fluttertoast.showToast(
      msg: "Already marked as inactive",
      toastLength: Toast.LENGTH_SHORT,
      backgroundColor: secondaryBackground,
      textColor: primaryHighlight,
    );
  } else {
    activeList.add(User.currentUser.email);
    updateFinesse(fin);
    Fluttertoast.showToast(
      msg: "Marked as inactive",
      toastLength: Toast.LENGTH_SHORT,
      backgroundColor: secondaryBackground,
      textColor: primaryHighlight,
    );
  }
}
