import 'dart:convert';
import 'package:finesse_nation/Finesse.dart';
import 'package:finesse_nation/User.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meta/meta.dart';
import '.env.dart';
import 'User.dart';
import 'login/flutter_login.dart';

class Network {
  static const DOMAIN = 'https://finesse-nation.herokuapp.com/api/';
  static const DELETE_URL = DOMAIN + 'food/deleteEvent';
  static const ADD_URL = DOMAIN + 'food/addEvent';
  static const GET_URL = DOMAIN + 'food/getEvents';
  static const UPDATE_URL = DOMAIN + 'food/updateEvent';
  static const LOGIN_URL = DOMAIN + 'user/login';
  static const SIGNUP_URL = DOMAIN + 'user/signup';
  static const PASSWORD_RESET_URL = DOMAIN + 'user/generatePasswordResetLink';
  static const NOTIFICATION_TOGGLE_URL = DOMAIN + 'user/changeNotifications';

  static final token = environment['FINESSE_API_TOKEN'];
  static final serverKey = environment['FINESSE_SERVER_KEY'];

  static Future<http.Response> postData(var url, var data) async {
    return await http.post(url,
        headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'api_token': token
        },
        body: json.encode(data));
  }

  static Future<void> addFinesse(Finesse newFinesse) async {
    Map bodyMap = newFinesse.toMap();
    http.Response response = await postData(ADD_URL, bodyMap);

    final int statusCode = response.statusCode;
    if (statusCode != 200 && statusCode != 201) {
      throw new Exception(
          "Error while posting data, $token, ${response.statusCode}, ${response.body}, ${response.toString()}");
    }
  }

  static Future<List<Finesse>> fetchFinesses() async {
    final response = await http.get(GET_URL, headers: {'api_token': token});
//    print('finished getting');
//    print(response.statusCode);
//    print(response.body.length);
//    print('body = ${response.body}');
    if (response.statusCode == 200) {
//      print('decoding');
      /*List<Map<dynamic,dynamic>>*/
      var data = json.decode(response.body);
      List<Finesse> responseJson =
          data.map<Finesse>((json) => Finesse.fromJson(json)).toList();
      responseJson = await applyFilters(responseJson);
      return responseJson;
    } else {
      print('nope');
      print(token);
      print(response.statusCode);
      print(response.body);
      throw Exception('Failed to load finesses');
    }
  }

  static Future<List<Finesse>> applyFilters(responseJson) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool activeFilter = prefs.getBool('activeFilter') ?? true;
    final bool typeFilter = prefs.getBool('typeFilter') ?? true;
    List<Finesse> filteredFinesses = new List<Finesse>.from(responseJson);

//    print(activeFilter);
//    print(typeFilter);
    if (activeFilter == false) {
      filteredFinesses.removeWhere((value) => value.getActive() == false);
    }
    if (typeFilter == false) {
      filteredFinesses.removeWhere((value) => value.getCategory() == "Other");
    }
    return filteredFinesses;
  }

  static Future<void> removeFinesse(Finesse newFinesse) async {
    var jsonObject = {"eventId": newFinesse.getId()};

    final http.Response response = await http.post(DELETE_URL,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'api_token': token
        },
        body: json.encode(jsonObject));

    final int statusCode = response.statusCode;
    if (statusCode < 200 || statusCode > 400 || json == null) {
      throw new Exception("Error while removing finesses");
    }
    if (response.statusCode == 201) {
      // TODO
    }
  }

  static Future<void> updateFinesse(Finesse newFinesse) async {
    var jsonObject = {"eventId": newFinesse.getId()};
    var bodyMap = newFinesse.toMap();
    bodyMap.addAll(jsonObject);
    http.Response response = await postData(UPDATE_URL, bodyMap);

    final int statusCode = response.statusCode;
    if (statusCode < 200 || statusCode > 400 || json == null) {
      throw new Exception("Error while updating finesses");
    }
    if (response.statusCode == 201) {
      // TODO
    }
  }

  static Future<void> sendToAll({
    @required String title,
    @required String body,
  }) =>
      sendToTopic(title: title, body: body, topic: 'all');

  static Future<void> sendToTopic(
          {@required String title,
          @required String body,
          @required String topic}) =>
      sendTo(title: title, body: body, fcmToken: '/topics/$topic');

  static Future<void> sendTo({
    @required String title,
    @required String body,
    @required String fcmToken,
  }) =>
      http.post(
        'https://fcm.googleapis.com/fcm/send',
        body: json.encode({
          'notification': {
            'body': '$body',
            'title': '$title',
            'image':
                'https://vignette.wikia.nocookie.net/rezero/images/0/02/Rem_Anime.png',
          },
          'priority': 'high',
          'data': {
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'status': 'done',
          },
          'to': '$fcmToken',
        }),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'key=$serverKey',
        },
      );

  // Sign in callback
  static Future<String> authUser(LoginData data) async {
    Map bodyMap = data.toMap();
    http.Response response = await postData(LOGIN_URL, bodyMap);

    var status = response.statusCode;
    if (status == 400) {
      return 'Username or password is incorrect.';
    }
    // TODO: GET the actual user data
    User.currentUser = User(data.email, data.password, 'TBD', 'TBD', 0, true);
    return null;
  }

  // Forgot Password callback
  static Future<String> recoverPassword(String email) async {
    email = email.trim();
    var emailCheck = validateEmail(email);
    const VALID_STATUS = null;
    if (emailCheck == VALID_STATUS) {
      var payload = {"emailId": email};
      print(payload);
      http.Response response = await postData(PASSWORD_RESET_URL, payload);
      print(response.statusCode);
      print(response.body);
      if (response.statusCode == 200) {
        return null;
      } else {
        print(response.statusCode);
        print(response.body);
        print(token);
        return "Password Reset request failed";
      }
    } else {
      return emailCheck;
    }
  }

  // Sign up callback
  static Future<String> createUser(LoginData data) async {
    String email = data.email;
    email = email.trim();
    String password = data.password;
    int points = 0;
    var atSplit = email.split('@');
    var username = atSplit[0];
    var dotSplit = atSplit[1].split('.');
    var school = dotSplit[0];
    var payload = {
      "userName": username,
      "emailId": email,
      "password": password,
      "school": school,
      "points": points
    };
    http.Response response = await postData(SIGNUP_URL, payload);

    var status = response.statusCode, respBody = json.decode(response.body);
    if (status == 400) {
      return respBody['msg'];
    }
    // TODO: GET the actual user data
    User.currentUser = User(email, password, username, school, points, true);
    return null;
  }

  static String validateEmail(String email) {
    if (email.isEmpty) {
      return 'Email can\'t be empty';
    }
    bool emailValid = RegExp(
            r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$")
        .hasMatch(email);
    if (emailValid) {
      return null;
    }

    return "Invalid email address";
  }

  static String validatePassword(String password) {
    return password.length < 6
        ? 'Password must be at least 6 characters'
        : null;
  }

  static Future<String> changeNotifications(toggle) async {
    var payload = {"emailId": User.currentUser.email, 'notifications': toggle};
    print(payload);
    http.Response response = await postData(NOTIFICATION_TOGGLE_URL, payload);
    print(response.statusCode);
    print(response.body);
    if (response.statusCode == 200) {
      User.currentUser.setNotifications(toggle);
      return null;
    } else {
      print(response.statusCode);
      print(response.body);
      print(token);
      return "Notification change request failed";
    }
  }
}
