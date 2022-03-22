import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:yasm_mobile/constants/hive_names.constant.dart';
import 'package:firebase_auth/firebase_auth.dart' as FA;
import 'package:yasm_mobile/constants/logger.constant.dart';
import 'package:yasm_mobile/dto/auth/login_user/login_user.dto.dart';
import 'package:yasm_mobile/dto/auth/register_user/register_user.dto.dart';
import 'package:yasm_mobile/exceptions/auth/not_logged_in.exception.dart';
import 'package:yasm_mobile/exceptions/auth/user_not_found.exception.dart';
import 'package:yasm_mobile/exceptions/auth/wrong_password.exception.dart';
import 'package:yasm_mobile/exceptions/common/general.exception.dart';
import 'package:yasm_mobile/exceptions/common/server.exception.dart';
import 'package:yasm_mobile/models/user/user.model.dart';

/*
 * Service implementation for authentication.
 */
class AuthService {
  final FA.FirebaseAuth _firebaseAuth = FA.FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final Box<User> _yasmUserDb = Hive.box<User>(YASM_USER_BOX);
  final Box<List<dynamic>> _yasmPostsDb =
      Hive.box<List<dynamic>>(YASM_POSTS_BOX);
  final Box<List<dynamic>> _yasmActivitiesDb =
      Hive.box<List<dynamic>>(YASM_ACTIVITY_BOX);
  final Box<List<dynamic>> _yasmStoriesDb =
      Hive.box<List<dynamic>>(YASM_STORIES_BOX);

  final String apiUrl;
  final String rawApiUrl;

  AuthService({
    required this.rawApiUrl,
    required this.apiUrl,
  });

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
      Uri url = Uri.parse("$apiUrl/follow-api/get");
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
      User loggedInUser = User.fromJson(body);

      log.i("Saving user to Hive DB");
      this._yasmUserDb.put(LOGGED_IN_USER, loggedInUser);
      log.i("Saved user to Hive DB");

      // Return the user details.
      return loggedInUser;
    } on SocketException {
      log.wtf("Dedicated Server Offline");
      User? loggedInUser = this.fetchOfflineUser();
      if (loggedInUser == null) {
        throw NotLoggedInException(message: "User not logged in.");
      } else {
        return loggedInUser;
      }
    } on TimeoutException {
      log.wtf("Dedicated Server Offline");
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
    return this._yasmUserDb.get(LOGGED_IN_USER);
  }

  /*
   * Method to register user details to the server.
   * @param registerUser DTO for user registration
   */
  Future<void> registerUser(RegisterUser registerUser) async {
    // Prepare URL and the content type header.
    Uri url = Uri.parse("$apiUrl/auth/register");
    Map<String, String> headers = {
      "Content-Type": "application/json",
    };

    // Send details to server for user registration.
    http.Response response = await http
        .post(
          url,
          headers: headers,
          body: json.encode(registerUser.toJson()),
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
  }

  /*
   * Method to log the user in the application.
   * @param loginUser DTO for user login
   */
  Future<User> login(LoginUser loginUser) async {
    try {
      // Log the user in with firebase using their credentials.
      await _firebaseAuth.signInWithEmailAndPassword(
        email: loginUser.email,
        password: loginUser.password,
      );

      // Return the user details from server.
      return await this.getLoggedInUser();
    } on FA.FirebaseAuthException catch (error, stackTrace) {
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
      } else {
        log.e(error.code, error.code, stackTrace);
        throw GeneralException(
            message: 'Something went wrong, please try again later.');
      }
    } catch (error, stackTrace) {
      log.e(error, error, stackTrace);

      throw GeneralException(
          message: 'Something went wrong, please try again later.');
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
    } catch (error, stackTrace) {
      log.e(error, error, stackTrace);

      throw GeneralException(
          message: 'Something went wrong, please try again later.');
    }
  }

  /*
   * Logout from the application.
   */
  Future<void> logout() async {
    try {
      String userId = this._firebaseAuth.currentUser!.uid;
      await this._firebaseFirestore.collection('tokens').doc(userId).delete();
      await this._clearAllHiveBoxes();

      await _firebaseAuth.signOut();
    } catch (error, stackTrace) {
      log.e(error, error, stackTrace);

      throw GeneralException(
        message: 'Something went wrong, please try again later.',
      );
    }
  }

  Future<void> _clearAllHiveBoxes() async {
    await this._yasmUserDb.clear();
    await this._yasmStoriesDb.clear();
    await this._yasmPostsDb.clear();
    await this._yasmActivitiesDb.clear();
  }
}
