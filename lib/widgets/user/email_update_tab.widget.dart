import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:provider/provider.dart';
import 'package:yasm_mobile/constants/logger.constant.dart';
import 'package:yasm_mobile/dto/user/update_email/update_email.dto.dart';
import 'package:yasm_mobile/exceptions/auth/not_logged_in.exception.dart';
import 'package:yasm_mobile/exceptions/auth/user_already_exists.exception.dart';
import 'package:yasm_mobile/exceptions/auth/wrong_password.exception.dart';
import 'package:yasm_mobile/exceptions/common/server.exception.dart';
import 'package:yasm_mobile/models/user/user.model.dart';
import 'package:yasm_mobile/providers/auth/auth.provider.dart';
import 'package:yasm_mobile/services/user.service.dart';
import 'package:yasm_mobile/utils/display_snackbar.util.dart';
import 'package:yasm_mobile/widgets/common/custom_field.widget.dart';

class EmailUpdateTab extends StatefulWidget {
  const EmailUpdateTab({Key? key}) : super(key: key);

  @override
  _EmailUpdateTabState createState() => _EmailUpdateTabState();
}

class _EmailUpdateTabState extends State<EmailUpdateTab> {
  TextEditingController _emailController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();

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

    // Dispose off the controllers.
    this._emailController.dispose();
    this._passwordController.dispose();
  }

  /*
   * Form submission method for user email update.
   */
  Future<void> _onFormSubmit() async {
    // Validate the form.
    if (this._formKey.currentState!.validate()) {
      try {
        // Prepare DTO for updating password.
        UpdateEmailDto updateEmailDto = new UpdateEmailDto(
          emailAddress: this._emailController.text,
          password: this._passwordController.text,
        );

        // Update it on server and also update the state as well.
        User user = await this._userService.updateUserEmailAddress(
              updateEmailDto,
              this._authProvider.getUser()!,
            );

        this._authProvider.saveUser(user);

        // Display success snackbar.
        displaySnackBar("Email updated!", context);
      } on ServerException catch (error) {
        displaySnackBar(
          error.message,
          context,
        );
      } on NotLoggedInException catch (error) {
        displaySnackBar(
          error.message,
          context,
        );
      } catch (error, stackTrace) {
        log.e(error, error, stackTrace);

        displaySnackBar(
          "Something went wrong, please try again later.",
          context,
        );
      }
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
        child: Consumer<AuthProvider>(
          builder: (context, state, child) {
            User? user = state.getUser();
            this._emailController.text = user != null ? user.emailAddress : '';
            return Form(
              key: this._formKey,
              child: Column(
                children: [
                  CustomField(
                    textFieldController: this._emailController,
                    label: "Email Address",
                    validators: [
                      RequiredValidator(
                        errorText: "Please enter your email address.",
                      ),
                      EmailValidator(
                        errorText: "Please enter a valid email address.",
                      ),
                    ],
                    textInputType: TextInputType.emailAddress,
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
                    child: Text('Update Email Address'),
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
