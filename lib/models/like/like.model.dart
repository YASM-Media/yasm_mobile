import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:yasm_mobile/models/user/user.model.dart';

part 'like.model.g.dart';

@JsonSerializable()
@HiveType(typeId: 4)
class Like {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final User user;

  Like({
    required this.id,
    required this.user,
  });

  factory Like.fromJson(Map<String, dynamic> json) => _$LikeFromJson(json);

  Map<String, dynamic> toJson() => _$LikeToJson(this);
}
