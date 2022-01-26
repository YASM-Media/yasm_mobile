import 'package:json_annotation/json_annotation.dart';

part 'create_thread.dto.g.dart';

@JsonSerializable()
class CreateThreadDto {
  @JsonKey(defaultValue: [])
  final List<String> participants;

  CreateThreadDto({
    required this.participants,
  });

  factory CreateThreadDto.fromJson(Map<String, dynamic> json) =>
      _$CreateThreadDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CreateThreadDtoToJson(this);
}
