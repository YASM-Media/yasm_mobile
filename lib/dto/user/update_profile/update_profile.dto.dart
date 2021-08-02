import 'package:json_annotation/json_annotation.dart';

part 'update_profile.dto.g.dart';

@JsonSerializable()
class UpdateProfileDto {
  final String firstName;
  final String lastName;
  final String biography;
  final String imageUrl;

  UpdateProfileDto({
    required this.firstName,
    required this.lastName,
    required this.biography,
    required this.imageUrl,
  });

  factory UpdateProfileDto.fromJson(Map<String, dynamic> json) =>
      _$UpdateProfileDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateProfileDtoToJson(this);
}
