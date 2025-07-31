import 'package:flutter/material.dart';

class AppWidget {
  static TextStyle boldTextStyle() {
    return TextStyle(
      color: Colors.black,
      fontSize: 28,
      fontWeight: FontWeight.bold,
    );
  }

  static TextStyle lightTextFieldStyle() {
    return TextStyle(
      color: Colors.black54,
      fontSize: 20,
      fontWeight: FontWeight.w500,
    );
  }

  static TextStyle semiboldTetField() {
    return TextStyle(
      color: Colors.black,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    );
  }

  static TextStyle loginPageText() {
    return TextStyle(
      color: Colors.black,
      fontSize: 18,
      fontWeight: FontWeight.bold,
    );
  }

  static TextStyle loginPageHeading() {
    return TextStyle(
      color: Colors.black,
      fontSize: 30,
      fontWeight: FontWeight.w700,
    );
  }
}
