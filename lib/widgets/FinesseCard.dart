import 'package:finesse_nation/Finesse.dart';
import 'package:finesse_nation/Pages/FinessePage.dart';
import 'package:flutter/material.dart';
import 'package:finesse_nation/Util.dart';
import 'package:finesse_nation/Styles.dart';
import 'package:finesse_nation/Network.dart';
import 'package:finesse_nation/User.dart';

class FinesseCard extends StatefulWidget {
  final Finesse fin;
  final List<bool> isSelected;

  FinesseCard(this.fin, this.isSelected);

  @override
  _FinesseCardState createState() => _FinesseCardState(fin, isSelected);
}

class _FinesseCardState extends State<FinesseCard> {
  Finesse fin;
  List<bool> isSelected;

  _FinesseCardState(this.fin, this.isSelected);

  void handleVote(int index, List<String> upvoted, List<String> downvoted) {
    for (int buttonIndex = 0; buttonIndex < isSelected.length; buttonIndex++) {
      if (buttonIndex == index) {
        // button that was pressed
        if (index == 0) {
          // upvote
          if (isSelected[buttonIndex]) {
            upvoted.remove(fin.eventId);
            fin.downvote();
          } else {
            upvoted.add(fin.eventId);
            fin.upvote();
          }
        } else {
          // downvote
          if (isSelected[buttonIndex]) {
            downvoted.remove(fin.eventId);
            fin.upvote();
          } else {
            downvoted.add(fin.eventId);
            fin.downvote();
          }
        }
        setState(() {
          isSelected[buttonIndex] = !isSelected[buttonIndex];
        });
      } else {
        // button that wasn't pressed
        if (index == 0) {
          // upvote
          if (isSelected[buttonIndex]) {
            downvoted.remove(fin.eventId);
            fin.upvote();
          }
        } else {
          // downvote
          if (isSelected[buttonIndex]) {
            upvoted.remove(fin.eventId);
            fin.downvote();
          }
        }
        setState(() {
          isSelected[buttonIndex] = false;
        });
      }
    }
    Network.setVotes(upvoted, downvoted);
    Network.updateFinesse(fin);
  }

  Widget build(BuildContext context) {
    List<String> upvoted = User.currentUser.upvoted;
    List<String> downvoted = User.currentUser.downvoted;
    return Card(
      color: Styles.darkGrey,
      child: InkWell(
        onTap: () => {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => FinessePage(fin)),
          )
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (fin.image != "")
              Hero(
                tag: fin.eventId,
                child: fin.image == ""
                    ? Container()
                    : Image.memory(
                        fin.convertedImage,
                        width: 600,
                        height: 240,
                        fit: BoxFit.cover,
                      ),
              ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2.0),
                    child: Text(
                      fin.eventTitle,
                      key: Key("title"),
                      style: TextStyle(
                        fontSize: 20,
                        color: Styles.brightOrange,
                      ),
                    ),
                  ),
                  Text(
                    fin.location + " · ${Util.timeSince(fin.postedTime)}",
                    style: TextStyle(
                      fontSize: 14,
                      color: Styles.darkOrange,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        "${fin.points} points\n"
                        "4 comments",
                        style: TextStyle(
                          fontSize: 14,
                          color: Styles.darkOrange,
                        ),
                      ),
                      ToggleButtons(
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
                        onPressed: (index) =>
                            handleVote(index, upvoted, downvoted),
                        isSelected: isSelected,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
