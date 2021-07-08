import 'package:flutter/material.dart';
import 'package:yasm_mobile/dto/auth/login_user/login_user.dto.dart';
import 'package:yasm_mobile/dto/auth/register_user/register_user.dto.dart';
import 'package:yasm_mobile/exceptions/auth/UserAlreadyExists.exception.dart';
import 'package:yasm_mobile/exceptions/auth/UserNotFound.exception.dart';
import 'package:yasm_mobile/exceptions/auth/WrongPassword.exception.dart';
import 'package:yasm_mobile/pages/home.page.dart';
import 'package:yasm_mobile/services/auth.service.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:yasm_mobile/widgets/common/custom_field.widget.dart';

enum AuthFormType {
  Register,
  Login,
  ForgotPassword,
}

class Auth extends StatefulWidget {
  static const routeName = "/auth";

  const Auth({Key? key}) : super(key: key);

  @override
  _AuthState createState() => _AuthState();
}

class _AuthState extends State<Auth> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  AuthFormType _authFormType = AuthFormType.Login;

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailAddressController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    super.dispose();

    this._firstNameController.dispose();
    this._lastNameController.dispose();
    this._emailAddressController.dispose();
    this._passwordController.dispose();
  }

  void _displaySnackBar(String message) {
    final snackBar = SnackBar(
      backgroundColor: Colors.black54,
      content: Text(
        message,
        style: TextStyle(
          color: Colors.white,
        ),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> _onFormSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_authFormType == AuthFormType.Register) {
      try {
        await _authService.registerUser(RegisterUser.fromJson({
          "firstName": _firstNameController.text,
          "lastName": _lastNameController.text,
          "emailAddress": _emailAddressController.text,
          "password": _passwordController.text,
        }));

        _switchAuthState(AuthFormType.Login);
        _displaySnackBar(
          "Registration success!!🌟 Now you can "
          "login here with your credentials!",
        );
      } on UserAlreadyExistsException catch (error) {
        _displaySnackBar(error.message);
      } catch (error) {
        _displaySnackBar("Something went wrong on our side! Please try again");
      }
    } else if (_authFormType == AuthFormType.Login) {
      try {
        await _authService.login(LoginUser.fromJson({
          "email": _emailAddressController.text,
          "password": _passwordController.text,
        }));

        Navigator.of(context).pushReplacementNamed(Home.routeName);
      } on UserNotFoundException catch (error) {
        _displaySnackBar(error.message);
      } on WrongPasswordException catch (error) {
        _displaySnackBar(error.message);
      } catch (error) {
        _displaySnackBar("Something went wrong on our side! Please try again");
      }
    } else {
      try {
        await _authService.sendPasswordResetMail(_emailAddressController.text);
        _displaySnackBar(
            "A mail containing the link to reset your password has been sent.");
      } on UserNotFoundException catch (error) {
        _displaySnackBar(error.message);
      } catch (error) {
        _displaySnackBar("Something went wrong on our side! Please try again");
      }
    }
  }

  void _switchAuthState(AuthFormType authFormType) {
    setState(() {
      _authFormType = authFormType;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.all(30.0),
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.all(20.0),
                      child: Image.asset(
                        'assets/logo/logo_1024.png',
                        scale: 8.0,
                      ),
                    ),
                    Text(
                      _authFormType == AuthFormType.Register
                          ? 'Register an account'
                          : _authFormType == AuthFormType.Login
                              ? "Log in to your account"
                              : "Reset your password",
                      style: TextStyle(
                        fontSize: 30.0,
                      ),
                    ),
                  ],
                ),
              ),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    if (_authFormType == AuthFormType.Register)
                      CustomField(
                        textFieldController: this._firstNameController,
                        label: "First Name",
                        validators: <FieldValidator>[
                          RequiredValidator(
                            errorText: "Please enter your first name",
                          ),
                        ],
                      ),
                    if (_authFormType == AuthFormType.Register)
                      CustomField(
                        textFieldController: this._lastNameController,
                        label: "Last Name",
                        validators: <FieldValidator>[
                          RequiredValidator(
                            errorText: "Please enter your last name",
                          ),
                        ],
                      ),
                    CustomField(
                      textFieldController: this._emailAddressController,
                      label: "Email Address",
                      validators: <FieldValidator>[
                        RequiredValidator(
                          errorText: "Please enter your email address",
                        ),
                        EmailValidator(
                          errorText: "Please enter a valid email address.",
                        )
                      ],
                    ),
                    if (_authFormType != AuthFormType.ForgotPassword)
                      CustomField(
                        textFieldController: this._passwordController,
                        obscureText: true,
                        label: "Your Password",
                        validators: <FieldValidator>[
                          RequiredValidator(
                            errorText: "Please enter your password",
                          ),
                          MinLengthValidator(
                            5,
                            errorText:
                                "Minimum password length is 5 characters.",
                          )
                        ],
                      ),
                  ],
                ),
              ),
              if (_authFormType == AuthFormType.Login ||
                  _authFormType == AuthFormType.Register)
                ElevatedButton(
                  onPressed: _onFormSubmit,
                  child: Text(
                    _authFormType == AuthFormType.Register
                        ? 'Register'
                        : 'Login',
                  ),
                ),
              if (_authFormType == AuthFormType.ForgotPassword)
                ElevatedButton(
                  onPressed: _onFormSubmit,
                  child: Text("Send Password Reset Mail"),
                ),
              if (_authFormType == AuthFormType.Login ||
                  _authFormType == AuthFormType.Register)
                TextButton(
                  onPressed: () {
                    if (_authFormType == AuthFormType.Login) {
                      _switchAuthState(AuthFormType.Register);
                    } else if (_authFormType == AuthFormType.Register) {
                      _switchAuthState(AuthFormType.Login);
                    }
                  },
                  child: Text(
                    _authFormType == AuthFormType.Register
                        ? 'Log in to your account here!'
                        : 'Create an account here!',
                  ),
                ),
              if (_authFormType == AuthFormType.ForgotPassword)
                TextButton(
                  onPressed: () {
                    _switchAuthState(AuthFormType.Login);
                  },
                  child: Text(
                    "Have an account?",
                  ),
                ),
              if (_authFormType == AuthFormType.Login)
                TextButton(
                  onPressed: () {
                    _switchAuthState(AuthFormType.ForgotPassword);
                  },
                  child: Text('Forgot Password?'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
