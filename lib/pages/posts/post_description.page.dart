import 'dart:io';

import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:provider/provider.dart';
import 'package:yasm_mobile/constants/logger.constant.dart';
import 'package:yasm_mobile/dto/post/create_post/create_post.dto.dart';
import 'package:yasm_mobile/exceptions/auth/not_logged_in.exception.dart';
import 'package:yasm_mobile/exceptions/common/server.exception.dart';
import 'package:yasm_mobile/pages/home.page.dart';
import 'package:yasm_mobile/services/post.service.dart';
import 'package:yasm_mobile/utils/display_snackbar.util.dart';
import 'package:yasm_mobile/utils/image_upload.util.dart';
import 'package:yasm_mobile/widgets/common/custom_text_area.widget.dart';

class PostDescription extends StatefulWidget {
  const PostDescription({Key? key}) : super(key: key);

  static const routeName = "/new-post-description";

  @override
  _PostDescriptionState createState() => _PostDescriptionState();
}

class _PostDescriptionState extends State<PostDescription> {
  final TextEditingController _descriptionController =
      new TextEditingController();

  final GlobalKey<FormState> _formKey = new GlobalKey();

  late List<File> images;
  late final PostService _postService;

  bool loading = false;

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

    setState(() {
      loading = true;
    });

    try {
      Iterable<Future<String>> iterableList = this.images.map(
          (imageFile) async =>
              await uploadImageAndGenerateUrl(imageFile, "posts"));

      List<String> uploadedImages = await Future.wait(iterableList);

      CreatePostDto createPostDto = new CreatePostDto(
        images: uploadedImages,
        text: this._descriptionController.text,
      );

      this._postService.createPost(createPostDto);

      setState(() {
        loading = false;
      });

      displaySnackBar("Post created!", context);

      Navigator.of(context).pushReplacementNamed(Home.routeName);
    } on ServerException catch (error) {
      setState(() {
        loading = false;
      });

      displaySnackBar(
        error.message,
        context,
      );
    } on NotLoggedInException catch (error) {
      setState(() {
        loading = false;
      });

      displaySnackBar(
        error.message,
        context,
      );
    } catch (error, stackTrace) {
      log.e(error, error, stackTrace);

      setState(() {
        loading = false;
      });

      displaySnackBar(
        "Something went wrong, please try again later.",
        context,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    this.images = ModalRoute.of(context)!.settings.arguments as List<File>;
    return Scaffold(
      appBar: AppBar(
        title: Text('Post Description'),
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
        backgroundColor: this.loading ? Colors.grey[900] : Colors.pink,
        child: this.loading ? CircularProgressIndicator() : Icon(Icons.check),
        onPressed: this.loading ? null : this._onFormSubmit,
      ),
    );
  }
}
