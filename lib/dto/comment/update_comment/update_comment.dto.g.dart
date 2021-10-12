// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_comment.dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateCommentDto _$UpdateCommentDtoFromJson(Map<String, dynamic> json) {
  return UpdateCommentDto(
    id: json['id'] as String,
    text: json['text'] as String,
  );
}

Map<String, dynamic> _$UpdateCommentDtoToJson(UpdateCommentDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'text': instance.text,
    };
