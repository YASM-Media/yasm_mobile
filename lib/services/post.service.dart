import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart' as FA;
import 'package:yasm_mobile/constants/endpoint.constant.dart';
import 'package:yasm_mobile/constants/hive_names.constant.dart';
import 'package:yasm_mobile/constants/logger.constant.dart';
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
  final Box<List<dynamic>> _yasmPostsDb =
      Hive.box<List<dynamic>>(YASM_POSTS_BOX);

  /*
   * Helper method to generate the url for
   * the type of category of posts to fetch.
   * @param postFetchType Enum for post fetching type.
   */
  String _generatePostFetchingUrl(PostFetchType postFetchType) {
    String url = ENDPOINT;

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
    try {
      // Fetch the currently logged in user.
      FA.User? firebaseUser = this._firebaseAuth.currentUser;

      // Check is the user exists.
      if (firebaseUser == null) {
        throw NotLoggedInException(message: "User not logged in.");
      }
      // Fetching the ID token for authentication.
      String firebaseAuthToken = await firebaseUser.getIdToken();

      // Preparing the URL for the server request.
      Uri url = Uri.parse(this._generatePostFetchingUrl(postFetchType));

      // Preparing the headers for the request.
      Map<String, String> headers = {
        "Authorization": "Bearer $firebaseAuthToken",
      };

      // Fetching posts from the server.
      http.Response response = await http
          .get(
            url,
            headers: headers,
          )
          .timeout(new Duration(seconds: 10));

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

      // Decoding all posts to JSON and converting them to post objects.
      List<dynamic> rawPosts = json.decode(response.body);
      List<Post> posts = rawPosts.map((post) => Post.fromJson(post)).toList();

      // Save posts to local storage.
      this._savePostsToDevice(postFetchType, posts);

      // Returning posts.
      return posts;
    } on SocketException {
      log.wtf("Dedicated Server Offline");
      return this._fetchPostsFromDevice(postFetchType);
    } on TimeoutException {
      log.wtf("Dedicated Server Offline");
      return this._fetchPostsFromDevice(postFetchType);
    } on FA.FirebaseAuthException catch (error) {
      if (error.code == "network-request-failed") {
        return this._fetchPostsFromDevice(postFetchType);
      } else {
        throw error;
      }
    }
  }

  /*
   * Fetch posts by a particular user.
   * @param userId ID for the user for who the posts should be fetched.
   */
  Future<List<Post>> fetchPostsByUser(String userId) async {
    try {
      // Fetch the currently logged in user.
      FA.User? firebaseUser = this._firebaseAuth.currentUser;

      // Check is the user exists.
      if (firebaseUser == null) {
        throw NotLoggedInException(message: "User not logged in.");
      }
      // Fetching the ID token for authentication.
      String firebaseAuthToken = await firebaseUser.getIdToken();

      // Preparing the URL for the server request.
      Uri url = Uri.parse("$ENDPOINT/posts/get/user/$userId");

      // Preparing the headers for the request.
      Map<String, String> headers = {
        "Authorization": "Bearer $firebaseAuthToken",
      };

      // Fetching posts from the server.
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

      // Decoding all posts to JSON and converting them to post objects.
      List<dynamic> rawPosts = json.decode(response.body);
      List<Post> posts = rawPosts.map((post) => Post.fromJson(post)).toList();

      this._saveUserPostsToDevice(posts, userId);

      // Returning posts.
      return posts;
    } on SocketException {
      log.wtf("Dedicated Server Offline");
      return this._fetchUserPostsFromDevice(userId);
    } on TimeoutException {
      log.wtf("Dedicated Server Offline");
      return this._fetchUserPostsFromDevice(userId);
    } on FA.FirebaseAuthException catch (error) {
      if (error.code == "network-request-failed") {
        return this._fetchUserPostsFromDevice(userId);
      } else {
        throw error;
      }
    }
  }

  Future<Post> fetchPostById(String postId) async {
    // Fetch the currently logged in user.
    FA.User? firebaseUser = this._firebaseAuth.currentUser;

    // Check is the user exists.
    if (firebaseUser == null) {
      throw NotLoggedInException(message: "User not logged in.");
    }
    // Fetching the ID token for authentication.
    String firebaseAuthToken = await firebaseUser.getIdToken();

    // Preparing the URL for the server request.
    Uri url = Uri.parse("$ENDPOINT/posts/get/post/$postId");

    // Preparing the headers for the request.
    Map<String, String> headers = {
      "Authorization": "Bearer $firebaseAuthToken",
    };

    // Fetching posts from the server.
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

    // Decoding all posts to JSON and converting them to post objects.
    dynamic rawPost = json.decode(response.body);
    Post post = Post.fromJson(rawPost);

    // Returning posts.
    return post;
  }

  /*
   * Create a new post with images.
   * @param createPostDto DTO for creating posts
   */
  Future<void> createPost(CreatePostDto createPostDto) async {
    // Fetch the currently logged in user.
    FA.User? firebaseUser = this._firebaseAuth.currentUser;

    // Check is the user exists.
    if (firebaseUser == null) {
      throw NotLoggedInException(message: "User not logged in.");
    }
    // Fetching the ID token for authentication.
    String firebaseAuthToken = await firebaseUser.getIdToken();

    // Preparing the URL for the server request.
    Uri url = Uri.parse("$ENDPOINT/posts/create");

    // Preparing the headers for the request.
    Map<String, String> headers = {
      "Authorization": "Bearer $firebaseAuthToken",
      "Content-Type": "application/json",
    };

    // Preparing the body for the request
    String body = json.encode(createPostDto.toJson());

    // POSTing to the server with new post details.
    http.Response response = await http
        .post(
          url,
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
  }

  /*
   * Update posts with updated images/body.
   * @param updatePostDto DTO for updating posts
   */
  Future<void> updatePost(UpdatePostDto updatePostDto) async {
    // Fetch the currently logged in user.
    FA.User? firebaseUser = this._firebaseAuth.currentUser;

    // Check is the user exists.
    if (firebaseUser == null) {
      throw NotLoggedInException(message: "User not logged in.");
    }
    // Fetching the ID token for authentication.
    String firebaseAuthToken = await firebaseUser.getIdToken();

    // Preparing the URL for the server request.
    Uri url = Uri.parse("$ENDPOINT/posts/update");

    // Preparing the headers for the request.
    Map<String, String> headers = {
      "Authorization": "Bearer $firebaseAuthToken",
      "Content-Type": "application/json",
    };

    // Preparing the body for the request
    String body = json.encode(updatePostDto.toJson());

    // POSTing to the server with updated post details.
    http.Response response = await http
        .post(
          url,
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
  }

  /*
   * Method to delete the post.
   * @param postId ID of the post to be deleted.
   */
  Future<void> deletePost(String postId) async {
    // Fetch the currently logged in user.
    FA.User? firebaseUser = this._firebaseAuth.currentUser;

    // Check is the user exists.
    if (firebaseUser == null) {
      throw NotLoggedInException(message: "User not logged in.");
    }
    // Fetching the ID token for authentication.
    String firebaseAuthToken = await firebaseUser.getIdToken();

    // Preparing the URL for the server request.
    Uri url = Uri.parse("$ENDPOINT/posts/delete");

    // Preparing the headers for the request.
    Map<String, String> headers = {
      "Authorization": "Bearer $firebaseAuthToken",
      "Content-Type": "application/json",
    };

    // Preparing the body for the request
    String body = json.encode({"id": postId});

    // POSTing to the server to delete the post.
    http.Response response = await http
        .post(
          url,
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
  }

  void _savePostsToDevice(PostFetchType postFetchType, List<Post> posts) {
    switch (postFetchType) {
      case PostFetchType.SUGGESTED:
        {
          log.i("Saving SUGGESTED POSTS to Hive DB");
          this._yasmPostsDb.put(SUGGESTED_POSTS, posts);
          log.i("Saved SUGGESTED POSTS to Hive DB");
          break;
        }
      case PostFetchType.BEST:
        {
          log.i("Saving BEST POSTS to Hive DB");
          this._yasmPostsDb.put(BEST_POSTS, posts);
          log.i("Saved BEST POSTS to Hive DB");
          break;
        }
      case PostFetchType.NEW:
        {
          log.i("Saving NEW POSTS to Hive DB");
          this._yasmPostsDb.put(NEW_POSTS, posts);
          log.i("Saved NEW POSTS to Hive DB");
          break;
        }
    }
  }

  List<Post> _fetchPostsFromDevice(PostFetchType postFetchType) {
    switch (postFetchType) {
      case PostFetchType.SUGGESTED:
        {
          log.i("Fetching SUGGESTED POSTS from Hive DB");
          return this
              ._yasmPostsDb
              .get(SUGGESTED_POSTS, defaultValue: [])!.cast<Post>();
        }
      case PostFetchType.BEST:
        {
          log.i("Fetching BEST POSTS from Hive DB");
          return this
              ._yasmPostsDb
              .get(BEST_POSTS, defaultValue: [])!.cast<Post>();
        }
      case PostFetchType.NEW:
        {
          log.i("Fetching NEW POSTS from Hive DB");
          return this
              ._yasmPostsDb
              .get(NEW_POSTS, defaultValue: [])!.cast<Post>();
        }
      default:
        {
          log.i("Fetching NEW POSTS from Hive DB");
          return this
              ._yasmPostsDb
              .get(NEW_POSTS, defaultValue: [])!.cast<Post>();
        }
    }
  }

  void _saveUserPostsToDevice(List<Post> posts, String userId) {
    log.i("Saving POSTS BY $userId to Hive DB");
    this._yasmPostsDb.put(userId, posts);
    log.i("Saved POSTS BY $userId to Hive DB");
  }

  List<Post> _fetchUserPostsFromDevice(String userId) {
    log.i("Fetching POSTS BY $userId from Hive DB");
    return this._yasmPostsDb.get(userId, defaultValue: [])!.cast<Post>();
  }
}
