import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart' as FA;
import 'package:http/http.dart' as http;
import 'package:yasm_mobile/constants/endpoint.constant.dart';
import 'package:yasm_mobile/exceptions/auth/not_logged_in.exception.dart';
import 'package:yasm_mobile/exceptions/common/server.exception.dart';

class LikeService {
  final FA.FirebaseAuth _firebaseAuth = FA.FirebaseAuth.instance;

  Future<void> likePost(String postId) async {
    // Fetch the currently logged in user.
    FA.User? firebaseUser = this._firebaseAuth.currentUser;

    // Check is the user exists.
    if (firebaseUser != null) {
      // Fetching the ID token for authentication.
      String firebaseAuthToken = await firebaseUser.getIdToken();

      // Preparing the URL for the server request.
      Uri url = Uri.parse("$endpoint/like-api/like");

      // Preparing the headers for the request.
      Map<String, String> headers = {
        "Authorization": "Bearer $firebaseAuthToken",
        "Content-Type": "application/json",
      };

      // Preparing the body for the request
      String body = json.encode({"postId": postId});

      // POSTing to the server with new post details.
      http.Response response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      // Checking for errors.
      if (response.statusCode >= 400) {
        // Decode the response and throw an exception.
        Map<String, dynamic> body = json.decode(response.body);
        throw ServerException(message: body["message"]);
      }
    } else {
      // If there is no user logged is using firebase, throw an exception.
      throw NotLoggedInException(message: "User not logged in.");
    }
  }

  Future<void> unlikePost(String postId) async {
    // Fetch the currently logged in user.
    FA.User? firebaseUser = this._firebaseAuth.currentUser;

    // Check is the user exists.
    if (firebaseUser != null) {
      // Fetching the ID token for authentication.
      String firebaseAuthToken = await firebaseUser.getIdToken();

      // Preparing the URL for the server request.
      Uri url = Uri.parse("$endpoint/like-api/unlike");

      // Preparing the headers for the request.
      Map<String, String> headers = {
        "Authorization": "Bearer $firebaseAuthToken",
        "Content-Type": "application/json",
      };

      // Preparing the body for the request
      String body = json.encode({"postId": postId});

      // POSTing to the server with new post details.
      http.Response response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      // Checking for errors.
      if (response.statusCode >= 400) {
        // Decode the response and throw an exception.
        Map<String, dynamic> body = json.decode(response.body);
        throw ServerException(message: body["message"]);
      }
    } else {
      // If there is no user logged is using firebase, throw an exception.
      throw NotLoggedInException(message: "User not logged in.");
    }
  }
}