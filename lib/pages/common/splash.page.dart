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
  // Firebase stream subscription.
  StreamSubscription? _streamSubscription;

  late AuthService _authService;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    this._authService = Provider.of<AuthService>(context, listen: false);
    setState(() {
      /*
         * Listen for logged in user using firebase auth changes.
         * If the user exists, fetch details from server and save
         * it in provider and route the user to home page.
         *
         * Otherwise, route them to Auth page.
         */
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
