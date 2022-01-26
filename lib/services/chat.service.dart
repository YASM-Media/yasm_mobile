import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as FA;
import 'package:uuid/uuid.dart';
import 'package:yasm_mobile/dto/chat/create_chat/create_chat.dto.dart';
import 'package:yasm_mobile/dto/chat/create_thread/create_thread.dto.dart';
import 'package:yasm_mobile/dto/chat/delete_chat/delete_chat.dto.dart';
import 'package:yasm_mobile/dto/chat/delete_thread/delete_thread.dto.dart';
import 'package:yasm_mobile/models/chat/chat_message/chat_message.model.dart';
import 'package:yasm_mobile/models/chat/chat_thread/chat_thread.model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FA.FirebaseAuth _firebaseAuth = FA.FirebaseAuth.instance;
  final Uuid _uuid = new Uuid();

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
}
