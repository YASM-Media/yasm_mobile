import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:provider/provider.dart';
import 'package:yasm_mobile/constants/logger.constant.dart';
import 'package:yasm_mobile/exceptions/auth/not_logged_in.exception.dart';
import 'package:yasm_mobile/exceptions/common/server.exception.dart';
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
          OfflineBuilder(
        connectivityBuilder: (
          BuildContext context,
          ConnectivityResult connectivity,
          Widget _,
        ) {
          final bool connected = connectivity != ConnectivityResult.none;

          return TextButton(
            onPressed: connected
                ? () async => await _handleFollowUnFollow(authProvider, context)
                : null,
            child: connected
                ? Text(
                    _checkFollowing(authProvider) ? 'UNFOLLOW' : 'FOLLOW',
                  )
                : Text('YOU ARE OFFLINE'),
          );
        },
        child: SizedBox(),
      ),
    );
  }

  Future<void> _handleFollowUnFollow(
      AuthProvider authProvider, BuildContext context) async {
    try {
      if (_checkFollowing(authProvider)) {
        await this._followService.unfollowUser(widget.user.id);
        displaySnackBar("Unfollowed Successfully!", context);
      } else {
        await this._followService.followUser(widget.user.id);
        displaySnackBar("Followed Successfully!", context);
      }

      await widget.refreshUsers();
    } on ServerException catch (error) {
      displaySnackBar(
        error.message,
        context,
      );
    } on NotLoggedInException catch (error) {
      displaySnackBar(
        error.message,
        context,
      );
    } catch (error, stackTrace) {
      log.e(error, error, stackTrace);

      displaySnackBar(
        "Something went wrong, please try again later.",
        context,
      );
    }
  }

  bool _checkFollowing(AuthProvider authProvider) {
    return widget.user.followers
            .where((element) => element.id == authProvider.getUser()!.id)
            .length >
        0;
  }
}
