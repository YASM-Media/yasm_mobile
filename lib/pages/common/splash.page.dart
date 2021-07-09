import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yasm_mobile/pages/auth/auth.page.dart';
import 'package:yasm_mobile/pages/common/loading.page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:yasm_mobile/pages/home.page.dart';
import 'package:yasm_mobile/providers/auth/auth.provider.dart';
import 'package:yasm_mobile/services/auth.service.dart';

class Splash extends StatefulWidget {
  static const routeName = "/";

  const Splash({Key? key}) : super(key: key);

  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  StreamSubscription? _streamSubscription;
  final AuthService _authService = new AuthService();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      this._streamSubscription =
          FirebaseAuth.instance.authStateChanges().listen((User? user) {
        if (user != null) {
          _authService.getLoggedInUser().then((user) {
            Provider.of<AuthProvider>(context, listen: false).saveUser(user);
            Navigator.of(context).pushReplacementNamed(Home.routeName);
          }).catchError((error) {
            print(error);
            Navigator.of(context).pushReplacementNamed(Auth.routeName);
          });
        } else {
          Navigator.of(context).pushReplacementNamed(Auth.routeName);
        }
      });
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    this._streamSubscription!.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Loading();
  }
}
