import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:provider/provider.dart';
import 'package:yasm_mobile/arguments/story.argument.dart';
import 'package:yasm_mobile/dto/chat/create_thread/create_thread.dto.dart';
import 'package:yasm_mobile/models/user/user.model.dart';
import 'package:yasm_mobile/pages/auth/auth.page.dart';
import 'package:yasm_mobile/pages/posts/posts.page.dart';
import 'package:yasm_mobile/pages/posts/select_images.page.dart';
import 'package:yasm_mobile/pages/search/search.page.dart';
import 'package:yasm_mobile/pages/stories/create_story.page.dart';
import 'package:yasm_mobile/pages/stories/story.page.dart';
import 'package:yasm_mobile/pages/user/user_profile.page.dart';
import 'package:yasm_mobile/pages/user/user_update.page.dart';
import 'package:yasm_mobile/providers/auth/auth.provider.dart';
import 'package:yasm_mobile/services/auth.service.dart';
import 'package:yasm_mobile/services/chat.service.dart';
import 'package:yasm_mobile/services/stories.service.dart';

class Home extends StatefulWidget {
  static const routeName = "/home";

  Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final AuthService _authService = AuthService();
  late final StoriesService _storiesService;
  late final ChatService _chatService;

  @override
  void initState() {
    super.initState();

    this._storiesService = Provider.of<StoriesService>(context, listen: false);
    this._chatService = Provider.of<ChatService>(context, listen: false);
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
                TextButton(
                  onPressed: () async {
                    await this._chatService.createChatThread(
                          new CreateThreadDto(
                            participants: [
                              '2e0533fa-2166-4832-93fc-a6f2ae24a3c2',
                              '87cea7a7-ffb2-43cb-b965-afc8e7c749b7',
                            ],
                          ),
                        );
                  },
                  child: Text('Dummy Chat'),
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
