import 'package:flutter/material.dart';

void displayMessageToUser(String message, BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      showCloseIcon: true,
      elevation: 7,
    ),
  );
}
