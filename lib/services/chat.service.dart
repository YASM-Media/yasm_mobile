import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:yasm_mobile/dto/chat/create_thread/create_thread.dto.dart';
import 'package:yasm_mobile/models/chat/chat_thread/chat_thread.model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
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
}
