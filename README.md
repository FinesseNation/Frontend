# Finesse Nation

[![Finesse Nation CI/CD](https://github.com/Periphery428/Finesse-Nation/workflows/Finesse%20Nation%20CI%2FCD/badge.svg)](https://github.com/Periphery428/Finesse-Nation/actions) ![Dart Analysis](https://github.com/Periphery428/Finesse-Nation/workflows/Dart%20Analysis/badge.svg) ![Unit, Widget, and Integration Tests](https://github.com/Periphery428/Finesse-Nation/workflows/Unit,%20Widget,%20and%20Integration%20Tests/badge.svg) ![Release](https://github.com/Periphery428/Finesse-Nation/workflows/Release/badge.svg)
[![Coverage Status](https://coveralls.io/repos/github/Periphery428/Finesse-Nation-Frontend/badge.png?branch=master)](https://coveralls.io/github/Periphery428/Finesse-Nation-Frontend?branch=master)


There are free meals and giveaways on campus all the time. Finesse Nation is an app that would allow users to share where the free items are located on campus.

Developed in Android Studio using the Flutter framework.

[Read the docs](project_documentation.pdf)

## Contributors
Robert Beckwith

Aditya Pandey

Shilpa Rani

Krastan Dimitrov

Jeffrey Josol

## Setup Token

You must set the environment variable ```FINESSE_NATION_TOKEN``` with the secret token.

You must run the file tool/env.dart. This will then generate the file, .env.dart into the lib folder, needed to successfully use the token.

## Setup Google Services
You must have the Google Service file into the Finesse Nation/android/app for the app to run.

## Instructions to Edit and Run
Download Flutter here https://flutter.dev/docs/get-started/install

```
git clone https://github.com/Periphery428/Finesse-Nation.git
```

Open the project in Android Studio

Launch AVD manager to setup and run an emulator (We used pixel 2 most of the time)

Then click the run button in Android studio.

## Running Tests

### Unit Tests
Run Unit Tests
```
flutter test --coverage
```

### Integration Tests

Run Integration Tests (You must have the emulator open first for this to work.)
```
flutter drive --target=test_driver/app.dart
```

### Monkey Tests
```
adb shell monkey -p com.periphery.finesse_nation -v <event-count>
```
