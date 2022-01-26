import 'package:json_annotation/json_annotation.dart';

part 'delete_thread.dto.g.dart';

@JsonSerializable()
class DeleteThreadDto {
  @JsonKey(defaultValue: '')
  final String threadId;

  DeleteThreadDto({
    required this.threadId,
  });

  factory DeleteThreadDto.fromJson(Map<String, dynamic> json) =>
      _$DeleteThreadDtoFromJson(json);

  Map<String, dynamic> toJson() => _$DeleteThreadDtoToJson(this);
}
