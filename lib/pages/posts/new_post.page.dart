import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:yasm_mobile/constants/logger.constant.dart';
import 'package:yasm_mobile/dto/post/create_post/create_post.dto.dart';
import 'package:yasm_mobile/exceptions/auth/not_logged_in.exception.dart';
import 'package:yasm_mobile/exceptions/common/server.exception.dart';
import 'package:yasm_mobile/services/post.service.dart';
import 'package:yasm_mobile/utils/display_snackbar.util.dart';
import 'package:yasm_mobile/utils/image_picker.util.dart';
import 'package:yasm_mobile/utils/image_upload.util.dart';
import 'package:yasm_mobile/widgets/common/custom_text_area.widget.dart';
import 'package:yasm_mobile/widgets/common/loading_icon_button.widget.dart';
import 'package:yasm_mobile/widgets/posts/file_image_carousel.widget.dart';
import 'package:yasm_mobile/utils/show_bottom_sheet.util.dart' as SBS;

class NewPost extends StatefulWidget {
  const NewPost({Key? key}) : super(key: key);

  static const routeName = "/create-post";

  @override
  _NewPostState createState() => _NewPostState();
}

class _NewPostState extends State<NewPost> {
  final List<File> _imageFiles = [];
  final TextEditingController _bodyController = new TextEditingController();
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  late final PostService _postService;

  bool _loading = false;

  @override
  void initState() {
    super.initState();

    this._postService = Provider.of<PostService>(context, listen: false);
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

      setState(() {
        this._imageFiles.add(imageFile);
      });
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
        this._imageFiles.add(imageFile);
      });
    }
  }

  void onDeleteImageFromArray(File imageFile) {
    setState(() {
      this._imageFiles.removeWhere((image) => image.path == imageFile.path);
    });
  }

  /*
   * Method to open up camera or gallery on user's selection.
   */
  void _onUploadImage() {
    SBS.showBottomSheet(
      context,
      Wrap(
        children: [
          ListTile(
            leading: Icon(Icons.camera_alt_rounded),
            title: Text('Upload from camera'),
            onTap: this._uploadFromCamera,
          ),
          ListTile(
            leading: Icon(Icons.photo_album_sharp),
            title: Text('Upload from storage'),
            onTap: this._uploadFromGallery,
          )
        ],
      ),
    );
  }

  Future<void> _onFormSubmit() async {
    if (!this._formKey.currentState!.validate()) {
      return;
    }

    if (this._imageFiles.length == 0) {
      displaySnackBar("Please upload some images.", context);

      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      Iterable<Future<String>> iterableList = this._imageFiles.map(
          (imageFile) async =>
              await uploadImageAndGenerateUrl(imageFile, "posts"));

      List<String> uploadedImages = await Future.wait(iterableList);

      CreatePostDto createPostDto = new CreatePostDto(
        images: uploadedImages,
        text: this._bodyController.text,
      );

      await this._postService.createPost(createPostDto);

      setState(() {
        _loading = false;
      });

      displaySnackBar("Post created!", context);

      Navigator.of(context).pop();
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

    setState(() {
      _loading = false;
    });
  }

  @override
  void dispose() {
    super.dispose();

    this._bodyController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create New Post'),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: this._formKey,
          child: Column(
            children: [
              if (this._imageFiles.length == 0)
                GestureDetector(
                  onTap: this._onUploadImage,
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.5,
                    decoration: BoxDecoration(color: Colors.black26),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.photo_camera_back,
                            size: MediaQuery.of(context).size.height * 0.2,
                            color: Colors.grey,
                          ),
                          Text(
                            'Click to add image.',
                            style: Theme.of(context).textTheme.subtitle1,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              if (this._imageFiles.length > 0)
                FileImageCarousel(
                  fileImages: this._imageFiles,
                  onDelete: this.onDeleteImageFromArray,
                ),
              if (this._imageFiles.length > 0)
                TextButton(
                  onPressed: this._onUploadImage,
                  child: Text('Add More Images'),
                ),
              CustomTextArea(
                textFieldController: this._bodyController,
                validators: [
                  RequiredValidator(errorText: 'Body is required'),
                  MinLengthValidator(
                    10,
                    errorText:
                        'At least 10 characters are required for the body of the post',
                  ),
                ],
                textInputType: TextInputType.text,
                helperText: 'Body of the post...',
                minLines: 5,
              ),
              LoadingIconButton(
                loading: this._loading,
                iconData: Icons.photo,
                onPress: this._onFormSubmit,
                normalText: 'Create Post',
                loadingText: 'Creating Post',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
