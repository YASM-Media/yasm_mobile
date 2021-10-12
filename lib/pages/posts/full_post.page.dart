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

  String _postId = '';

  @override
  void initState() {
    super.initState();

    this._postService = Provider.of<PostService>(context, listen: false);
    this._commentService = Provider.of<CommentService>(context, listen: false);
  }

  Future<void> _refreshPost() async {
    Post newPost = await this._postService.fetchPostById(_postId);

    setState(() {
      this._post = newPost;
    });
  }

  @override
  Widget build(BuildContext context) {
    this._postId = ModalRoute.of(context)!.settings.arguments as String;
    return Scaffold(
      appBar: AppBar(
        title: Text('Post'),
      ),
      body: FutureBuilder(
        future: this._postService.fetchPostById(this._postId),
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
                    refreshPosts: this._refreshPost,
                  ),
                  CommentForm(
                    postId: this._post.id,
                    refreshPost: this._refreshPost,
                  ),
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
