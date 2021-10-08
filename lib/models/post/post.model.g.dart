// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Post _$PostFromJson(Map<String, dynamic> json) {
  return Post(
    id: json['id'] as String,
    text: json['text'] as String,
    createdAt: json['createdAt'] as String,
    user: User.fromJson(json['user'] as Map<String, dynamic>),
    images: (json['images'] as List<dynamic>?)
            ?.map((e) => Image.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
    likes: (json['likes'] as List<dynamic>?)
            ?.map((e) => Like.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
    comments: (json['comments'] as List<dynamic>?)
            ?.map((e) => Post.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
  );
}

Map<String, dynamic> _$PostToJson(Post instance) => <String, dynamic>{
      'id': instance.id,
      'text': instance.text,
      'createdAt': instance.createdAt,
      'user': instance.user,
      'images': instance.images,
      'likes': instance.likes,
      'comments': instance.comments,
    };
