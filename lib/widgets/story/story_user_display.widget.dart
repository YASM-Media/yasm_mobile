import 'package:flutter/material.dart';
import 'package:yasm_mobile/models/user/user.model.dart';
import 'package:yasm_mobile/widgets/common/profile_picture.widget.dart';

class StoryUserDisplay extends StatelessWidget {
  final User user;
  final DateTime storyPosted;
  final DateTime _now = DateTime.now();

  StoryUserDisplay({
    Key? key,
    required this.user,
    required this.storyPosted,
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
    );
  }
}
