import 'package:flutter/material.dart';
import 'package:yasm_mobile/dto/auth/login_user/login_user.dto.dart';
import 'package:yasm_mobile/dto/auth/register_user/register_user.dto.dart';
import 'package:yasm_mobile/exceptions/auth/UserAlreadyExists.exception.dart';
import 'package:yasm_mobile/exceptions/auth/UserNotFound.exception.dart';
import 'package:yasm_mobile/exceptions/auth/WrongPassword.exception.dart';
import 'package:yasm_mobile/pages/home.page.dart';
import 'package:yasm_mobile/services/auth.service.dart';
import 'package:form_field_validator/form_field_validator.dart';

enum AuthFormType {
  Register,
  Login,
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
  void initState() {
    // TODO: implement initState
    super.initState();
  }

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

        _switchAuthState();
        _displaySnackBar(
          "Registration success!!🌟 Now you can "
          "login here with your credentials!",
        );
      } on UserAlreadyExistsException catch (error) {
        _displaySnackBar(error.message);
      } catch (error) {
        _displaySnackBar("Something went wrong on our side! Please try again");
      }
    } else {
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
    }
  }

  void _switchAuthState() {
    setState(() {
      if (_authFormType == AuthFormType.Register) {
        _authFormType = AuthFormType.Login;
      } else {
        _authFormType = AuthFormType.Register;
      }
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
                          ? 'Register Here!!🌟'
                          : 'Login Here!! 🌟',
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
                      Container(
                        margin: EdgeInsets.symmetric(
                          vertical: 10.0,
                          horizontal: 10.0,
                        ),
                        child: TextFormField(
                          keyboardType: TextInputType.text,
                          decoration: const InputDecoration(
                            labelText: "First Name",
                            border: OutlineInputBorder(
                              borderSide: BorderSide(),
                            ),
                          ),
                          controller: this._firstNameController,
                          validator: RequiredValidator(
                            errorText: "Please enter your first name",
                          ),
                        ),
                      ),
                    if (_authFormType == AuthFormType.Register)
                      Container(
                        margin: EdgeInsets.symmetric(
                          vertical: 10.0,
                          horizontal: 10.0,
                        ),
                        child: TextFormField(
                          keyboardType: TextInputType.text,
                          decoration: const InputDecoration(
                            labelText: "Last Name",
                            border: OutlineInputBorder(
                              borderSide: BorderSide(),
                            ),
                          ),
                          controller: this._lastNameController,
                          validator: RequiredValidator(
                            errorText: "Please enter your last name",
                          ),
                        ),
                      ),
                    Container(
                      margin: EdgeInsets.symmetric(
                        vertical: 10.0,
                        horizontal: 10.0,
                      ),
                      child: TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: "Email Address",
                          border: OutlineInputBorder(
                            borderSide: BorderSide(),
                          ),
                        ),
                        controller: this._emailAddressController,
                        validator: MultiValidator([
                          RequiredValidator(
                            errorText: "Please enter your email address",
                          ),
                          EmailValidator(
                            errorText: "Please enter a valid email address.",
                          )
                        ]),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(
                        vertical: 10.0,
                        horizontal: 10.0,
                      ),
                      child: TextFormField(
                        obscureText: true,
                        keyboardType: TextInputType.visiblePassword,
                        decoration: const InputDecoration(
                          labelText: "Your Password",
                          border: OutlineInputBorder(
                            borderSide: BorderSide(),
                          ),
                        ),
                        controller: this._passwordController,
                        validator: MultiValidator([
                          RequiredValidator(
                            errorText: "Please enter your password",
                          ),
                          MinLengthValidator(
                            5,
                            errorText:
                                "Minimum password length is 5 characters.",
                          )
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: _onFormSubmit,
                child: Text(
                  _authFormType == AuthFormType.Register
                      ? 'Register!!🌟'
                      : 'Login!! 🌟',
                ),
              ),
              ElevatedButton(
                onPressed: _switchAuthState,
                child: Text(
                  _authFormType == AuthFormType.Register
                      ? 'Switch to login mode!!🌟'
                      : 'Switch to register mode!! 🌟',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
