import 'dart:async';

import 'package:flutter/material.dart';
import 'package:yasm_mobile/pages/auth/auth.page.dart';
import 'package:yasm_mobile/pages/common/loading.page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:yasm_mobile/pages/home.page.dart';

class Splash extends StatefulWidget {
  static const routeName = "/";

  const Splash({Key? key}) : super(key: key);

  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  StreamSubscription? _streamSubscription;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      this._streamSubscription =
          FirebaseAuth.instance.authStateChanges().listen((User? user) {
        if (user == null) {
          Navigator.of(context).pushReplacementNamed(Auth.routeName);
        } else {
          Navigator.of(context).pushReplacementNamed(Home.routeName);
        }
      });
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    if (this._streamSubscription != null) {
      this._streamSubscription!.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Loading();
  }
}
