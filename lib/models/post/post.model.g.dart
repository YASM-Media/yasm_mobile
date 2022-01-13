// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post.model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PostAdapter extends TypeAdapter<Post> {
  @override
  final int typeId = 2;

  @override
  Post read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Post(
      id: fields[0] as String,
      text: fields[1] as String,
      createdAt: fields[2] as String,
      user: fields[3] as User,
      images: (fields[4] as List).cast<Image>(),
      likes: (fields[5] as List).cast<Like>(),
      comments: (fields[6] as List).cast<Post>(),
    );
  }

  @override
  void write(BinaryWriter writer, Post obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.text)
      ..writeByte(2)
      ..write(obj.createdAt)
      ..writeByte(3)
      ..write(obj.user)
      ..writeByte(4)
      ..write(obj.images)
      ..writeByte(5)
      ..write(obj.likes)
      ..writeByte(6)
      ..write(obj.comments);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PostAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Post _$PostFromJson(Map<String, dynamic> json) => Post(
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

Map<String, dynamic> _$PostToJson(Post instance) => <String, dynamic>{
      'id': instance.id,
      'text': instance.text,
      'createdAt': instance.createdAt,
      'user': instance.user,
      'images': instance.images,
      'likes': instance.likes,
      'comments': instance.comments,
    };
