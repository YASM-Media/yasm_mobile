import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

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

  @HiveField(3)
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

  @override
  String toString() {
    return 'User{id: $id, firstName: $firstName, lastName: $lastName, emailAddress: $emailAddress, biography: $biography, imageUrl: $imageUrl, followers: $followers, following: $following}';
  }
}
