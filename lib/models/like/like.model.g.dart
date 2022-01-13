// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'like.model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LikeAdapter extends TypeAdapter<Like> {
  @override
  final int typeId = 4;

  @override
  Like read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Like(
      id: fields[0] as String,
      user: fields[1] as User,
    );
  }

  @override
  void write(BinaryWriter writer, Like obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.user);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LikeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Like _$LikeFromJson(Map<String, dynamic> json) => Like(
      id: json['id'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$LikeToJson(Like instance) => <String, dynamic>{
      'id': instance.id,
      'user': instance.user,
    };
