import 'dart:typed_data';
import 'dart:convert';
import 'package:finesse_nation/main.dart';

class Finesse {
  String eventId;
  String eventTitle;
  String description;
  String image;
  String location;
  String duration;
  String category;
  DateTime postedTime;
  bool isActive;
  Uint8List convertedImage;
  String emailId;
  String school;

  static finesseAdd(
      title, description, image, location, duration, category, timePosted,
      {bool isActive = true, String school, String email}) {
    return Finesse(null, title, description, image, location, duration,
        category, timePosted, isActive, currentUser.email, currentUser.email);
  }

  Finesse(var eventId, var title, var description, var image, var location,
      var duration, var category, var timePosted, var isActive, var school, var emailId) {
    this.eventId = eventId;
    this.eventTitle = title;
    this.description = description;
    this.image = image;
    this.location = location;
    this.duration = duration;
    this.category = category;
    this.postedTime = timePosted;
    this.convertedImage = image == null ? null : base64.decode(image);
    this.isActive = isActive;
    this.school = school;
    this.emailId = emailId;
  }

  factory Finesse.fromJson(Map<String, dynamic> json) {
    return Finesse(
      json['_id'],
      json['eventTitle'] != null ? json['eventTitle'] : "",
      json['description'] != null ? json['description'] : "",
      json['image'] != null ? json['image'] : "",
      json['location'] != null ? json['location'] : "",
      json['duration'] != null ? json['duration'] : "",
      json['category'] != null ? json['category'] : "",
      json['postedTime'] != null ? DateTime.parse(json['postedTime']) : null,
      json['isActive'] != null ? json['isActive'] : true,
      json['school']!= null ? json['school'] : "",
      json['emailId']!= null ? json['emailId'] : "",

    );
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["eventTitle"] = eventTitle;
    map["description"] = description;
    map["image"] = image;
    map["location"] = location;
    map["duration"] = duration;
    map["category"] = category;
    map['postedTime'] = postedTime.toString();
    map['isActive'] = true;
    map['school'] = school;
    map['emailId'] = emailId;
    return map;
  }

  void setId(id) {
    this.eventId = id;
  }

  void setDescription(desc) {
    this.description = desc;
  }

  String getImage() {
    return image;
  }

  Uint8List getConvertedImage() {
    return convertedImage;
  }

  String getTitle() {
    return eventTitle;
  }

  String getLocation() {
    return location;
  }

  String getDescription() {
    return description;
  }

  String getDuration() {
    return duration;
  }

  String getCategory() {
    return category;
  }

  String getId() {
    return eventId;
  }

  DateTime getPostedTime() {
    return postedTime;
  }

  bool getActive() {
    return this.isActive;
  }
}
