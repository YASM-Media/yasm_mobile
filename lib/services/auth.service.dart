import 'dart:convert';
import 'dart:io';

import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:yasm_mobile/constants/endpoint.constant.dart';
import 'package:firebase_auth/firebase_auth.dart' as FA;
import 'package:yasm_mobile/dto/auth/login_user/login_user.dto.dart';
import 'package:yasm_mobile/dto/auth/register_user/register_user.dto.dart';
import 'package:yasm_mobile/exceptions/auth/not_logged_in.exception.dart';
import 'package:yasm_mobile/exceptions/auth/user_already_exists.exception.dart';
import 'package:yasm_mobile/exceptions/auth/user_not_found.exception.dart';
import 'package:yasm_mobile/exceptions/auth/wrong_password.exception.dart';
import 'package:yasm_mobile/exceptions/common/server.exception.dart';
import 'package:yasm_mobile/models/user/user.model.dart';

/*
 * Service implementation for authentication.
 */
class AuthService {
  final FA.FirebaseAuth _firebaseAuth = FA.FirebaseAuth.instance;
  final Box<User> _yasmUserDb = Hive.box<User>("yasm-user");

  final Logger log = new Logger(
    printer: new PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 10,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );

  /*
   * Method for fetching the user from server using firebase id token.
   */
  Future<User> getLoggedInUser() async {
    try {
      // Get the logged in user details.
      FA.User? firebaseUser = this._firebaseAuth.currentUser;

      // Check if user is not null.
      if (firebaseUser == null) {
        // If there is no user logged is using firebase, throw an exception.
        throw NotLoggedInException(message: "User not logged in.");
      }
      // Fetch the ID token for the user.
      String firebaseAuthToken =
          await this._firebaseAuth.currentUser!.getIdToken(true);

      // Prepare URL and the auth header.
      Uri url = Uri.parse("$ENDPOINT/follow-api/get");
      Map<String, String> headers = {
        "Authorization": "Bearer $firebaseAuthToken",
      };

      // Fetch user details from the server
      http.Response response = await http.get(
        url,
        headers: headers,
      );

      // Check if the response does not contain any error.
      if (response.statusCode >= 400 && response.statusCode < 500) {
        Map<String, dynamic> body = json.decode(response.body);
        throw ServerException(message: body['message']);
      } else if (response.statusCode >= 500) {
        throw ServerException(
          message: 'Something went wrong, please try again later.',
        );
      }

      // Decode the JSON object and build the user object from JSON.
      Map<String, dynamic> body = json.decode(response.body);
      User loggedInUser = User.fromJson(body);

      log.i("Saving user to Hive DB");
      this._yasmUserDb.put("logged-in-user", loggedInUser);
      log.i("Saved user to Hive DB");

      // Return the user details.
      return loggedInUser;
    } on SocketException {
      User? loggedInUser = this.fetchOfflineUser();
      if (loggedInUser == null) {
        throw NotLoggedInException(message: "User not logged in.");
      } else {
        return loggedInUser;
      }
    }
  }

  User? fetchOfflineUser() {
    log.i("Fetching user from Hive DB");
    return this._yasmUserDb.get("logged-in-user");
  }

  /*
   * Method to register user details to the server.
   * @param registerUser DTO for user registration
   */
  Future<void> registerUser(RegisterUser registerUser) async {
    // Prepare URL and the content type header.
    Uri url = Uri.parse("$ENDPOINT/auth/register");
    Map<String, String> headers = {
      "Content-Type": "application/json",
    };

    // Send details to server for user registration.
    http.Response response = await http.post(
      url,
      headers: headers,
      body: json.encode(registerUser.toJson()),
    );

    // Check for errors and then throw an error.
    if (response.statusCode == 422) {
      // Get the server response decoded from JSON form.
      Map<String, dynamic> body = json.decode(response.body);
      throw UserAlreadyExistsException(message: body["message"]);
    }
  }

  /*
   * Method to log the user in the application.
   * @param loginUser DTO for user login
   */
  Future<User?> login(LoginUser loginUser) async {
    try {
      // Log the user in with firebase using their credentials.
      await _firebaseAuth.signInWithEmailAndPassword(
        email: loginUser.email,
        password: loginUser.password,
      );

      // Return the user details from server.
      return await this.getLoggedInUser();
    } on FA.FirebaseAuthException catch (error) {
      // Firebase Error: If the user does not exist.
      if (error.code == 'user-not-found') {
        throw UserNotFoundException(
          message: 'No user found for that email.',
        );
      }
      // Firebase Error: If the user has typed the wrong password.
      else if (error.code == 'wrong-password') {
        throw WrongPasswordException(
          message: 'Wrong password provided for the specified user account.',
        );
      }
    }
  }

  /*
   * Method to send a password reset link to the given mail address.
   * @param emailAddress Email address potentially linked to an account.
   */
  Future<void> sendPasswordResetMail(String emailAddress) async {
    try {
      // Send the password reset mail for the given mail address.
      await _firebaseAuth.sendPasswordResetEmail(email: emailAddress);
    } on FA.FirebaseAuthException catch (error) {
      // If the user does not have an account, throw an error.
      if (error.code == 'user-not-found') {
        throw UserNotFoundException(
          message: 'No user found for that email.',
        );
      }
    }
  }

  /*
   * Logout from the application.
   */
  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
    } catch (error) {
      print(error);
    }
  }
}
