// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_user.dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginUser _$LoginUserFromJson(Map<String, dynamic> json) => LoginUser(
      email: json['email'] as String,
      password: json['password'] as String,
    );

Map<String, dynamic> _$LoginUserToJson(LoginUser instance) => <String, dynamic>{
      'email': instance.email,
      'password': instance.password,
    };
