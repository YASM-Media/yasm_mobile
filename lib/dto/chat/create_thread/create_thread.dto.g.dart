// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_thread.dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateThreadDto _$CreateThreadDtoFromJson(Map<String, dynamic> json) =>
    CreateThreadDto(
      participants: (json['participants'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );

Map<String, dynamic> _$CreateThreadDtoToJson(CreateThreadDto instance) =>
    <String, dynamic>{
      'participants': instance.participants,
    };
