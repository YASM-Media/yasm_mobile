import 'package:yasm_mobile/models/chat/chat_thread/chat_thread.model.dart';
import 'package:yasm_mobile/models/user/user.model.dart';

class ChatArguments {
  final ChatThread chatThread;
  final User user;

  ChatArguments({
    required this.chatThread,
    required this.user,
  });
}
