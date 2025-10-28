import 'package:flutter/material.dart';

class CommonFunctions {
  static void printScaffoldMessage(
    BuildContext context,
    String message,
    int a,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: a == 0 ? Colors.green : Colors.red,
        content: Text(message),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  static String getShortDescription(dynamic description) {
    if (description == null) return 'Not Fetched';

    final desc = description is String
        ? description.trim()
        : description.toString().trim();
    if (desc.isEmpty) return 'Not Fetched';

    final words = desc.split(RegExp(r'\s+'));

    if (words.length > 8) {
      return words.take(8).join(' ') + '...';
    }

    // Otherwise return full description
    return desc;
  }
}
