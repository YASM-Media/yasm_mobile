import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart' as FA;
import 'package:yasm_mobile/constants/logger.constant.dart';
import 'package:yasm_mobile/exceptions/auth/not_logged_in.exception.dart';
import 'package:yasm_mobile/exceptions/common/server.exception.dart';

class FollowService {
  final FA.FirebaseAuth _firebaseAuth = FA.FirebaseAuth.instance;

  final String apiUrl;
  final String rawApiUrl;

  FollowService({
    required this.rawApiUrl,
    required this.apiUrl,
  });

  Future<void> followUser(String userId) async {
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
    Uri url = Uri.parse("$apiUrl/follow-api/follow/$userId");
    Map<String, String> headers = {
      "Authorization": "Bearer $firebaseAuthToken",
    };

    // Fetch user details from the server
    http.Response response = await http
        .post(
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
  }

  Future<void> unfollowUser(String userId) async {
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
    Uri url = Uri.parse("$apiUrl/follow-api/unfollow/$userId");
    Map<String, String> headers = {
      "Authorization": "Bearer $firebaseAuthToken",
    };

    // Fetch user details from the server
    http.Response response = await http
        .post(
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
  }
}
