import 'dart:convert';
import 'dart:io';

import 'package:finesse_nation/Finesse.dart';
import 'package:finesse_nation/Network.dart';
import 'package:finesse_nation/Styles.dart';
import 'package:finesse_nation/User.dart';
import 'package:finesse_nation/main.dart';
import 'package:finesse_nation/widgets/PopUpBox.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Allows the user to add a new [Finesse].
class AddEvent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appTitle = 'Share a Finesse';

    return Scaffold(
      appBar: AppBar(
        title: Text(appTitle),
      ),
      backgroundColor: secondaryBackground,
      body: _MyCustomForm(),
    );
  }
}

typedef void OnPickImageCallback(
    double maxWidth, double maxHeight, int quality);

// Create a Form widget.
class _MyCustomForm extends StatefulWidget {
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

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
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
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextFormField(
                  key: Key('name'),
                  textCapitalization: TextCapitalization.sentences,
                  style: TextStyle(
                    color: Colors.white,
                  ),
                  controller: eventNameController,
                  decoration: const InputDecoration(
                    labelText: "Title *",
                    labelStyle: TextStyle(
                      color: primaryHighlight,
                    ),
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter an event name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  key: Key('location'),
                  textCapitalization: TextCapitalization.sentences,
                  style: TextStyle(
                    color: Colors.white,
                  ),
                  controller: locationController,
                  decoration: const InputDecoration(
                    labelText: "Location *",
                    labelStyle: TextStyle(
                      color: primaryHighlight,
                    ),
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter a location';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  key: Key('description'),
                  textCapitalization: TextCapitalization.sentences,
                  style: TextStyle(
                    color: Colors.white,
                  ),
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: "Description",
                    labelStyle: TextStyle(
                      color: primaryHighlight,
                    ),
                  ),
                  validator: (value) {
                    return null;
                  },
                ),
                TextFormField(
                  key: Key('duration'),
                  textCapitalization: TextCapitalization.sentences,
                  style: TextStyle(
                    color: Colors.white,
                  ),
                  controller: durationController,
                  decoration: const InputDecoration(
                    labelText: "Duration",
                    labelStyle: TextStyle(
                      color: primaryHighlight,
                    ),
                  ),
                  validator: (value) {
                    return null;
                  },
                ),
                Container(
                  padding: const EdgeInsets.only(top: 20),
                  child: Text(
                    "Type",
                    style: TextStyle(
                      color: primaryHighlight,
                      fontSize: 16,
                    ),
                  ),
                ),
                DropdownButton<String>(
                  items: <String>['Food', 'Other'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    );
                  }).toList(),
                  value: _type,
                  onChanged: (newValue) {
                    setState(() {
                      _type = newValue;
                    });
                  },
                ),
                Container(
                  padding: const EdgeInsets.only(top: 15, bottom: 10),
                  child: Text(
                    "Image",
                    style: TextStyle(
                      color: primaryHighlight,
                      fontSize: 16,
                    ),
                  ),
                ),
                if (_image != null) Image.file(_image, height: 240),
                Padding(
                  padding: EdgeInsets.only(top: 15),
                  child: ButtonTheme(
                    minWidth: 100,
                    height: 50,
                    child: FlatButton(
                      color: primaryHighlight,
                      key: Key("Upload"),
                      onPressed: () async {
                        await uploadImagePopup();
                      },
                      child: Text(
                        'ADD IMAGE',
                        style: TextStyle(color: secondaryBackground),
                      ),
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: ButtonTheme(
                      minWidth: 100,
                      height: 50,
                      child: RaisedButton(
                        key: Key('submit'),
                        color: primaryHighlight,
                        onPressed: () async {
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
                            String newId = jsonDecode(res)['id'];
                            User.currentUser.upvoted.add(newId);
                            FirebaseMessaging().subscribeToTopic(newId);
                            await FirebaseMessaging()
                                .unsubscribeFromTopic(ALL_TOPIC);
                            await sendToAll(
                                newFinesse.eventTitle, newFinesse.location,
                                id: newId, isNew: true);
                            if (User.currentUser.notifications) {
                              FirebaseMessaging().subscribeToTopic(ALL_TOPIC);
                            }
                            await Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      MyHomePage()),
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
