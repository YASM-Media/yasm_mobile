// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_comment.dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateCommentDto _$CreateCommentDtoFromJson(Map<String, dynamic> json) {
  return CreateCommentDto(
    text: json['text'] as String,
    postId: json['postId'] as String,
  );
}

Map<String, dynamic> _$CreateCommentDtoToJson(CreateCommentDto instance) =>
    <String, dynamic>{
      'text': instance.text,
      'postId': instance.postId,
    };
