import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yasm_mobile/constants/logger.constant.dart';
import 'package:yasm_mobile/models/chat/chat_thread/chat_thread.model.dart';
import 'package:yasm_mobile/pages/chat/chat.page.dart';
import 'package:yasm_mobile/services/chat.service.dart';

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
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
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
            return Text("Loading");
          }

          this._threads.clear();
          snapshot.data!.docs.forEach((thread) {
            this._threads.add(ChatThread.fromJson(thread.data()));
          });

          return ListView.builder(
            itemCount: this._threads.length,
            itemBuilder: (context, index) {
              ChatThread thread = this._threads[index];
              return ListTile(
                leading: Icon(Icons.person),
                title: Text(thread.id),
                subtitle: Text(thread.participants.join(", ")),
                onTap: () {
                  Navigator.of(context).pushNamed(
                    Chat.routeName,
                    arguments: thread.id,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
