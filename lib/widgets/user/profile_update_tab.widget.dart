import 'dart:io';

import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:yasm_mobile/dto/user/update_profile/update_profile.dto.dart';
import 'package:yasm_mobile/exceptions/auth/not_logged_in.exception.dart';
import 'package:yasm_mobile/exceptions/common/server.exception.dart';
import 'package:yasm_mobile/models/user/user.model.dart';
import 'package:yasm_mobile/providers/auth/auth.provider.dart';
import 'package:yasm_mobile/services/user.service.dart';
import 'package:yasm_mobile/utils/display_snackbar.util.dart';
import 'package:yasm_mobile/utils/image_picker.util.dart';
import 'package:yasm_mobile/utils/image_upload.util.dart';
import 'package:yasm_mobile/utils/show_bottom_sheet.util.dart' as SBS;
import 'package:yasm_mobile/widgets/common/custom_field.widget.dart';
import 'package:yasm_mobile/widgets/common/profile_picture.widget.dart';

class ProfileUpdateTab extends StatefulWidget {
  const ProfileUpdateTab({Key? key}) : super(key: key);

  @override
  _ProfileUpdateTabState createState() => _ProfileUpdateTabState();
}

class _ProfileUpdateTabState extends State<ProfileUpdateTab> {
  TextEditingController _firstNameController = new TextEditingController();
  TextEditingController _lastNameController = new TextEditingController();
  TextEditingController _biographyController = new TextEditingController();

  late AuthProvider _authProvider;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late UserService _userService;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // Injecting User Service from context.
    this._userService = Provider.of<UserService>(context, listen: false);

    // Initializing the authentication provider.
    this._authProvider = Provider.of<AuthProvider>(context, listen: false);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

    // Disposing off the controllers
    this._firstNameController.dispose();
    this._lastNameController.dispose();
    this._biographyController.dispose();
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
      String uploadedUrl =
          await uploadImageAndGenerateUrl(imageFile, "profile-pictures");

      // Update the user state
      User user = this._authProvider.getUser()!;
      user.imageUrl = uploadedUrl;

      // Save the updated state.
      this._authProvider.saveUser(user);

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

      // Upload the image to firebase and generate a URL.
      String uploadedUrl =
          await uploadImageAndGenerateUrl(imageFile, "profile-pictures");

      // Update the user state
      User user = this._authProvider.getUser()!;
      user.imageUrl = uploadedUrl;

      // Save the updated state.
      this._authProvider.saveUser(user);

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

  /*
   * Form submission method for user profile update.
   */
  Future<void> _onFormSubmit() async {
    try {
      // Validate the form.
      if (this._formKey.currentState!.validate()) {
        // Prepare DTO for updating profile.
        UpdateProfileDto updateProfileDto = new UpdateProfileDto(
          firstName: this._firstNameController.text,
          lastName: this._lastNameController.text,
          biography: this._biographyController.text,
          imageUrl: this._authProvider.getUser()!.imageUrl,
        );

        // Update it on server and also update the state as well.
        User user = await this._userService.updateUserProfile(
              updateProfileDto,
              this._authProvider.getUser()!,
            );

        this._authProvider.saveUser(user);

        // Display success snackbar.
        displaySnackBar("Profile updated!", context);
      }
    }
    // Handle errors gracefully.
    on ServerException catch (error) {
      displaySnackBar(error.message, context);
    } on NotLoggedInException {
      print("NOT LOGGED IN");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Consumer<AuthProvider>(builder: (context, state, child) {
        User? user = state.getUser();
        String imageUrl = user != null ? user.imageUrl : '';

        this._firstNameController.text = user != null ? user.firstName : '';
        this._lastNameController.text = user != null ? user.lastName : '';
        this._biographyController.text = user != null ? user.biography : '';

        return Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 20.0,
            horizontal: 10.0,
          ),
          child: Form(
            key: this._formKey,
            child: Column(
              children: [
                Column(
                  children: [
                    ProfilePicture(
                      imageUrl: imageUrl,
                      size: 200,
                    ),
                    TextButton(
                      onPressed: this._onUploadImage,
                      child: Text(
                        'Upload New Image',
                        style: TextStyle(
                          fontSize: 15.0,
                        ),
                      ),
                    )
                  ],
                ),
                CustomField(
                  textFieldController: this._firstNameController,
                  label: "First Name",
                  validators: [
                    RequiredValidator(errorText: "First name is required"),
                  ],
                  textInputType: TextInputType.text,
                ),
                CustomField(
                  textFieldController: this._lastNameController,
                  label: "Last Name",
                  validators: [
                    RequiredValidator(errorText: "Last name is required"),
                  ],
                  textInputType: TextInputType.text,
                ),
                CustomField(
                  textFieldController: this._biographyController,
                  label: "Biography",
                  validators: [
                    RequiredValidator(errorText: "Biography is required"),
                  ],
                  textInputType: TextInputType.multiline,
                ),
                ElevatedButton(
                  onPressed: this._onFormSubmit,
                  child: Text('Update Profile'),
                )
              ],
            ),
          ),
        );
      }),
    );
  }
}
