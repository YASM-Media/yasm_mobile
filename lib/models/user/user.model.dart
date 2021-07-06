import 'package:json_annotation/json_annotation.dart';

part 'user.model.g.dart';

@JsonSerializable()
class User {
  String id;
  String firstName;
  String lastName;
  String emailAddress;

  @JsonKey(defaultValue: '')
  String biography;

  @JsonKey(defaultValue: '')
  String imageUrl;

  @JsonKey(defaultValue: [])
  List<User> followers;

  @JsonKey(defaultValue: [])
  List<User> following;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.emailAddress,
    required this.biography,
    required this.imageUrl,
    required this.followers,
    required this.following,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}
