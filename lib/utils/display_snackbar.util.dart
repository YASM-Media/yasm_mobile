import 'package:flutter/material.dart';

void displaySnackBar(String message, BuildContext context) {
  final snackBar = SnackBar(
    backgroundColor: Colors.black54,
    content: Text(
      message,
      style: TextStyle(
        color: Colors.white,
      ),
    ),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
