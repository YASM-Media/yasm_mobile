import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'chat_message.model.g.dart';

@JsonSerializable()
class ChatMessage {
  @JsonKey(defaultValue: '')
  final String id;

  @JsonKey(defaultValue: '')
  final String userId;

  @JsonKey(defaultValue: '')
  final String message;

  @JsonKey(
    fromJson: timestampFromJson,
    toJson: timestampToJson,
  )
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.userId,
    required this.message,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);

  Map<String, dynamic> toJson() => _$ChatMessageToJson(this);

  static DateTime timestampFromJson(Timestamp ts) => ts.toDate();

  static Timestamp timestampToJson(DateTime dateTime) =>
      Timestamp.fromDate(dateTime);
}
