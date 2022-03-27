import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:yasm_mobile/constants/logger.constant.dart';
import 'package:yasm_mobile/exceptions/auth/not_logged_in.exception.dart';
import 'package:yasm_mobile/exceptions/common/server.exception.dart';
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

  bool loading = false;

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

      setState(() {
        this.bgImage = imageFile;
      });

      Navigator.of(context).pop();
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
        this.bgImage = imageFile;
      });

      Navigator.of(context).pop();
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
              children: this.bgImage == null
                  ? _textFields
                  : [
                      Image.file(
                        this.bgImage!,
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        fit: BoxFit.fill,
                      ),
                      ClipRRect(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                          child: Image.file(
                            this.bgImage!,
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height,
                            fit: BoxFit.fitWidth,
                          ),
                        ),
                      ),
                      ..._textFields,
                    ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (int index) {
          if (index == 0) {
            this._onUploadImage();
          } else if (index == 1) {
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
      floatingActionButton: OfflineBuilder(
        connectivityBuilder:
            (BuildContext context, ConnectivityResult value, Widget child) {
          bool connected = value != ConnectivityResult.none;

          return connected
              ? FloatingActionButton.extended(
                  backgroundColor:
                      this.loading ? Colors.grey[800] : Colors.pink,
                  label: Text(
                    this.loading ? 'Posting' : 'Post Story',
                  ),
                  icon: this.loading
                      ? SizedBox(
                          height:
                              MediaQuery.of(context).size.longestSide * 0.025,
                          width:
                              MediaQuery.of(context).size.longestSide * 0.025,
                          child: CircularProgressIndicator(
                            color: Colors.grey,
                          ),
                        )
                      : Icon(Icons.add_circle),
                  onPressed: _handleAddStory,
                )
              : FloatingActionButton.extended(
                  label: Text('You Are Offline'),
                  icon: Icon(Icons.offline_bolt),
                  onPressed: null,
                );
        },
        child: SizedBox(),
      ),
    );
  }

  Future<void> _handleAddStory() async {
    Uint8List? screenshot = await this._screenshotController.capture();

    if (screenshot != null) {
      setState(() {
        this.loading = true;
      });

      try {
        await this._storiesService.createStory(screenshot);

        displaySnackBar("Story Posted!", context);

        Navigator.of(context).pop();
      } on ServerException catch (error) {
        displaySnackBar(error.message, context);
      } on NotLoggedInException catch (error) {
        displaySnackBar(error.message, context);
      } catch (error, stackTrace) {
        log.e(error, error, stackTrace);
        displaySnackBar(
            "Something went wrong, please try again later.", context);
      }

      setState(() {
        this.loading = false;
      });
    }
  }
}
