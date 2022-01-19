import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yasm_mobile/arguments/story.argument.dart';
import 'package:yasm_mobile/constants/logger.constant.dart';
import 'package:yasm_mobile/dto/story/delete_story/delete_story.dto.dart';
import 'package:yasm_mobile/models/user/user.model.dart';
import 'package:yasm_mobile/services/stories.service.dart';
import 'package:yasm_mobile/widgets/stories/story_user_display.widget.dart';

class Story extends StatefulWidget {
  const Story({Key? key}) : super(key: key);

  static const routeName = "/story";

  @override
  _StoryState createState() => _StoryState();
}

class _StoryState extends State<Story> {
  List<User>? stories;
  int? index;

  int storyIndex = 0;

  Timer? _timer;

  late final StoriesService _storiesService;

  @override
  void initState() {
    super.initState();

    this._storiesService = Provider.of<StoriesService>(
      context,
      listen: false,
    );
  }

  Future<void> _deleteStory(String storyId) async {
    await this._storiesService.deleteStory(
          new DeleteStoryDto(
            storyId: storyId,
          ),
        );
  }

  void _startTimer() {
    this._timer = Timer(new Duration(seconds: 5), () {
      if ((this.storyIndex + 1) == this.stories![this.index!].stories.length) {
        this._timer!.cancel();

        if ((this.index! + 1) == this.stories!.length) {
          Navigator.of(context).pop();
        } else {
          Navigator.of(context).pushReplacementNamed(
            Story.routeName,
            arguments: StoryArgument(
              stories: this.stories!,
              index: this.index! + 1,
            ),
          );
        }
      } else {
        setState(() {
          storyIndex += 1;
        });
      }
    });
  }

  void _goForward() {
    this._timer!.cancel();
    log.i("Timer Cancelled for Forward");

    if ((this.storyIndex + 1) == this.stories![this.index!].stories.length) {
      if ((this.index! + 1) == this.stories!.length) {
        Navigator.of(context).pop();
      } else {
        Navigator.of(context).pushReplacementNamed(
          Story.routeName,
          arguments: StoryArgument(
            stories: this.stories!,
            index: this.index! + 1,
          ),
        );
      }
    } else {
      setState(() {
        storyIndex += 1;
      });
    }
  }

  void _goBack() {
    this._timer!.cancel();
    log.i("Timer Cancelled for Backward");

    if (this.storyIndex == 0) {
      if (this.index == 0) {
        return;
      } else {
        Navigator.of(context).pushReplacementNamed(
          Story.routeName,
          arguments: StoryArgument(
            stories: this.stories!,
            index: this.index! - 1,
          ),
        );
      }
    } else {
      setState(() {
        storyIndex -= 1;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();

    this._timer!.cancel();
  }

  @override
  Widget build(BuildContext context) {
    if (this.stories == null && this.index == null) {
      StoryArgument argument =
          ModalRoute.of(context)!.settings.arguments as StoryArgument;

      this.stories = argument.stories;
      this.index = argument.index;

      if (this.stories!.length == 0) {
        Navigator.of(context).pop();
      }
    }

    return Scaffold(
      body: GestureDetector(
        onTapUp: (TapUpDetails details) {
          double halfPoint = MediaQuery.of(context).size.width * 0.5;
          double tapArea = details.globalPosition.dx;

          if (halfPoint > tapArea) {
            this._goBack();
          } else {
            this._goForward();
          }
        },
        child: SafeArea(
          child: this.stories != null && this.index != null
              ? Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: Stack(
                    children: [
                      CachedNetworkImage(
                        fit: BoxFit.fitHeight,
                        imageUrl: this
                            .stories![this.index!]
                            .stories[this.storyIndex]
                            .storyUrl,
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        imageBuilder:
                            (BuildContext context, ImageProvider image) {
                          if (!(this._timer != null && this._timer!.isActive)) {
                            log.i("Timer Started");
                            this._startTimer();
                          }
                          return Image(
                            height: MediaQuery.of(context).size.height,
                            width: MediaQuery.of(context).size.width,
                            fit: BoxFit.fitHeight,
                            image: image,
                          );
                        },
                        progressIndicatorBuilder:
                            (context, url, downloadProgress) => Center(
                          child: CircularProgressIndicator(
                            value: downloadProgress.progress,
                          ),
                        ),
                      ),
                      StoryUserDisplay(
                        user: this.stories![this.index!],
                        storyPosted: this
                            .stories![this.index!]
                            .stories[this.storyIndex]
                            .createdAt,
                        deleteStory: () {
                          this._deleteStory(
                            this
                                .stories![this.index!]
                                .stories[this.storyIndex]
                                .id,
                          );
                        },
                      ),
                    ],
                  ),
                )
              : CircularProgressIndicator(),
        ),
      ),
    );
  }
}
