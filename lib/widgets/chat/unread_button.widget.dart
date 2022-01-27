import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yasm_mobile/constants/logger.constant.dart';
import 'package:yasm_mobile/models/chat/chat_thread/chat_thread.model.dart';
import 'package:yasm_mobile/models/user/user.model.dart';
import 'package:yasm_mobile/pages/chat/threads.page.dart';
import 'package:yasm_mobile/providers/auth/auth.provider.dart';
import 'package:yasm_mobile/services/chat.service.dart';

class UnreadButton extends StatefulWidget {
  const UnreadButton({Key? key}) : super(key: key);

  @override
  _UnreadButtonState createState() => _UnreadButtonState();
}

class _UnreadButtonState extends State<UnreadButton> {
  late final ChatService _chatService;

  @override
  void initState() {
    super.initState();

    this._chatService = Provider.of<ChatService>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (BuildContext context, AuthProvider authProvider, _) {
        User user = authProvider.getUser()!;

        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: this._chatService.fetchAllThreads(),
          builder: (
            BuildContext context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot,
          ) {
            if (snapshot.hasError) {
              log.e("Threads Error", snapshot.error, snapshot.stackTrace);
              return Text('Something went wrong, please try again later.');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildChatButton();
            }

            int unreadCount = 0;
            snapshot.data!.docs.forEach((thread) {
              ChatThread chatThread = ChatThread.fromJson(thread.data());

              if (chatThread.seen.where((id) => id == user.id).isEmpty) {
                unreadCount += 1;
              }
            });

            return _buildUnreadChatButton(unreadCount);
          },
        );
      },
    );
  }

  Widget _buildUnreadChatButton(int unreadCount) {
    return Stack(
      children: [
        IconButton(
          onPressed: this._handleChatButtonPress,
          icon: Icon(
            Icons.chat,
          ),
        ),
        Align(
          alignment: Alignment.topLeft,
          child: CircleAvatar(
            radius: MediaQuery.of(context).size.width * 0.025,
            backgroundColor: Colors.red,
            child: Text(
              unreadCount.toString(),
              style: TextStyle(
                color: Colors.white,
                fontSize: MediaQuery.of(context).size.width * 0.025,
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildChatButton() => IconButton(
        onPressed: this._handleChatButtonPress,
        icon: Icon(
          Icons.chat,
        ),
      );

  void _handleChatButtonPress() {
    Navigator.of(context).pushNamed(
      Threads.routeName,
    );
  }
}
