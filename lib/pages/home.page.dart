import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:provider/provider.dart';
import 'package:yasm_mobile/constants/logger.constant.dart';
import 'package:yasm_mobile/firebase_notifications_handler.dart';
import 'package:yasm_mobile/pages/activity/activity.page.dart';
import 'package:yasm_mobile/pages/posts/new_post.page.dart';
import 'package:yasm_mobile/pages/posts/posts.page.dart';
import 'package:yasm_mobile/pages/posts/select_images.page.dart';
import 'package:yasm_mobile/pages/search/search.page.dart';
import 'package:yasm_mobile/pages/user/user_profile.page.dart';
import 'package:yasm_mobile/services/tokens.service.dart';
import 'package:yasm_mobile/utils/check_connectivity.util.dart';

class Home extends StatefulWidget {
  static const routeName = "/home";

  Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late final TokensService _tokensService;

  List<Widget> _pages = [
    Posts(),
    Search(),
    Activity(),
    UserProfile(),
  ];
  int _page = 0;

  @override
  void initState() {
    super.initState();

    this._tokensService = Provider.of<TokensService>(context, listen: false);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FirebaseNotificationsHandler(
        child: this._pages.elementAt(this._page),
      ),
      bottomNavigationBar: BottomNavigationBar(
        // selectedFontSize: 20,
        selectedIconTheme: IconThemeData(color: Colors.white),
        selectedItemColor: Colors.white,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
        unselectedIconTheme: IconThemeData(
          color: Colors.grey[600],
        ),
        unselectedItemColor: Colors.grey[600],
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Activity',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'User',
          ),
        ],
        currentIndex: this._page,
        onTap: (int index) {
          setState(() {
            this._page = index;
          });
        },
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
                    Navigator.of(context).pushNamed(NewPost.routeName);
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
