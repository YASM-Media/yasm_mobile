import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:provider/provider.dart';
import 'package:yasm_mobile/dto/comment/create_comment/create_comment.dto.dart';
import 'package:yasm_mobile/exceptions/common/server.exception.dart';
import 'package:yasm_mobile/services/comment.service.dart';
import 'package:yasm_mobile/utils/display_snackbar.util.dart';
import 'package:yasm_mobile/widgets/common/custom_text_area.widget.dart';

class CommentForm extends StatefulWidget {
  final Function refreshPost;
  final String postId;

  CommentForm({
    Key? key,
    required this.refreshPost,
    required this.postId,
  }) : super(key: key);

  @override
  _CommentFormState createState() => _CommentFormState();
}

class _CommentFormState extends State<CommentForm> {
  late final CommentService _commentService;

  final TextEditingController _commentController = new TextEditingController();
  final GlobalKey<FormState> _formKey = new GlobalKey();

  Future<void> _onFormSubmit() async {
    if (!this._formKey.currentState!.validate()) {
      return;
    }

    try {
      CreateCommentDto createCommentDto = new CreateCommentDto(
        text: this._commentController.text,
        postId: widget.postId,
      );

      this._commentService.createComment(createCommentDto);
      widget.refreshPost();

      displaySnackBar("Comment created!", context);
    } on ServerException catch (error) {
      print(error.message);
      displaySnackBar("Something went wrong, try again later.", context);
    }
  }

  @override
  void initState() {
    super.initState();

    this._commentService = Provider.of<CommentService>(context, listen: false);
  }

  @override
  void dispose() {
    super.dispose();

    this._commentController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(0, 10, 0, 20),
      child: Form(
        key: this._formKey,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.80,
              child: CustomTextArea(
                textFieldController: this._commentController,
                label: "Comment Here",
                validators: [
                  RequiredValidator(
                    errorText: 'Please enter some text',
                  ),
                ],
                textInputType: TextInputType.text,
              ),
            ),
            TextButton(
              onPressed: this._onFormSubmit,
              child: Text('SUBMIT'),
            ),
          ],
        ),
      ),
    );
  }
}
