import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:provider/provider.dart';
import 'package:yasm_mobile/constants/logger.constant.dart';
import 'package:yasm_mobile/constants/post_options.constant.dart';
import 'package:yasm_mobile/dto/comment/delete_comment/delete_comment.dto.dart';
import 'package:yasm_mobile/dto/comment/update_comment/update_comment.dto.dart';
import 'package:yasm_mobile/exceptions/auth/not_logged_in.exception.dart';
import 'package:yasm_mobile/exceptions/common/server.exception.dart';
import 'package:yasm_mobile/models/post/post.model.dart';
import 'package:yasm_mobile/providers/auth/auth.provider.dart';
import 'package:yasm_mobile/services/comment.service.dart';
import 'package:yasm_mobile/services/like.service.dart';
import 'package:yasm_mobile/utils/display_snackbar.util.dart';
import 'package:yasm_mobile/widgets/common/custom_field.widget.dart';
import 'package:yasm_mobile/widgets/common/profile_picture.widget.dart';

class Comment extends StatefulWidget {
  final Post comment;
  final Function refreshPost;
  final String postId;

  Comment({
    Key? key,
    required this.comment,
    required this.refreshPost,
    required this.postId,
  }) : super(key: key);

  @override
  _CommentState createState() => _CommentState();
}

class _CommentState extends State<Comment> {
  late final LikeService _likeService;
  late bool _isLiked;
  late final CommentService _commentService;

  final GlobalKey<FormState> _editCommentKey = new GlobalKey();
  final TextEditingController _editCommentController =
      new TextEditingController();

  @override
  void initState() {
    super.initState();

    this._likeService = Provider.of<LikeService>(context, listen: false);
    this._commentService = Provider.of<CommentService>(context, listen: false);
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

  void _onEditComment(BuildContext context, Post comment) {
    this._editCommentController.text = comment.text;

    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text('Edit Comment'),
        content: Form(
          key: this._editCommentKey,
          child: CustomField(
            textFieldController: this._editCommentController,
            label: 'Your Comment',
            validators: [
              MinLengthValidator(
                5,
                errorText: 'Your comment should be at least 5 characters long',
              ),
            ],
            textInputType: TextInputType.text,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await this._editComment(comment.id);
            },
            child: Text('Edit Comment'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _editComment(String commentId) async {
    try {
      UpdateCommentDto updateCommentDto = new UpdateCommentDto(
        id: commentId,
        text: this._editCommentController.text,
      );

      await this._commentService.updateComment(updateCommentDto);

      widget.refreshPost();
      this._editCommentController.text = '';

      Navigator.of(context).pop();

      displaySnackBar("Comment updated!", context);
    } on ServerException catch (error) {
      displaySnackBar(error.message, context);
    } on NotLoggedInException catch (error) {
      displaySnackBar(error.message, context);
    } catch (error, stackTrace) {
      log.e(error, error, stackTrace);
      displaySnackBar("Something went wrong, please try again later.", context);
    }
  }

  void _onDeleteComment(BuildContext context, Post comment) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text('Are you sure you want to delete this comment?'),
        content: Text(comment.text),
        actions: [
          TextButton(
            onPressed: () async {
              await this._deleteComment(comment, context);
            },
            child: Text('Yes'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('No'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteComment(Post comment, BuildContext context) async {
    try {
      DeleteCommentDto deleteCommentDto = new DeleteCommentDto(
        postId: widget.postId,
        commentId: comment.id,
      );

      await this._commentService.deleteComment(deleteCommentDto);

      Navigator.of(context).pop();

      displaySnackBar("Comment Deleted!", context);

      widget.refreshPost();
    } on ServerException catch (error) {
      displaySnackBar(error.message, context);
    } on NotLoggedInException catch (error) {
      displaySnackBar(error.message, context);
    } catch (error, stackTrace) {
      log.e(error, error, stackTrace);
      displaySnackBar("Something went wrong, please try again later.", context);
    }
  }

  @override
  void dispose() {
    super.dispose();

    this._editCommentController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    this._isLiked = !(this._checkIfNotLiked(
      Provider.of<AuthProvider>(
        context,
        listen: false,
      ),
    ));

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
                  await _handleLikeUnlikePost();
                },
                icon: Icon(
                  this._isLiked ? Icons.favorite : Icons.favorite_border,
                  color: Colors.pink,
                ),
              ),
              Consumer<AuthProvider>(
                builder: (context, auth, _) =>
                    this.widget.comment.user.id == auth.getUser()!.id
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
                                this._onEditComment(
                                  context,
                                  this.widget.comment,
                                );
                              }
                              if (selectedData == PostOptionsType.DELETE) {
                                this._onDeleteComment(
                                  context,
                                  this.widget.comment,
                                );
                              }
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

  Future<void> _handleLikeUnlikePost() async {
    try {
      if (this._isLiked) {
        await this._likeService.unlikePost(widget.comment.id);
      } else {
        await this._likeService.likePost(widget.comment.id);
      }

      widget.refreshPost();
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
}
