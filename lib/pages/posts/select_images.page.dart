import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:yasm_mobile/pages/posts/post_description.page.dart';
import 'package:yasm_mobile/utils/image_picker.util.dart';
import 'package:yasm_mobile/utils/show_bottom_sheet.util.dart' as SBS;
import 'package:yasm_mobile/widgets/posts/image_post.widget.dart';

class SelectImages extends StatefulWidget {
  const SelectImages({Key? key}) : super(key: key);

  static const routeName = "/new-post-select-images";

  @override
  _SelectImagesState createState() => _SelectImagesState();
}

class _SelectImagesState extends State<SelectImages> {
  List<File> images = List.empty(growable: true);

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
        this.images.add(imageFile);
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
        this.images.add(imageFile);
      });
    }
  }

  void onDeleteImageFromArray(File imageFile) {
    setState(() {
      this.images.removeWhere((image) => image.path == imageFile.path);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select images'),
      ),
      body: this.images.length != 0
          ? Stack(
              children: [
                ListView.builder(
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
                Align(
                  alignment: Alignment.bottomCenter,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(
                        PostDescription.routeName,
                        arguments: this.images,
                      );
                    },
                    child: Text(
                      'Proceed',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            )
          : Center(
              child: Text('Add Images from Storage or from Camera.'),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: this._onUploadImage,
        child: Icon(Icons.add),
      ),
    );
  }
}
