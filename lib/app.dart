import 'package:flutter/material.dart';
import 'package:yasm_mobile/pages/activity/activity.page.dart';
import 'package:yasm_mobile/pages/auth/auth.page.dart';
import 'package:yasm_mobile/pages/chat/chat.page.dart';
import 'package:yasm_mobile/pages/chat/threads.page.dart';
import 'package:yasm_mobile/pages/common/splash.page.dart';
import 'package:yasm_mobile/pages/home.page.dart';
import 'package:yasm_mobile/pages/posts/full_post.page.dart';
import 'package:yasm_mobile/pages/posts/new_post.page.dart';
import 'package:yasm_mobile/pages/posts/posts.page.dart';
import 'package:yasm_mobile/pages/posts/update_post.page.dart';
import 'package:yasm_mobile/pages/search/search.page.dart';
import 'package:yasm_mobile/pages/search/search_results.page.dart';
import 'package:yasm_mobile/pages/stories/create_story.page.dart';
import 'package:yasm_mobile/pages/stories/story.page.dart';
import 'package:yasm_mobile/pages/user/user_profile.page.dart';
import 'package:yasm_mobile/pages/user/user_update.page.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YASM!!🌟',
      debugShowCheckedModeBanner: false,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.pink,
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.black,
        ),
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all<Color>(
              Colors.pink,
            ),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(
              Colors.pink,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all<Color>(
              Colors.pink,
            ),
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.pink,
          foregroundColor: Colors.white,
        ),
      ),
      themeMode: ThemeMode.dark,
      home: Splash(),
      routes: {
        Home.routeName: (context) => Home(),
        Auth.routeName: (context) => Auth(),
        UserUpdate.routeName: (context) => UserUpdate(),
        UserProfile.routeName: (context) => UserProfile(),
        NewPost.routeName: (context) => NewPost(),
        Posts.routeName: (context) => Posts(),
        UpdatePost.routeName: (context) => UpdatePost(),
        FullPost.routeName: (context) => FullPost(),
        Search.routeName: (context) => Search(),
        SearchResults.routeName: (context) => SearchResults(),
        Story.routeName: (context) => Story(),
        CreateStory.routeName: (context) => CreateStory(),
        Chat.routeName: (context) => Chat(),
        Threads.routeName: (context) => Threads(),
        Activity.routeName: (context) => Activity(),
      },
    );
  }
}
