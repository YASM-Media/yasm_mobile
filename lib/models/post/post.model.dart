import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:yasm_mobile/models/image/image.model.dart';
import 'package:yasm_mobile/models/like/like.model.dart';
import 'package:yasm_mobile/models/user/user.model.dart';

part 'post.model.g.dart';

@JsonSerializable()
@HiveType(typeId: 2)
class Post {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String text;

  @HiveField(2)
  final String createdAt;

  @HiveField(3)
  final User user;

  @JsonKey(defaultValue: [])
  @HiveField(4)
  final List<Image> images;

  @JsonKey(defaultValue: [])
  @HiveField(5)
  final List<Like> likes;

  @JsonKey(defaultValue: [])
  @HiveField(6)
  final List<Post> comments;

  Post({
    required this.id,
    required this.text,
    required this.createdAt,
    required this.user,
    required this.images,
    required this.likes,
    required this.comments,
  });

  factory Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);

  Map<String, dynamic> toJson() => _$PostToJson(this);
}
