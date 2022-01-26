import 'package:json_annotation/json_annotation.dart';

part 'delete_chat.dto.g.dart';

@JsonSerializable()
class DeleteChatDto {
  @JsonKey(defaultValue: '')
  final String threadId;

  @JsonKey(defaultValue: '')
  final String chatId;

  DeleteChatDto({
    required this.threadId,
    required this.chatId,
  });

  factory DeleteChatDto.fromJson(Map<String, dynamic> json) =>
      _$DeleteChatDtoFromJson(json);

  Map<String, dynamic> toJson() => _$DeleteChatDtoToJson(this);
}
