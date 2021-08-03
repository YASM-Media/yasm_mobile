import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:yasm_mobile/services/user.service.dart';
import 'package:yasm_mobile/widgets/common/custom_field.widget.dart';

class PasswordUpdateTab extends StatefulWidget {
  const PasswordUpdateTab({Key? key}) : super(key: key);

  @override
  _PasswordUpdateTabState createState() => _PasswordUpdateTabState();
}

class _PasswordUpdateTabState extends State<PasswordUpdateTab> {
  TextEditingController _newPasswordController = new TextEditingController();
  TextEditingController _newPasswordAgainController =
      new TextEditingController();
  TextEditingController _oldPasswordController = new TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey();

  final UserService _userService = new UserService();

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

    this._newPasswordController.dispose();
    this._newPasswordAgainController.dispose();
    this._oldPasswordController.dispose();
  }

  Future<void> _onFormSubmit() async {
    try {} catch (error) {}
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: [
          CustomField(
            textFieldController: this._newPasswordController,
            label: "New Password",
            validators: [
              RequiredValidator(
                errorText: "Please enter your new password.",
              ),
              MinLengthValidator(
                5,
                errorText:
                    "Your new password should be at least 5 characters long.",
              )
            ],
            textInputType: TextInputType.emailAddress,
          ),
          CustomField(
            textFieldController: this._newPasswordAgainController,
            label: "New Password Again",
            validators: [
              RequiredValidator(
                errorText: "Please enter your new password.",
              ),
              MinLengthValidator(
                5,
                errorText:
                    "Your new password should be at least 5 characters long.",
              )
            ],
            textInputType: TextInputType.visiblePassword,
            obscureText: true,
          ),
          CustomField(
            textFieldController: this._oldPasswordController,
            label: "Old Password",
            validators: [
              RequiredValidator(
                errorText: "Please enter your old password.",
              ),
              MinLengthValidator(
                5,
                errorText:
                    "Your old password should be at least 5 characters long.",
              )
            ],
            textInputType: TextInputType.visiblePassword,
            obscureText: true,
          ),
          ElevatedButton(
            onPressed: this._onFormSubmit,
            child: Text('Update Password'),
          )
        ],
      ),
    );
  }
}
