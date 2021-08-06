import 'package:flutter/material.dart';
import 'package:yasm_mobile/models/user/user.model.dart';

class FollowCount extends StatelessWidget {
  final User user;
  FollowCount({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          children: [
            Text(
              "${user.followers.length}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text("Followers"),
          ],
        ),
        Column(
          children: [
            Text(
              "${user.following.length}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text("Following"),
          ],
        ),
      ],
    );
  }
}
