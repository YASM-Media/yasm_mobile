import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart' as FA;
import 'package:yasm_mobile/constants/logger.constant.dart';
import 'package:yasm_mobile/exceptions/auth/not_logged_in.exception.dart';
import 'package:yasm_mobile/exceptions/common/server.exception.dart';
import 'package:yasm_mobile/models/post/post.model.dart';
import 'package:yasm_mobile/models/user/user.model.dart';

class SearchService {
  final FA.FirebaseAuth _firebaseAuth = FA.FirebaseAuth.instance;

  final String apiUrl;
  final String rawApiUrl;

  SearchService({
    required this.rawApiUrl,
    required this.apiUrl,
  });

  Future<List<User>> searchForUser(String searchQuery) async {
    if (searchQuery.length == 0) {
      return [];
    }

    // Fetch the currently logged in user.
    FA.User? firebaseUser = this._firebaseAuth.currentUser;

    // Check is the user exists.
    if (firebaseUser == null) {
      throw NotLoggedInException(message: "User not logged in.");
    }
    // Fetching the ID token for authentication.
    String firebaseAuthToken = await firebaseUser.getIdToken();

    Map<String, String> queryParams = {
      "searchQuery": searchQuery,
    };

    String queryString = Uri(queryParameters: queryParams).query;

    // Preparing the URL for the server request.
    Uri url = Uri.parse("$apiUrl/search/user?$queryString");

    // Preparing the headers for the request.
    Map<String, String> headers = {
      "Authorization": "Bearer $firebaseAuthToken",
      "Content-Type": "application/json",
    };

    // POSTing to the server with new post details.
    http.Response response = await http
        .get(
          url,
          headers: headers,
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

    List<dynamic> body = json.decode(response.body);
    List<User> searchResult =
        body.map((result) => User.fromJson(result)).toList();

    return searchResult;
  }

  Future<List<Post>> searchForPosts(String searchQuery) async {
    if (searchQuery.length == 0) {
      return [];
    }

    // Fetch the currently logged in user.
    FA.User? firebaseUser = this._firebaseAuth.currentUser;

    // Check is the user exists.
    if (firebaseUser == null) {
      throw NotLoggedInException(message: "User not logged in.");
    }
    // Fetching the ID token for authentication.
    String firebaseAuthToken = await firebaseUser.getIdToken();

    Map<String, String> queryParams = {
      "searchQuery": searchQuery,
    };

    String queryString = Uri(queryParameters: queryParams).query;

    // Preparing the URL for the server request.
    Uri url = Uri.parse("$apiUrl/search/post?$queryString");

    // Preparing the headers for the request.
    Map<String, String> headers = {
      "Authorization": "Bearer $firebaseAuthToken",
      "Content-Type": "application/json",
    };

    // POSTing to the server with new post details.
    http.Response response = await http
        .get(
          url,
          headers: headers,
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

    List<dynamic> body = json.decode(response.body);
    List<Post> searchResult =
        body.map((result) => Post.fromJson(result)).toList();

    return searchResult;
  }
}
