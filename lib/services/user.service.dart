import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart' as FA;
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:yasm_mobile/constants/endpoint.constant.dart';
import 'package:yasm_mobile/constants/hive_names.constant.dart';
import 'package:yasm_mobile/constants/logger.constant.dart';
import 'package:yasm_mobile/dto/user/update_email/update_email.dto.dart';
import 'package:yasm_mobile/dto/user/update_password/update_password.dto.dart';
import 'package:yasm_mobile/dto/user/update_profile/update_profile.dto.dart';
import 'package:yasm_mobile/exceptions/auth/not_logged_in.exception.dart';
import 'package:yasm_mobile/exceptions/auth/user_already_exists.exception.dart';
import 'package:yasm_mobile/exceptions/auth/wrong_password.exception.dart';
import 'package:yasm_mobile/exceptions/common/general.exception.dart';
import 'package:yasm_mobile/exceptions/common/server.exception.dart';
import 'package:yasm_mobile/exceptions/user/weak_password.exception.dart';
import 'package:yasm_mobile/models/user/user.model.dart';

/*
 * Service implementation for user features.
 */
class UserService {
  final FA.FirebaseAuth _firebaseAuth = FA.FirebaseAuth.instance;
  final Box<User> _yasmUserDb = Hive.box<User>("yasm-user");

  /*
   * Method for fetching the user from server using firebase id token.
   */
  Future<User> getUser(String userId) async {
    try {
      // Get the logged in user details.
      FA.User? firebaseUser = this._firebaseAuth.currentUser;

      // Check if user is not null.
      if (firebaseUser == null) {
        throw NotLoggedInException(message: "User not logged in.");
      }
      // Fetch the ID token for the user.
      String firebaseAuthToken =
          await this._firebaseAuth.currentUser!.getIdToken(true);

      // Prepare URL and the auth header.
      Uri url = Uri.parse("$ENDPOINT/follow-api/get/$userId");
      Map<String, String> headers = {
        "Authorization": "Bearer $firebaseAuthToken",
      };

      // Fetch user details from the server
      http.Response response = await http
          .get(
            url,
            headers: headers,
          )
          .timeout(new Duration(seconds: 10));

      // Check if the response does not contain any error.
      if (response.statusCode >= 400 && response.statusCode < 500) {
        Map<String, dynamic> body = json.decode(response.body);
        throw ServerException(message: body['message']);
      } else if (response.statusCode >= 500) {
        Map<String, dynamic> body = json.decode(response.body);

        log.e(body["message"]);

        throw ServerException(
          message: 'Something went wrong, please try again later.',
        );
      }

      // Decode the JSON object and build the user object from JSON.
      Map<String, dynamic> body = json.decode(response.body);
      User user = User.fromJson(body);

      this._saveUserDetailsToDevice(user, userId);

      // Return the user details.
      return user;
    } on SocketException {
      log.wtf("Dedicated Server Offline");
      return this._fetchUserDetailsFromDevice(userId);
    } on TimeoutException {
      log.wtf("Dedicated Server Offline");
      return this._fetchUserDetailsFromDevice(userId);
    } on FA.FirebaseAuthException catch (error) {
      if (error.code == "network-request-failed") {
        return this._fetchUserDetailsFromDevice(userId);
      } else {
        throw error;
      }
    }
  }

  /*
   * Update user profile such as name and profile picture.
   * @param updateProfileDto DTO for profile update.
   */
  Future<User> updateUserProfile(
    UpdateProfileDto updateProfileDto,
    User user,
  ) async {
    // Fetching the currently logged in user.
    FA.User? loggedInUser = this._firebaseAuth.currentUser;

    // Check if user is null
    if (loggedInUser == null) {
      throw NotLoggedInException(message: "User not logged in.");
    }
    // Preparing the URL for the server request.
    Uri uri = Uri.parse("$ENDPOINT/user/update/profile");

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
    http.Response response = await http
        .post(
          uri,
          headers: headers,
          body: body,
        )
        .timeout(new Duration(seconds: 10));

    // Checking for errors.
    if (response.statusCode >= 400 && response.statusCode < 500) {
      Map<String, dynamic> body = json.decode(response.body);
      throw ServerException(message: body['message']);
    } else if (response.statusCode >= 500) {
      Map<String, dynamic> body = json.decode(response.body);

      log.e(body["message"]);

      throw ServerException(
        message: 'Something went wrong, please try again later.',
      );
    }

    // Update the user state and return the object.
    user.imageUrl = updateProfileDto.imageUrl;
    user.firstName = updateProfileDto.firstName;
    user.lastName = updateProfileDto.lastName;
    user.biography = updateProfileDto.biography;

    log.i("Saving user to Hive DB");
    this._yasmUserDb.put(LOGGED_IN_USER, user);
    log.i("Saved user to Hive DB");

    return user;
  }

  Future<void> _updateFirebaseUserEmailAddress(
      UpdateEmailDto updateEmailDto) async {
    // Fetch the currently logged in user.
    FA.User? loggedInUser = this._firebaseAuth.currentUser;

    // Check is the user exists.
    if (loggedInUser == null) {
      throw NotLoggedInException(message: "User not logged in.");
    }
    try {
      // Get the email address for the currently logged in user.
      String currentUserEmailAddress = loggedInUser.email!;

      // Prepare the auth credentials for re-authentication.
      FA.AuthCredential authCredential = FA.EmailAuthProvider.credential(
        email: currentUserEmailAddress,
        password: updateEmailDto.password,
      );

      // Re-authenticate the user with credential.
      await loggedInUser.reauthenticateWithCredential(authCredential);

      // Update password for the user.
      await loggedInUser.updateEmail(updateEmailDto.emailAddress);
    } on FA.FirebaseAuthException catch (error) {
      // Firebase Error: If the user has typed a weak password.
      if (error.code == "email-already-in-use") {
        throw UserAlreadyExistsException(
          message: "There is an account associated with this email address.",
        );
      }

      // Firebase Error: If the user has typed the wrong password.
      else if (error.code == 'wrong-password') {
        throw WrongPasswordException(
          message: 'Wrong password provided for the specified user account.',
        );
      } else {
        log.e(error.code, error.code, error.stackTrace);

        throw GeneralException(
            message: "Something went wrong, please try again later.");
      }
    } catch (error, stackTrace) {
      log.e(error, error, stackTrace);

      throw GeneralException(
          message: "Something went wrong, please try again later.");
    }
  }

  /*
   * Update email address for the given user.
   * @param updateEmailDto DTO for email address update.
   */
  Future<User> updateUserEmailAddress(
      UpdateEmailDto updateEmailDto, User user) async {
    // Fetching the currently logged in user.
    FA.User? loggedInUser = this._firebaseAuth.currentUser;

    // Check if user is null
    if (loggedInUser == null) {
      throw NotLoggedInException(message: "User not logged in.");
    }
    // Preparing the URL for the server request.
    Uri uri = Uri.parse("$ENDPOINT/user/update/email");

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
    http.Response response = await http
        .post(
          uri,
          headers: headers,
          body: body,
        )
        .timeout(new Duration(seconds: 10));

    // Checking for errors.
    if (response.statusCode >= 400 && response.statusCode < 500) {
      Map<String, dynamic> body = json.decode(response.body);
      throw ServerException(message: body['message']);
    } else if (response.statusCode >= 500) {
      Map<String, dynamic> body = json.decode(response.body);

      log.e(body["message"]);

      throw ServerException(
        message: 'Something went wrong, please try again later.',
      );
    }

    // Update the email address on firebase as well.
    await this._updateFirebaseUserEmailAddress(updateEmailDto);

    // Update the user state and return the object.
    user.emailAddress = updateEmailDto.emailAddress;

    log.i("Saving user to Hive DB");
    this._yasmUserDb.put("logged-in-user", user);
    log.i("Saved user to Hive DB");

    return user;
  }

  /*
   * Update password for the given user.
   * @param updateEmailDto DTO for password update.
   */
  Future<void> updateUserPassword(UpdatePasswordDto updatePasswordDto) async {
    // Fetch the currently logged in user.
    FA.User? loggedInUser = this._firebaseAuth.currentUser;

    // Check is the user exists.
    if (loggedInUser == null) {
      throw NotLoggedInException(message: "User not logged in.");
    }
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
      } else {
        log.e(error.code, error.code, error.stackTrace);

        throw GeneralException(
            message: "Something went wrong, please try again later.");
      }
    } catch (error, stackTrace) {
      log.e(error, error, stackTrace);

      throw GeneralException(
          message: "Something went wrong, please try again later.");
    }
  }

  /*
   * Delete user account.
   * @param password Password for the currently logged in user.
   */
  Future<void> deleteUserAccount(String password) async {
    // Fetching the currently logged in user.
    FA.User? loggedInUser = this._firebaseAuth.currentUser;

    // Check if user is null
    if (loggedInUser == null) {
      throw NotLoggedInException(message: "User not logged in.");
    }
    // Preparing the URL for the server request.
    Uri uri = Uri.parse("$ENDPOINT/auth/delete");

    // Fetching the ID token for authentication.
    String firebaseAuthToken = await loggedInUser.getIdToken();

    // Preparing the headers for the request.
    Map<String, String> headers = {
      "Authorization": "Bearer $firebaseAuthToken",
      "Content-Type": "application/json",
    };

    // Preparing the body for the request
    String body = json.encode({"password": password});

    // POSTing to the server with updated profile details.
    http.Response response = await http
        .post(
          uri,
          headers: headers,
          body: body,
        )
        .timeout(new Duration(seconds: 10));

    // Checking for errors.
    if (response.statusCode >= 400 && response.statusCode < 500) {
      Map<String, dynamic> body = json.decode(response.body);
      throw ServerException(message: body['message']);
    } else if (response.statusCode >= 500) {
      Map<String, dynamic> body = json.decode(response.body);

      log.e(body["message"]);

      throw ServerException(
        message: 'Something went wrong, please try again later.',
      );
    }

    // Logout from firebase.
    await this._firebaseAuth.signOut();
  }

  void _saveUserDetailsToDevice(User user, String userId) {
    log.i("Saving $userId to Hive DB");
    this._yasmUserDb.put(userId, user);
    log.i("Saved $userId to Hive DB");
  }

  User _fetchUserDetailsFromDevice(String userId) {
    log.i("Fetching $userId from Hive DB");
    return this._yasmUserDb.get(
          userId,
          defaultValue: new User(
            id: "offline",
            firstName: "",
            lastName: "",
            emailAddress: "",
            biography: "",
            imageUrl: "",
            followers: [],
            following: [],
            stories: [],
          ),
        )!;
  }
}
