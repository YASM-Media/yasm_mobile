import 'package:json_annotation/json_annotation.dart';

part 'update_post.dto.g.dart';

@JsonSerializable()
class UpdatePostDto {
  final String id;
  final List<String> images;
  final String text;

  UpdatePostDto({
    required this.id,
    required this.images,
    required this.text,
  });

  factory UpdatePostDto.fromJson(Map<String, dynamic> json) =>
      _$UpdatePostDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UpdatePostDtoToJson(this);
}
