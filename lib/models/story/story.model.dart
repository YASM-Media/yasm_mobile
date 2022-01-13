import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:yasm_mobile/models/user/user.model.dart';

part 'story.model.g.dart';

@JsonSerializable()
@HiveType(typeId: 5)
class Story {

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String storyUrl;

  @HiveField(2)
  final User user;

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  final DateTime updatedAt;

  Story({
    required this.id,
    required this.storyUrl,
    required this.user,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Story.fromJson(Map<String, dynamic> json) =>
      _$StoryFromJson(json);

  Map<String, dynamic> toJson() => _$StoryToJson(this);
}
