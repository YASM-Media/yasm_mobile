import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:yasm_mobile/dto/user/update_password/update_password.dto.dart';
import 'package:yasm_mobile/exceptions/auth/not_logged_in.exception.dart';
import 'package:yasm_mobile/exceptions/auth/wrong_password.exception.dart';
import 'package:yasm_mobile/exceptions/common/server.exception.dart';
import 'package:yasm_mobile/exceptions/user/weak_password.exception.dart';
import 'package:yasm_mobile/services/user.service.dart';
import 'package:yasm_mobile/utils/display_snackbar.util.dart';
import 'package:yasm_mobile/utils/validators/value_validator.dart';
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

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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
    try {
      if (this._formKey.currentState!.validate()) {
        UpdatePasswordDto updatePasswordDto = new UpdatePasswordDto(
          oldPassword: this._oldPasswordController.text,
          newPassword: this._newPasswordController.text,
        );
        await this._userService.updateUserPassword(updatePasswordDto);

        displaySnackBar("Password updated!", context);
      }
    } on WrongPasswordException catch (error) {
      displaySnackBar(error.message, context);
    } on WeakPasswordException catch (error) {
      displaySnackBar(error.message, context);
    } on NotLoggedInException {
      print("NOT LOGGED IN");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 20.0,
          horizontal: 10.0,
        ),
        child: Form(
          key: this._formKey,
          child: Column(
            children: [
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
                  ),
                ],
                textInputType: TextInputType.visiblePassword,
                obscureText: true,
              ),
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
                textInputType: TextInputType.visiblePassword,
                obscureText: true,
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
                  ),
                  ValueValidator(
                    checkAgainstTextController: this._newPasswordController,
                    errorText: "Passwords don't match",
                  ),
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
        ),
      ),
    );
  }
}
