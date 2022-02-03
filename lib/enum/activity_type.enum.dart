import 'package:hive/hive.dart';

part 'activity_type.enum.g.dart';

@HiveType(typeId: 6)
enum ActivityType {
  @HiveField(0)
  FOLLOW,

  @HiveField(1)
  LIKE,

  @HiveField(2)
  COMMENT,
}
