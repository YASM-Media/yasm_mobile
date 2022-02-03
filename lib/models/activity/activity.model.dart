import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:yasm_mobile/enum/activity_type.enum.dart';
import 'package:yasm_mobile/models/post/post.model.dart';
import 'package:yasm_mobile/models/user/user.model.dart';

part 'activity.model.g.dart';

@HiveType(typeId: 7)
@JsonSerializable()
class Activity {
  @HiveField(0, defaultValue: '')
  final String id;

  @HiveField(1)
  final User mainUser;

  @HiveField(2)
  final User triggeredByUser;

  @HiveField(3)
  final ActivityType activityType;

  @HiveField(4, defaultValue: null)
  final Post? post;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  final DateTime updatedAt;

  Activity({
    required this.id,
    required this.mainUser,
    required this.triggeredByUser,
    required this.activityType,
    this.post,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Activity.fromJson(Map<String, dynamic> json) =>
      _$ActivityFromJson(json);

  Map<String, dynamic> toJson() => _$ActivityToJson(this);
}
