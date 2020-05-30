import 'dart:async';
import 'package:finesse_nation/Comment.dart';
import 'package:finesse_nation/Finesse.dart';
import 'package:finesse_nation/Network.dart';
import 'package:finesse_nation/User.dart';
import 'package:finesse_nation/login/flutter_login.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/test.dart';

/// Helper function to add a finesse to the database.
/// Optional parameter name of the test
Future<Finesse> addFinesseHelper([name]) async {
  var now = new DateTime.now();
  Finesse newFinesse = Finesse.finesseAdd(
      name ?? "Add Event unit test",
      "Description:" + now.toString(),
      null,
      "Activities and Recreation Center",
      "60 hours",
      "Food",
      new DateTime.now());
  await Network.addFinesse(newFinesse);
  return newFinesse;
}

/// Creates a list of 4 finesses to mock the finesse list from the database
/// Optional parameters to set the type and the state of active.
List<Finesse> createFinesseList({String type = "Food", List<String> isActive}) {
  List<Finesse> finesseList = [];

  for (var i = 0; i < 4; i++) {
    finesseList.add(Finesse.finesseAdd(
        "Add Event unit test",
        "Description:" + new DateTime.now().toString(),
        null,
        "Activities and Recreation Center",
        "60 hours",
        type,
        new DateTime.now(),
        isActive: isActive));
  }
  return finesseList;
}

const VALID_EMAIL = 'test@test.com';
const INVALID_EMAIL = 'Finesse';
const CURRENT_USER_EMAIL = "test1@test.edu";
const VALID_PASSWORD = 'test123';
const INVALID_LOGIN_MSG = 'Username or password is incorrect.';
const TEST_EVENT_ID = '5ece1abf1b3bbf0017bd5e3a';

///Login function to handle creating the login data and verify success
Future<void> login(
    {String email: VALID_EMAIL,
    String password: VALID_PASSWORD,
    var expected}) async {
  LoginData data = LoginData(email: email, password: password);
  var actual = await Network.authUser(data);
  expect(actual, expected);
}

///Signup a new user with email and password and verify success
Future<void> signup({String email, String password, var expected}) async {
  LoginData data = LoginData(email: email, password: password);
  var actual = await Network.createUser(data);
  expect(actual, expected);
}

///Check if the email is valid
void validateEmail(String email, var expected) {
  var result = Network.validateEmail(email);
  expect(result, expected);
}

///Check if the password is valid
void validatePassword(String password, var expected) {
  var result = Network.validatePassword(password);
  expect(result, expected);
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues(
      {"typeFilter": false, "activeFilter": false});
  User.currentUser = User('test@test.com', 'test123', 'test', 'test', 0, true, [], []);

  ///Add a new finesse to the database and check that the database contains it
  test('Adding a new Finesse', () async {
    Finesse newFinesse = await addFinesseHelper('Adding a new Finesse');
    List<Finesse> finesseList = await Future.value(Network.fetchFinesses());
    expect(finesseList.last.description, newFinesse.description);
    expect(finesseList.last.location, newFinesse.location);
    expect(finesseList.last.eventTitle, newFinesse.eventTitle);
    expect(finesseList.last.postedTime, newFinesse.postedTime);
    expect(finesseList.last.emailId, newFinesse.emailId);
    expect(finesseList.last.duration, newFinesse.duration);
    Network.removeFinesse(finesseList.last);
  });

  ///Add a finesse with invalid url and check for exception
  test('Adding a new Finesse Exception', () async {
    var now = new DateTime.now();
    Finesse newFinesse = Finesse.finesseAdd(
        "Add Event exception test",
        "Description:" + now.toString(),
        null,
        "Activities and Recreation Center",
        "60 hours",
        "Food",
        new DateTime.now());
    expectException(Network.addFinesse(newFinesse, url: "http://google.com"),
        "Error while posting data");
  });

  ///Add a finesse to the database and then remove it and verify that it is gone
  test('Removing a Finesse', () async {
    Finesse newFinesse = await addFinesseHelper('Removing a Finesse');

    Finesse secondNewFinesse = await addFinesseHelper('Removing a Finesse');

    await getAndRemove(secondNewFinesse); // Remove the first Finesse

    await getAndRemove(newFinesse);
  });

  ///Remove a finesse with invalid ID
  test('Removing a Finesse Exception', () async {
    Finesse newFinesse = Finesse.finesseAdd(
        "",
        "Description:",
        null,
        "Activities and Recreation Center",
        "60 hours",
        "Food",
        new DateTime.now());

    newFinesse.eventId = "invalid";
    await expectException(
        Network.removeFinesse(newFinesse), "Error while removing finesse");
  });

  ///Update a finesse with invalid id
  test('Updating a Finesse Exception', () async {
    Finesse newFinesse = Finesse.finesseAdd(
        "",
        "Description:",
        null,
        "Activities and Recreation Center",
        "60 hours",
        "Food",
        new DateTime.now());

    newFinesse.eventId = "invalid";

    await expectException(
        Network.updateFinesse(newFinesse), "Error while updating finesse");
  });

  ///Add a finesse and then update it and verify that it has updated
  test('Updating a Finesse', () async {
    Finesse firstNewFinesse = await addFinesseHelper('Updating a Finesse');

    List<Finesse> finesseList = await Future.value(Network.fetchFinesses());

    var now = new DateTime.now();
    String newDescription = "Description:" + now.toString();

    Finesse updatedFinesse = finesseList.last;
    updatedFinesse.description = newDescription;

    await Network.updateFinesse(updatedFinesse);

    finesseList = await Future.value(Network.fetchFinesses());
    expect(finesseList.last.description, isNot(firstNewFinesse.description));
    expect(finesseList.last.description, updatedFinesse.description);
    expect(finesseList.last.convertedImage, updatedFinesse.convertedImage);
    expect(finesseList.last.image, updatedFinesse.image);

    await Network.removeFinesse(finesseList.last);
  });

  /// Get a list of other finesses and filter them. Verify that they are removed.
  test('applyFilters Test Other', () async {
    List<Finesse> finesseList = createFinesseList(type: "Other", isActive: <String>[]);
    List<Finesse> newList = await Network.applyFilters(finesseList);
    expect(newList.length, 0);
    expect(newList.length < finesseList.length, true);
  });

  /// Verify nothing was filtered
  test('applyFilters Test No Filter', () async {
    List<Finesse> finesseList = createFinesseList(type: "Food", isActive: <String>[]);
    List<Finesse> newList = await Network.applyFilters(finesseList);

    expect(newList.length, 4);
    expect(newList.length == finesseList.length, true);
  });

  /// Verify inactive posts were removed
  test('applyFilters Test Inactive', () async {
    List<Finesse> finesseList = createFinesseList(
        type: "Food", isActive: ["username1", "username2", "username3"]);
    List<Finesse> newList = await Network.applyFilters(finesseList);

    expect(newList.length, 0);
    expect(newList.length < finesseList.length, true);
  });

  /// With filters off posts were not filtered.
  test('applyFilters Test Filters off', () async {
    SharedPreferences.setMockInitialValues(
        {"typeFilter": true, "activeFilter": true});

    List<Finesse> finesseList = createFinesseList(
        type: "Other", isActive: ["username1", "username2", "username3"]);
    List<Finesse> newList = await Network.applyFilters(finesseList);

    expect(newList.length, 4);
    expect(newList.length == finesseList.length, true);
  });

  test('Validate good email', () async {
    validateEmail(VALID_EMAIL, null);
  });

  test('Validate bad email', () async {
    validateEmail(INVALID_EMAIL, 'Invalid email address');
  });

  test('Validating empty email', () async {
    validateEmail('', 'Email can\'t be empty');
  });

  test('Validating good password', () async {
    validatePassword('longpassword', null);
  });

  test('Validating bad password', () async {
    validatePassword('short', 'Password must be at least 6 characters');
  });

  test('Validating empty password', () async {
    validatePassword('', 'Password must be at least 6 characters');
  });

  test('Correct Login', () async {
    await login(expected: null);
  });

  test('Incorrect Password', () async {
    await login(password: 'test1234', expected: INVALID_LOGIN_MSG);
  });

  test('Incorrect Email', () async {
    await login(email: 'test@test.org', expected: INVALID_LOGIN_MSG);
  });

  test('Incorrect Login', () async {
    await login(
        email: 'test@test.org',
        password: 'test1234',
        expected: INVALID_LOGIN_MSG);
  });

  ///Signing up a unique user (based on timestamp)
  test('Correct Signup', () async {
    String email =
        DateTime.now().millisecondsSinceEpoch.toString() + '@test.com';
    String password = VALID_PASSWORD;
    await signup(email: email, password: password, expected: null);
    await login(email: email, password: password, expected: null);
  });

  ///Invalid user signed up.
  test('Incorrect Signup', () async {
    String email = VALID_EMAIL; // Already exists
    String password = VALID_PASSWORD;
    await signup(
        email: email, password: password, expected: 'User already exists');
  });

  test('Recover Password good email', () async {
    String result = await Network.recoverPassword(VALID_EMAIL);
    expect(result, null);
  });

  test('Recover Password invalid email', () async {
    String result = await Network.recoverPassword(INVALID_EMAIL);
    expect(result, 'Invalid email address');
  });

  test('Changing Notifications ON', () async {
    await testChangingNotifications(true);
  });

  test('Changing Notifications OFF', () async {
    await testChangingNotifications(false);
  });

  ///Change the notifications with an invalid user email
  test('Changing Notifications Exception', () async {
    String temp = User.currentUser.email;
    User.currentUser.email = "invalid";
    await expectException(Network.changeNotifications(false),
        "Notification change request failed");
    User.currentUser.email = temp;
  });

  /// Get the current user data for test1@test.com and verify
  test('Getting Current User Data', () async {
    User.currentUser =
        User(CURRENT_USER_EMAIL, "none", "none", "none", 0, false, [], []);
    await Network.updateCurrentUser();
    expect(User.currentUser.points, 0);
    expect(User.currentUser.email, CURRENT_USER_EMAIL);
    expect(User.currentUser.password, isNot("none"));
  });

  test('Send Garbage to the Update Current User Function', () async {
    await expectException(
        Network.updateCurrentUser(email: "asdfasefwef@esaasef.edu"),
        "Failed to get current user");
  });

  ///Send push notification check for network response
  test('Send Push Notification', () async {
    var response = await Network.sendToAll('test', 'test', topic: 'tests');
    expect(response.statusCode, 200);
  });

  /// Add a valid comment the database check that the api responds
  test('Add valid comment', () async {
    Comment comment =
        Comment('test comment', VALID_EMAIL, DateTime.now().toString());
    var response = await Network.addComment(comment, TEST_EVENT_ID);
    expect(response.statusCode, 200);
  });

  /// Check that an exception is thrown when adding an empty comment
  test('Add invalid comment', () async {
    try {
      await Network.addComment(Comment('', '', ''), '');
    } catch (e) {
      String error = e.toString();
      expect(error.contains('Error while adding comment'), true);
      expect(error.contains('status = 400'), true);
      expect(error.contains('Please enter a valid email address'), true);
      expect(error.contains('The comment cannot be empty'), true);
      expect(error.contains('The time cannot be empty'), true);
      expect(error.contains('Please enter a valid event id'), true);
      return;
    }
    fail('Adding invalid comments should have thrown an exception');
  });

  /// Get the comments for a specific event and verify that they are correct.
  test('Get Comments', () async {
    Comment testComment =
        Comment('test comment', VALID_EMAIL, DateTime.now().toString());
    await Network.addComment(testComment, TEST_EVENT_ID);
    List<Comment> comments = await Network.getComments(TEST_EVENT_ID);
    Comment last = comments.last;
    expect(last.comment, testComment.comment);
    expect(last.emailId, testComment.emailId);
    expect(last.postedTime, testComment.postedTime);
  });

  test('Get Invalid Comments', () async {
    List<Comment> result = await Network.getComments('no_comments');
    expect(result.length, 0);
  });
}

/// Checks if the passed in function throws an exception
Future<void> expectException(f, expectedText) async {
  var exceptionText = "";
  try {
    await f;
  } on Exception catch (text) {
    exceptionText = '$text';
  }
  expect(exceptionText, 'Exception: $expectedText');
}

/// Wrapper to check notifications easier
Future testChangingNotifications(bool toggle) async {
  await Network.changeNotifications(toggle);
  expect(User.currentUser.notifications, toggle);
}

/// Get finesses to find the id and remove the finesse.
Future<List<Finesse>> getAndRemove(Finesse expectedFinesse) async {
  List<Finesse> finesseList = await Future.value(Network.fetchFinesses());

  expect(finesseList.last.description,
      expectedFinesse.description); // Check that it was added

  await Network.removeFinesse(finesseList.last); // Remove the first Finesse
  return finesseList;
}
