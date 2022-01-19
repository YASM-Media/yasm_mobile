import 'package:flutter/material.dart';
import 'package:yasm_mobile/constants/post_fetch_type.constant.dart';
import 'package:yasm_mobile/widgets/posts/post_list.widget.dart';
import 'package:yasm_mobile/widgets/stories/stories_list.widget.dart';

class Posts extends StatefulWidget {
  const Posts({Key? key}) : super(key: key);

  static const routeName = "/posts";

  @override
  _PostsState createState() => _PostsState();
}

class _PostsState extends State<Posts> {
  PostFetchType _postFetchType = PostFetchType.BEST;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Posts'),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              fit: FlexFit.loose,
              child: StoriesList(),
            ),
            _buildSorter(),
            PostList(
              postFetchType: this._postFetchType,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSorter() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20.0,
        vertical: 10.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Sort By'),
          PopupMenuButton(
            child: Text(
              this._postFetchType.toString().split(".")[1],
              style: TextStyle(
                color: Colors.pink,
              ),
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: Text("Best of the last 24h"),
                value: PostFetchType.BEST,
              ),
              PopupMenuItem(
                child: Text("New Posts"),
                value: PostFetchType.NEW,
              ),
            ],
            onSelected: (PostFetchType selectedData) {
              setState(() {
                this._postFetchType = selectedData;
              });
            },
          ),
        ],
      ),
    );
  }
}
