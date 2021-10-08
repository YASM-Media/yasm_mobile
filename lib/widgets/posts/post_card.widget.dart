import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yasm_mobile/constants/post_options.constant.dart';
import 'package:yasm_mobile/models/post/post.model.dart';
import 'package:yasm_mobile/pages/posts/update_post.page.dart';
import 'package:yasm_mobile/providers/auth/auth.provider.dart';
import 'package:yasm_mobile/services/post.service.dart';
import 'package:yasm_mobile/utils/display_snackbar.util.dart';
import 'package:yasm_mobile/widgets/common/profile_picture.widget.dart';
import 'package:yasm_mobile/utils/show_bottom_sheet.util.dart' as SBS;

class PostCard extends StatefulWidget {
  final Post post;
  final Function refreshPosts;

  PostCard({Key? key, required this.post, required this.refreshPosts})
      : super(key: key);

  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  late final PostService _postService;

  @override
  void initState() {
    super.initState();

    this._postService = Provider.of(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTopRow(),
          _buildImageScroller(context),
          _buildActions(),
          _buildBottomRow()
        ],
      ),
    );
  }

  void _onDeletePost(BuildContext context) {
    SBS.showBottomSheet(
      context,
      Wrap(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text('Are you sure you want to delete this post?'),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () async {
                  await this._postService.deletePost(widget.post.id);

                  Navigator.of(context).pop();

                  displaySnackBar("Post Deleted!", context);

                  await widget.refreshPosts();
                },
                child: Text('YES'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('NO'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Padding _buildBottomRow() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Liked by ${this.widget.post.likes.length} others",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(this.widget.post.text),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        Consumer<AuthProvider>(
          builder: (context, auth, _) => IconButton(
            onPressed: () {},
            icon: Icon(
              _checkIfLiked(auth) ? Icons.favorite_border : Icons.favorite,
              color: Colors.pink,
            ),
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: Icon(
            Icons.textsms_outlined,
            color: Colors.pink,
          ),
        ),
      ],
    );
  }

  bool _checkIfLiked(AuthProvider auth) {
    return this
            .widget
            .post
            .likes
            .where((like) => like.user.id == auth.getUser()!.id)
            .length ==
        0;
  }

  Widget _buildImageScroller(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.45,
      child: ListView.builder(
        physics: PageScrollPhysics(),
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: this.widget.post.images.length,
        itemBuilder: (context, index) => CachedNetworkImage(
          imageUrl: this.widget.post.images[index].imageUrl,
          width: MediaQuery.of(context).size.width,
          fit: BoxFit.contain,
          progressIndicatorBuilder: (context, url, downloadProgress) {
            return Center(
              child:
                  CircularProgressIndicator(value: downloadProgress.progress),
            );
          },
          errorWidget: (context, url, error) {
            print(error);
            return Icon(Icons.error);
          },
        ),
      ),
    );
  }

  Widget _buildTopRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              margin: EdgeInsets.all(10.0),
              child: ProfilePicture(
                imageUrl: this.widget.post.user.imageUrl,
                size: 40,
              ),
            ),
            Text(
                "${this.widget.post.user.firstName} ${this.widget.post.user.lastName}"),
          ],
        ),
        Consumer<AuthProvider>(
          builder: (context, auth, _) =>
              this.widget.post.user.id == auth.getUser()!.id
                  ? PopupMenuButton(
                      child: Icon(Icons.more_vert),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          child: Text("Update Post"),
                          value: PostOptionsType.UPDATE,
                        ),
                        PopupMenuItem(
                          child: Text("Delete Post"),
                          value: PostOptionsType.DELETE,
                        ),
                      ],
                      onSelected: (PostOptionsType selectedData) {
                        if (selectedData == PostOptionsType.UPDATE) {
                          Navigator.of(context).pushNamed(
                            UpdatePost.routeName,
                            arguments: this.widget.post,
                          );
                        }
                        if (selectedData == PostOptionsType.DELETE) {
                          this._onDeletePost(context);
                        }
                      },
                    )
                  : SizedBox(),
        ),
      ],
    );
  }
}
