import 'package:json_annotation/json_annotation.dart';
import 'package:yasm_mobile/models/user/user.model.dart';

part 'like.model.g.dart';

@JsonSerializable()
class Like {
  final String id;
  final User user;

  Like({
    required this.id,
    required this.user,
  });

  factory Like.fromJson(Map<String, dynamic> json) => _$LikeFromJson(json);

  Map<String, dynamic> toJson() => _$LikeToJson(this);
}
