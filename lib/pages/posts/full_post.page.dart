import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yasm_mobile/animations/loading.animation.dart';
import 'package:yasm_mobile/constants/logger.constant.dart';
import 'package:yasm_mobile/models/post/post.model.dart';
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
  Post? _post;
  late final PostService _postService;

  String _postId = '';

  @override
  void initState() {
    super.initState();

    this._postService = Provider.of<PostService>(context, listen: false);
  }

  void _refreshPost() async {
    setState(() {});
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
            log.e(snapshot.error, snapshot.error, snapshot.stackTrace);

            return Text("Something went wrong, please try again later.");
          }

          if (snapshot.connectionState == ConnectionState.done) {
            this._post = snapshot.data!;
            return _buildFullPostBody();
          }

          return this._post == null
              ? Loading(
                  message: 'Loading Post',
                )
              : _buildFullPostBody();
        },
      ),
    );
  }

  Widget _buildFullPostBody() {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {});
      },
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            PostCard(
              post: this._post!,
              refreshPosts: this._refreshPost,
            ),
            CommentForm(
              postId: this._post!.id,
              refreshPost: this._refreshPost,
            ),
            CommentList(
              comments: this._post!.comments,
              postId: this._post!.id,
              refreshPost: this._refreshPost,
            ),
          ],
        ),
      ),
    );
  }
}
