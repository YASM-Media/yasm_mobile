import 'package:json_annotation/json_annotation.dart';
import 'package:yasm_mobile/models/chat/chat_message/chat_message.model.dart';

part 'chat_thread.model.g.dart';

@JsonSerializable()
class ChatThread {

  @JsonKey(defaultValue: '')
  final String id;

  @JsonKey(defaultValue: [])
  final List<String> participants;

  @JsonKey(defaultValue: [])
  final List<ChatMessage> messages;

  @JsonKey(defaultValue: [])
  final List<String> seen;

  ChatThread({
    required this.id,
    required this.participants,
    required this.messages,
    required this.seen,
  });

  factory ChatThread.fromJson(Map<String, dynamic> json) =>
      _$ChatThreadFromJson(json);

  Map<String, dynamic> toJson() => _$ChatThreadToJson(this);
}
