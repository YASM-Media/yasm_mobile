import 'package:json_annotation/json_annotation.dart';
import 'package:yasm_mobile/models/image/image.model.dart';

part 'create_post.dto.g.dart';

@JsonSerializable()
class CreatePostDto {
  final List<Image> images;
  final String text;

  CreatePostDto({
    required this.images,
    required this.text,
  });

  factory CreatePostDto.fromJson(Map<String, dynamic> json) =>
      _$CreatePostDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CreatePostDtoToJson(this);
}
