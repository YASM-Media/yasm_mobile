import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeleton_loader/skeleton_loader.dart';
import 'package:yasm_mobile/constants/logger.constant.dart';
import 'package:yasm_mobile/dto/chat/chat_arguments/chat_arguments.dto.dart';
import 'package:yasm_mobile/models/chat/chat_thread/chat_thread.model.dart';
import 'package:yasm_mobile/models/user/user.model.dart';
import 'package:yasm_mobile/pages/chat/chat.page.dart';
import 'package:yasm_mobile/providers/auth/auth.provider.dart';
import 'package:yasm_mobile/services/user.service.dart';
import 'package:yasm_mobile/widgets/common/profile_picture.widget.dart';

class Thread extends StatefulWidget {
  final ChatThread chatThread;

  const Thread({
    Key? key,
    required this.chatThread,
  }) : super(key: key);

  @override
  _ThreadState createState() => _ThreadState();
}

class _ThreadState extends State<Thread> {
  late final UserService _userService;
  User? _user;

  @override
  void initState() {
    super.initState();

    this._userService = Provider.of<UserService>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (
        BuildContext context,
        AuthProvider authProvider,
        Widget? child,
      ) {
        String userId = this
            .widget
            .chatThread
            .participants
            .firstWhere((id) => id != authProvider.getUser()!.id);

        return FutureBuilder(
          future: this._userService.getUser(userId),
          builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
            if (snapshot.hasError) {
              log.e(snapshot.error, snapshot.error, snapshot.stackTrace);

              return Text("Something went wrong, please try again later.");
            }

            if (snapshot.connectionState == ConnectionState.done) {
              this._user = snapshot.data!;

              return _buildThreadTile();
            }

            return this._user == null
                ? _buildThreadLoader()
                : _buildThreadTile();
          },
        );
      },
    );
  }

  Widget _buildThreadTile() {
    return ListTile(
      leading: ProfilePicture(
        imageUrl: this._user!.imageUrl,
        size: MediaQuery.of(context).size.width * 0.16,
      ),
      title: Text('${this._user!.firstName} ${this._user!.lastName}'),
      subtitle: Text(
        this.widget.chatThread.messages.length > 0
            ? this.widget.chatThread.messages.last.message
            : '',
      ),
      onTap: () {
        Navigator.of(context).pushNamed(
          Chat.routeName,
          arguments: new ChatArguments(
            chatThread: this.widget.chatThread,
            user: this._user!,
          ),
        );
      },
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
