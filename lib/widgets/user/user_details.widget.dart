import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yasm_mobile/models/user/user.model.dart';
import 'package:yasm_mobile/providers/auth/auth.provider.dart';
import 'package:yasm_mobile/widgets/common/profile_picture.widget.dart';
import 'package:yasm_mobile/widgets/user/follow_count.widget.dart';
import 'package:yasm_mobile/widgets/user/user_name_biography.widget.dart';

class UserDetails extends StatefulWidget {
  final String userId;

  UserDetails({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  _UserDetailsState createState() => _UserDetailsState();
}

class _UserDetailsState extends State<UserDetails> {
  late final User user;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        padding: EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            10.0,
          ),
          border: Border.all(
            color: Colors.white24,
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(0, 0, 0, 20),
              child: ProfilePicture(
                imageUrl: user.imageUrl,
                size: 140,
              ),
            ),
            UserNameBiography(user: user),
            FollowCount(user: user),
          ],
        ),
      ),
    );
  }
}
