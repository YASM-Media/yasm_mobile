import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yasm_mobile/constants/post_list_type.constant.dart';
import 'package:yasm_mobile/providers/auth/auth.provider.dart';
import 'package:yasm_mobile/widgets/posts/post_list.widget.dart';
import 'package:yasm_mobile/widgets/user/user_details.widget.dart';

class UserProfile extends StatelessWidget {
  const UserProfile({Key? key}) : super(key: key);

  static const routeName = "/user-profile";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              UserDetails(),
              Consumer<AuthProvider>(
                builder: (context, auth, _) => PostList(
                  postListType: PostListType.USER,
                  userId: auth.getUser()!.id,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
