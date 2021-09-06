import 'dart:io';

import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:yasm_mobile/dto/post/create_post/create_post.dto.dart';
import 'package:yasm_mobile/exceptions/common/server.exception.dart';
import 'package:yasm_mobile/services/post.service.dart';
import 'package:yasm_mobile/utils/display_snackbar.util.dart';
import 'package:yasm_mobile/utils/image_picker.util.dart';
import 'package:yasm_mobile/utils/image_upload.util.dart';
import 'package:yasm_mobile/widgets/common/custom_field.widget.dart';
import 'package:yasm_mobile/widgets/posts/image_post.widget.dart';

enum NewPostStatus {
  IMAGE,
  TEXT,
}

class NewPost extends StatefulWidget {
  const NewPost({Key? key}) : super(key: key);

  static const routeName = "/new-post";

  @override
  _NewPostState createState() => _NewPostState();
}

class _NewPostState extends State<NewPost> {
  List<File> images = List.empty(growable: true);
  NewPostStatus _newPostStatus = NewPostStatus.IMAGE;

  final TextEditingController _descriptionController =
      new TextEditingController();

  final GlobalKey<FormState> _formKey = new GlobalKey();

  late PostService _postService;

  @override
  void initState() {
    super.initState();

    this._postService = Provider.of<PostService>(
      context,
      listen: false,
    );
  }

  @override
  void dispose() {
    super.dispose();

    this._descriptionController.dispose();
  }

  /*
   * Method for uploading images from gallery.
   */
  Future<void> _uploadFromGallery() async {
    // Open the gallery and get the selected image.
    XFile? imageXFile = await openGallery();

    // Run if there is an image selected.
    if (imageXFile != null) {
      // Prepare the file from the selected image.
      File imageFile = new File(imageXFile.path);

      this.images.add(imageFile);
    }
  }

  /*
   * Method for uploading images from camera.
   */
  Future<void> _uploadFromCamera() async {
    // Open the gallery and get the selected image.
    XFile? imageXFile = await openCamera();

    // Run if there is an image selected.
    if (imageXFile != null) {
      // Prepare the file from the selected image.
      File imageFile = new File(imageXFile.path);

      setState(() {
        this.images.add(imageFile);
      });
    }
  }

  void onDeleteImageFromArray(File imageFile) {
    setState(() {
      this.images.removeWhere((image) => image.path == imageFile.path);
    });
  }

  Future<void> _onFormSubmit() async {
    if (!this._formKey.currentState!.validate()) {
      return;
    }

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

      displaySnackBar("Post created!", context);

      Navigator.of(context).pop();
    } on ServerException catch (error) {
      print(error.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create New Post'),
      ),
      body: this._newPostStatus == NewPostStatus.IMAGE
          ? Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: this.images.length,
                    itemBuilder: (context, int index) {
                      return ImagePost(
                        imageFile: this.images[index],
                        onDelete: () {
                          this.onDeleteImageFromArray(this.images[index]);
                        },
                      );
                    },
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(60.0),
                  child: Column(
                    children: [
                      Text('Select images to be uploaded'),
                      TextButton(
                        onPressed: this._uploadFromGallery,
                        child: Text('Upload from storage'),
                      ),
                      TextButton(
                        onPressed: this._uploadFromCamera,
                        child: Text('Upload from camera'),
                      ),
                    ],
                  ),
                )
              ],
            )
          : Form(
              key: this._formKey,
              child: Column(
                children: [
                  CustomField(
                    textFieldController: this._descriptionController,
                    label: "Post Description",
                    validators: [
                      RequiredValidator(errorText: "Description is required.")
                    ],
                    textInputType: TextInputType.text,
                  ),
                  TextButton(
                    child: Text('Create New Post'),
                    onPressed: this._onFormSubmit,
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (this._newPostStatus == NewPostStatus.IMAGE) {
            setState(() {
              this._newPostStatus = NewPostStatus.TEXT;
            });
          } else {
            setState(() {
              this._newPostStatus = NewPostStatus.IMAGE;
            });
          }
        },
        child: Icon(
          this._newPostStatus == NewPostStatus.IMAGE
              ? Icons.arrow_forward
              : Icons.arrow_back,
        ),
      ),
    );
  }
}
