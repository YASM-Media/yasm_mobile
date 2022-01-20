import 'package:flutter/material.dart';
import 'package:yasm_mobile/constants/post_list_type.constant.dart';
import 'package:yasm_mobile/widgets/posts/post_list.widget.dart';
import 'package:yasm_mobile/widgets/user/user_details.widget.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({Key? key}) : super(key: key);

  static const routeName = "/user-profile";

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  @override
  Widget build(BuildContext context) {
    String userId = ModalRoute.of(context)!.settings.arguments as String;
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            setState(() {});
          },
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                UserDetails(
                  userId: userId,
                ),
                PostList(
                  postListType: PostListType.USER,
                  userId: userId,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
