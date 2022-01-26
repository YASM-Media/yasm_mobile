// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delete_chat.dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeleteChatDto _$DeleteChatDtoFromJson(Map<String, dynamic> json) =>
    DeleteChatDto(
      threadId: json['threadId'] as String? ?? '',
      chatId: json['chatId'] as String? ?? '',
    );

Map<String, dynamic> _$DeleteChatDtoToJson(DeleteChatDto instance) =>
    <String, dynamic>{
      'threadId': instance.threadId,
      'chatId': instance.chatId,
    };
