import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:provider/provider.dart';
import 'package:yasm_mobile/constants/logger.constant.dart';
import 'package:yasm_mobile/firebase_notifications_handler.dart';
import 'package:yasm_mobile/pages/activity/activity.page.dart';
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
        child: IndexedStack(
          index: this._page,
          children: this._pages,
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              margin: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.04,
              ),
              child: IconButton(
                icon: Icon(Icons.home),
                onPressed: () {
                  setState(() {
                    this._page = 0;
                  });
                },
              ),
            ),
            Container(
              margin: EdgeInsets.only(
                right: MediaQuery.of(context).size.width * 0.1,
                left: MediaQuery.of(context).size.width * 0.05,
              ),
              child: IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                  setState(() {
                    this._page = 1;
                  });
                },
              ),
            ),
            Container(
              margin: EdgeInsets.only(
                left: MediaQuery.of(context).size.width * 0.1,
                right: MediaQuery.of(context).size.width * 0.05,
              ),
              child: IconButton(
                icon: Icon(Icons.favorite),
                onPressed: () {
                  setState(() {
                    this._page = 2;
                  });
                },
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.04,
              ),
              child: IconButton(
                icon: Icon(Icons.person),
                onPressed: () {
                  setState(() {
                    this._page = 3;
                  });
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
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
