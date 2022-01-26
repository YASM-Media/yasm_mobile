import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yasm_mobile/constants/logger.constant.dart';
import 'package:yasm_mobile/dto/chat/chat_arguments/chat_arguments.dto.dart';
import 'package:yasm_mobile/models/chat/chat_thread/chat_thread.model.dart';
import 'package:yasm_mobile/models/user/user.model.dart';
import 'package:yasm_mobile/pages/chat/chat.page.dart';
import 'package:yasm_mobile/pages/chat/threads.page.dart';
import 'package:yasm_mobile/pages/common/loading.page.dart';
import 'package:yasm_mobile/services/chat.service.dart';
import 'package:yasm_mobile/services/user.service.dart';

class FirebaseNotificationsHandler extends StatefulWidget {
  final Widget child;

  const FirebaseNotificationsHandler({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  _FirebaseNotificationsHandlerState createState() =>
      _FirebaseNotificationsHandlerState();
}

class _FirebaseNotificationsHandlerState
    extends State<FirebaseNotificationsHandler> {
  late final FirebaseMessaging _firebaseMessaging;
  late final StreamSubscription _fmSubscription;

  late final UserService _userService;
  late final ChatService _chatService;

  bool loading = false;

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
      setState(() {
        this.loading = true;
      });

      ChatThread chatThread =
          await this._chatService.fetchThreadData(message.data['thread']);

      User user = await this._userService.getUser(message.data['user']);

      setState(() {
        this.loading = false;
      });

      Navigator.pushNamed(
        context,
        Chat.routeName,
        arguments: ChatArguments(
          chatThread: chatThread,
          user: user,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();

    this._firebaseMessaging = FirebaseMessaging.instance;
    this._userService = Provider.of<UserService>(context, listen: false);
    this._chatService = Provider.of<ChatService>(context, listen: false);

    setupInteractedMessage();
  }

  @override
  void dispose() {
    this._fmSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return !loading ? widget.child : Loading();
  }
}
