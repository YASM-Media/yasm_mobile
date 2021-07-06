import 'package:json_annotation/json_annotation.dart';

part 'register_user.dto.g.dart';

@JsonSerializable()
class RegisterUser {
  String firstName;
  String lastName;
  String emailAddress;
  String password;

  RegisterUser({
    required this.firstName,
    required this.lastName,
    required this.emailAddress,
    required this.password,
  });

  factory RegisterUser.fromJson(Map<String, dynamic> json) =>
      _$RegisterUserFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterUserToJson(this);
}
