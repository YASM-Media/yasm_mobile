// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatMessage _$ChatMessageFromJson(Map<String, dynamic> json) => ChatMessage(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      message: json['message'] as String? ?? '',
      createdAt: ChatMessage.timestampFromJson(json['createdAt'] as Timestamp),
    );

Map<String, dynamic> _$ChatMessageToJson(ChatMessage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'message': instance.message,
      'createdAt': ChatMessage.timestampToJson(instance.createdAt),
    };
