import 'dart:typed_data';
import 'dart:convert';
import 'package:finesse_nation/Comment.dart';
import 'package:finesse_nation/User.dart';

/// An event involving free food/items.
class Finesse {
  /// The unique ID for this Finesse.
  String eventId;

  /// The title of this Finesse.
  String eventTitle;

  /// The description of this Finesse.
  String description;

  /// The image of this Finesse.
  String image;

  /// The location of this Finesse.
  String location;

  /// The duration of this Finesse.
  String duration;

  /// The category of this Finesse (Food/Other).
  String category;

  /// The time this Finesse was posted.
  DateTime postedTime;

  /// The list of emailIds of [User]s who have marked this Finesse as inactive.
  List<String> isActive;

  /// The base64-encoded image of this Finesse.
  Uint8List convertedImage;

  /// The emailId of the [User] who posted this Finesse.
  String emailId;

  /// The school of the [User] who posted this Finesse.
  String school;

  /// The number of points for this Finesse.
  int points;

  /// The number of comments for this Finesse.
  int numComments;

  /// The comments on this Finesse.
  List<Comment> comments;

  /// Creates a Finesse.
  Finesse(
    String eventId,
    String title,
    String description,
    String image,
    String location,
    String duration,
    String category,
    DateTime postedTime,
    List<String> isActive,
    String school,
    String emailId,
    int points,
    int numComments,
  ) {
    this.eventId = eventId;
    this.eventTitle = title;
    this.description = description;
    this.image = image;
    this.location = location;
    this.duration = duration;
    this.category = category;
    this.postedTime = postedTime;
    this.convertedImage = image == null ? null : base64.decode(image);
    this.isActive = isActive;
    this.school = school;
    this.emailId = emailId;
    this.points = points;
    this.numComments = numComments;
    this.comments = [];
  }

  /// Creates a Finesse with an empty event id.
  static Finesse finesseAdd(
    String title,
    String description,
    String image,
    String location,
    String duration,
    String category,
    DateTime timePosted, {
    List<String> isActive: const <String>[],
    String school,
    String email,
    int points: 1,
    int numComments: 0,
  }) {
    return Finesse(
      null,
      title,
      description,
      image,
      location,
      duration,
      category,
      timePosted,
      isActive,
      User.currentUser?.school ?? 'test',
      User.currentUser?.email ?? 'test',
      points,
      numComments,
    );
  }

  /// Attempts to convert the [time] from a [String] to a [DateTime].
  ///
  /// Returns the converted time on success, the current time on fail.
  static DateTime parse(String time) {
    if (time != null) {
      try {
        String timeStr = time.toString();
        DateTime res = DateTime.parse(timeStr);
        return res;
      } catch (Exception) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  /// Creates a Finesse from [json].
  factory Finesse.fromJson(Map<String, dynamic> json) {
    Finesse fin = Finesse(
      json['_id'],
      json['eventTitle'] ?? "",
      json['description'] ?? "",
      json['image'] ?? "",
      json['location'] ?? "",
      json['duration'] ?? "",
      json['category'] ?? "",
      parse(json['postedTime']) ?? DateTime.now(),
      List<String>.from(json['isActive']) ?? [],
      json['school'] ?? "",
      json['emailId'] ?? "",
      json['points'] ?? 0,
      json['numComments'] ?? 0,
    );
    return fin;
  }

  /// Returns a [Map] containing this Finesse's fields.
  Map toMap() {
    var map = Map<String, dynamic>();
    map["eventTitle"] = eventTitle;
    map["description"] = description;
    map["image"] = image;
    map["location"] = location;
    map["duration"] = duration;
    map["category"] = category;
    map['postedTime'] = postedTime.toString();
    map['isActive'] = isActive;
    map['school'] = school;
    map['emailId'] = emailId;
    map['points'] = points;
    map['numComments'] = numComments;
    return map;
  }

  int upvote() => ++points;

  int downvote() => --points;
}
