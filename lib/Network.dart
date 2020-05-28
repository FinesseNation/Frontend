import 'dart:convert';
import 'package:finesse_nation/Finesse.dart';
import 'package:finesse_nation/User.dart';
import 'package:finesse_nation/Pages/SettingsPage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:finesse_nation/.env.dart';
import 'package:finesse_nation/login/flutter_login.dart';
import 'package:finesse_nation/Comment.dart';

/// Contains functions used to interact with the API.
class Network {
  /// The root domain for the Finesse Nation API.
  static const DOMAIN = 'https://finesse-nation.herokuapp.com/api/';

  /// Deleting a Finesse.
  static const DELETE_URL = DOMAIN + 'food/deleteEvent';

  /// Adding a Finesse.
  static const ADD_URL = DOMAIN + 'food/addEvent';

  /// Getting the Finesses.
  static const GET_URL = DOMAIN + 'food/getEvents';

  /// Adding a comment.
  static const ADD_COMMENT_URL = DOMAIN + 'comment';

  /// Getting a comment.
  static const GET_COMMENT_URL = DOMAIN + 'comment/';

  /// Updating a Finesse.
  static const UPDATE_URL = DOMAIN + 'food/updateEvent';

  /// Logging in with an existing account.
  static const LOGIN_URL = DOMAIN + 'user/login';

  /// Creating a new account.
  static const SIGNUP_URL = DOMAIN + 'user/signup';

  /// Resetting a password.
  static const PASSWORD_RESET_URL = DOMAIN + 'user/generatePasswordResetLink';

  /// Toggling a user's notifications.
  static const NOTIFICATION_TOGGLE_URL = DOMAIN + 'user/changeNotifications';

  /// Getting a specific user's information.
  static const GET_CURRENT_USER_URL = DOMAIN + 'user/getCurrentUser';

  /// Sending a notification.
  static const SEND_NOTIFICATION_URL = 'https://fcm.googleapis.com/fcm/send';

  /// Getting vote count for a Finesse.
  static const GET_EVENT_VOTING_URL = DOMAIN + 'vote/eventPoints?eventId=';

  /// Getting a user's vote status for a particular Finesse.
  static const GET_USER_VOTE_ON_EVENT_URL = DOMAIN + 'vote/info?';

  /// Add a vote to a Finesse.
  static const POST_EVENT_VOTING_URL = DOMAIN + 'vote';

  static const SET_VOTES_URL = DOMAIN + 'user/setVotes';

  /// The topic used to send notifications about new Finesses.
  static const ALL_TOPIC = 'new_finesse';

  /// The authentication key for all API calls.
  static final token = environment['FINESSE_API_TOKEN'];

  /// The server key for Firebase Cloud Messaging.
  static final serverKey = environment['FINESSE_SERVER_KEY'];

  /// Send a POST request containing [data] to the [url].
  static Future<http.Response> postData(var url, var data) async {
    return await http.post(url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'api_token': token
        },
        body: json.encode(data));
  }

  /// Adds [newFinesse].
  static Future<void> addFinesse(Finesse newFinesse,
      {var url = ADD_URL}) async {
    Map bodyMap = newFinesse.toMap();
    http.Response response = await postData(url, bodyMap);

    final int statusCode = response.statusCode;
    if (statusCode != 200 && statusCode != 201) {
      throw Exception("Error while posting data");
    }
  }

  /// Gets Finesses.
  static Future<List<Finesse>> fetchFinesses() async {
    final response = await http.get(GET_URL, headers: {'api_token': token});

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      List<Finesse> responseJson =
          data.map<Finesse>((json) => Finesse.fromJson(json)).toList();
      responseJson = await applyFilters(responseJson);
      return responseJson;
    } else {
      throw Exception('Failed to load finesses');
    }
  }

  /// Filters the current Finesses by status/type
  static Future<List<Finesse>> applyFilters(responseJson) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool activeFilter = prefs.getBool('activeFilter') ?? true;
    final bool typeFilter = prefs.getBool('typeFilter') ?? true;
    List<Finesse> filteredFinesses = List<Finesse>.from(responseJson);

    if (activeFilter == false) {
      filteredFinesses.removeWhere((fin) => fin.isActive.length > 2);
      filteredFinesses
          .removeWhere((fin) => fin.isActive.contains(User.currentUser.email));
      filteredFinesses.removeWhere((fin) => fin.isActive.contains(fin.emailId));
    }
    if (typeFilter == false) {
      filteredFinesses.removeWhere((value) => value.category == "Other");
    }
    return filteredFinesses;
  }

  /// Removes [newFinesse].
  static Future<void> removeFinesse(Finesse newFinesse) async {
    var jsonObject = {"eventId": newFinesse.eventId};
    http.Response response = await postData(DELETE_URL, jsonObject);

    if (response.statusCode != 200) {
      throw new Exception("Error while removing finesse");
    }
  }

  /// Updates [newFinesse].
  static Future<void> updateFinesse(Finesse newFinesse) async {
    var jsonObject = {"eventId": newFinesse.eventId};
    var bodyMap = newFinesse.toMap();
    bodyMap.addAll(jsonObject);
    http.Response response = await postData(UPDATE_URL, bodyMap);

    if (response.statusCode != 200) {
      throw new Exception("Error while updating finesse");
    }
  }

  /// Sends a message containing [title] and [body] to [topic].
  static Future<http.Response> sendToAll(String title, String body,
      {String topic: ALL_TOPIC}) {
    final content = {
      'notification': {
        'body': '$body',
        'title': '$title',
      },
      'priority': 'high',
      'data': {
        'click_action': 'FLUTTER_NOTIFICATION_CLICK',
        'status': 'done',
      },
      'to': '/topics/null', // $topic
    };
    return http.post(
      SEND_NOTIFICATION_URL,
      body: json.encode(content),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverKey',
      },
    );
  }

  /// Attempts to login using the credentials in [data].
  ///
  /// Returns an error message on failure, null on success.
  static Future<String> authUser(LoginData data) async {
    Map bodyMap = data.toMap();
    http.Response response = await postData(LOGIN_URL, bodyMap);

    var status = response.statusCode;
    if (status == 400) {
      return 'Username or password is incorrect.';
    }
    await Network.updateCurrentUser(email: data.email);
    return null;
  }

  /// Attempts to reset the password associated with [email].
  ///
  /// Returns an error message on failure, null on success.
  static Future<String> recoverPassword(String email) async {
    email = email.trim();
    var emailCheck = validateEmail(email);
    const VALID_STATUS = null;
    if (emailCheck == VALID_STATUS) {
      var payload = {"emailId": email};
      http.Response response = await postData(PASSWORD_RESET_URL, payload);
      if (response.statusCode == 200) {
        return null;
      } else {
        return "Password Reset request failed";
      }
    } else {
      return emailCheck;
    }
  }

  /// Attempts to sign up using the credentials in [data].
  ///
  /// Returns an error message on failure, null on success.
  static Future<String> createUser(LoginData data) async {
    String email = data.email;
    email = email.trim();
    String password = data.password;
    var payload = {
      "emailId": email,
      "password": password,
    };
    http.Response response = await postData(SIGNUP_URL, payload);

    var status = response.statusCode, respBody = json.decode(response.body);
    if (status == 400) {
      return respBody['msg'];
    }
    await Network.updateCurrentUser(email: data.email);
    return null;
  }

  /// Validates [email].
  static String validateEmail(String email) {
    if (email.isEmpty) {
      return 'Email can\'t be empty';
    }
    bool emailValid =
        RegExp(r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]"
                r"{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]"
                r"{0,253}[a-zA-Z0-9])?)*$")
            .hasMatch(email);
    if (emailValid) {
      return null;
    }

    return "Invalid email address";
  }

  /// Validates [password].
  static String validatePassword(String password) {
    return password.length < 6
        ? 'Password must be at least 6 characters'
        : null;
  }

  /// Changes the current user's notification preferences to [toggle].
  static Future<void> changeNotifications(bool toggle) async {
    var payload = {"emailId": User.currentUser.email, 'notifications': toggle};
    http.Response response = await postData(NOTIFICATION_TOGGLE_URL, payload);
    if (response.statusCode == 200) {
      User.currentUser.notifications = toggle;
    } else {
      throw Exception('Notification change request failed');
    }
  }

  static Future<void> setVotes() async {
    var payload = {
      "emailId": User.currentUser.email,
      'upvoted': User.currentUser.upvoted,
      'downvoted': User.currentUser.downvoted,
    };
    http.Response response = await postData(SET_VOTES_URL, payload);
    if (response.statusCode != 200) {
      print(response.statusCode);
      print(response.body);
      throw Exception('set votes request failed');
    }
  }

  /// Populates the current user fields using [email].
  static Future<void> updateCurrentUser({String email}) async {
    email = email ?? User.currentUser.email;
    var payload = {"emailId": email};
    http.Response response = await postData(GET_CURRENT_USER_URL, payload);

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      User.currentUser = User.fromJson(data);
      await Notifications.notificationsSet(User.currentUser.notifications);
      SharedPreferences.getInstance().then((prefs) {
        prefs.setString('currentUser', email);
      });
    } else {
      throw Exception('Failed to get current user');
    }
  }

  /// Gets the votes for a particular Finesse using [eventId].
  static Future<int> fetchVotes(eventId) async {
    final response = await http
        .get(GET_EVENT_VOTING_URL + eventId, headers: {'api_token': token});
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      int votes = data["upVote"] - data["downVote"];
      return votes;
    } else {
      throw Exception("Failed to load votes");
    }
  }

  /// Gets a user's vote status for a Finesse using the user's [emailId]
  /// and the Finesse's [eventId].
  static Future<int> fetchUserVoteOnEvent(eventId, emailId) async {
    final response = await http.get(
        GET_USER_VOTE_ON_EVENT_URL +
            "eventId=" +
            eventId +
            "&emailId=" +
            emailId,
        headers: {'api_token': token});
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      String vote = data["status"];
      if (vote == "UPVOTE") {
        return 1;
      } else if (vote == "DOWNVOTE") {
        return -1;
      } else {
        return 0;
      }
    } else {
      throw Exception("Failed to load user vote");
    }
  }

  /// Adds [vote] to a Finesse using the user's [emailId] and
  /// the Finesses's [eventId].
  static Future<http.Response> postVote(
      String eventId, String emailId, int vote) async {
    Map bodyMap = {};
    bodyMap["eventId"] = eventId;
    bodyMap["emailId"] = emailId;
    bodyMap["vote"] = vote;

    http.Response response = await postData(POST_EVENT_VOTING_URL, bodyMap);

    final int statusCode = response.statusCode;
    if (statusCode != 200) {
      throw Exception("Error while voting");
    }
    return response;
  }

  /// Adds [comment] to the Finesse with the given [eventId].
  static Future<http.Response> addComment(
      Comment comment, String eventId) async {
    Map bodyMap = comment.toMap();
    bodyMap['eventId'] = eventId;
    http.Response response = await postData(ADD_COMMENT_URL, bodyMap);

    final int statusCode = response.statusCode;
    if (statusCode != 200) {
      throw Exception(
          "Error while adding comment, status = ${response.statusCode},"
          " ${response.body}}");
    }
    return response;
  }

  /// Gets the comments for a Finesse given its [eventId].
  static Future<List<Comment>> getComments(String eventId) async {
    final response = await http
        .get(GET_COMMENT_URL + eventId, headers: {'api_token': token});

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      List<Comment> comments =
          data.map<Comment>((json) => Comment.fromJson(json)).toList();
      return comments;
    } else {
      throw Exception("Error while getting comments");
    }
  }
}
