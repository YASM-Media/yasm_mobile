// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delete_comment.dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeleteCommentDto _$DeleteCommentDtoFromJson(Map<String, dynamic> json) =>
    DeleteCommentDto(
      postId: json['postId'] as String,
      commentId: json['commentId'] as String,
    );

Map<String, dynamic> _$DeleteCommentDtoToJson(DeleteCommentDto instance) =>
    <String, dynamic>{
      'postId': instance.postId,
      'commentId': instance.commentId,
    };
