// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'like.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Like _$LikeFromJson(Map<String, dynamic> json) {
  return Like(
    id: json['id'] as String,
    user: User.fromJson(json['user'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$LikeToJson(Like instance) => <String, dynamic>{
      'id': instance.id,
      'user': instance.user,
    };
