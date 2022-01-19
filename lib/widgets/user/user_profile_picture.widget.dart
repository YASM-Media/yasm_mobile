import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yasm_mobile/arguments/story.argument.dart';
import 'package:yasm_mobile/constants/logger.constant.dart';
import 'package:yasm_mobile/models/story/story.model.dart' as SM;
import 'package:yasm_mobile/models/user/user.model.dart';
import 'package:yasm_mobile/pages/stories/story.page.dart';
import 'package:yasm_mobile/services/stories.service.dart';
import 'package:yasm_mobile/widgets/common/profile_picture.widget.dart';
import 'package:yasm_mobile/widgets/stories/story_item.widget.dart';

class UserProfilePicture extends StatefulWidget {
  final User user;

  const UserProfilePicture({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  _UserProfilePictureState createState() => _UserProfilePictureState();
}

class _UserProfilePictureState extends State<UserProfilePicture> {
  late final StoriesService _storiesService;

  @override
  void initState() {
    super.initState();

    this._storiesService = Provider.of<StoriesService>(context, listen: false);
  }

  void _handleStoryPress(int index) {
    Navigator.of(context).pushNamed(
      Story.routeName,
      arguments: StoryArgument(
        stories: [widget.user],
        index: index,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: this._storiesService.fetchStoriesByUser(widget.user.id),
      builder: (BuildContext context, AsyncSnapshot<List<SM.Story>> snapshot) {
        if (snapshot.hasError) {
          log.e(snapshot.error, snapshot.error, snapshot.stackTrace);
          return Text("Something went wrong, please try again later.");
        }

        if (snapshot.connectionState == ConnectionState.done) {
          List<SM.Story> stories = snapshot.data!;

          stories.forEach((element) {
            widget.user.stories.add(element);
          });

          return stories.length > 0
              ? StoryItem(
                  userStory: widget.user,
                  index: 0,
                  size: MediaQuery.of(context).size.height * 0.2,
                  handleStoryPress: this._handleStoryPress,
                )
              : ProfilePicture(
                  imageUrl: widget.user.imageUrl,
                  size: MediaQuery.of(context).size.height * 0.2,
                );
        }

        return ProfilePicture(
          imageUrl: widget.user.imageUrl,
          size: MediaQuery.of(context).size.height * 0.2,
        );
      },
    );
  }
}
