import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:yasm_mobile/constants/endpoint.constant.dart';
import 'package:firebase_auth/firebase_auth.dart' as FA;
import 'package:yasm_mobile/exceptions/auth/not_logged_in.exception.dart';
import 'package:yasm_mobile/exceptions/common/server.exception.dart';
import 'package:yasm_mobile/models/user/user.model.dart';

class SearchService {
  final FA.FirebaseAuth _firebaseAuth = FA.FirebaseAuth.instance;

  Future<List<User>> searchForUser(String searchQuery) async {
    // Fetch the currently logged in user.
    FA.User? firebaseUser = this._firebaseAuth.currentUser;

    // Check is the user exists.
    if (firebaseUser != null) {
      // Fetching the ID token for authentication.
      String firebaseAuthToken = await firebaseUser.getIdToken();

      Map<String, String> queryParams = {
        "searchQuery": searchQuery,
      };

      String queryString = Uri(queryParameters: queryParams).query;

      // Preparing the URL for the server request.
      Uri url = Uri.parse("$endpoint/search/user?$queryString");

      // Preparing the headers for the request.
      Map<String, String> headers = {
        "Authorization": "Bearer $firebaseAuthToken",
        "Content-Type": "application/json",
      };

      // POSTing to the server with new post details.
      http.Response response = await http.get(
        url,
        headers: headers,
      );

      // Checking for errors.
      if (response.statusCode >= 400) {
        // Decode the response and throw an exception.
        Map<String, dynamic> body = json.decode(response.body);
        throw ServerException(message: body["message"]);
      }

      List<dynamic> body = json.decode(response.body);
      List<User> searchResult =
          body.map((result) => User.fromJson(result)).toList();

      return searchResult;
    } else {
      // If there is no user logged is using firebase, throw an exception.
      throw NotLoggedInException(message: "User not logged in.");
    }
  }
}
