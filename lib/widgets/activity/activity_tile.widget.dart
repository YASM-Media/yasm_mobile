import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:yasm_mobile/enum/activity_type.enum.dart';
import 'package:yasm_mobile/models/activity/activity.model.dart';
import 'package:yasm_mobile/pages/posts/full_post.page.dart';
import 'package:yasm_mobile/pages/user/user_profile.page.dart';
import 'package:yasm_mobile/widgets/common/profile_picture.widget.dart';

class ActivityTile extends StatelessWidget {
  final Activity activity;

  const ActivityTile({
    Key? key,
    required this.activity,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OfflineBuilder(
      connectivityBuilder: (
        BuildContext context,
        ConnectivityResult connectivity,
        Widget _,
      ) {
        final bool connected = connectivity != ConnectivityResult.none;

        return ListTile(
          leading: Icon(
            this._leadingIcon(),
            color: Colors.pink,
          ),
          title: this._textBody(),
          trailing: this._trailingWidget(context),
          onTap: connected ? () => _onTapActivity(context) : null,
        );
      },
      child: SizedBox(),
    );
  }

  void _onTapActivity(BuildContext context) {
    switch (this.activity.activityType) {
      case ActivityType.COMMENT:
        {
          Navigator.of(context).pushNamed(
            FullPost.routeName,
            arguments: this.activity.post!.id,
          );
          break;
        }
      case ActivityType.LIKE:
        {
          Navigator.of(context).pushNamed(
            FullPost.routeName,
            arguments: this.activity.post!.id,
          );
          break;
        }
      case ActivityType.FOLLOW:
        {
          Navigator.of(context).pushNamed(
            UserProfile.routeName,
            arguments: this.activity.triggeredByUser.id,
          );
          break;
        }
    }
  }

  IconData _leadingIcon() {
    switch (this.activity.activityType) {
      case ActivityType.COMMENT:
        {
          return Icons.comment;
        }
      case ActivityType.LIKE:
        {
          return Icons.favorite;
        }
      case ActivityType.FOLLOW:
        {
          return Icons.person_add;
        }
    }
  }

  Widget _textBody() {
    switch (this.activity.activityType) {
      case ActivityType.COMMENT:
        {
          return Text(
            "${this.activity.triggeredByUser.firstName} ${this.activity.triggeredByUser.lastName} commented on your post",
          );
        }
      case ActivityType.LIKE:
        {
          return Text(
            "${this.activity.triggeredByUser.firstName} ${this.activity.triggeredByUser.lastName} liked your post",
          );
        }
      case ActivityType.FOLLOW:
        {
          return Text(
            "${this.activity.triggeredByUser.firstName} ${this.activity.triggeredByUser.lastName} followed you",
          );
        }
    }
  }

  Widget _trailingWidget(BuildContext context) {
    switch (this.activity.activityType) {
      case ActivityType.COMMENT:
        {
          return ProfilePicture(
            imageUrl: this.activity.post!.images[0].imageUrl,
            size: MediaQuery.of(context).size.longestSide * 0.07,
          );
        }
      case ActivityType.LIKE:
        {
          return ProfilePicture(
            imageUrl: this.activity.post!.images[0].imageUrl,
            size: MediaQuery.of(context).size.longestSide * 0.07,
          );
        }
      case ActivityType.FOLLOW:
        {
          return ProfilePicture(
            imageUrl: this.activity.triggeredByUser.imageUrl,
            size: MediaQuery.of(context).size.longestSide * 0.07,
          );
        }
    }
  }
}
