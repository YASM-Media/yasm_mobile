import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yasm_mobile/constants/logger.constant.dart';
import 'package:yasm_mobile/models/chat/chat_thread/chat_thread.model.dart';
import 'package:yasm_mobile/models/user/user.model.dart';
import 'package:yasm_mobile/providers/auth/auth.provider.dart';
import 'package:yasm_mobile/services/chat.service.dart';
import 'package:yasm_mobile/widgets/chat/thread.widget.dart';
import 'package:yasm_mobile/widgets/chat/user_thread.widget.dart';

class Threads extends StatefulWidget {
  const Threads({Key? key}) : super(key: key);

  static const routeName = "/threads";

  @override
  _ThreadsState createState() => _ThreadsState();
}

class _ThreadsState extends State<Threads> {
  late final ChatService _chatService;
  List<ChatThread> _threads = [];

  @override
  void initState() {
    super.initState();

    // Injecting required services from context.
    this._chatService = Provider.of<ChatService>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Threads'),
      ),
      body: Consumer<AuthProvider>(
        builder:
            (BuildContext context, AuthProvider authProvider, Widget? child) {
          User loggedInUser = authProvider.getUser()!;

          List<User> followingUsers = [...loggedInUser.following];

          log.i(followingUsers);
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: this._chatService.fetchAllThreads(),
                  builder: (
                    BuildContext context,
                    AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot,
                  ) {
                    if (snapshot.hasError) {
                      log.e(
                          "Threads Error", snapshot.error, snapshot.stackTrace);
                      return Text(
                          'Something went wrong, please try again later.');
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Text("Loading");
                    }

                    this._threads.clear();
                    snapshot.data!.docs.forEach((thread) {
                      ChatThread chatThread =
                          ChatThread.fromJson(thread.data());

                      chatThread.participants.forEach((participantId) {
                        followingUsers
                            .removeWhere((user) => user.id == participantId);
                      });

                      log.i(followingUsers);

                      this._threads.add(chatThread);
                    });

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: this._threads.length,
                          itemBuilder: (context, index) {
                            ChatThread thread = this._threads[index];
                            return Thread(
                              chatThread: thread,
                            );
                          },
                        ),
                        if (followingUsers.isNotEmpty)
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal:
                                  MediaQuery.of(context).size.width * 0.055,
                              vertical:
                                  MediaQuery.of(context).size.height * 0.02,
                            ),
                            child: Text(
                              'Start Chatting',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize:
                                    MediaQuery.of(context).size.height * 0.03,
                              ),
                            ),
                          ),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: followingUsers.length,
                          itemBuilder: (context, index) {
                            String userId = followingUsers[index].id;
                            return UserThread(
                              userId: userId,
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
