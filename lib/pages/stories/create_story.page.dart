import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:yasm_mobile/services/stories.service.dart';
import 'package:yasm_mobile/utils/display_snackbar.util.dart';
import 'package:yasm_mobile/utils/image_picker.util.dart';
import 'package:yasm_mobile/widgets/stories/draggable_text_field.widget.dart';
import 'package:yasm_mobile/utils/show_bottom_sheet.util.dart' as SBS;


class CreateStory extends StatefulWidget {
  const CreateStory({Key? key}) : super(key: key);

  static const routeName = "/create-story";

  @override
  _CreateStoryState createState() => _CreateStoryState();
}

class _CreateStoryState extends State<CreateStory> {
  List<DraggableTextField> _textFields = [];
  late final StoriesService _storiesService;
  File? bgImage;

  ScreenshotController _screenshotController = new ScreenshotController();

  @override
  void initState() {
    super.initState();

    this._storiesService = Provider.of<StoriesService>(context, listen: false);
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

      // Upload the image to firebase and generate a URL.

      // Display a success snackbar.
      displaySnackBar(
        "Image has been uploaded! Please click \"Update Profile\" to confirm your changes when you are done!",
        context,
      );
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

      // Display a success snackbar.
      displaySnackBar(
        "Image has been uploaded! Please click \"Update Profile\" to confirm your changes when you are done!",
        context,
      );
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Screenshot(
          controller: this._screenshotController,
          child: Container(
            child: Stack(
              children: _textFields,
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (int index) {
          if (index == 1) {
            setState(
              () {
                this._textFields.add(
                      new DraggableTextField(),
                    );
              },
            );
          }
        },
        backgroundColor: Colors.pink,
        fixedColor: Colors.white,
        unselectedItemColor: Colors.white,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.add_a_photo),
            label: 'Add A Photo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.format_color_text),
            label: 'Add Text',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: Text('Post Story'),
        icon: Icon(Icons.add_circle),
        onPressed: _handleAddStory,
      ),
    );
  }

  Future<void> _handleAddStory() async {
    Uint8List? screenshot = await this._screenshotController.capture();

    if(screenshot != null) {
      String url = await this._storiesService.uploadStoryAndGenerateUrl(screenshot);

      print(url);
    }
  }
}
