import 'package:json_annotation/json_annotation.dart';

part 'update_comment.dto.g.dart';

@JsonSerializable()
class UpdateCommentDto {
  final String id;
  final String text;

  UpdateCommentDto({
    required this.id,
    required this.text,
  });

  factory UpdateCommentDto.fromJson(Map<String, dynamic> json) =>
      _$UpdateCommentDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateCommentDtoToJson(this);
}
