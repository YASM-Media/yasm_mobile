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

  final UserService _userService = new UserService();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    this._authProvider = Provider.of<AuthProvider>(context, listen: false);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

    this._firstNameController.dispose();
    this._lastNameController.dispose();
    this._biographyController.dispose();
  }

  Future<void> _uploadFromGallery() async {
    XFile? imageXFile = await openGallery();

    if (imageXFile != null) {
      File imageFile = new File(imageXFile.path);
      String uploadedUrl =
          await uploadImageAndGenerateUrl(imageFile, "profile-pictures");

      User user = this._authProvider.getUser()!;
      user.imageUrl = uploadedUrl;

      this._authProvider.saveUser(user);

      displaySnackBar(
        "Image has been uploaded! Please click \"Update Profile\" to confirm your changes when you are done!",
        context,
      );
    }
  }

  Future<void> _uploadFromCamera() async {
    XFile? imageXFile = await openCamera();

    if (imageXFile != null) {
      File imageFile = new File(imageXFile.path);
      String uploadedUrl =
          await uploadImageAndGenerateUrl(imageFile, "profile-pictures");

      User user = this._authProvider.getUser()!;
      user.imageUrl = uploadedUrl;

      this._authProvider.saveUser(user);

      displaySnackBar(
        "Image has been uploaded! Please click \"Update Profile\" to confirm your changes when you are done!",
        context,
      );
    }
  }

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
    try {
      if (this._formKey.currentState!.validate()) {
        UpdateProfileDto updateProfileDto = new UpdateProfileDto(
          firstName: this._firstNameController.text,
          lastName: this._lastNameController.text,
          biography: this._biographyController.text,
          imageUrl: this._authProvider.getUser()!.imageUrl,
        );
        User user = await this._userService.updateUserProfile(
              updateProfileDto,
              this._authProvider.getUser()!,
            );

        this._authProvider.saveUser(user);

        displaySnackBar("Profile updated!", context);
      }
    } on ServerException catch (error) {
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
                    CircleAvatar(
                      child: imageUrl.length == 0
                          ? Icon(
                              Icons.person,
                              size: 100.0,
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(100.0),
                              child: Image.network(
                                imageUrl,
                                height: 200.0,
                                width: 200.0,
                              ),
                            ),
                      radius: 100.0,
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
