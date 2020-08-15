import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:dotted_border/dotted_border.dart';
import 'package:finesse_nation/Comment.dart';
import 'package:finesse_nation/Finesse.dart';
import 'package:finesse_nation/Network.dart';
import 'package:finesse_nation/Styles.dart';
import 'package:finesse_nation/User.dart';
import 'package:finesse_nation/Util.dart';
import 'package:finesse_nation/main.dart';
import 'package:finesse_nation/widgets/PopUpBox.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';

enum DotMenu { markEnded }

/// Displays details about a specific [Finesse].
class FinessePage extends StatefulWidget {
  final Finesse fin;
  final List<bool> voteStatus;

  FinessePage(this.fin, this.voteStatus);

  @override
  _FinessePageState createState() => _FinessePageState();
}

class _FinessePageState extends State<FinessePage> {
  Finesse fin;
  List<bool> voteStatus;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController commentController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController durationController = TextEditingController();

  final picker = ImagePicker();

  bool _commentIsEmpty = true;

  bool _inEditMode;

  String tempImage;
  bool deletedImage;
  File _image;

  List<bool> activeStatus;

  // double width = 1;
  // double gap = 1;

  void resetState() {
    _inEditMode = false;

    tempImage = null;
    deletedImage = false;
    _image = null;
    fin.image = tempImage ?? fin.image;

    activeStatus = [fin.isActive, !fin.isActive];
  }

  @override
  void initState() {
    super.initState();

    fin = widget.fin;
    voteStatus = widget.voteStatus;

    resetState();
  }

  void _onImageButtonPressed(ImageSource source) async {
    PickedFile pickedFile = await picker.getImage(source: source);

    setState(() {
      _image = File(pickedFile.path);
    });
  }

  Future<void> uploadImagePopup() async {
    await PopUpBox.showPopupBox(
      title: "Upload Image",
      context: context,
      button: FlatButton(
        key: Key("UploadOK"),
        onPressed: () {
          Navigator.of(context, rootNavigator: true).pop();
        },
        child: Text(
          "CANCEL",
          style: TextStyle(
            color: primaryHighlight,
          ),
        ),
      ),
      willDisplayWidget: Column(
        children: [
          FlatButton(
            onPressed: () {
              _onImageButtonPressed(ImageSource.gallery);
              Navigator.of(context, rootNavigator: true).pop();
            },
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 15, right: 15, bottom: 15),
                  child: const Icon(
                    Icons.photo_library,
                    color: secondaryHighlight,
                  ),
                ),
                Text(
                  'From Gallery',
                  style: TextStyle(color: primaryHighlight, fontSize: 14),
                ),
              ],
            ),
          ),
          FlatButton(
            onPressed: () {
              _onImageButtonPressed(ImageSource.camera);
              Navigator.of(context, rootNavigator: true).pop();
            },
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 15, right: 15, bottom: 15),
                  child: const Icon(
                    Icons.camera_alt,
                    color: secondaryHighlight,
                  ),
                ),
                Text(
                  'From Camera',
                  style: TextStyle(
                    color: primaryHighlight,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget imageSection;
    if (_inEditMode && (fin.image == '' || deletedImage)) {
      imageSection = _image == null
          ? Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              customBorder: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: DottedBorder(
                color: secondaryHighlight,
                padding: EdgeInsets.all(10),
                strokeWidth: 1,
                dashPattern: [8, 8] /* [width, gap] */,
                borderType: BorderType.RRect,
                radius: Radius.circular(10),
                child: SizedBox(
                  width: 500,
                  child: Center(
                    child: Text(
                      'ADD IMAGE',
                      style: TextStyle(
                        fontSize: 16,
                        color: secondaryHighlight,
                      ),
                    ),
                  ),
                ),
              ),
              onTap: uploadImagePopup,
            ),
          ),
          /*Slider(
                  value: width,
                  onChanged: (val) {
                    setState(() {
                      width = val;
                    });
                  },
                  min: 0,
                  max: 20,
                  divisions: 20,
                  label: '$width',
                ),
                Slider(
                  value: gap,
                  onChanged: (val) {
                    setState(() {
                      gap = val;
                    });
                  },
                  min: 0,
                  max: 20,
                  divisions: 20,
                  label: '$gap',
                )*/
        ],
      )
          : Stack(
        alignment: Alignment.center,
        children: [
          Image.file(
            _image,
            width: 600,
            height: 240,
            fit: BoxFit.cover,
            colorBlendMode: BlendMode.luminosity,
            color: Colors.white.withOpacity(0.5),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: uploadImagePopup,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 30),
              ),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  tempImage = fin.image;
                  setState(() {
                    _image = null;
                    deletedImage = true;
                  });
                },
              ),
            ],
          ),
        ],
      );
    } else if (_inEditMode && fin.image != '') {
      imageSection = Stack(
        alignment: Alignment.center,
        children: [
          _image != null
              ? Image.file(
            _image,
            width: 600,
            height: 240,
            fit: BoxFit.cover,
            colorBlendMode: BlendMode.luminosity,
            color: Colors.white.withOpacity(0.5),
          )
              : Image.memory(
            fin.convertedImage,
            width: 600,
            height: 240,
            fit: BoxFit.cover,
            colorBlendMode: BlendMode.luminosity,
            color: Colors.white.withOpacity(0.5),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: uploadImagePopup,
                icon: Icon(Icons.edit),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 30),
              ),
              IconButton(
                onPressed: () {
                  tempImage = fin.image;
                  setState(() {
                    _image = null;
                    deletedImage = true;
                  });
                },
                icon: Icon(Icons.delete),
              ),
            ],
          ),
        ],
      );
    } else {
      imageSection = InkWell(
        onTap: () async {
          changeStatusColor(Colors.black);
          changeNavigationColor(Colors.black);
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  FullImage(
                    fin,
                  ),
            ),
          );
          changeStatusColor(primaryBackground);
          changeNavigationColor(primaryBackground);
        },
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
    }

    Widget titleSection = Container(
      padding: EdgeInsets.only(
          left: 20, bottom: _inEditMode ? 5 : 20, top: _inEditMode ? 0 : 20),
      child: _inEditMode
          ? SizedBox(
        width: 300,
        child: TextFormField(
          autovalidate: true,
          controller: titleController,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 30,
            color: primaryHighlight,
          ),
          decoration: const InputDecoration(
            hintText: "Title",
            hintStyle: TextStyle(
              color: secondaryHighlight,
            ),
          ),
          validator: (value) =>
          value.isEmpty ? 'Please enter a title' : null,
        ),
      )
          : Text(
        fin.eventTitle,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 30,
          color: fin.isActive ? primaryHighlight : inactiveColor,
        ),
      ),
    );

    Widget locationSection = Container(
      padding: EdgeInsets.only(left: 20, bottom: _inEditMode ? 5 : 20),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.only(right: 10),
            child: Icon(
              Icons.place,
              color: fin.isActive ? secondaryHighlight : inactiveColor,
            ),
          ),
          _inEditMode
              ? SizedBox(
            width: 300,
            child: TextFormField(
              autovalidate: true,
              controller: locationController,
              style: TextStyle(
                fontSize: 16,
                color: primaryHighlight,
              ),
              decoration: const InputDecoration(
                hintText: "Location",
                hintStyle: TextStyle(
                  color: secondaryHighlight,
                ),
              ),
              validator: (value) =>
              value.isEmpty ? 'Please enter a location' : null,
            ),
          )
              : Flexible(
            child: InkWell(
              onTap: () =>
                  launch(
                      'https://www.google.com/maps/search/${fin.location}'),
              child: Text(
                fin.location,
                style: TextStyle(
                  fontSize: 16,
                  color: fin.isActive ? primaryHighlight : inactiveColor,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    Widget descriptionSection = Container(
      padding: EdgeInsets.only(left: 20, bottom: _inEditMode ? 5 : 20),
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.only(right: 10),
            child: Icon(
              Icons.short_text,
              color: fin.isActive
                  ? fin.isActive ? secondaryHighlight : inactiveColor
                  : inactiveColor,
            ),
          ),
          _inEditMode
              ? SizedBox(
            width: 300,
            child: TextFormField(
              controller: descriptionController,
              style: TextStyle(
                fontSize: 16,
                color: primaryHighlight,
              ),
              decoration: const InputDecoration(
                hintText: "Description",
                hintStyle: TextStyle(
                  color: secondaryHighlight,
                ),
              ),
            ),
          )
              : Flexible(
            child: SelectableLinkify(
              text: fin.description,
              style: TextStyle(
                fontSize: 16,
                color: fin.isActive ? primaryHighlight : inactiveColor,
              ),
              linkStyle: TextStyle(color: secondaryHighlight),
              options: LinkifyOptions(
                removeWww: true,
              ),
              onOpen: (link) async {
                if (await canLaunch(link.url)) {
                  await launch(link.url);
                } else {
                  throw 'Could not launch $link';
                }
              },
            ),
          ),
        ],
      ),
    );

    Widget timeSection = Container(
      padding: EdgeInsets.only(left: 20, bottom: _inEditMode ? 5 : 20),
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.only(right: 10),
            child: Icon(
              Icons.calendar_today,
              color: fin.isActive ? secondaryHighlight : inactiveColor,
            ),
          ),
          _inEditMode
              ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 30,
                child: ToggleButtons(
                  fillColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  selectedColor: primaryHighlight,
                  color: secondaryHighlight,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Text(
                        'Ongoing',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Text(
                        'Inactive',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                  onPressed: (int index) {
                    setState(() {
                      for (int buttonIndex = 0;
                      buttonIndex < activeStatus.length;
                      buttonIndex++) {
                        if (buttonIndex == index) {
                          setState(() {
                            activeStatus[buttonIndex] = true;
                          });
                        } else {
                          setState(() {
                            activeStatus[buttonIndex] = false;
                          });
                        }
                      }
                    });
                  },
                  isSelected: activeStatus,
                ),
              ),
              if (activeStatus[0])
                SizedBox(
                  width: 300,
                  height: 30,
                  child: TextFormField(
                    controller: durationController,
                    style: TextStyle(
                      fontSize: 16,
                      color: primaryHighlight,
                    ),
                    decoration: const InputDecoration(
                      prefixText: 'Duration: ',
                      prefixStyle: TextStyle(
                        fontSize: 16,
                        color: secondaryHighlight,
                      ),
                    ),
                  ),
                ),
            ],
          )
              : !fin.isActive
              ? Text(
            'Inactive',
            style: TextStyle(
              fontSize: 16,
              color: inactiveColor,
            ),
          )
              : Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (fin.duration != '')
                  Flexible(
                    child: Text(
                      'Duration: ' + fin.duration,
                      style: TextStyle(
                        fontSize: 16,
                        color: primaryHighlight,
                      ),
                    ),
                  ),
                Text(
                  'Posted ' + timeago.format(fin.postedTime),
                  style: TextStyle(
                    fontSize: fin.duration != '' ? 14 : 16,
                    color: fin.duration != ''
                        ? secondaryHighlight
                        : primaryHighlight,
                  ),
                ),
              ],
            ),
          ),
        ],
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
          Flexible(
            child: Text(
              fin.emailId,
              style: TextStyle(
                fontSize: 16,
                color: fin.isActive ? primaryHighlight : inactiveColor,
              ),
            ),
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
                    handleVote(index, voteStatus, fin);
                  });
                },
                isSelected: voteStatus,
              ),
            ),
        ],
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
      ),
    );

    Future<void> postComment(String comment) async {
      Comment newComment = Comment.post(comment);
      setState(() => fin.comments.add(newComment));
      addComment(newComment, fin.eventId);
      fin.numComments++;
      commentController.clear();
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
        controller: commentController,
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
                String comment = commentController.value.text;
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
          ],
        ),
      );
    }

    Widget viewCommentSection = FutureBuilder(
      initialData: fin.comments,
      future: getComments(fin.eventId),
      builder: (context, snapshot) {
        if (snapshot.hasData &&
            snapshot.connectionState == ConnectionState.done) {
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

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !_inEditMode,
        title: _inEditMode
            ? Text('Editing \'${fin.eventTitle}\'')
            : Text(fin.eventTitle),
        actions: <Widget>[
          if (fin.emailId == User.currentUser.email)
            if (!_inEditMode)
              IconButton(
                icon: Icon(
                  Icons.edit,
                  color: primaryHighlight,
                ),
                onPressed: () {
                  setState(() {
                    _inEditMode = true;
                    titleController.text = fin.eventTitle;
                    locationController.text = fin.location;
                    descriptionController.text = fin.description;
                    durationController.text = fin.duration;
                    activeStatus = [fin.isActive, !fin.isActive];
                  });
                },
              )
            else
              Row(
                children: [
                  IconButton(
                      tooltip: 'Submit',
                      icon: Icon(
                        Icons.check,
                        color: primaryHighlight,
                      ),
                      onPressed: () {
                        if (_formKey.currentState.validate()) {
                          setState(() {
                            if (_image != null) {
                              fin.image =
                                  base64Encode(_image.readAsBytesSync());
                              fin.convertedImage = base64.decode(fin.image);
                            }
                            if (deletedImage) {
                              fin.image = '';
                            }
                            fin.eventTitle = titleController.text;
                            fin.location = locationController.text;
                            fin.description = descriptionController.text;
                            if (activeStatus[0]) {
                              fin.duration = durationController.text;
                              fin.markedInactive.remove(User.currentUser.email);
                            } else {
                              fin.markedInactive.add(User.currentUser.email);
                            }
                            resetState();
                          });
                          updateFinesse(fin);
                        }
                      }),
                  IconButton(
                      tooltip: 'Cancel',
                      icon: Icon(
                        Icons.close,
                        color: primaryHighlight,
                      ),
                      onPressed: () {
                        bool wasEdited = (_image != null ||
                            (fin.image != '' && deletedImage == true)) ||
                            (titleController.text != fin.eventTitle) ||
                            (locationController.text != fin.location) ||
                            (descriptionController.text != fin.description) ||
                            (activeStatus[0] != fin.isActive) ||
                            (durationController.text != fin.duration);
                        if (wasEdited) {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  title: Text('Discard changes?'),
                                  content: SingleChildScrollView(
                                    child: Text(
                                        'Are you sure you want to discard your changes to this event?'),
                                  ),
                                  actions: <Widget>[
                                    FlatButton(
                                      child: Text('NO'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    FlatButton(
                                      child: Text('YES'),
                                      onPressed: () {
                                        setState(() {
                                          resetState();
                                        });
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              });
                        } else {
                          setState(() {
                            resetState();
                          });
                        }
                      }),
                  IconButton(
                      tooltip: 'Delete',
                      icon: Icon(
                        Icons.delete,
                        color: primaryHighlight,
                      ),
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                title: Text('Delete?'),
                                content: SingleChildScrollView(
                                  child: Text(
                                      'Are you sure you want to delete this event?'),
                                ),
                                actions: <Widget>[
                                  FlatButton(
                                    child: Text('NO'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  FlatButton(
                                    child: Text('YES'),
                                    onPressed: () async {
                                      await removeFinesse(fin);
                                      await Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                            builder: (BuildContext context) =>
                                                HomePage()),
                                            (Route<dynamic> route) => false,
                                      );
                                    },
                                  ),
                                ],
                              );
                            });
                      }),
                ],
              ),
          /* if (fin.isActive)
            PopupMenuButton<DotMenu>(
              key: Key("threeDotButton"),
              onSelected: (DotMenu result) {
                setState(() {
                  _markAsEnded(fin);
                });
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<DotMenu>>[
                const PopupMenuItem<DotMenu>(
                  key: Key("markAsEndedButton"),
                  value: DotMenu.markEnded,
                  child: Text('Mark as inactive'),
                ),
              ],
            )*/
        ],
      ),
      backgroundColor: primaryBackground,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Card(
            clipBehavior: Clip.hardEdge,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            color: secondaryBackground,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (fin.image != "" || _inEditMode) imageSection,
                      titleSection,
                      locationSection,
                      if (fin.description != "" || _inEditMode)
                        descriptionSection,
                      timeSection,
                    ],
                  ),
                ),
                userSection,
                votingSection,
                viewCommentSection,
                addCommentSection,
              ],
            ),
          ),
        ),
      ),
    );
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
        onTap: () {
          Navigator.pop(context);
        },
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
