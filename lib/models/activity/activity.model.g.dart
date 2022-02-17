// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity.model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ActivityAdapter extends TypeAdapter<Activity> {
  @override
  final int typeId = 7;

  @override
  Activity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Activity(
      id: fields[0] == null ? 0 : fields[0] as int,
      mainUser: fields[1] as User,
      triggeredByUser: fields[2] as User,
      activityType: fields[3] as ActivityType,
      post: fields[4] as Post?,
      createdAt: fields[5] as DateTime,
      updatedAt: fields[6] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Activity obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.mainUser)
      ..writeByte(2)
      ..write(obj.triggeredByUser)
      ..writeByte(3)
      ..write(obj.activityType)
      ..writeByte(4)
      ..write(obj.post)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActivityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Activity _$ActivityFromJson(Map<String, dynamic> json) => Activity(
      id: json['id'] as int,
      mainUser: User.fromJson(json['mainUser'] as Map<String, dynamic>),
      triggeredByUser:
          User.fromJson(json['triggeredByUser'] as Map<String, dynamic>),
      activityType: $enumDecode(_$ActivityTypeEnumMap, json['activityType']),
      post: json['post'] == null
          ? null
          : Post.fromJson(json['post'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$ActivityToJson(Activity instance) => <String, dynamic>{
      'id': instance.id,
      'mainUser': instance.mainUser,
      'triggeredByUser': instance.triggeredByUser,
      'activityType': _$ActivityTypeEnumMap[instance.activityType],
      'post': instance.post,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$ActivityTypeEnumMap = {
  ActivityType.FOLLOW: 'FOLLOW',
  ActivityType.LIKE: 'LIKE',
  ActivityType.COMMENT: 'COMMENT',
};
