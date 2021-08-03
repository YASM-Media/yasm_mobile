import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:provider/provider.dart';
import 'package:yasm_mobile/models/user/user.model.dart';
import 'package:yasm_mobile/providers/auth/auth.provider.dart';
import 'package:yasm_mobile/services/user.service.dart';
import 'package:yasm_mobile/widgets/common/custom_field.widget.dart';

class EmailUpdateTab extends StatefulWidget {
  const EmailUpdateTab({Key? key}) : super(key: key);

  @override
  _EmailUpdateTabState createState() => _EmailUpdateTabState();
}

class _EmailUpdateTabState extends State<EmailUpdateTab> {
  late TextEditingController _emailController;
  TextEditingController _passwordController = new TextEditingController();
  TextEditingController _passwordAgainController = new TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey();

  final UserService _userService = new UserService();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    User user = Provider.of<AuthProvider>(context, listen: false).getUser()!;

    this._emailController = TextEditingController.fromValue(
      TextEditingValue(
        text: user.emailAddress,
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

    this._emailController.dispose();
    this._passwordController.dispose();
    this._passwordAgainController.dispose();
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
          CustomField(
            textFieldController: this._passwordAgainController,
            label: "Password Again",
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
  }
}
