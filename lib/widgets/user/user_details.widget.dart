import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yasm_mobile/models/user/user.model.dart';
import 'package:yasm_mobile/services/user.service.dart';
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
  late User _user;
  late final UserService _userService;

  @override
  void initState() {
    super.initState();

    this._userService = Provider.of<UserService>(context, listen: false);
  }

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
          child: FutureBuilder(
            future: this._userService.getUser(widget.userId),
            builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
              if (snapshot.hasError) {
                print("ERROR: ${snapshot.error}");
                return CircularProgressIndicator();
              }

              if (snapshot.connectionState == ConnectionState.done) {
                this._user = snapshot.data!;
                return Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                      child: ProfilePicture(
                        imageUrl: snapshot.data!.imageUrl,
                        size: 140,
                      ),
                    ),
                    UserNameBiography(user: snapshot.data!),
                    FollowCount(user: snapshot.data!),
                  ],
                );
              }

              return CircularProgressIndicator();
            },
          )),
    );
  }
}
