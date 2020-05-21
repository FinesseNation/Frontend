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
int voteAmount;
List<Comment> mainComments;

/// Displays details about a specific [Finesse].
class FinessePage extends StatelessWidget {
  final Finesse fin;

  FinessePage(this.fin);

  Widget build(BuildContext context) {
    _commentIsEmpty = true;
    voteAmount = 0;
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
      body: Container(child: _FinesseDetails(fin)),
      backgroundColor: Colors.black,
    );
  }
}

// Create the details widget.
class _FinesseDetails extends StatefulWidget {
  final Finesse fin;

  _FinesseDetails(this.fin);

  @override
  _FinesseDetailsState createState() {
    return _FinesseDetailsState(fin);
  }
}

// Create a corresponding State class.
class _FinesseDetailsState extends State<_FinesseDetails> {
  Finesse fin;
  Future<List<Comment>> comments;
  Future<int> votes;
  Future<int> origVote;
  final TextEditingController _controller = TextEditingController();

  _FinesseDetailsState(Finesse fin) {
    this.fin = fin;
    this.comments = Network.getComments(fin.eventId);
    this.votes = Network.fetchVotes(fin.eventId);
    this.origVote =
        Network.fetchUserVoteOnEvent(fin.eventId, User.currentUser.email);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      initialData: [<Comment>[], 0, 0],
      future: Future.wait([comments, votes, origVote]),
      builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
        return snapshot.data != null
            ? mainCard(
                snapshot.data[0], snapshot.data[1], snapshot.data[2], context)
            : Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget mainCard(
      List<Comment> comments, int votes, int origVote, BuildContext context) {
    mainComments = comments;
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
              size: 24.0,
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
              size: 24.0,
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
                      ((getVoteCount(origVote, voteAmount, votes)) >= 0)
                          ? Icons.arrow_upward
                          : Icons.arrow_downward,
                      color: Color(0xffc47600),
                      size: 24.0)),
              Text(
                (getVoteCount(origVote, voteAmount, votes)).abs().toString() +
                    ((getVoteCount(origVote, voteAmount, votes) >= 0)
                        ? " upvotes"
                        : " downvotes"),
                style: TextStyle(fontSize: 16, color: Color(0xffff9900)),
              ),
            ]),
            Row(
              children: <Widget>[
                IconButton(
                  icon: Icon(
                    Icons.arrow_upward,
                    color: Color(0xffc47600),
                  ),
                  onPressed: (!canUpVote(origVote, voteAmount))
                      ? null
                      : () {
                          Network.postVote(
                              fin.eventId, User.currentUser.email, 1);
                          setState(() {
                            voteAmount = 1;
                          });
                        },
                ),
                IconButton(
                    icon: Icon(Icons.arrow_downward, color: Color(0xffc47600)),
                    color: Color(0xffc47600),
                    onPressed: (!canDownVote(origVote, voteAmount))
                        ? null
                        : () {
                            Network.postVote(
                                fin.eventId, User.currentUser.email, -1);
                            setState(() {
                              voteAmount = -1;
                            });
                          })
              ],
            )
          ],
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
        ));

    Widget userSection = Container(
      padding: const EdgeInsets.only(left: 20, bottom: 20),
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.only(right: 10),
            child: Icon(
              Icons.account_circle,
              color: Styles.darkOrange,
              size: 24.0,
            ),
          ),
          Text(
            "Posted by: ",
            style: TextStyle(
              fontSize: 16,
              color: Styles.brightOrange,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                fin.emailId,
                style: TextStyle(
                  fontSize: 16,
                  color: Styles.brightOrange,
                ),
              ),
            ],
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
              size: 24.0,
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
                    setState(() => mainComments.add(newComment));
                    Network.addComment(newComment, fin.eventId);
                    _controller.clear();
                  }),
      ),
      style: TextStyle(color: Colors.grey[100]),
      onFieldSubmitted: (comment) {
        if (comment.isNotEmpty) {
          Comment newComment = Comment.post(comment);
          setState(() => mainComments.add(newComment));
          Network.addComment(newComment, fin.eventId);
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

    Stream<Comment> commentStream = (() async* {
      while (true) {
        List<Comment> tempComments = await Network.getComments(fin.eventId);
        for (Comment c in tempComments) {
          if (!mainComments.contains(c)) {
            yield c;
          }
        }
        await Future<void>.delayed(Duration(seconds: 1));
      }
    })();

    Widget viewCommentSection = StreamBuilder(
      stream: commentStream,
      builder: (BuildContext context, AsyncSnapshot<Comment> snapshot) {
        if (snapshot.hasData &&
            snapshot.connectionState == ConnectionState.active) {
          mainComments.add(snapshot.data);
        }
        List<Widget> children =
            mainComments.map((comment) => getCommentView(comment)).toList();
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
                '${mainComments.length}',
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

  int getVoteCount(int origVote, int voteAmount, int votes) {
    if (origVote == -1) {
      if (voteAmount == 0) {
        return votes;
      } else if (voteAmount == 1) {
        return votes + 2;
      } else if (voteAmount == -1) {
        return votes;
      }
    } else if (origVote == 0) {
      if (voteAmount == 0) {
        return votes;
      } else if (voteAmount == 1) {
        return votes + 1;
      } else if (voteAmount == -1) {
        return votes - 1;
      }
    } else if (origVote == 1) {
      if (voteAmount == 0) {
        return votes;
      } else if (voteAmount == -1) {
        return votes - 2;
      } else if (voteAmount == 1) {
        return votes;
      }
    }
    throw Exception("Failure in getting vote count");
  }

  canUpVote(int origVote, int voteAmount) {
    if (origVote == 0) {
      if (voteAmount == 0) {
        return true;
      } else if (voteAmount == 1) {
        return false;
      } else if (voteAmount == -1) {
        return true;
      }
    } else if (origVote == -1) {
      if (voteAmount == 0 || voteAmount == -1) {
        return true;
      } else if (voteAmount == 1) {
        return false;
      }
    } else if (origVote == 1) {
      if (voteAmount == 0 || voteAmount == 1) {
        return false;
      } else if (voteAmount == -1) {
        return true;
      }
    }
    throw Exception("Failure to check upvoting");
  }

  canDownVote(int origVote, int voteAmount) {
    if (origVote == 0) {
      if (voteAmount == 0) {
        return true;
      } else if (voteAmount == 1) {
        return true;
      } else if (voteAmount == -1) {
        return false;
      }
    } else if (origVote == -1) {
      if (voteAmount == 0 || voteAmount == -1) {
        return false;
      } else if (voteAmount == 1) {
        return true;
      }
    } else if (origVote == 1) {
      if (voteAmount == 0 || voteAmount == 1) {
        return true;
      } else if (voteAmount == -1) {
        return false;
      }
    }
    throw Exception("Failure to check downvoting");
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
