import 'package:json_annotation/json_annotation.dart';
import 'package:yasm_mobile/models/image/image.model.dart';
import 'package:yasm_mobile/models/like/like.model.dart';
import 'package:yasm_mobile/models/user/user.model.dart';

part 'post.model.g.dart';

@JsonSerializable()
class Post {
  final String id;
  final String text;
  final String createdAt;
  final User user;

  @JsonKey(defaultValue: [])
  final List<Image> images;

  @JsonKey(defaultValue: [])
  final List<Like> likes;

  @JsonKey(defaultValue: [])
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
