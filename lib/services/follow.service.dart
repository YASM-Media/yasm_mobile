import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart' as FA;
import 'package:yasm_mobile/constants/endpoint.constant.dart';
import 'package:yasm_mobile/exceptions/auth/not_logged_in.exception.dart';

class FollowService {
  final FA.FirebaseAuth _firebaseAuth = FA.FirebaseAuth.instance;

  Future<void> followUser(String userId) async {
    // Get the logged in user details.
    FA.User? firebaseUser = this._firebaseAuth.currentUser;

    // Check if user is not null.
    if (firebaseUser != null) {
      // Fetch the ID token for the user.
      String firebaseAuthToken =
          await this._firebaseAuth.currentUser!.getIdToken(true);

      // Prepare URL and the auth header.
      Uri url = Uri.parse("$endpoint/follow-api/follow/$userId");
      Map<String, String> headers = {
        "Authorization": "Bearer $firebaseAuthToken",
      };

      // Fetch user details from the server
      http.Response response = await http.post(
        url,
        headers: headers,
      );

      print(json.decode(response.body));

      // Check if the response does not contain any error.
      if (response.statusCode >= 400) {
        print(json.decode(response.body));
        throw Exception("Something went wrong, please try again later.");
      }
    } else {
      // If there is no user logged is using firebase, throw an exception.
      throw NotLoggedInException(message: "User not logged in.");
    }
  }

  Future<void> unfollowUser(String userId) async {
    // Get the logged in user details.
    FA.User? firebaseUser = this._firebaseAuth.currentUser;

    // Check if user is not null.
    if (firebaseUser != null) {
      // Fetch the ID token for the user.
      String firebaseAuthToken =
          await this._firebaseAuth.currentUser!.getIdToken(true);

      // Prepare URL and the auth header.
      Uri url = Uri.parse("$endpoint/follow-api/unfollow/$userId");
      Map<String, String> headers = {
        "Authorization": "Bearer $firebaseAuthToken",
      };

      // Fetch user details from the server
      http.Response response = await http.post(
        url,
        headers: headers,
      );

      print(json.decode(response.body));

      // Check if the response does not contain any error.
      if (response.statusCode >= 400) {
        print(json.decode(response.body));
        throw Exception("Something went wrong, please try again later.");
      }
    } else {
      // If there is no user logged is using firebase, throw an exception.
      throw NotLoggedInException(message: "User not logged in.");
    }
  }
}
