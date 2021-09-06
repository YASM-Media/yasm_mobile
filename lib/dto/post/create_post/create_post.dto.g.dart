// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_post.dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreatePostDto _$CreatePostDtoFromJson(Map<String, dynamic> json) {
  return CreatePostDto(
    images: (json['images'] as List<dynamic>).map((e) => e as String).toList(),
    text: json['text'] as String,
  );
}

Map<String, dynamic> _$CreatePostDtoToJson(CreatePostDto instance) =>
    <String, dynamic>{
      'images': instance.images,
      'text': instance.text,
    };
