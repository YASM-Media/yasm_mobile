import 'package:flutter/material.dart';
import 'package:yasm_mobile/models/user/user.model.dart';
import 'package:yasm_mobile/widgets/common/profile_picture.widget.dart';

class StoryItem extends StatelessWidget {
  final User userStory;
  final int index;
  final double size;
  final Function handleStoryPress;

  const StoryItem({
    Key? key,
    required this.userStory,
    required this.index,
    required this.size,
    required this.handleStoryPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        this.handleStoryPress(this.index);
      },
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal:
          MediaQuery.of(context).size.width * 0.01,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            this.size,
          ),
          border: Border.all(
            color: Colors.pink,
            width: 4,
          ),
        ),
        child: ProfilePicture(
          imageUrl: userStory.imageUrl,
          size: this.size,
        ),
      ),
    );
  }
}
