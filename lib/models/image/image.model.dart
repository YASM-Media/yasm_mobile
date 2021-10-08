import 'package:json_annotation/json_annotation.dart';

part 'image.model.g.dart';

@JsonSerializable()
class Image {
  final String id;
  final String imageUrl;

  Image({
    required this.id,
    required this.imageUrl,
  });

  factory Image.fromJson(Map<String, dynamic> json) => _$ImageFromJson(json);

  Map<String, dynamic> toJson() => _$ImageToJson(this);
}
