import 'package:json_annotation/json_annotation.dart';

part 'create_thread.model.g.dart';

@JsonSerializable()
class CreateThread {
  @JsonKey(defaultValue: [])
  final List<String> participants;

  CreateThread({
    required this.participants,
  });

  factory CreateThread.fromJson(Map<String, dynamic> json) =>
      _$CreateThreadFromJson(json);

  Map<String, dynamic> toJson() => _$CreateThreadToJson(this);
}
