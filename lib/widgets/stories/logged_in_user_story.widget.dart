import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yasm_mobile/arguments/story.argument.dart';
import 'package:yasm_mobile/constants/logger.constant.dart';
import 'package:yasm_mobile/models/story/story.model.dart' as SM;
import 'package:yasm_mobile/models/user/user.model.dart';
import 'package:yasm_mobile/pages/stories/create_story.page.dart';
import 'package:yasm_mobile/pages/stories/story.page.dart';
import 'package:yasm_mobile/services/stories.service.dart';
import 'package:yasm_mobile/widgets/common/profile_picture.widget.dart';
import 'package:yasm_mobile/widgets/stories/story_item.widget.dart';

class LoggedInUserStory extends StatefulWidget {
  final User user;
  final double size;

  const LoggedInUserStory({
    Key? key,
    required this.user,
    required this.size,
  }) : super(key: key);

  @override
  _LoggedInUserStoryState createState() => _LoggedInUserStoryState();
}

class _LoggedInUserStoryState extends State<LoggedInUserStory> {
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
                  size: widget.size,
                  handleStoryPress: this._handleStoryPress,
                )
              : GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushNamed(CreateStory.routeName);
                  },
                  child: Stack(
                    children: [
                      Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * 0.01,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            widget.size,
                          ),
                          border: Border.all(
                            color: Colors.grey[900]!,
                            width: 4,
                          ),
                        ),
                        child: ProfilePicture(
                          imageUrl: widget.user.imageUrl,
                          size: widget.size,
                        ),
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: CircleAvatar(
                          radius: MediaQuery.of(context).size.width * 0.04,
                          backgroundColor: Colors.grey[900],
                          child: Icon(
                            Icons.add,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
        }

        return ProfilePicture(
          imageUrl: widget.user.imageUrl,
          size: widget.size,
        );
      },
    );
  }
}
