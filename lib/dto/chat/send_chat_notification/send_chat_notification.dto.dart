import 'package:json_annotation/json_annotation.dart';

part 'send_chat_notification.dto.g.dart';

@JsonSerializable()
class SendChatNotificationDto {

  @JsonKey(defaultValue: '')
  final String threadId;

  @JsonKey(defaultValue: '')
  final String message;

  SendChatNotificationDto({
    required this.threadId,
    required this.message,
  });

  factory SendChatNotificationDto.fromJson(Map<String, dynamic> json) =>
      _$SendChatNotificationDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SendChatNotificationDtoToJson(this);
}
