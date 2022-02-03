import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:provider/provider.dart';
import 'package:yasm_mobile/constants/logger.constant.dart';
import 'package:yasm_mobile/dto/chat/create_thread/create_thread.dto.dart';
import 'package:yasm_mobile/firebase_notifications_handler.dart';
import 'package:yasm_mobile/pages/activity/activity.page.dart';
import 'package:yasm_mobile/pages/auth/auth.page.dart';
import 'package:yasm_mobile/pages/chat/threads.page.dart';
import 'package:yasm_mobile/pages/posts/posts.page.dart';
import 'package:yasm_mobile/pages/posts/select_images.page.dart';
import 'package:yasm_mobile/pages/search/search.page.dart';
import 'package:yasm_mobile/pages/stories/create_story.page.dart';
import 'package:yasm_mobile/pages/user/user_profile.page.dart';
import 'package:yasm_mobile/pages/user/user_update.page.dart';
import 'package:yasm_mobile/providers/auth/auth.provider.dart';
import 'package:yasm_mobile/services/auth.service.dart';
import 'package:yasm_mobile/services/chat.service.dart';
import 'package:yasm_mobile/services/tokens.service.dart';
import 'package:yasm_mobile/utils/check_connectivity.util.dart';

class Home extends StatefulWidget {
  static const routeName = "/home";

  Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late final ChatService _chatService;
  late final TokensService _tokensService;
  late final AuthService _authService;

  @override
  void initState() {
    super.initState();

    this._chatService = Provider.of<ChatService>(context, listen: false);
    this._tokensService = Provider.of<TokensService>(context, listen: false);
    this._authService = Provider.of<AuthService>(context, listen: false);

    checkConnectivity().then((value) {
      if (value) {
        this._tokensService.generateAndSaveTokenToDatabase();
        FirebaseMessaging.instance.onTokenRefresh
            .listen(this._tokensService.saveTokenToDatabase);
      } else {
        log.i(
            "Device offline, suspending FCM Token Generation and Topic Subscription");
      }
    }).catchError((error, stackTrace) {
      log.e("HomePage Error", error, stackTrace);
    });
  }

  Future<void> logout(context) async {
    await _authService.logout();
    Provider.of<AuthProvider>(context, listen: false).removeUser();
    Navigator.of(context).pushReplacementNamed(Auth.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('YASM!!🌟'),
      ),
      body: FirebaseNotificationsHandler(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Consumer<AuthProvider>(
                builder: (context, auth, _) => Text(
                  auth.getUser() != null
                      ? auth.getUser()!.emailAddress
                      : "You are not logged in.",
                ),
              ),
              Column(
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(UserUpdate.routeName);
                    },
                    child: Text('User Update'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(
                        UserProfile.routeName,
                        arguments:
                            Provider.of<AuthProvider>(context, listen: false)
                                .getUser()!
                                .id,
                      );
                    },
                    child: Text('User Profile'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(Posts.routeName);
                    },
                    child: Text('Posts'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(Search.routeName);
                    },
                    child: Text('Search'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(CreateStory.routeName);
                    },
                    child: Text('Create Story'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(Threads.routeName);
                    },
                    child: Text('Chat Threads'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(Activity.routeName);
                    },
                    child: Text('Activity'),
                  ),
                  TextButton(
                    onPressed: () async {
                      await this._authService.logout();
                    },
                    child: Text('Log Out'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: OfflineBuilder(
        connectivityBuilder: (
          BuildContext context,
          ConnectivityResult connectivity,
          Widget _,
        ) {
          final bool connected = connectivity != ConnectivityResult.none;

          return FloatingActionButton(
            onPressed: connected
                ? () {
                    Navigator.of(context).pushNamed(SelectImages.routeName);
                  }
                : null,
            child: Icon(Icons.add),
          );
        },
        child: SizedBox(),
      ),
    );
  }
}
