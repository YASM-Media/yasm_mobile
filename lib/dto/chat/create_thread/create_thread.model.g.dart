// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_thread.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateThread _$CreateThreadFromJson(Map<String, dynamic> json) => CreateThread(
      participants: (json['participants'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );

Map<String, dynamic> _$CreateThreadToJson(CreateThread instance) =>
    <String, dynamic>{
      'participants': instance.participants,
    };
