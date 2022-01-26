import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:yasm_mobile/constants/logger.constant.dart';
import 'package:yasm_mobile/pages/chat/threads.page.dart';

class FirebaseNotificationsHandler extends StatefulWidget {
  final Widget child;

  const FirebaseNotificationsHandler({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  _FirebaseNotificationsHandlerState createState() => _FirebaseNotificationsHandlerState();
}

class _FirebaseNotificationsHandlerState extends State<FirebaseNotificationsHandler> {
  late final FirebaseMessaging _firebaseMessaging;
  late final StreamSubscription _fmSubscription;

  Future<void> setupInteractedMessage() async {
    RemoteMessage? initialMessage =
    await this._firebaseMessaging.getInitialMessage();

    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    setState(() {
      this._fmSubscription =
          FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
    });

    log.i("Firebase Notification Handler Ready To Go.");
  }

  Future<void> _handleMessage(RemoteMessage message) async {
    if (message.data['type'] == 'chat') {
      Navigator.pushNamed(
        context,
        Threads.routeName,
      );
    }
  }

  @override
  void initState() {
    super.initState();

    this._firebaseMessaging = FirebaseMessaging.instance;

    setupInteractedMessage();
  }

  @override
  void dispose() {
    this._fmSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
