import 'package:json_annotation/json_annotation.dart';

part 'login_user.dto.g.dart';

@JsonSerializable()
class LoginUser {
  String email;
  String password;

  LoginUser({
    required this.email,
    required this.password,
  });

  factory LoginUser.fromJson(Map<String, dynamic> json) =>
      _$LoginUserFromJson(json);

  Map<String, dynamic> toJson() => _$LoginUserToJson(this);
}
