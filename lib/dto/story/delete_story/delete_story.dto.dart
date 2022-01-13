import 'package:json_annotation/json_annotation.dart';

part 'delete_story.dto.g.dart';

@JsonSerializable()
class DeleteStoryDto {
  final String storyId;

  DeleteStoryDto({
    required this.storyId,
  });

  factory DeleteStoryDto.fromJson(Map<String, dynamic> json) =>
      _$DeleteStoryDtoFromJson(json);

  Map<String, dynamic> toJson() => _$DeleteStoryDtoToJson(this);
}
