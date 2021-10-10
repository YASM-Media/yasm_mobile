import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yasm_mobile/models/user/user.model.dart';
import 'package:yasm_mobile/providers/auth/auth.provider.dart';
import 'package:yasm_mobile/services/follow.service.dart';
import 'package:yasm_mobile/utils/display_snackbar.util.dart';

class FollowButton extends StatefulWidget {
  final User user;
  final Function refreshUsers;

  FollowButton({
    Key? key,
    required this.user,
    required this.refreshUsers,
  }) : super(key: key);

  @override
  _FollowButtonState createState() => _FollowButtonState();
}

class _FollowButtonState extends State<FollowButton> {
  late final FollowService _followService;
  late bool isFollowing;

  @override
  void initState() {
    super.initState();

    this._followService = Provider.of<FollowService>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (BuildContext context, AuthProvider authProvider, _) =>
          TextButton(
        onPressed: () async {
          if (_checkFollowing(authProvider)) {
            await this._followService.unfollowUser(widget.user.id);
            displaySnackBar("Unfollowed Successfully!", context);
          } else {
            await this._followService.followUser(widget.user.id);
            displaySnackBar("Followed Successfully!", context);
          }

          await widget.refreshUsers();
        },
        child: Text(
          _checkFollowing(authProvider) ? 'UNFOLLOW' : 'FOLLOW',
        ),
      ),
    );
  }

  bool _checkFollowing(AuthProvider authProvider) {
    return widget.user.followers
            .where((element) => element.id == authProvider.getUser()!.id)
            .length >
        0;
  }
}
