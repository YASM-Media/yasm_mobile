import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:yasm_mobile/constants/logger.constant.dart';
import 'package:yasm_mobile/dto/post/update_post/update_post.dto.dart';
import 'package:yasm_mobile/exceptions/auth/not_logged_in.exception.dart';
import 'package:yasm_mobile/exceptions/common/server.exception.dart';
import 'package:yasm_mobile/models/post/post.model.dart';
import 'package:yasm_mobile/pages/home.page.dart';
import 'package:yasm_mobile/services/post.service.dart';
import 'package:yasm_mobile/utils/display_snackbar.util.dart';
import 'package:yasm_mobile/utils/image_picker.util.dart';
import 'package:yasm_mobile/widgets/common/custom_text_area.widget.dart';
import 'package:yasm_mobile/utils/image_upload.util.dart';
import 'package:yasm_mobile/utils/show_bottom_sheet.util.dart' as SBS;
import 'package:yasm_mobile/widgets/posts/mixed_image_carousel.widget.dart';


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
  Post? post;
  List<String> _postImages = [];

  bool _loading = false;

  @override
  void initState() {
    super.initState();

    this._postService = Provider.of<PostService>(
      context,
      listen: false,
    );
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
        this._postImages.add(imageFile.path);
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
        this._postImages.add(imageFile.path);
      });
    }
  }

  void onDeleteImageFromArray(String image) {
    setState(() {
      this._postImages.removeWhere((i) => image == i);
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

    setState(() {
      _loading = true;
    });

    try {
      List<String> updatedImages =
      await Future.wait(this._postImages.map((image) async {
        if (image.startsWith("http")) {
          return image;
        } else {
          return await uploadImageAndGenerateUrl(new File(image), 'posts');
        }
      }));

      UpdatePostDto updatePostDto = new UpdatePostDto(
        id: this.post!.id,
        images: updatedImages,
        text: this._descriptionController.text,
      );

      await this._postService.updatePost(updatePostDto);

      displaySnackBar("Post Updated!", context);

      setState(() {
        _loading = false;
      });

      Navigator.of(context).pushReplacementNamed(Home.routeName);
    } on ServerException catch (error) {
      setState(() {
        _loading = false;
      });

      displaySnackBar(
        error.message,
        context,
      );
    } on NotLoggedInException catch (error) {
      setState(() {
        _loading = false;
      });

      displaySnackBar(
        error.message,
        context,
      );
    } catch (error, stackTrace) {
      log.e(error, error, stackTrace);

      setState(() {
        _loading = false;
      });

      displaySnackBar(
        "Something went wrong, please try again later.",
        context,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (this.post == null) {
      this.post = ModalRoute
          .of(context)!
          .settings
          .arguments as Post;
      this._descriptionController.text = this.post!.text;
      this._postImages =
          this.post!.images.map((e) => e.imageUrl).toList(growable: true);
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Post'),
      ),
      body: Form(
        key: this._formKey,
        child: Column(
          children: [
            if (this._postImages.length == 0)
              GestureDetector(
                onTap: this._onUploadImage,
                child: Container(
                  height: MediaQuery
                      .of(context)
                      .size
                      .height * 0.5,
                  decoration: BoxDecoration(color: Colors.black26),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.photo_camera_back,
                          size: MediaQuery
                              .of(context)
                              .size
                              .height *
                              0.2,
                          color: Colors.grey,
                        ),
                        Text(
                          'Click to add image.',
                          style:
                          Theme
                              .of(context)
                              .textTheme
                              .subtitle1,
                        )
                      ],
                    ),
                  ),
                ),
              ),
            if (this._postImages.length > 0)
              MixedImageCarousel(
                images: this._postImages,
                onDelete: this.onDeleteImageFromArray,
              ),
            if (this._postImages.length > 0)
              TextButton(
                onPressed: this._onUploadImage,
                child: Text('Add More Images'),
              ),
            CustomTextArea(
              textFieldController: this._descriptionController,
              helperText: 'Body of the post...',
              validators: [
                RequiredValidator(errorText: 'Description is required.'),
                MinLengthValidator(
                  10,
                  errorText:
                  'At least 10 characters required for the body of the post',
                ),
              ],
              minLines: 5,
              textInputType: TextInputType.text,
            ),
            OfflineBuilder(
              connectivityBuilder: (BuildContext context,
                  ConnectivityResult connectivity,
                  Widget _,) {
                final bool connected = connectivity != ConnectivityResult.none;
                return ElevatedButton.icon(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                      this._loading ? Colors.grey[900]! : Colors.pink,
                    ),
                  ),
                  onPressed: connected
                      ? !this._loading
                      ? this._onFormSubmit
                      : null
                      : null,
                  label: Text(
                    connected
                        ? !this._loading
                        ? 'Update'
                        : 'Updating'
                        : 'You are offline',
                  ),
                  icon: connected
                      ? !this._loading
                      ? Icon(
                    Icons.photo,
                  )
                      : SizedBox(
                    height: MediaQuery
                        .of(context)
                        .size
                        .longestSide *
                        0.025,
                    width: MediaQuery
                        .of(context)
                        .size
                        .longestSide *
                        0.025,
                    child: CircularProgressIndicator(
                      color: Colors.grey,
                    ),
                  )
                      : Icon(
                    Icons.offline_bolt_outlined,
                  ),
                );
              },
              child: SizedBox(),
            )
          ],
        ),
      ),
    );
  }
}
