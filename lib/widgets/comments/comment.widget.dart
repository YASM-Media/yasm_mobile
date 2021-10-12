import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yasm_mobile/constants/post_options.constant.dart';
import 'package:yasm_mobile/models/post/post.model.dart';
import 'package:yasm_mobile/providers/auth/auth.provider.dart';
import 'package:yasm_mobile/services/comment.service.dart';
import 'package:yasm_mobile/services/like.service.dart';
import 'package:yasm_mobile/widgets/common/profile_picture.widget.dart';

class Comment extends StatefulWidget {
  final Post comment;
  final Function onEditComment;

  Comment({
    Key? key,
    required this.comment,
    required this.onEditComment,
  }) : super(key: key);

  @override
  _CommentState createState() => _CommentState();
}

class _CommentState extends State<Comment> {
  late final LikeService _likeService;
  late final CommentService _commentService;
  late bool _isLiked;

  @override
  void initState() {
    super.initState();

    this._likeService = Provider.of<LikeService>(context, listen: false);
    this._commentService = Provider.of<CommentService>(context, listen: false);

    this._isLiked = !(this._checkIfNotLiked(
      Provider.of<AuthProvider>(
        context,
        listen: false,
      ),
    ));
  }

  bool _checkIfNotLiked(AuthProvider auth) {
    return this
            .widget
            .comment
            .likes
            .where((like) => like.user.id == auth.getUser()!.id)
            .length ==
        0;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                margin: EdgeInsets.symmetric(
                  horizontal: 10.0,
                ),
                child: ProfilePicture(
                  imageUrl: this.widget.comment.user.imageUrl,
                  size: 40,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${this.widget.comment.user.firstName} ${this.widget.comment.user.lastName}",
                  ),
                  Text(this.widget.comment.text),
                ],
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                onPressed: () async {
                  if (this._isLiked) {
                    await this._likeService.unlikePost(widget.comment.id);
                  } else {
                    await this._likeService.likePost(widget.comment.id);
                  }

                  setState(() {
                    this._isLiked = !this._isLiked;
                  });
                },
                icon: Icon(
                  this._isLiked ? Icons.favorite : Icons.favorite_border,
                  color: Colors.pink,
                ),
              ),
              Consumer<AuthProvider>(
                builder: (context, auth, _) => this.widget.comment.user.id ==
                        auth.getUser()!.id
                    ? PopupMenuButton(
                        child: Icon(Icons.more_vert),
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            child: Text("Update Comment"),
                            value: PostOptionsType.UPDATE,
                          ),
                          PopupMenuItem(
                            child: Text("Delete Comment"),
                            value: PostOptionsType.DELETE,
                          ),
                        ],
                        onSelected: (PostOptionsType selectedData) {
                          if (selectedData == PostOptionsType.UPDATE) {
                            widget.onEditComment(context, this.widget.comment);
                          }
                          if (selectedData == PostOptionsType.DELETE) {}
                        },
                      )
                    : SizedBox(
                        width: MediaQuery.of(context).size.width * 0.057,
                      ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
