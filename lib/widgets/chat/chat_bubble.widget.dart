import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:yasm_mobile/models/chat/chat_message/chat_message.model.dart';
import 'package:yasm_mobile/providers/auth/auth.provider.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage chatMessage;
  final Function onDelete;

  const ChatBubble({
    Key? key,
    required this.chatMessage,
    required this.onDelete,
  }) : super(key: key);

  void _openDeleteDialog(BuildContext context) {
    String formattedMessage = this.chatMessage.message.length > 15
        ? "${this.chatMessage.message.substring(0, 15)}..."
        : this.chatMessage.message;
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
      title: Text('Are you sure you want to delete this message?'),
      content: Text(formattedMessage),
      actions: [
        TextButton(
          onPressed: () async {
            Navigator.of(context).pop();
            await this.onDelete(this.chatMessage.id);
          },
          child: Text('YES'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('NO'),
        ),
      ],
    ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (BuildContext context, AuthProvider state, _) {
        bool userCheck = this.chatMessage.userId == state.getUser()!.id;
        return GestureDetector(
          onLongPress: userCheck
              ? () {
            this._openDeleteDialog(context);
          }
              : null,
          child: Container(
            margin: EdgeInsets.all(
              10.0,
            ),
            alignment: userCheck ? Alignment.centerRight : Alignment.centerLeft,
            child: Column(
              crossAxisAlignment:
              userCheck ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(
                    10.0,
                  ),
                  decoration: BoxDecoration(
                    color: userCheck ? Colors.grey[900] : Colors.pink,
                    borderRadius: BorderRadius.circular(
                      20.0,
                    ),
                  ),
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.5,
                  ),
                  child: Text(
                    this.chatMessage.message,
                    style: TextStyle(
                      color: userCheck ? Colors.white : Colors.black,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 5.0,
                    vertical: 5.0,
                  ),
                  child: Text(
                    DateFormat.yMd()
                        .add_jm()
                        .format(
                      this.chatMessage.createdAt.toLocal(),
                    )
                        .toString(),
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 10.0,
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}