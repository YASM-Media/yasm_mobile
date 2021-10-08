import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yasm_mobile/constants/post_fetch_type.constant.dart';
import 'package:yasm_mobile/constants/post_list_type.constant.dart';
import 'package:yasm_mobile/models/post/post.model.dart';
import 'package:yasm_mobile/services/post.service.dart';
import 'package:yasm_mobile/widgets/posts/post_card.widget.dart';

class PostList extends StatefulWidget {
  final PostFetchType postFetchType;
  final PostListType postListType;
  final String userId;

  PostList({
    Key? key,
    this.postFetchType = PostFetchType.BEST,
    this.postListType = PostListType.NORMAL,
    this.userId = '',
  }) : super(key: key);

  @override
  _PostListState createState() => _PostListState();
}

class _PostListState extends State<PostList> {
  late final PostService _postService;
  late List<Post> posts;

  @override
  void initState() {
    super.initState();

    this._postService = Provider.of<PostService>(context, listen: false);
  }

  Future<void> refreshPosts() async {
    List<Post> postsArray = await (widget.postListType == PostListType.NORMAL
        ? this._postService.fetchPostsByCategory(widget.postFetchType)
        : this._postService.fetchPostsByUser(widget.userId));

    setState(() {
      this.posts = postsArray;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: widget.postListType == PostListType.NORMAL
          ? this._postService.fetchPostsByCategory(widget.postFetchType)
          : this._postService.fetchPostsByUser(widget.userId),
      builder: (BuildContext context, AsyncSnapshot<List<Post>> snapshot) {
        if (snapshot.hasError) {
          print("ERROR: ${snapshot.error}");
        }

        if (snapshot.connectionState == ConnectionState.done) {
          this.posts = snapshot.data!;

          return ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: this.posts.length,
            itemBuilder: (BuildContext context, int index) {
              Post post = this.posts[index];
              return PostCard(post: post, refreshPosts: this.refreshPosts,);
            },
          );
        }

        return CircularProgressIndicator();
      },
    );
  }
}
