import 'package:flutter/material.dart';
import 'package:yasm_mobile/animations/data_not_found.animation.dart';
import 'package:yasm_mobile/models/user/user.model.dart';
import 'package:yasm_mobile/pages/user/user_profile.page.dart';
import 'package:yasm_mobile/widgets/common/profile_picture.widget.dart';

class UserList extends StatelessWidget {
  final List<User> users;

  UserList({Key? key, required this.users}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return this.users.length == 0
        ? DataNotFound(message: 'No users found')
        : ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
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
                    Navigator.of(context).pushReplacementNamed(
                      UserProfile.routeName,
                      arguments: userDup.id,
                    );
                  },
                  child: Text('PROFILE'),
                ),
              );
            },
          );
  }
}
