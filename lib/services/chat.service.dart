import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as FA;
import 'package:uuid/uuid.dart';
import 'package:yasm_mobile/constants/endpoint.constant.dart';
import 'package:yasm_mobile/constants/logger.constant.dart';
import 'package:yasm_mobile/dto/chat/create_chat/create_chat.dto.dart';
import 'package:yasm_mobile/dto/chat/create_thread/create_thread.dto.dart';
import 'package:yasm_mobile/dto/chat/delete_chat/delete_chat.dto.dart';
import 'package:yasm_mobile/dto/chat/delete_thread/delete_thread.dto.dart';
import 'package:yasm_mobile/dto/chat/send_chat_notification/send_chat_notification.dto.dart';
import 'package:yasm_mobile/exceptions/auth/not_logged_in.exception.dart';
import 'package:yasm_mobile/exceptions/common/server.exception.dart';
import 'package:yasm_mobile/models/chat/chat_message/chat_message.model.dart';
import 'package:yasm_mobile/models/chat/chat_thread/chat_thread.model.dart';
import 'package:http/http.dart' as http;

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FA.FirebaseAuth _firebaseAuth = FA.FirebaseAuth.instance;
  final Uuid _uuid = new Uuid();

  Stream<QuerySnapshot<Map<String, dynamic>>> fetchAllThreads() => this
      ._firestore
      .collection('threads')
      .where("participants", arrayContains: this._firebaseAuth.currentUser!.uid)
      .snapshots();

  Stream<DocumentSnapshot<Map<String, dynamic>>> listenToThread(
    String threadId,
  ) =>
      this._firestore.collection('threads').doc(threadId).snapshots();

  Future<ChatThread> fetchThreadData(
    String threadId,
  ) async {
    DocumentSnapshot threadDocumentSnapshot =
        await this._firestore.collection('threads').doc(threadId).get();

    Map<String, dynamic> data =
        threadDocumentSnapshot.data() as Map<String, dynamic>;

    ChatThread chatThread = ChatThread.fromJson(data);

    return chatThread;
  }

  Future<String> createChatThread(CreateThreadDto createThreadDto) async {
    ChatThread chatThread = new ChatThread(
      id: this._uuid.v4(),
      participants: createThreadDto.participants,
      messages: [],
      seen: createThreadDto.participants,
    );

    await this
        ._firestore
        .collection('threads')
        .doc(chatThread.id)
        .set(chatThread.toJson());

    return chatThread.id;
  }

  Future<void> createChatMessage(CreateChatDto createChatDto) async {
    String userId = this._firebaseAuth.currentUser!.uid;
    ChatMessage chatMessage = new ChatMessage(
      id: this._uuid.v4(),
      userId: userId,
      message: createChatDto.message,
      createdAt: createChatDto.createdAt,
    );

    DocumentSnapshot threadDocumentSnapshot = await this
        ._firestore
        .collection('threads')
        .doc(createChatDto.threadId)
        .get();

    Map<String, dynamic> data =
        threadDocumentSnapshot.data() as Map<String, dynamic>;

    ChatThread chatThread = ChatThread.fromJson(data);
    chatThread.messages.add(chatMessage);
    chatThread.seen.clear();
    chatThread.seen.add(userId);

    Map<String, dynamic> threadJson = chatThread.toJson();
    threadJson['messages'] = threadJson['messages']
        .map((ChatMessage message) => message.toJson())
        .toList();

    await this
        ._firestore
        .collection('threads')
        .doc(chatThread.id)
        .set(threadJson);

    await this._sendChatNotification(
      new SendChatNotificationDto(
        threadId: chatThread.id,
        message: createChatDto.message,
      ),
    );
  }

  Future<void> markSeenMessages(ChatThread chatThread) async {
    String userId = this._firebaseAuth.currentUser!.uid;

    if (chatThread.seen.where((id) => id == userId).isNotEmpty) {
      log.i("Message Already Read");
      return;
    }

    chatThread.seen.add(userId);

    Map<String, dynamic> threadJson = chatThread.toJson();
    threadJson['messages'] = threadJson['messages']
        .map((ChatMessage message) => message.toJson())
        .toList();

    await this
        ._firestore
        .collection('threads')
        .doc(chatThread.id)
        .set(threadJson);
  }

  Future<void> deleteChatThread(DeleteThreadDto deleteThreadDto) async =>
      await this
          ._firestore
          .collection('threads')
          .doc(deleteThreadDto.threadId)
          .delete();

  Future<void> deleteChatMessage(DeleteChatDto deleteChatDto) async {
    String userId = this._firebaseAuth.currentUser!.uid;

    DocumentSnapshot threadDocumentSnapshot = await this
        ._firestore
        .collection('threads')
        .doc(deleteChatDto.threadId)
        .get();

    Map<String, dynamic> data =
        threadDocumentSnapshot.data() as Map<String, dynamic>;

    ChatThread chatThread = ChatThread.fromJson(data);

    chatThread.messages.removeWhere((message) =>
        message.id == deleteChatDto.chatId && message.userId == userId);

    Map<String, dynamic> threadJson = chatThread.toJson();
    threadJson['messages'] = threadJson['messages']
        .map((ChatMessage message) => message.toJson())
        .toList();

    await this
        ._firestore
        .collection('threads')
        .doc(chatThread.id)
        .set(threadJson);
  }

  Future<void> _sendChatNotification(
      SendChatNotificationDto sendChatNotificationDto) async {
    // Fetch the currently logged in user.
    FA.User? firebaseUser = this._firebaseAuth.currentUser;

    // Check is the user exists.
    if (firebaseUser == null) {
      throw NotLoggedInException(message: "User not logged in.");
    }

    // Fetching the ID token for authentication.
    String firebaseAuthToken = await firebaseUser.getIdToken();

    // Preparing the URL for the server request.
    Uri url = Uri.parse("$ENDPOINT/notification/chat");

    // Preparing the headers for the request.
    Map<String, String> headers = {
      "Authorization": "Bearer $firebaseAuthToken",
    };

    // POSTing to the server with new post details.
    http.Response response = await http
        .post(
          url,
          headers: headers,
          body: sendChatNotificationDto.toJson(),
        )
        .timeout(new Duration(seconds: 10));

    // Check if the response does not contain any error.
    if (response.statusCode >= 400 && response.statusCode < 500) {
      Map<String, dynamic> body = json.decode(response.body);
      throw ServerException(message: body['message']);
    } else if (response.statusCode >= 500) {
      Map<String, dynamic> body = json.decode(response.body);

      log.e(body["message"]);

      throw ServerException(
        message: 'Something went wrong, please try again later.',
      );
    }
  }
}
