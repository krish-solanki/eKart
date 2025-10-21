import 'package:flutter/material.dart';
import 'package:shopping_app/widget/Colors/Colors.dart';

class AppWidget {
  static TextStyle boldTextStyle() {
    return TextStyle(
      color: Colors.black,
      fontSize: 28,
      fontWeight: FontWeight.bold,
    );
  }

  static TextStyle orderPageTextStyle({Color? color}) {
    return TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.bold);
  }

  static TextStyle lightTextFieldStyle() {
    return TextStyle(
      color: Colors.black54,
      fontSize: 20,
      fontWeight: FontWeight.w500,
    );
  }

  static TextStyle dontHaveAccount() {
    return TextStyle(
      color: Colors.black54,
      fontSize: 16,
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

  static TextStyle productName() {
    return TextStyle(
      color: Colors.black,
      fontSize: 16,
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

  static TextStyle titleFont() {
    return TextStyle(
      color: AllColor.blackColor,
      fontSize: 20,
      fontWeight: FontWeight.w800,
    );
  }

  static TextStyle descriptionFont() {
    return TextStyle(
      color: AllColor.blackColor,
      fontSize: 16,
      fontWeight: FontWeight.w500,
    );
  }

    static TextStyle descriptionFont1() {
    return TextStyle(
      color: AllColor.blackColor,
      fontSize: 14,
      fontWeight: FontWeight.w500,
    );
  }

  static TextStyle pricrFont() {
    return TextStyle(
      color: AllColor.blackColor,
      fontSize: 18,
      fontWeight: FontWeight.w900,
    );
  }

  static TextStyle searchBarFont() {
    return TextStyle(
      color: Colors.black54,
      fontSize: 16,
      fontWeight: FontWeight.normal,
    );
  }

  static TextStyle orderIdStyle() {
    return TextStyle(
      fontSize: 18.0,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    );
  }

  static TextStyle labelStyle() {
    return TextStyle(
      fontSize: 16.0,
      fontWeight: FontWeight.w500, // A medium weight
      color: Colors.black54,
    );
  }

  static TextStyle dataStyle() {
    return TextStyle(
      fontSize: 16.0,
      fontWeight: FontWeight.normal,
      color: Colors.black87,
    );
  }

  static TextStyle priceStyle() {
    return TextStyle(
      fontSize: 20.0,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    );
  }
}
