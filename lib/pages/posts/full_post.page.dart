import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yasm_mobile/models/post/post.model.dart';
import 'package:yasm_mobile/services/comment.service.dart';
import 'package:yasm_mobile/services/post.service.dart';
import 'package:yasm_mobile/widgets/comments/comment_form.widget.dart';
import 'package:yasm_mobile/widgets/comments/comment_list.widget.dart';
import 'package:yasm_mobile/widgets/posts/post_card.widget.dart';

class FullPost extends StatefulWidget {
  const FullPost({Key? key}) : super(key: key);

  static const routeName = "/full-post";

  @override
  _FullPostState createState() => _FullPostState();
}

class _FullPostState extends State<FullPost> {
  late Post _post;
  late final PostService _postService;
  late final CommentService _commentService;

  @override
  void initState() {
    super.initState();

    this._postService = Provider.of<PostService>(context, listen: false);
    this._commentService = Provider.of<CommentService>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    String postId = ModalRoute.of(context)!.settings.arguments as String;
    return Scaffold(
      appBar: AppBar(
        title: Text('Post'),
      ),
      body: FutureBuilder(
        future: this._postService.fetchPostById(postId),
        builder: (BuildContext context, AsyncSnapshot<Post> snapshot) {
          if (snapshot.hasError) {
            print(snapshot.error);
          }

          if (snapshot.connectionState == ConnectionState.done) {
            this._post = snapshot.data!;
            return SingleChildScrollView(
              child: Column(
                children: [
                  PostCard(
                    post: this._post,
                    refreshPosts: () {},
                  ),
                  CommentForm(),
                  CommentList(
                    comments: this._post.comments,
                  ),
                ],
              ),
            );
          }

          return CircularProgressIndicator();
        },
      ),
    );
  }
}
