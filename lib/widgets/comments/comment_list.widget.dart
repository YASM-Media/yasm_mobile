import 'package:flutter/material.dart';
import 'package:yasm_mobile/models/post/post.model.dart';
import 'package:yasm_mobile/widgets/comments/comment.widget.dart';

class CommentList extends StatelessWidget {
  final List<Post> comments;
  final Function refreshPost;
  final String postId;

  CommentList({
    Key? key,
    required this.comments,
    required this.refreshPost,
    required this.postId,
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
          postId: this.postId,
          refreshPost: this.refreshPost,
        );
      },
    );
  }
}
