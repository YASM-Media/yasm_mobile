import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:provider/provider.dart';
import 'package:yasm_mobile/pages/auth/auth.page.dart';
import 'package:yasm_mobile/pages/posts/posts.page.dart';
import 'package:yasm_mobile/pages/posts/select_images.page.dart';
import 'package:yasm_mobile/pages/search/search.page.dart';
import 'package:yasm_mobile/pages/stories/create_story.page.dart';
import 'package:yasm_mobile/pages/user/user_profile.page.dart';
import 'package:yasm_mobile/pages/user/user_update.page.dart';
import 'package:yasm_mobile/providers/auth/auth.provider.dart';
import 'package:yasm_mobile/services/auth.service.dart';

class Home extends StatelessWidget {
  static const routeName = "/home";

  Home({Key? key}) : super(key: key);

  final AuthService _authService = AuthService();

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
      body: Center(
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
              ],
            ),
          ],
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
