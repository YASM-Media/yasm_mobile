import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeleton_loader/skeleton_loader.dart';
import 'package:yasm_mobile/arguments/chat.argument.dart';
import 'package:yasm_mobile/constants/logger.constant.dart';
import 'package:yasm_mobile/dto/chat/create_thread/create_thread.dto.dart';
import 'package:yasm_mobile/models/chat/chat_thread/chat_thread.model.dart';
import 'package:yasm_mobile/models/user/user.model.dart';
import 'package:yasm_mobile/pages/chat/chat.page.dart';
import 'package:yasm_mobile/providers/auth/auth.provider.dart';
import 'package:yasm_mobile/services/chat.service.dart';
import 'package:yasm_mobile/services/user.service.dart';
import 'package:yasm_mobile/widgets/common/profile_picture.widget.dart';

class UserThread extends StatefulWidget {
  final String userId;

  const UserThread({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  _UserThreadState createState() => _UserThreadState();
}

class _UserThreadState extends State<UserThread> {
  late final UserService _userService;
  late final ChatService _chatService;
  User? _user;

  @override
  void initState() {
    super.initState();

    this._userService = Provider.of<UserService>(context, listen: false);
    this._chatService = Provider.of<ChatService>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (
        BuildContext context,
        AuthProvider authProvider,
        Widget? child,
      ) {
        String loggedInUserId = authProvider.getUser()!.id;

        return FutureBuilder(
          future: this._userService.getUser(
                this.widget.userId,
              ),
          builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
            if (snapshot.hasError) {
              log.e(snapshot.error, snapshot.error, snapshot.stackTrace);

              return Text("Something went wrong, please try again later.");
            }

            if (snapshot.connectionState == ConnectionState.done) {
              this._user = snapshot.data!;

              return _buildThreadTile(loggedInUserId);
            }

            return this._user == null
                ? _buildThreadLoader()
                : _buildThreadTile(loggedInUserId);
          },
        );
      },
    );
  }

  Widget _buildThreadTile(String loggedInUserId) {
    return ListTile(
      leading: ProfilePicture(
        imageUrl: this._user!.imageUrl,
        size: MediaQuery.of(context).size.width * 0.16,
      ),
      title: Text(
        '${this._user!.firstName} ${this._user!.lastName}',
        style: TextStyle(
          fontWeight: FontWeight.normal,
        ),
      ),
      subtitle: Text(''),
    );
  }

  Widget _buildThreadLoader() {
    return SkeletonLoader(
      builder: Container(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Row(
          children: <Widget>[
            CircleAvatar(
              backgroundColor: Colors.white,
              radius: MediaQuery.of(context).size.width * 0.08,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.02,
            ),
            Expanded(
              child: Column(
                children: <Widget>[
                  Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * 0.02,
                    color: Colors.white,
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                  Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * 0.02,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      items: 1,
      period: Duration(
        seconds: 2,
      ),
      highlightColor: Colors.grey,
      direction: SkeletonDirection.ltr,
    );
  }
}
