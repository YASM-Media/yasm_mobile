import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:provider/provider.dart';
import 'package:yasm_mobile/dto/post/update_post/update_post.dto.dart';
import 'package:yasm_mobile/exceptions/common/server.exception.dart';
import 'package:yasm_mobile/models/post/post.model.dart';
import 'package:yasm_mobile/pages/home.page.dart';
import 'package:yasm_mobile/services/post.service.dart';
import 'package:yasm_mobile/utils/display_snackbar.util.dart';
import 'package:yasm_mobile/widgets/common/custom_text_area.widget.dart';

class UpdatePost extends StatefulWidget {
  const UpdatePost({Key? key}) : super(key: key);

  static const routeName = "/update-post";

  @override
  _UpdatePostState createState() => _UpdatePostState();
}

class _UpdatePostState extends State<UpdatePost> {
  final TextEditingController _descriptionController =
      new TextEditingController();

  final GlobalKey<FormState> _formKey = new GlobalKey();

  late final PostService _postService;
  late final Post post;

  @override
  void initState() {
    super.initState();

    this._postService = Provider.of<PostService>(
      context,
      listen: false,
    );
  }

  Future<void> _onFormSubmit() async {
    if (!this._formKey.currentState!.validate()) {
      return;
    }

    try {
      UpdatePostDto updatePostDto = new UpdatePostDto(
        id: this.post.id,
        images: this.post.images.map((e) => e.imageUrl).toList(),
        text: this._descriptionController.text,
      );

      await this._postService.updatePost(updatePostDto);

      displaySnackBar("Post Updated!", context);

      Navigator.of(context).pushReplacementNamed(Home.routeName);
    } on ServerException catch (error) {
      print(error.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    this.post = ModalRoute.of(context)!.settings.arguments as Post;
    this._descriptionController.text = this.post.text;
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Post'),
      ),
      body: Form(
        key: this._formKey,
        child: CustomTextArea(
          textFieldController: this._descriptionController,
          label: "Description",
          validators: [
            RequiredValidator(errorText: 'Description is required.')
          ],
          minLines: 3,
          textInputType: TextInputType.text,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.check),
        onPressed: this._onFormSubmit,
      ),
    );
  }
}
