import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:provider/provider.dart';
import 'package:yasm_mobile/constants/logger.constant.dart';
import 'package:yasm_mobile/constants/post_options.constant.dart';
import 'package:yasm_mobile/exceptions/auth/not_logged_in.exception.dart';
import 'package:yasm_mobile/exceptions/common/server.exception.dart';
import 'package:yasm_mobile/models/post/post.model.dart';
import 'package:yasm_mobile/pages/posts/full_post.page.dart';
import 'package:yasm_mobile/pages/posts/update_post.page.dart';
import 'package:yasm_mobile/pages/user/user_profile.page.dart';
import 'package:yasm_mobile/providers/auth/auth.provider.dart';
import 'package:yasm_mobile/services/like.service.dart';
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
  late final LikeService _likeService;

  late bool _isLiked;

  @override
  void initState() {
    super.initState();

    this._postService = Provider.of<PostService>(context, listen: false);
    this._likeService = Provider.of<LikeService>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    this._isLiked = !(this._checkIfNotLiked(
      Provider.of<AuthProvider>(context, listen: false),
    ));

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
    showDialog(
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        content: Text('Are you sure you want to delete this post?'),
        actions: [
          TextButton(
            onPressed: () async {
              await _confirmPostDeletion(context);
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
      context: context,
    );
  }

  Future<void> _confirmPostDeletion(BuildContext context) async {
    try {
      await this._postService.deletePost(widget.post.id);

      Navigator.of(context).pop();

      displaySnackBar("Post Deleted!", context);

      await widget.refreshPosts();
    } on ServerException catch (error) {
      displaySnackBar(
        error.message,
        context,
      );
    } on NotLoggedInException catch (error) {
      displaySnackBar(
        error.message,
        context,
      );
    } catch (error, stackTrace) {
      log.e(error, error, stackTrace);

      displaySnackBar(
        "Something went wrong, please try again later.",
        context,
      );
    }
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
    return OfflineBuilder(
      connectivityBuilder: (
        BuildContext context,
        ConnectivityResult connectivity,
        Widget _,
      ) {
        final bool connected = connectivity != ConnectivityResult.none;
        return Row(
          children: [
            IconButton(
              onPressed: connected
                  ? () async {
                      if (this._isLiked) {
                        await this._likeService.unlikePost(widget.post.id);
                      } else {
                        await this._likeService.likePost(widget.post.id);
                      }

                      widget.refreshPosts();
                    }
                  : null,
              icon: Icon(
                this._isLiked ? Icons.favorite : Icons.favorite_border,
                color: Colors.pink,
              ),
            ),
            IconButton(
              onPressed: connected
                  ? () {
                      Navigator.pushNamed(
                        context,
                        FullPost.routeName,
                        arguments: widget.post.id,
                      );
                    }
                  : null,
              icon: Icon(
                Icons.textsms_outlined,
                color: Colors.pink,
              ),
            ),
          ],
        );
      },
      child: SizedBox(),
    );
  }

  bool _checkIfNotLiked(AuthProvider auth) {
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
          imageBuilder: (context, imageProvider) => Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: imageProvider,
                fit: BoxFit.cover,
              ),
            ),
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Image(
                  image: imageProvider,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopRow() {
    return OfflineBuilder(
      connectivityBuilder: (
        BuildContext context,
        ConnectivityResult connectivity,
        Widget _,
      ) {
        final bool connected = connectivity != ConnectivityResult.none;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: connected
                  ? () {
                      Navigator.of(context).pushNamed(
                        UserProfile.routeName,
                        arguments: widget.post.user.id,
                      );
                    }
                  : null,
              child: Row(
                children: [
                  Container(
                    margin: EdgeInsets.all(10.0),
                    child: ProfilePicture(
                      imageUrl: this.widget.post.user.imageUrl,
                      size: 40,
                    ),
                  ),
                  Text(
                    "${this.widget.post.user.firstName} ${this.widget.post.user.lastName}",
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Consumer<AuthProvider>(
                  builder: (context, auth, _) =>
                      this.widget.post.user.id == auth.getUser()!.id
                          ? Container(
                              margin: EdgeInsets.symmetric(
                                horizontal:
                                    MediaQuery.of(context).size.width * 0.05,
                              ),
                              child: PopupMenuButton(
                                enabled: connected,
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
                              ),
                            )
                          : SizedBox(),
                ),
              ],
            ),
          ],
        );
      },
      child: SizedBox(),
    );
  }
}
