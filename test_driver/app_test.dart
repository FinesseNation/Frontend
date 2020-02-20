import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  group('Counter App', () {
    final counterTextFinder = find.byValueKey('counterKey');
    final buttonFinder = find.byValueKey('rahbert');


    FlutterDriver driver;

    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    tearDownAll(() async {
      if (driver != null) {
        driver.close();
      }
    });

    test('starts app at 0', () async {
      expect(await driver.getText(counterTextFinder), "0");
    });


    test('increments the app counter', () async {
      await driver.tap(buttonFinder);
      await driver.waitFor(find.text('1'));
      expect(await driver.getText(counterTextFinder), "1");
    });
  });
}