import 'package:flutter/material.dart';

class CommonFunctions {
  static void printScaffoldMessage(
    BuildContext context,
    String message,
    int a,
  ) {
    if (a == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text(message),
          duration: const Duration(seconds: 1),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(message),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }
}
