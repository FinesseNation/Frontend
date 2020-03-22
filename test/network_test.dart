// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.
import 'dart:async';
import 'package:finesse_nation/Finesse.dart';
import 'package:finesse_nation/Network.dart';
import 'package:flutter_test/flutter_test.dart';

Future<Finesse> addFinesseHelper() async {
  var now = new DateTime.now();
  Finesse newFinesse = Finesse.finesseAdd(
      "Add Event unit test",
      "Description:" + now.toString(),
      "",
      "Second floor Arc",
      "60 hours",
      "Food",
      new DateTime.now());
  await Network.addFinesse(newFinesse);
  return newFinesse;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Adding a new Finesse', () async {
    Finesse newFinesse = await addFinesseHelper();
    List<Finesse> finesseList = await Future.value(Network.fetchFinesses());
    expect(finesseList.last.getDescription(), newFinesse.getDescription());
    Network.removeFinesse(finesseList.last);
  });

  test('Removing a Finesse', () async {
    Finesse newFinesse = await addFinesseHelper();

    Finesse secondNewFinesse = await addFinesseHelper();

    List<Finesse> finesseList = await Future.value(Network.fetchFinesses());

    expect(finesseList.last.getDescription(),
        secondNewFinesse.getDescription()); // Check that it was added

    await Network.removeFinesse(finesseList.last); // Remove the first Finesse

    finesseList = await Future.value(Network.fetchFinesses());

    expect(
        finesseList.last.getDescription(),
        newFinesse
            .getDescription()); // Check to make sure the new event was actually removed

    await Network.removeFinesse(finesseList.last);
  });

  test('Updating a Finesse', () async {
    Finesse firstNewFinesse = await addFinesseHelper();

    List<Finesse> finesseList = await Future.value(Network.fetchFinesses());

    var now = new DateTime.now();
    String newDescription = "Description:" + now.toString();

    Finesse updatedFinesse = finesseList.last;
    updatedFinesse.setDescription(newDescription);

    await Network.updateFinesse(updatedFinesse);

    finesseList = await Future.value(Network.fetchFinesses());
    expect(finesseList.last.getDescription(),
        isNot(firstNewFinesse.getDescription()));
    expect(finesseList.last.getDescription(), updatedFinesse.getDescription());

    await Network.removeFinesse(finesseList.last);
  });

}
