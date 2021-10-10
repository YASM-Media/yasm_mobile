import 'package:flutter/material.dart';
import 'package:yasm_mobile/models/user/user.model.dart';
import 'package:yasm_mobile/pages/user/user_profile.page.dart';
import 'package:yasm_mobile/utils/show_bottom_sheet.util.dart' as SBS;
import 'package:yasm_mobile/widgets/common/profile_picture.widget.dart';

class FollowCount extends StatelessWidget {
  final User user;

  FollowCount({Key? key, required this.user}) : super(key: key);

  void _showUserList(BuildContext context, List<User> users) {
    SBS.showBottomSheet(
      context,
      ListView.builder(
        itemCount: users.length,
        itemBuilder: (BuildContext context, int index) {
          User userDup = users[index];
          return ListTile(
            leading: ProfilePicture(
              imageUrl: userDup.imageUrl,
              size: 50,
            ),
            title: Text("${userDup.firstName} ${userDup.lastName}"),
            subtitle: Text(userDup.biography),
            trailing: TextButton(
              onPressed: () {
                Navigator.of(context).pushNamed(
                  UserProfile.routeName,
                  arguments: userDup.id,
                );
              },
              child: Text('PROFILE'),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            this._showUserList(context, this.user.followers);
          },
          child: Column(
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
        ),
        GestureDetector(
          onTap: () {
            this._showUserList(context, this.user.following);
          },
          child: Column(
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
        ),
      ],
    );
  }
}
