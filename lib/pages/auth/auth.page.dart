import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:provider/provider.dart';
import 'package:yasm_mobile/constants/logger.constant.dart';
import 'package:yasm_mobile/dto/auth/login_user/login_user.dto.dart';
import 'package:yasm_mobile/dto/auth/register_user/register_user.dto.dart';
import 'package:yasm_mobile/exceptions/auth/user_not_found.exception.dart';
import 'package:yasm_mobile/exceptions/auth/wrong_password.exception.dart';
import 'package:yasm_mobile/exceptions/common/general.exception.dart';
import 'package:yasm_mobile/exceptions/common/server.exception.dart';
import 'package:yasm_mobile/models/user/user.model.dart';
import 'package:yasm_mobile/pages/home.page.dart';
import 'package:yasm_mobile/providers/auth/auth.provider.dart';
import 'package:yasm_mobile/services/auth.service.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:yasm_mobile/utils/display_snackbar.util.dart';
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
  late AuthService _authService;
  final _formKey = GlobalKey<FormState>();

  AuthFormType _authFormType = AuthFormType.Login;

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailAddressController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    this._authService = Provider.of<AuthService>(context, listen: false);
  }

  @override
  void dispose() {
    super.dispose();

    this._firstNameController.dispose();
    this._lastNameController.dispose();
    this._emailAddressController.dispose();
    this._passwordController.dispose();
  }

  /*
   * Method to handle form submission.
   */
  Future<void> _onFormSubmit() async {
    // Check for form validation.
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // CASE 1: Submitting details for registering a user.
    if (_authFormType == AuthFormType.Register) {
      try {
        // Send user details.
        await _authService.registerUser(RegisterUser.fromJson({
          "firstName": _firstNameController.text,
          "lastName": _lastNameController.text,
          "emailAddress": _emailAddressController.text,
          "password": _passwordController.text,
        }));

        // Switch form state to login.
        _switchAuthState(AuthFormType.Login);

        // Display form submission success.
        displaySnackBar(
          "Registration success!!🌟 Now you can "
          "login here with your credentials!",
          context,
        );
      }
      // Handle errors gracefully.
      on ServerException catch (error) {
        displaySnackBar(error.message, context);
      } catch (error, stackTrace) {
        log.e(error, error, stackTrace);
        displaySnackBar(
          "Something went wrong on our side! Please try again",
          context,
        );
      }
    }
    // CASE 2: Submitting details for logging a user in.
    else if (_authFormType == AuthFormType.Login) {
      try {
        // Send login details.
        User user = await _authService.login(LoginUser.fromJson({
          "email": _emailAddressController.text,
          "password": _passwordController.text,
        }));
        // Save user details in provider.
        Provider.of<AuthProvider>(context, listen: false).saveUser(user);

        // Navigate to home page.
        Navigator.of(context).pushReplacementNamed(Home.routeName);
      }
      // Handle errors gracefully.
      on UserNotFoundException catch (error) {
        displaySnackBar(
          error.message,
          context,
        );
      } on WrongPasswordException catch (error) {
        displaySnackBar(
          error.message,
          context,
        );
      } on ServerException catch (error) {
        displaySnackBar(
          error.message,
          context,
        );
      } on GeneralException catch (error) {
        displaySnackBar(
          error.message,
          context,
        );
      } catch (error, stackTrace) {
        log.e(error, error, stackTrace);
        displaySnackBar(
          "Something went wrong on our side! Please try again",
          context,
        );
      }
    }
    // CASE 3: Submitting details for sending password reset mail.
    else {
      try {
        await _authService.sendPasswordResetMail(_emailAddressController.text);
        displaySnackBar(
          "A mail containing the link to reset your password has been sent.",
          context,
        );
      }
      // Handle errors gracefully.
      on UserNotFoundException catch (error) {
        displaySnackBar(
          error.message,
          context,
        );
      } on GeneralException catch (error) {
        displaySnackBar(
          error.message,
          context,
        );
      } catch (error, stackTrace) {
        log.e(error, error, stackTrace);
        displaySnackBar(
          "Something went wrong on our side! Please try again",
          context,
        );
      }
    }
  }

  /*
   * Method to handle form state changes.
   */
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
                        'assets/logo/logo_text_1024.png',
                        scale: 6.0,
                      ),
                    ),
                    Text(
                      _authFormType == AuthFormType.Register
                          ? 'Register an account'
                          : _authFormType == AuthFormType.Login
                              ? "Log in to your account"
                              : "Reset your password",
                      textAlign: TextAlign.center,
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
                        textInputType: TextInputType.text,
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
                        textInputType: TextInputType.text,
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
                      textInputType: TextInputType.emailAddress,
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
                        textInputType: TextInputType.visiblePassword,
                      ),
                  ],
                ),
              ),
              if (_authFormType == AuthFormType.Login ||
                  _authFormType == AuthFormType.Register)
                OfflineBuilder(
                  connectivityBuilder: (
                    BuildContext context,
                    ConnectivityResult connectivity,
                    Widget _,
                  ) {
                    final bool connected =
                        connectivity != ConnectivityResult.none;

                    return connected
                        ? ElevatedButton(
                            onPressed: _onFormSubmit,
                            child: Text(
                              _authFormType == AuthFormType.Register
                                  ? 'Register'
                                  : 'Login',
                            ),
                          )
                        : ElevatedButton(
                            onPressed: null,
                            child: Text('You are offline'),
                          );
                  },
                  child: SizedBox(),
                ),
              if (_authFormType == AuthFormType.ForgotPassword)
                OfflineBuilder(
                  connectivityBuilder: (
                    BuildContext context,
                    ConnectivityResult connectivity,
                    Widget _,
                  ) {
                    final bool connected =
                        connectivity != ConnectivityResult.none;

                    return ElevatedButton(
                      onPressed: connected ? _onFormSubmit : null,
                      child: Text(connected
                          ? "Send Password Reset Mail"
                          : "You are offline"),
                    );
                  },
                  child: SizedBox(),
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
