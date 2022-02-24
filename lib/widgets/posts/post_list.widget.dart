import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yasm_mobile/animations/loading_list.animation.dart';
import 'package:yasm_mobile/animations/data_not_found.animation.dart';
import 'package:yasm_mobile/animations/search.animation.dart';
import 'package:yasm_mobile/constants/logger.constant.dart';
import 'package:yasm_mobile/constants/post_fetch_type.constant.dart';
import 'package:yasm_mobile/constants/post_list_type.constant.dart';
import 'package:yasm_mobile/models/post/post.model.dart';
import 'package:yasm_mobile/services/post.service.dart';
import 'package:yasm_mobile/services/search.service.dart';
import 'package:yasm_mobile/widgets/posts/post_card.widget.dart';

class PostList extends StatefulWidget {
  final PostFetchType postFetchType;
  final PostListType postListType;
  final String userId;
  final String searchQuery;

  PostList({
    Key? key,
    this.postFetchType = PostFetchType.BEST,
    this.postListType = PostListType.NORMAL,
    this.userId = '',
    this.searchQuery = '',
  }) : super(key: key);

  @override
  _PostListState createState() => _PostListState();
}

class _PostListState extends State<PostList> {
  late final PostService _postService;
  late final SearchService _searchService;
  List<Post>? posts;

  @override
  void initState() {
    super.initState();

    this._postService = Provider.of<PostService>(context, listen: false);
    this._searchService = Provider.of<SearchService>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: widget.postListType == PostListType.NORMAL
          ? this._postService.fetchPostsByCategory(widget.postFetchType)
          : widget.postListType == PostListType.USER
              ? this._postService.fetchPostsByUser(widget.userId)
              : this._searchService.searchForPosts(widget.searchQuery),
      builder: (BuildContext context, AsyncSnapshot<List<Post>> snapshot) {
        if (snapshot.hasError) {
          log.e(snapshot.error, snapshot.error, snapshot.stackTrace);

          return Text("Something went wrong, please try again later.");
        }

        if (snapshot.connectionState == ConnectionState.done) {
          this.posts = snapshot.data!;

          return _buildPostList();
        }

        return this.posts == null
            ? this.widget.postListType == PostListType.SEARCH
                ? Search(message: 'Searching for posts')
                : LoadingList(
                    message: 'Loading Posts',
                  )
            : _buildPostList();
      },
    );
  }

  Widget _buildPostList() {
    return this.posts!.length == 0
        ? DataNotFound(
            message: 'No Posts Found',
          )
        : ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: this.posts!.length,
            itemBuilder: (BuildContext context, int index) {
              Post post = this.posts![index];
              return PostCard(
                post: post,
                refreshPosts: () {
                  setState(() {});
                },
              );
            },
          );
  }
}
