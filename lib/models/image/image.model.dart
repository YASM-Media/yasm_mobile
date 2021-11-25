import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'image.model.g.dart';

@JsonSerializable()
@HiveType(typeId: 3)
class Image {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String imageUrl;

  Image({
    required this.id,
    required this.imageUrl,
  });

  factory Image.fromJson(Map<String, dynamic> json) => _$ImageFromJson(json);

  Map<String, dynamic> toJson() => _$ImageToJson(this);
}
