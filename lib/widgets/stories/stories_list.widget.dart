import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yasm_mobile/arguments/story.argument.dart';
import 'package:yasm_mobile/constants/logger.constant.dart';
import 'package:yasm_mobile/models/user/user.model.dart';
import 'package:yasm_mobile/pages/stories/story.page.dart';
import 'package:yasm_mobile/providers/auth/auth.provider.dart';
import 'package:yasm_mobile/services/stories.service.dart';
import 'package:yasm_mobile/widgets/stories/logged_in_user_story.widget.dart';
import 'package:yasm_mobile/widgets/stories/story_item.widget.dart';

class StoriesList extends StatefulWidget {
  const StoriesList({Key? key}) : super(key: key);

  @override
  _StoriesListState createState() => _StoriesListState();
}

class _StoriesListState extends State<StoriesList> {
  List<User>? _stories;

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
        stories: this._stories!,
        index: index,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.1,
        child: IntrinsicHeight(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Consumer<AuthProvider>(
                builder: (BuildContext context, AuthProvider auth, _) =>
                    LoggedInUserStory(
                  user: auth.getUser()!,
                  size: MediaQuery.of(context).size.height * 0.09,
                ),
              ),
              VerticalDivider(
                thickness: MediaQuery.of(context).size.width * 0.008,
              ),
              FutureBuilder(
                future: this._storiesService.fetchAvailableStories(),
                builder:
                    (BuildContext context, AsyncSnapshot<List<User>> snapshot) {
                  if (snapshot.hasError) {
                    log.e(snapshot.error, snapshot.error, snapshot.stackTrace);

                    return Text(
                      "Something went wrong, please try again later.",
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.done) {
                    this._stories = snapshot.data!;

                    return _buildStoriesList();
                  }

                  return this._stories == null
                      ? Row(
                          children: [
                            CircularProgressIndicator(),
                          ],
                        )
                      : _buildStoriesList();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStoriesList() {
    return Flexible(
      fit: FlexFit.loose,
      child: ListView.builder(
        itemCount: this._stories!.length,
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemBuilder: (BuildContext context, int index) {
          User userStory = this._stories![index];

          return StoryItem(
            userStory: userStory,
            index: index,
            size: MediaQuery.of(context).size.height * 0.09,
            handleStoryPress: this._handleStoryPress,
          );
        },
      ),
    );
  }
}
