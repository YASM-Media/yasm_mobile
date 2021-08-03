import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:provider/provider.dart';
import 'package:yasm_mobile/models/user/user.model.dart';
import 'package:yasm_mobile/providers/auth/auth.provider.dart';
import 'package:yasm_mobile/services/user.service.dart';
import 'package:yasm_mobile/widgets/common/custom_field.widget.dart';

class ProfileUpdateTab extends StatefulWidget {
  const ProfileUpdateTab({Key? key}) : super(key: key);

  @override
  _ProfileUpdateTabState createState() => _ProfileUpdateTabState();
}

class _ProfileUpdateTabState extends State<ProfileUpdateTab> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _biographyController;

  late String _imageUrl;

  final GlobalKey<FormState> _formKey = GlobalKey();

  final UserService _userService = new UserService();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    User user = Provider.of<AuthProvider>(context, listen: false).getUser()!;

    this._imageUrl = user.imageUrl;

    this._firstNameController = TextEditingController.fromValue(
      TextEditingValue(
        text: user.firstName,
      ),
    );

    this._lastNameController = TextEditingController.fromValue(
      TextEditingValue(
        text: user.lastName,
      ),
    );

    this._biographyController = TextEditingController.fromValue(
      TextEditingValue(
        text: user.biography,
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

    this._firstNameController.dispose();
    this._lastNameController.dispose();
    this._biographyController.dispose();
  }

  Future<void> _onFormSubmit() async {
    try {} catch (error) {}
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: this._formKey,
      child: Column(
        children: [
          Column(
            children: [
              CircleAvatar(
                child: this._imageUrl.length == 0
                    ? Icon(
                        Icons.person,
                        size: 100.0,
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(100.0),
                        child: Image.network(
                          this._imageUrl,
                          height: 200.0,
                          width: 200.0,
                        ),
                      ),
                radius: 100.0,
              ),
              TextButton(
                onPressed: () {},
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
    );
  }
}
