import 'package:flutter/material.dart';
import 'package:yasm_mobile/models/post/post.model.dart';
import 'package:yasm_mobile/widgets/comments/comment.widget.dart';

class CommentList extends StatelessWidget {
  final List<Post> comments;

  CommentList({
    Key? key,
    required this.comments,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: this.comments.length,
      itemBuilder: (BuildContext context, int index) {
        Post comment = this.comments[index];

        return Comment(
          comment: comment,
        );
      },
    );
  }
}
