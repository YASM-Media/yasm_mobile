import 'package:json_annotation/json_annotation.dart';

part 'create_story.dto.g.dart';

@JsonSerializable()
class CreateStoryDto {
  final String storyUrl;

  CreateStoryDto({
    required this.storyUrl,
  });

  factory CreateStoryDto.fromJson(Map<String, dynamic> json) =>
      _$CreateStoryDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CreateStoryDtoToJson(this);
}
