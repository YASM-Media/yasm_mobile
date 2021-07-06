import 'package:flutter/material.dart';

class Auth extends StatefulWidget {
  static const routeName = "/auth";

  const Auth({Key? key}) : super(key: key);

  @override
  _AuthState createState() => _AuthState();
}

class _AuthState extends State<Auth> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Auth Page'),
      ),
    );
  }
}
