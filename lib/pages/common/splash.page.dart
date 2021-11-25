import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yasm_mobile/constants/logger.constant.dart';
import 'package:yasm_mobile/models/user/user.model.dart';
import 'package:yasm_mobile/pages/auth/auth.page.dart';
import 'package:yasm_mobile/pages/common/loading.page.dart';
import 'package:firebase_auth/firebase_auth.dart' as FA;
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

  late final AuthService _authService;

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
          FA.FirebaseAuth.instance.authStateChanges().listen(
                _handleFirebaseAuthEvents,
                onError: _handleFirebaseStreamError,
              );
    });
  }

  void _handleFirebaseAuthEvents(FA.User? user) {
    if (user != null) {
      log.i("Firebase Logged In User");
      _handleServerAuthStatus();
    } else {
      Navigator.of(context).pushReplacementNamed(Auth.routeName);
    }
  }

  void _handleServerAuthStatus() {
    _authService
        .getLoggedInUser()
        .then(_handleServerAuthSuccess)
        .catchError(_handleServerAuthError);
  }

  _handleServerAuthError(error, stackTrace) {
    if (error.runtimeType == FA.FirebaseAuthException) {
      FA.FirebaseAuthException exception = error as FA.FirebaseAuthException;

      log.e(exception.code, exception.code, exception.stackTrace);

      this._checkForOfflineUser();
    } else {
      log.e(error.toString(), error, stackTrace);
      Navigator.of(context).pushReplacementNamed(Auth.routeName);
    }
  }

  FutureOr<Null> _handleServerAuthSuccess(user) {
    log.i("Server Logged In User");

    Provider.of<AuthProvider>(context, listen: false).saveUser(user);
    Navigator.of(context).pushReplacementNamed(Home.routeName);
  }

  _handleFirebaseStreamError(error, stackTrace) {
    log.e(error.toString(), error, stackTrace);
    this._checkForOfflineUser();
  }

  void _checkForOfflineUser() {
    User? user = this._authService.fetchOfflineUser();

    if (user != null) {
      Provider.of<AuthProvider>(context, listen: false).saveUser(user);
      Navigator.of(context).pushReplacementNamed(Home.routeName);
    } else {
      Navigator.of(context).pushReplacementNamed(Auth.routeName);
    }
  }

  @override
  void dispose() {
    super.dispose();
    this._streamSubscription!.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Loading();
  }
}
