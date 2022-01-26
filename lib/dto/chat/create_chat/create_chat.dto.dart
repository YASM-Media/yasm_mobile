import 'package:json_annotation/json_annotation.dart';

part 'create_chat.dto.g.dart';

@JsonSerializable()
class CreateChatDto {
  @JsonKey(defaultValue: '')
  final String message;

  @JsonKey(defaultValue: '')
  final String threadId;

  final DateTime createdAt;

  CreateChatDto({
    required this.threadId,
    required this.message,
    required this.createdAt,
  });

  factory CreateChatDto.fromJson(Map<String, dynamic> json) =>
      _$CreateChatDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CreateChatDtoToJson(this);
}
