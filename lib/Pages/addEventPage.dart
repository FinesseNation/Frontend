import 'dart:convert';
import 'dart:io';

import 'package:finesse_nation/Finesse.dart';
import 'package:finesse_nation/Network.dart';
import 'package:finesse_nation/Styles.dart';
import 'package:finesse_nation/User.dart';
import 'package:finesse_nation/main.dart';
import 'package:finesse_nation/widgets/PopUpBox.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

/// Allows the user to add a new [Finesse].
class AddEvent extends StatelessWidget {
  final bool isOngoing;

  AddEvent(this.isOngoing);

  @override
  Widget build(BuildContext context) {
    final appTitle = 'Share a Finesse';

    return Scaffold(
      appBar: AppBar(
        title: Text(appTitle),
      ),
      backgroundColor: primaryBackground,
      body: _MyCustomForm(isOngoing),
    );
  }
}

// Create a Form widget.
class _MyCustomForm extends StatefulWidget {
  final bool isOngoing;

  _MyCustomForm(this.isOngoing);

  @override
  _MyCustomFormState createState() {
    return _MyCustomFormState();
  }
}

// Create a corresponding State class.
// This class holds data related to the form.
class _MyCustomFormState extends State<_MyCustomForm> {
  final _formKey = GlobalKey<FormState>();
  final eventNameController = TextEditingController();
  final locationController = TextEditingController();
  final descriptionController = TextEditingController();
  final durationController = TextEditingController();
  final picker = ImagePicker();

  DateTime _startDate;
  DateTime _endDate;
  TimeOfDay _startTime;
  TimeOfDay _endTime;

  String _type = "Food";

  File _image;
  double width = 1200;
  double height = 480;

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    eventNameController.dispose();
    locationController.dispose();
    descriptionController.dispose();
    durationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    DateTime now = DateTime.now();
    _startDate = now.subtract(
      Duration(
        hours: now.hour,
        minutes: now.minute,
        seconds: now.second,
        milliseconds: now.millisecond,
        microseconds: now.microsecond,
      ),
    );
    print('init start = $_startDate');
    _startTime = TimeOfDay.now();
    _endDate = _startDate;
    _endTime = TimeOfDay(
      hour: _startTime.hour + 1,
      minute: _startTime.minute,
    ); // TODO: Won't be correct if time after 11pm
  }

  bool endIsBeforeStart() {
    DateTime start = _startDate.add(
      Duration(
        hours: _startTime.hour,
        minutes: _startTime.minute,
      ),
    );
    DateTime end = _endDate.add(
      Duration(
        hours: _endTime.hour,
        minutes: _endTime.minute,
      ),
    );
    print('start = $start');
    print('end = $end');

    print(end.isBefore(start) ? 'invalid' : 'valid');
    print('-------------------');
    return end.isBefore(start);
  }

  void _onImageButtonPressed(ImageSource source) async {
    final pickedFile = await picker.getImage(source: source);

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

  Widget timeRow(String type) {
    bool isStart = type == 'Start';
    bool isInvalid = isStart && endIsBeforeStart();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: Text(
            type,
            style: TextStyle(
              color: secondaryHighlight,
              fontSize: 12,
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
              onTap: () async {
                DateTime tempDate = await showDatePicker(
                  context: context,
                  initialDate: isStart ? _startDate : _endDate,
                  firstDate: isStart ? DateTime.now() : _startDate,
                  lastDate: DateTime.now().add(
                    Duration(days: 365),
                  ),
                );
                if (tempDate == null) {
                  return;
                }
                setState(() {
                  if (isStart) {
                    _startDate = tempDate;
                    if (endIsBeforeStart()) {
                      // TODO: increment end date and time correctly
                      _endDate = tempDate;
                    }
                  } else {
                    _endDate = tempDate;
                  }
                });
              },
              child: Text(
                DateFormat('EEEE, MMM d, y')
                    .format(isStart ? _startDate : _endDate),
                style: TextStyle(
                  color: isInvalid ? Colors.red : primaryHighlight,
                  fontSize: 16,
                ),
              ),
            ),
            InkWell(
              onTap: () async {
                TimeOfDay tempTime = await showTimePicker(
                  context: context,
                  initialTime: isStart ? _startTime : _endTime,
                );
                if (tempTime == null) {
                  return;
                }
                setState(() {
                  isStart ? _startTime = tempTime : _endTime = tempTime;
                });
              },
              child: Text(
                isStart ? _startTime.format(context) : _endTime.format(context),
                style: TextStyle(
                  color: isInvalid ? Colors.red : primaryHighlight,
                  fontSize: 16,
                ),
              ),
            )
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus &&
            currentFocus.focusedChild != null) {
          currentFocus.focusedChild.unfocus();
        }
      },
      child: SingleChildScrollView(
        child: Container(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Card(
                    clipBehavior: Clip.hardEdge,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    color: secondaryBackground,
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 10, right: 15, bottom: 10),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: Icon(
                                  Icons.title,
                                  color: secondaryHighlight,
                                ),
                              ),
                              Expanded(
                                child: TextFormField(
                                  key: Key('name'),
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                  controller: eventNameController,
                                  decoration: const InputDecoration(
                                    labelText: "Title",
                                    labelStyle: TextStyle(
                                      color: secondaryHighlight,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Please enter an event name';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: Icon(
                                  Icons.location_on,
                                  color: secondaryHighlight,
                                ),
                              ),
                              Expanded(
                                child: TextFormField(
                                  key: Key('location'),
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                  controller: locationController,
                                  decoration: const InputDecoration(
                                    labelText: "Location",
                                    labelStyle: TextStyle(
                                      color: secondaryHighlight,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Please enter a location';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: Icon(
                                  Icons.short_text,
                                  color: secondaryHighlight,
                                ),
                              ),
                              Expanded(
                                child: TextFormField(
                                  key: Key('description'),
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                  controller: descriptionController,
                                  decoration: const InputDecoration(
                                    labelText: "Description",
                                    labelStyle: TextStyle(
                                      color: secondaryHighlight,
                                    ),
                                  ),
                                  validator: (value) {
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: Icon(
                                  Icons.calendar_today,
                                  color: secondaryHighlight,
                                ),
                              ),
                              if (widget.isOngoing)
                                Expanded(
                                  child: TextFormField(
                                    key: Key('duration'),
                                    textCapitalization:
                                        TextCapitalization.sentences,
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                    controller: durationController,
                                    decoration: const InputDecoration(
                                      labelText: "Duration",
                                      labelStyle: TextStyle(
                                        color: secondaryHighlight,
                                      ),
                                    ),
                                    validator: (value) {
                                      return null;
                                    },
                                  ),
                                )
                              else
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        timeRow('Start'),
                                        Padding(
                                          padding:
                                              EdgeInsets.symmetric(vertical: 2),
                                        ),
                                        timeRow('End'),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 15),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: Icon(
                                    Icons.image,
                                    color: secondaryHighlight,
                                  ),
                                ),
                                if (_image != null)
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    child: InkWell(
                                      child: Image.file(_image, height: 240),
                                      onTap: () async {
                                        await uploadImagePopup();
                                      },
                                    ),
                                  )
                                else
                                  SizedBox(
                                    height: 25,
                                    child: OutlineButton(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(100)),
                                      child: Text(
                                        'Add image',
                                        style: TextStyle(
                                          color: secondaryHighlight,
                                          fontSize: 16,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                      key: Key("Upload"),
                                      onPressed: () async {
                                        await uploadImagePopup();
                                      },
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16.0, horizontal: 10),
                    child: ButtonTheme(
                      minWidth: 100,
                      height: 50,
                      child: RaisedButton(
                        key: Key('submit'),
                        color: primaryHighlight,
                        onPressed: () async {
                          if (endIsBeforeStart()) {
                            Scaffold.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    "The event can't end before it begins"),
                              ),
                            );
                            return;
                          } else {
                            Scaffold.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Cool"),
                              ),
                            );
                            return;
                          }
                          if (_formKey.currentState.validate()) {
                            Scaffold.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Sharing Finesse',
                                  style: TextStyle(
                                    color: secondaryHighlight,
                                  ),
                                ),
                              ),
                            );
                            Text eventName = Text(eventNameController.text);
                            Text location = Text(locationController.text);
                            Text description = Text(descriptionController.text);
                            Text duration = Text(durationController.text);
                            DateTime currTime = DateTime.now();

                            String imageString;
                            if (_image == null) {
                              imageString = '';
                            } else {
                              imageString =
                                  base64Encode(_image.readAsBytesSync());
                            }

                            Finesse newFinesse = Finesse.finesseAdd(
                              eventName.data,
                              description.data,
                              imageString,
                              location.data,
                              duration.data,
                              _type,
                              currTime,
                            );
                            String res = await addFinesse(newFinesse);
                            // could exploit the fact that id is sequential-ish
                            String newId = jsonDecode(res)['id'];
                            User.currentUser.upvoted.add(newId);
                            User.currentUser.subscriptions.add(newId);
                            // just don't display anything if app is open
                            // in order to avoid unsub then resub
                            await firebaseMessaging
                                .unsubscribeFromTopic(ALL_TOPIC);
                            await sendToAll(
                                newFinesse.eventTitle, newFinesse.location,
                                id: newId, isNew: true);
                            if (User.currentUser.notifications) {
                              firebaseMessaging.subscribeToTopic(newId);
                              firebaseMessaging.subscribeToTopic(ALL_TOPIC);
                            }
                            await Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      HomePage()),
                                  (Route<dynamic> route) => false,
                            );
                          }
                        },
                        child: Text(
                          'SUBMIT',
                          style: TextStyle(color: secondaryBackground),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
