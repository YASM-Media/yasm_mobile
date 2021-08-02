import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart' as FA;
import 'package:http/http.dart' as http;
import 'package:yasm_mobile/constants/endpoint.constant.dart';
import 'package:yasm_mobile/dto/user/update_email/update_email.dto.dart';
import 'package:yasm_mobile/dto/user/update_password/update_password.dto.dart';
import 'package:yasm_mobile/dto/user/update_profile/update_profile.dto.dart';
import 'package:yasm_mobile/exceptions/auth/not_logged_in.exception.dart';
import 'package:yasm_mobile/exceptions/auth/wrong_password.exception.dart';
import 'package:yasm_mobile/exceptions/common/server.exception.dart';
import 'package:yasm_mobile/exceptions/user/weak_password.exception.dart';

/*
 * Service implementation for user features.
 */
class UserService {
  final FA.FirebaseAuth _firebaseAuth = FA.FirebaseAuth.instance;

  /*
   * Update user profile such as name and profile picture.
   * @param updateProfileDto DTO for profile update.
   */
  Future<void> updateUserProfile(UpdateProfileDto updateProfileDto) async {
    // Fetching the currently logged in user.
    FA.User? loggedInUser = this._firebaseAuth.currentUser;

    // Check if user is null
    if (loggedInUser != null) {
      // Preparing the URL for the server request.
      Uri uri = Uri.parse("$endpoint/user/update/profile");

      // Fetching the ID token for authentication.
      String firebaseAuthToken = await loggedInUser.getIdToken();

      // Preparing the headers for the request.
      Map<String, String> headers = {
        "Authorization": "Bearer $firebaseAuthToken",
        "Content-Type": "application/json",
      };

      // Preparing the body for the request
      String body = json.encode(updateProfileDto.toJson());

      // POSTing to the server with updated profile details.
      http.Response response = await http.post(
        uri,
        headers: headers,
        body: body,
      );

      // Checking for errors.
      if (response.statusCode != 200) {
        // Decode the response and throw an exception.
        Map<String, dynamic> body = json.decode(response.body);
        throw ServerException(message: body["message"]);
      }
    } else {
      // If there is no user logged is using firebase, throw an exception.
      throw NotLoggedInException(message: "User not logged in.");
    }
  }

  /*
   * Update email address for the given user.
   * @param updateEmailDto DTO for email address update.
   */
  Future<void> updateUserEmailAddress(UpdateEmailDto updateEmailDto) async {
    // Fetching the currently logged in user.
    FA.User? loggedInUser = this._firebaseAuth.currentUser;

    // Check if user is null
    if (loggedInUser != null) {
      // Preparing the URL for the server request.
      Uri uri = Uri.parse("$endpoint/user/update/email");

      // Fetching the ID token for authentication.
      String firebaseAuthToken = await loggedInUser.getIdToken();

      // Preparing the headers for the request.
      Map<String, String> headers = {
        "Authorization": "Bearer $firebaseAuthToken",
        "Content-Type": "application/json",
      };

      // Preparing the body for the request
      String body = json.encode(updateEmailDto.toJson());

      // POSTing to the server with updated profile details.
      http.Response response = await http.post(
        uri,
        headers: headers,
        body: body,
      );

      // Checking for errors.
      if (response.statusCode != 200) {
        // Decode the response and throw an exception.
        Map<String, dynamic> body = json.decode(response.body);
        throw ServerException(message: body["message"]);
      }
    } else {
      // If there is no user logged is using firebase, throw an exception.
      throw NotLoggedInException(message: "User not logged in.");
    }
  }

  /*
   * Update password for the given user.
   * @param updateEmailDto DTO for password update.
   */
  Future<void> updateUserPassword(UpdatePasswordDto updatePasswordDto) async {
    // Fetch the currently logged in user.
    FA.User? loggedInUser = this._firebaseAuth.currentUser;

    // Check is the user exists.
    if (loggedInUser != null) {
      try {
        // Get the email address for the currently logged in user.
        String currentUserEmailAddress = loggedInUser.email!;

        // Prepare the auth credentials for re-authentication.
        FA.AuthCredential authCredential = FA.EmailAuthProvider.credential(
          email: currentUserEmailAddress,
          password: updatePasswordDto.oldPassword,
        );

        // Re-authenticate the user with credential.
        await loggedInUser.reauthenticateWithCredential(authCredential);

        // Update password for the user.
        await loggedInUser.updatePassword(updatePasswordDto.newPassword);
      } on FA.FirebaseAuthException catch (error) {
        // Firebase Error: If the user has typed a weak password.
        if (error.code == "weak-password") {
          throw WeakPasswordException(message: "Password provided is weak.");
        }

        // Firebase Error: If the user has typed the wrong password.
        else if (error.code == 'wrong-password') {
          throw WrongPasswordException(
            message: 'Wrong password provided for the specified user account.',
          );
        }
      }
    } else {
      // If there is no user logged is using firebase, throw an exception.
      throw NotLoggedInException(message: "User not logged in.");
    }
  }
}
