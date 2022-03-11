import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:yasm_mobile/models/story/story.model.dart';

part 'user.model.g.dart';

@JsonSerializable()
@HiveType(typeId: 1)
class User {
  @HiveField(0)
  String id;

  @HiveField(1)
  String firstName;

  @HiveField(2)
  String lastName;

  @HiveField(3, defaultValue: '')
  @JsonKey(defaultValue: '')
  String emailAddress;

  @JsonKey(defaultValue: '')
  @HiveField(4)
  String biography;

  @JsonKey(defaultValue: '')
  @HiveField(5)
  String imageUrl;

  @JsonKey(defaultValue: [])
  @HiveField(6)
  List<User> followers;

  @JsonKey(defaultValue: [])
  @HiveField(7)
  List<User> following;

  @JsonKey(defaultValue: [])
  @HiveField(8, defaultValue: [])
  List<Story> stories;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.emailAddress,
    required this.biography,
    required this.imageUrl,
    required this.followers,
    required this.following,
    required this.stories,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}
