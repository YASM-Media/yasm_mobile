// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'send_chat_notification.dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SendChatNotificationDto _$SendChatNotificationDtoFromJson(
        Map<String, dynamic> json) =>
    SendChatNotificationDto(
      threadId: json['threadId'] as String? ?? '',
      message: json['message'] as String? ?? '',
    );

Map<String, dynamic> _$SendChatNotificationDtoToJson(
        SendChatNotificationDto instance) =>
    <String, dynamic>{
      'threadId': instance.threadId,
      'message': instance.message,
    };
