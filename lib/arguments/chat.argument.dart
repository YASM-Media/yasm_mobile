import 'package:yasm_mobile/models/chat/chat_thread/chat_thread.model.dart';
import 'package:yasm_mobile/models/user/user.model.dart';

class ChatArgument {
  final ChatThread chatThread;
  final User user;

  ChatArgument({
    required this.chatThread,
    required this.user,
  });
}
