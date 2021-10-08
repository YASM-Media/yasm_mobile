import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yasm_mobile/constants/post_options.constant.dart';
import 'package:yasm_mobile/models/post/post.model.dart';
import 'package:yasm_mobile/providers/auth/auth.provider.dart';
import 'package:yasm_mobile/widgets/common/profile_picture.widget.dart';

class PostCard extends StatelessWidget {
  final Post post;

  PostCard({Key? key, required this.post}) : super(key: key);

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

  Padding _buildBottomRow() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Liked by ${this.post.likes.length} others",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(this.post.text),
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
        itemCount: this.post.images.length,
        itemBuilder: (context, index) => CachedNetworkImage(
          imageUrl: this.post.images[index].imageUrl,
          width: MediaQuery.of(context).size.width,
          fit: BoxFit.fitWidth,
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
                imageUrl: this.post.user.imageUrl,
                size: 40,
              ),
            ),
            Text("${this.post.user.firstName} ${this.post.user.lastName}"),
          ],
        ),
        Consumer<AuthProvider>(
          builder: (context, auth, _) => this.post.user.id == auth.getUser()!.id
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
                  onSelected: (PostOptionsType selectedData) {},
                )
              : SizedBox(),
        ),
      ],
    );
  }
}
