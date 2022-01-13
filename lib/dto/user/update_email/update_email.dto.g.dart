// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_email.dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateEmailDto _$UpdateEmailDtoFromJson(Map<String, dynamic> json) =>
    UpdateEmailDto(
      emailAddress: json['emailAddress'] as String,
      password: json['password'] as String,
    );

Map<String, dynamic> _$UpdateEmailDtoToJson(UpdateEmailDto instance) =>
    <String, dynamic>{
      'emailAddress': instance.emailAddress,
      'password': instance.password,
    };
