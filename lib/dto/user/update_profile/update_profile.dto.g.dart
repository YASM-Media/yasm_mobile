// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_profile.dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateProfileDto _$UpdateProfileDtoFromJson(Map<String, dynamic> json) =>
    UpdateProfileDto(
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      biography: json['biography'] as String,
      imageUrl: json['imageUrl'] as String,
    );

Map<String, dynamic> _$UpdateProfileDtoToJson(UpdateProfileDto instance) =>
    <String, dynamic>{
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'biography': instance.biography,
      'imageUrl': instance.imageUrl,
    };
