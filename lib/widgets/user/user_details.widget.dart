import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yasm_mobile/models/user/user.model.dart';
import 'package:yasm_mobile/providers/auth/auth.provider.dart';
import 'package:yasm_mobile/services/auth.service.dart';
import 'package:yasm_mobile/services/user.service.dart';
import 'package:yasm_mobile/widgets/common/profile_picture.widget.dart';
import 'package:yasm_mobile/widgets/user/follow_button.widget.dart';
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
  late final AuthService _authService;

  @override
  void initState() {
    super.initState();

    this._userService = Provider.of<UserService>(context, listen: false);
    this._authService = Provider.of<AuthService>(context, listen: false);
  }

  Future<void> _refreshUsers() async {
    User loggedInUser = await this._authService.getLoggedInUser();
    Provider.of<AuthProvider>(context, listen: false).saveUser(loggedInUser);

    User refreshedUser = await this._userService.getUser(widget.userId);

    setState(() {
      this._user = refreshedUser;
    });
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
        constraints: BoxConstraints(
          minWidth: MediaQuery.of(context).size.width,
          minHeight: 300,
        ),
        child: FutureBuilder(
          future: this._authService.getLoggedInUser(),
          builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
            if (snapshot.hasError) {
              print("ERROR: ${snapshot.error}");
              return CircularProgressIndicator();
            }

            if (snapshot.connectionState == ConnectionState.done) {
              this._user = snapshot.data!;
              return Consumer<AuthProvider>(
                builder: (
                  BuildContext context,
                  AuthProvider authProvider,
                  Widget? child,
                ) =>
                    Column(
                  children: [
                    child!,
                    if (this._user.id != authProvider.getUser()!.id)
                      FollowButton(
                        user: this._user,
                        refreshUsers: this._refreshUsers,
                      ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                      child: ProfilePicture(
                        imageUrl: snapshot.data!.imageUrl,
                        size: MediaQuery.of(context).size.height * 0.2,
                      ),
                    ),
                    UserNameBiography(user: this._user),
                    FollowCount(user: this._user),
                  ],
                ),
              );
            }

            return Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }
}
