import 'package:json_annotation/json_annotation.dart';

part 'create_comment.dto.g.dart';

@JsonSerializable()
class CreateCommentDto {
  final String text;
  final String postId;

  CreateCommentDto({
    required this.text,
    required this.postId,
  });

  factory CreateCommentDto.fromJson(Map<String, dynamic> json) =>
      _$CreateCommentDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CreateCommentDtoToJson(this);
}
