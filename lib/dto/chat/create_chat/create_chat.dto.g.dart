// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_chat.dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateChatDto _$CreateChatDtoFromJson(Map<String, dynamic> json) =>
    CreateChatDto(
      threadId: json['threadId'] as String? ?? '',
      message: json['message'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$CreateChatDtoToJson(CreateChatDto instance) =>
    <String, dynamic>{
      'message': instance.message,
      'threadId': instance.threadId,
      'createdAt': instance.createdAt.toIso8601String(),
    };
