import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:provider/provider.dart';
import 'package:yasm_mobile/constants/post_options.constant.dart';
import 'package:yasm_mobile/models/user/user.model.dart';
import 'package:yasm_mobile/providers/auth/auth.provider.dart';
import 'package:yasm_mobile/widgets/common/profile_picture.widget.dart';

class StoryUserDisplay extends StatelessWidget {
  final User user;
  final DateTime storyPosted;
  final DateTime _now = DateTime.now();
  final VoidCallback deleteStory;

  StoryUserDisplay({
    Key? key,
    required this.user,
    required this.storyPosted,
    required this.deleteStory,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Duration duration = _now.difference(storyPosted);

    return Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black,
              Colors.transparent,
            ],
          ),
        ),
        child: Consumer<AuthProvider>(
          builder: (BuildContext context, AuthProvider auth, Widget? child) {
            User user = auth.getUser()!;

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                child!,
                if (user.id == this.user.id)
                  OfflineBuilder(
                    connectivityBuilder: (
                      BuildContext context,
                      ConnectivityResult connectivity,
                      Widget _,
                    ) {
                      final bool connected =
                          connectivity != ConnectivityResult.none;
                      return PopupMenuButton(
                        enabled: connected,
                        child: Icon(Icons.more_vert),
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            child: Text("Delete Story"),
                            value: PostOptionsType.DELETE,
                          ),
                        ],
                        onSelected: (PostOptionsType selectedData) {
                          if (selectedData == PostOptionsType.DELETE) {
                            this.deleteStory();

                            Navigator.of(context).pop();
                          }
                        },
                      );
                    },
                    child: SizedBox(),
                  ),
              ],
            );
          },
          child: Row(
            children: [
              Container(
                margin: EdgeInsets.all(10.0),
                child: ProfilePicture(
                  imageUrl: this.user.imageUrl,
                  size: 30,
                ),
              ),
              Container(
                margin: EdgeInsets.all(10.0),
                child: Text(
                  "${this.user.firstName} ${this.user.lastName}",
                ),
              ),
              if (duration.inSeconds < 60)
                Text('${duration.inSeconds}s ago')
              else if (duration.inSeconds < 3600)
                Text('${duration.inMinutes}m ago')
              else
                Text('${duration.inHours}h ago')
            ],
          ),
        ));
  }
}
