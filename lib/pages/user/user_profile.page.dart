import 'package:flutter/material.dart';
import 'package:yasm_mobile/widgets/user/user_details.widget.dart';

class UserProfile extends StatelessWidget {
  const UserProfile({Key? key}) : super(key: key);

  static const routeName = "/user-profile";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            UserDetails(),
          ],
        ),
      ),
    );
  }
}
