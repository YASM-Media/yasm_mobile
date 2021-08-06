import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:provider/provider.dart';
import 'package:yasm_mobile/exceptions/auth/not_logged_in.exception.dart';
import 'package:yasm_mobile/exceptions/common/server.exception.dart';
import 'package:yasm_mobile/pages/auth/auth.page.dart';
import 'package:yasm_mobile/providers/auth/auth.provider.dart';
import 'package:yasm_mobile/services/user.service.dart';
import 'package:yasm_mobile/utils/display_snackbar.util.dart';
import 'package:yasm_mobile/widgets/common/custom_field.widget.dart';

class DeleteAccountTab extends StatefulWidget {
  const DeleteAccountTab({Key? key}) : super(key: key);

  @override
  _DeleteAccountTabState createState() => _DeleteAccountTabState();
}

class _DeleteAccountTabState extends State<DeleteAccountTab> {
  TextEditingController _passwordController = new TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final UserService _userService = new UserService();

  late AuthProvider _authProvider;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // Initializing the authentication provider.
    this._authProvider = Provider.of<AuthProvider>(context, listen: false);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

    // Dispose off the controller.
    this._passwordController.dispose();
  }

  /*
   * Form submission method for user delete.
   */
  Future<void> _onFormSubmit() async {
    try {
      // Validate the form.
      if (this._formKey.currentState!.validate()) {
        // Delete the account from the server.
        await this
            ._userService
            .deleteUserAccount(this._passwordController.text);

        // Clear off the provider state.
        this._authProvider.removeUser();

        // Log out to the authentication page.
        Navigator.of(context).pushReplacementNamed(Auth.routeName);
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
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 20.0,
          horizontal: 10.0,
        ),
        child: Form(
          key: this._formKey,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(text: 'Please note that deleting your account '),
                      TextSpan(
                        text: 'deletes all of your data from YASM. ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text:
                            'This action is irreversible and no data is recoverable after deleting your account.',
                      ),
                    ],
                  ),
                ),
              ),
              CustomField(
                textFieldController: this._passwordController,
                label: "Password",
                validators: [
                  RequiredValidator(
                    errorText: "Please enter your password.",
                  ),
                  MinLengthValidator(
                    5,
                    errorText:
                        "Your password should be at least 5 characters long.",
                  )
                ],
                textInputType: TextInputType.visiblePassword,
                obscureText: true,
              ),
              ElevatedButton(
                onPressed: this._onFormSubmit,
                child: Text('Delete Account'),
              )
            ],
          ),
        ),
      ),
    );
  }
}