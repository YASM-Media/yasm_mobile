import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:provider/provider.dart';
import 'package:yasm_mobile/arguments/chat.argument.dart';
import 'package:yasm_mobile/constants/logger.constant.dart';
import 'package:yasm_mobile/dto/chat/create_thread/create_thread.dto.dart';
import 'package:yasm_mobile/exceptions/auth/not_logged_in.exception.dart';
import 'package:yasm_mobile/exceptions/common/server.exception.dart';
import 'package:yasm_mobile/models/chat/chat_thread/chat_thread.model.dart';
import 'package:yasm_mobile/models/user/user.model.dart';
import 'package:yasm_mobile/pages/chat/chat.page.dart';
import 'package:yasm_mobile/providers/auth/auth.provider.dart';
import 'package:yasm_mobile/services/chat.service.dart';
import 'package:yasm_mobile/services/follow.service.dart';
import 'package:yasm_mobile/utils/display_snackbar.util.dart';

class FollowChatButton extends StatefulWidget {
  final User user;
  final Function refreshUsers;

  FollowChatButton({
    Key? key,
    required this.user,
    required this.refreshUsers,
  }) : super(key: key);

  @override
  _FollowChatButtonState createState() => _FollowChatButtonState();
}

class _FollowChatButtonState extends State<FollowChatButton> {
  late final FollowService _followService;
  late final ChatService _chatService;
  late bool isFollowing;

  @override
  void initState() {
    super.initState();

    this._followService = Provider.of<FollowService>(context, listen: false);
    this._chatService = Provider.of<ChatService>(
      context,
      listen: false,
    );
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
          User loggedInUser = authProvider.getUser()!;

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: connected
                    ? () async =>
                        await _handleFollowUnFollow(authProvider, context)
                    : null,
                child: connected
                    ? Text(
                        _checkFollowing(authProvider) ? 'UNFOLLOW' : 'FOLLOW',
                      )
                    : Text('YOU ARE OFFLINE'),
              ),
              TextButton(
                onPressed: connected
                    ? () async => await this._startChatSession(loggedInUser)
                    : null,
                child: connected
                    ? Text(
                        'MESSAGE',
                      )
                    : Text('YOU ARE OFFLINE'),
              ),
            ],
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

  Future<void> _startChatSession(User loggedInUser) async {
    CreateThreadDto createThreadDto = new CreateThreadDto(
      participants: [loggedInUser.id, this.widget.user.id],
    );

    String chatThreadId =
        await this._chatService.createChatThread(createThreadDto);
    ChatThread chatThread =
        await this._chatService.fetchThreadData(chatThreadId);

    Navigator.of(context).pushNamed(
      Chat.routeName,
      arguments: new ChatArgument(
        chatThread: chatThread,
        user: this.widget.user,
      ),
    );
  }
}
