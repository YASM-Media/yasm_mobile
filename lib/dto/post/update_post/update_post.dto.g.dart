// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_post.dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdatePostDto _$UpdatePostDtoFromJson(Map<String, dynamic> json) =>
    UpdatePostDto(
      id: json['id'] as String,
      images:
          (json['images'] as List<dynamic>).map((e) => e as String).toList(),
      text: json['text'] as String,
    );

Map<String, dynamic> _$UpdatePostDtoToJson(UpdatePostDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'images': instance.images,
      'text': instance.text,
    };
