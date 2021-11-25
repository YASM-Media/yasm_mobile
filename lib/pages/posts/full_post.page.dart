import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yasm_mobile/constants/comment_form_type.constant.dart';
import 'package:yasm_mobile/constants/logger.constant.dart';
import 'package:yasm_mobile/dto/comment/delete_comment/delete_comment.dto.dart';
import 'package:yasm_mobile/exceptions/auth/not_logged_in.exception.dart';
import 'package:yasm_mobile/exceptions/common/server.exception.dart';
import 'package:yasm_mobile/models/post/post.model.dart';
import 'package:yasm_mobile/services/comment.service.dart';
import 'package:yasm_mobile/services/post.service.dart';
import 'package:yasm_mobile/utils/display_snackbar.util.dart';
import 'package:yasm_mobile/widgets/comments/comment_form.widget.dart';
import 'package:yasm_mobile/widgets/comments/comment_list.widget.dart';
import 'package:yasm_mobile/widgets/posts/post_card.widget.dart';
import 'package:yasm_mobile/utils/show_bottom_sheet.util.dart' as SBS;

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
    try {
      Post newPost = await this._postService.fetchPostById(_postId);

      setState(() {
        this._post = newPost;
      });
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

  void _onEditComment(BuildContext context, Post comment) {
    SBS.showBottomSheet(
      context,
      Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height * 0.5,
        ),
        child: CommentForm(
          refreshPost: this._refreshPost,
          postId: this._post.id,
          commentFormType: CommentFormType.UPDATE,
          text: comment.text,
          commentId: comment.id,
        ),
      ),
    );
  }

  void _onDeleteComment(BuildContext context, Post comment) {
    SBS.showBottomSheet(
      context,
      Wrap(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text('Are you sure you want to delete this comment?'),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () async {
                  await _handleDeletingComment(comment, context);
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

  Future<void> _handleDeletingComment(
      Post comment, BuildContext context) async {
    try {
      DeleteCommentDto deleteCommentDto = new DeleteCommentDto(
        postId: this._post.id,
        commentId: comment.id,
      );

      await this._commentService.deleteComment(deleteCommentDto);

      Navigator.of(context).pop();

      displaySnackBar("Comment Deleted!", context);

      await this._refreshPost();
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
                    commentFormType: CommentFormType.CREATE,
                  ),
                  CommentList(
                    comments: this._post.comments,
                    onEditComment: this._onEditComment,
                    onDeleteComment: this._onDeleteComment,
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
