// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_type.enum.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ActivityTypeAdapter extends TypeAdapter<ActivityType> {
  @override
  final int typeId = 6;

  @override
  ActivityType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ActivityType.FOLLOW;
      case 1:
        return ActivityType.LIKE;
      case 2:
        return ActivityType.COMMENT;
      default:
        return ActivityType.FOLLOW;
    }
  }

  @override
  void write(BinaryWriter writer, ActivityType obj) {
    switch (obj) {
      case ActivityType.FOLLOW:
        writer.writeByte(0);
        break;
      case ActivityType.LIKE:
        writer.writeByte(1);
        break;
      case ActivityType.COMMENT:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActivityTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
