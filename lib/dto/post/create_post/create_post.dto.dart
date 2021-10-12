import 'package:json_annotation/json_annotation.dart';

part 'create_post.dto.g.dart';

@JsonSerializable()
class CreatePostDto {
  final List<String> images;
  final String text;

  CreatePostDto({
    required this.images,
    required this.text,
  });

  factory CreatePostDto.fromJson(Map<String, dynamic> json) =>
      _$CreatePostDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CreatePostDtoToJson(this);
}
