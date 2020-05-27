import 'package:flutter/material.dart';

import 'package:finesse_nation/login/flutter_login.dart';
import 'package:finesse_nation/main.dart';
import 'package:finesse_nation/Network.dart';
import 'package:finesse_nation/Styles.dart';

/// Handles login and registration.
class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      title: null,
      logo: 'images/logo.png',
      theme: LoginTheme(
          primaryColor: Colors.black,
          accentColor: Colors.black,
          cardTheme: CardTheme(color: Styles.brightOrange),
          buttonTheme: LoginButtonTheme(
            splashColor: Colors.grey[800],
          )),
      emailValidator: /*(_) => null  ,// */ Network.validateEmail,
      passwordValidator: /*(_) => null  ,// */ Network.validatePassword,
      onLogin: /*(_) => null  ,// */ Network.authUser,
      onSignup: /*(_) => null  ,// */ Network.createUser,
      onSubmitAnimationCompleted: () {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => MyHomePage(),
        ));
      },
      onRecoverPassword: Network.recoverPassword,
      logoTag: 'logo',
      messages: LoginMessages(
          recoverPasswordDescription:
              'Email will be sent with a link to reset your password.'),
    );
  }
}
