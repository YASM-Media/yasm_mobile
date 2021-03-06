import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:yasm_mobile/constants/logger.constant.dart';
import 'package:yasm_mobile/dto/user/update_profile/update_profile.dto.dart';
import 'package:yasm_mobile/exceptions/auth/not_logged_in.exception.dart';
import 'package:yasm_mobile/exceptions/common/server.exception.dart';
import 'package:yasm_mobile/models/user/user.model.dart';
import 'package:yasm_mobile/providers/auth/auth.provider.dart';
import 'package:yasm_mobile/services/tokens.service.dart';
import 'package:yasm_mobile/services/user.service.dart';
import 'package:yasm_mobile/utils/display_snackbar.util.dart';
import 'package:yasm_mobile/utils/image_picker.util.dart';
import 'package:yasm_mobile/utils/image_upload.util.dart';
import 'package:yasm_mobile/utils/show_bottom_sheet.util.dart' as SBS;
import 'package:yasm_mobile/widgets/common/custom_field.widget.dart';
import 'package:yasm_mobile/widgets/common/custom_text_area.widget.dart';
import 'package:yasm_mobile/widgets/common/loading_icon_button.widget.dart';
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

  late final AuthProvider _authProvider;
  late final TokensService _tokensService;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late UserService _userService;

  bool loading = false;
  bool _notifications = false;
  bool _notificationsLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // Injecting User Service from context.
    this._userService = Provider.of<UserService>(context, listen: false);

    // Initializing the authentication provider.
    this._authProvider = Provider.of<AuthProvider>(context, listen: false);

    this._tokensService = Provider.of<TokensService>(context, listen: false);

    this
        ._tokensService
        .checkNotificationsAvailability()
        .then((bool availability) => setState(() {
              this._notifications = availability;
            }))
        .catchError(
          (error, stackTrace) => log.i(
            "ProfileUpdateTab error",
            error,
            stackTrace,
          ),
        );
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

      setState(() {
        loading = true;
      });

      // Upload the image to firebase and generate a URL.
      String uploadedUrl =
          await uploadImageAndGenerateUrl(imageFile, "profile-pictures");

      // Update the user state
      User user = this._authProvider.getUser()!;
      user.imageUrl = uploadedUrl;

      // Save the updated state.
      this._authProvider.saveUser(user);

      setState(() {
        loading = false;
      });

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

      setState(() {
        loading = true;
      });

      // Upload the image to firebase and generate a URL.
      String uploadedUrl =
          await uploadImageAndGenerateUrl(imageFile, "profile-pictures");

      // Update the user state
      User user = this._authProvider.getUser()!;
      user.imageUrl = uploadedUrl;

      // Save the updated state.
      this._authProvider.saveUser(user);

      setState(() {
        loading = false;
      });

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
        setState(() {
          loading = true;
        });

        try {
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

          setState(() {
            loading = false;
          });

          // Display success snackbar.
          displaySnackBar("Profile updated!", context);
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
    }
    // Handle errors gracefully.
    on ServerException catch (error) {
      setState(() {
        loading = false;
      });
      displaySnackBar(error.message, context);
    } on NotLoggedInException {
      setState(() {
        loading = false;
      });
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
                    OfflineBuilder(
                      connectivityBuilder: (
                        BuildContext context,
                        ConnectivityResult connectivity,
                        Widget _,
                      ) {
                        final bool connected =
                            connectivity != ConnectivityResult.none;
                        return TextButton(
                          onPressed: connected ? this._onUploadImage : null,
                          child: Text(
                            connected ? 'Upload New Image' : 'You are offline',
                            style: TextStyle(
                              fontSize: 15.0,
                            ),
                          ),
                        );
                      },
                      child: SizedBox(),
                    ),
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
                CustomTextArea(
                  textFieldController: this._biographyController,
                  label: "Biography",
                  validators: [
                    RequiredValidator(errorText: "Biography is required"),
                  ],
                  textInputType: TextInputType.multiline,
                ),
                ListTile(
                  leading: Text('Toggle Notifications'),
                  trailing: !this._notificationsLoading
                      ? Switch(
                          value: this._notifications,
                          onChanged: (_) async {
                            setState(() {
                              this._notificationsLoading = true;
                            });
                            await this
                                ._tokensService
                                .toggleReceiveNotifications();
                            bool newValue = await this
                                ._tokensService
                                .checkNotificationsAvailability();

                            setState(() {
                              this._notifications = newValue;
                              this._notificationsLoading = false;
                            });
                          },
                        )
                      : CircularProgressIndicator(),
                ),
                LoadingIconButton(
                  loading: this.loading,
                  iconData: Icons.edit,
                  onPress: this._onFormSubmit,
                  normalText: 'Update Profile',
                  loadingText: 'Updating Profile',
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
