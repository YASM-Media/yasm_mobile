import 'package:flutter/material.dart';
import 'package:yasm_mobile/dto/auth/login_user/login_user.dto.dart';
import 'package:yasm_mobile/dto/auth/register_user/register_user.dto.dart';
import 'package:yasm_mobile/exceptions/auth/UserAlreadyExists.exception.dart';
import 'package:yasm_mobile/exceptions/auth/UserNotFound.exception.dart';
import 'package:yasm_mobile/exceptions/auth/WrongPassword.exception.dart';
import 'package:yasm_mobile/services/auth.service.dart';

class Auth extends StatefulWidget {
  static const routeName = "/auth";

  const Auth({Key? key}) : super(key: key);

  @override
  _AuthState createState() => _AuthState();
}

class _AuthState extends State<Auth> {
  final AuthService _authService = AuthService();

  Future<void> _tempRegister() async {
    try {
      await _authService.registerUser(RegisterUser.fromJson({
        "firstName": "test",
        "lastName": "test",
        "emailAddress": "test@test.com",
        "password": "test123",
      }));
    } on UserAlreadyExistsException catch (error) {
      print(error.message);
    } catch (error) {
      print("ERROR: $error");
    }
  }

  Future<void> _tempLogin() async {
    try {
      await _authService.login(LoginUser.fromJson({
        "email": "test@test.com",
        "password": "test123",
      }));
    } on UserNotFoundException catch (error) {
      print(error.message);
    } on WrongPasswordException catch (error) {
      print(error.message);
    } catch (error) {
      print("ERROR: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Auth Page'),
            ElevatedButton(
              onPressed: _tempRegister,
              child: Text('Temp Register'),
            ),
            ElevatedButton(
              onPressed: _tempLogin,
              child: Text('Temp Login'),
            ),
          ],
        ),
      ),
    );
  }
}
