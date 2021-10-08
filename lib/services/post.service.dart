import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart' as FA;
import 'package:yasm_mobile/constants/endpoint.constant.dart';
import 'package:yasm_mobile/constants/post_fetch_type.constant.dart';
import 'package:yasm_mobile/dto/post/create_post/create_post.dto.dart';
import 'package:yasm_mobile/dto/post/update_post/update_post.dto.dart';
import 'package:yasm_mobile/exceptions/auth/not_logged_in.exception.dart';
import 'package:yasm_mobile/exceptions/common/server.exception.dart';
import 'package:yasm_mobile/models/post/post.model.dart';

/*
 * Service implementation for post features.
 */
class PostService {
  final FA.FirebaseAuth _firebaseAuth = FA.FirebaseAuth.instance;

  /*
   * Helper method to generate the url for
   * the type of category of posts to fetch.
   * @param postFetchType Enum for post fetching type.
   */
  String _generatePostFetchingUrl(PostFetchType postFetchType) {
    String url = endpoint;

    switch (postFetchType) {
      case PostFetchType.SUGGESTED:
        {
          url += "/posts/get/suggested";
          break;
        }
      case PostFetchType.BEST:
        {
          url += "/posts/get/best";
          break;
        }
      case PostFetchType.NEW:
        {
          url += "/posts/get/new";
          break;
        }
      default:
        {
          url += "/posts/get/new";
          break;
        }
    }

    return url;
  }

  /*
   * Fetch posts by category.
   * @param postFetchType Enum for post fetching type.
   */
  Future<List<Post>> fetchPostsByCategory(PostFetchType postFetchType) async {
    // Fetch the currently logged in user.
    FA.User? firebaseUser = this._firebaseAuth.currentUser;

    // Check is the user exists.
    if (firebaseUser != null) {
      // Fetching the ID token for authentication.
      String firebaseAuthToken = await firebaseUser.getIdToken();

      // Preparing the URL for the server request.
      Uri url = Uri.parse(this._generatePostFetchingUrl(postFetchType));

      // Preparing the headers for the request.
      Map<String, String> headers = {
        "Authorization": "Bearer $firebaseAuthToken",
      };

      // Fetching posts from the server.
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

      // Decoding all posts to JSON and converting them to post objects.
      List<dynamic> rawPosts = json.decode(response.body);
      List<Post> posts = rawPosts.map((post) => Post.fromJson(post)).toList();

      // Returning posts.
      return posts;
    } else {
      // If there is no user logged is using firebase, throw an exception.
      throw NotLoggedInException(message: "User not logged in.");
    }
  }

  /*
   * Fetch posts by a particular user.
   * @param userId ID for the user for who the posts should be fetched.
   */
  Future<List<Post>> fetchPostsByUser(String userId) async {
    // Fetch the currently logged in user.
    FA.User? firebaseUser = this._firebaseAuth.currentUser;

    // Check is the user exists.
    if (firebaseUser != null) {
      // Fetching the ID token for authentication.
      String firebaseAuthToken = await firebaseUser.getIdToken();

      // Preparing the URL for the server request.
      Uri url = Uri.parse("$endpoint/posts/get/user/$userId");

      // Preparing the headers for the request.
      Map<String, String> headers = {
        "Authorization": "Bearer $firebaseAuthToken",
      };

      // Fetching posts from the server.
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

      // Decoding all posts to JSON and converting them to post objects.
      List<Map<String, dynamic>> rawPosts = json.decode(response.body);
      List<Post> posts = rawPosts.map((post) => Post.fromJson(post)).toList();

      // Returning posts.
      return posts;
    } else {
      // If there is no user logged is using firebase, throw an exception.
      throw NotLoggedInException(message: "User not logged in.");
    }
  }

  /*
   * Create a new post with images.
   * @param createPostDto DTO for creating posts
   */
  Future<void> createPost(CreatePostDto createPostDto) async {
    // Fetch the currently logged in user.
    FA.User? firebaseUser = this._firebaseAuth.currentUser;

    // Check is the user exists.
    if (firebaseUser != null) {
      // Fetching the ID token for authentication.
      String firebaseAuthToken = await firebaseUser.getIdToken();

      // Preparing the URL for the server request.
      Uri url = Uri.parse("$endpoint/posts/create");

      // Preparing the headers for the request.
      Map<String, String> headers = {
        "Authorization": "Bearer $firebaseAuthToken",
        "Content-Type": "application/json",
      };

      // Preparing the body for the request
      String body = json.encode(createPostDto.toJson());

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

  /*
   * Update posts with updated images/body.
   * @param updatePostDto DTO for updating posts
   */
  Future<void> updatePost(UpdatePostDto updatePostDto) async {
    // Fetch the currently logged in user.
    FA.User? firebaseUser = this._firebaseAuth.currentUser;

    // Check is the user exists.
    if (firebaseUser != null) {
      // Fetching the ID token for authentication.
      String firebaseAuthToken = await firebaseUser.getIdToken();

      // Preparing the URL for the server request.
      Uri url = Uri.parse("$endpoint/posts/update");

      // Preparing the headers for the request.
      Map<String, String> headers = {
        "Authorization": "Bearer $firebaseAuthToken",
        "Content-Type": "application/json",
      };

      // Preparing the body for the request
      String body = json.encode(updatePostDto.toJson());

      // POSTing to the server with updated post details.
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

  /*
   * Method to delete the post.
   * @param postId ID of the post to be deleted.
   */
  Future<void> deletePost(String postId) async {
    // Fetch the currently logged in user.
    FA.User? firebaseUser = this._firebaseAuth.currentUser;

    // Check is the user exists.
    if (firebaseUser != null) {
      // Fetching the ID token for authentication.
      String firebaseAuthToken = await firebaseUser.getIdToken();

      // Preparing the URL for the server request.
      Uri url = Uri.parse("$endpoint/posts/delete");

      // Preparing the headers for the request.
      Map<String, String> headers = {
        "Authorization": "Bearer $firebaseAuthToken",
        "Content-Type": "application/json",
      };

      // Preparing the body for the request
      String body = json.encode({"id": postId});

      // POSTing to the server to delete the post.
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
