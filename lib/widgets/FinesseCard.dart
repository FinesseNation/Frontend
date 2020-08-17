import 'package:finesse_nation/Finesse.dart';
import 'package:finesse_nation/Pages/FinessePage.dart';
import 'package:finesse_nation/Styles.dart';
import 'package:finesse_nation/User.dart';
import 'package:finesse_nation/Util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:timeago/timeago.dart' as timeago;

class FinesseCard extends StatefulWidget {
  final Finesse fin;

  FinesseCard(this.fin);

  @override
  _FinesseCardState createState() => _FinesseCardState();
}

class _FinesseCardState extends State<FinesseCard> {
  Finesse fin;
  List<bool> isSelected;

  @override
  void initState() {
    super.initState();
    fin = widget.fin;
    isSelected = [
      User.currentUser.upvoted.contains(fin.eventId),
      User.currentUser.downvoted.contains(fin.eventId)
    ];
  }

  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Card(
        clipBehavior: Clip.hardEdge,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        color: secondaryBackground,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    FinessePage(
                      fin,
                      voteStatus: isSelected,
                    ),
              ),
            ).whenComplete(() => setState(() => {}));
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
                          colorBlendMode: BlendMode.saturation,
                          color:
                              fin.isActive ? Colors.transparent : inactiveColor,
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
                          fontSize: 17,
                          fontWeight: FontWeight.w300,
                          color:
                              fin.isActive ? primaryHighlight : inactiveColor,
                        ),
                      ),
                    ),
                    Text(
                      fin.location + " · ${timeago.format(fin.postedTime)}",
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            fin.isActive ? secondaryHighlight : inactiveColor,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          "${fin.points} ${(fin.points == 1) ? "point" : "points"}\n"
                          "${fin.numComments} ${(fin.numComments == 1) ? "comment" : "comments"}",
                          style: TextStyle(
                            fontSize: 12,
                            color: fin.isActive
                                ? secondaryHighlight
                                : inactiveColor,
                          ),
                        ),
                        Visibility(
                          visible: fin.isActive,
                          maintainState: true,
                          maintainAnimation: true,
                          maintainSize: true,
                          child: ToggleButtons(
                            renderBorder: false,
                            fillColor: Colors.transparent,
                            splashColor: Colors.transparent,
                            selectedColor: primaryHighlight,
                            color: secondaryHighlight,
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
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
