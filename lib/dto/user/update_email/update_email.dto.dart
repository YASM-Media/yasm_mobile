import 'package:json_annotation/json_annotation.dart';

part 'update_email.dto.g.dart';

@JsonSerializable()
class UpdateEmailDto {
  final String emailAddress;
  final String password;

  UpdateEmailDto({
    required this.emailAddress,
    required this.password,
  });

  factory UpdateEmailDto.fromJson(Map<String, dynamic> json) =>
      _$UpdateEmailDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateEmailDtoToJson(this);
}
