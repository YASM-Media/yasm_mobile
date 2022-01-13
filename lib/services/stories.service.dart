import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart' as FA;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:yasm_mobile/constants/endpoint.constant.dart';
import 'package:yasm_mobile/constants/hive_names.constant.dart';
import 'package:yasm_mobile/constants/logger.constant.dart';
import 'package:yasm_mobile/dto/story/create_story/create_story.dto.dart';
import 'package:yasm_mobile/dto/story/delete_story/delete_story.dto.dart';
import 'package:yasm_mobile/exceptions/auth/not_logged_in.exception.dart';
import 'package:http/http.dart' as http;
import 'package:yasm_mobile/exceptions/common/server.exception.dart';
import 'package:yasm_mobile/models/story/story.model.dart';
import 'package:yasm_mobile/models/user/user.model.dart';

class StoriesService {
  final FA.FirebaseAuth _firebaseAuth = FA.FirebaseAuth.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  final Uuid uuid = new Uuid();
  final Box<List<dynamic>> _yasmStoriesBox =
      Hive.box<List<dynamic>>(YASM_STORIES_BOX);

  Future<List<User>> fetchAvailableStories() async {
    // Fetch the currently logged in user.
    FA.User? firebaseUser = this._firebaseAuth.currentUser;

    try {
      // Check is the user exists.
      if (firebaseUser == null) {
        throw NotLoggedInException(message: "User not logged in.");
      }

      // Fetching the ID token for authentication.
      String firebaseAuthToken = await firebaseUser.getIdToken();

      // Preparing the URL for the server request.
      Uri url = Uri.parse("$ENDPOINT/story");

      // Preparing the headers for the request.
      Map<String, String> headers = {
        "Authorization": "Bearer $firebaseAuthToken",
      };

      // POSTing to the server with new post details.
      http.Response response = await http
          .get(
            url,
            headers: headers,
          )
          .timeout(new Duration(seconds: 10));

      // Check if the response does not contain any error.
      if (response.statusCode >= 400 && response.statusCode < 500) {
        Map<String, dynamic> body = json.decode(response.body);
        log.e(body["message"]);
        throw ServerException(message: body['message']);
      } else if (response.statusCode >= 500) {
        Map<String, dynamic> body = json.decode(response.body);

        log.e(body["message"]);

        throw ServerException(
          message: 'Something went wrong, please try again later.',
        );
      }

      List<dynamic> responseData = json.decode(response.body);
      List<User> stories = responseData
          .map((rawResponse) => User.fromJson(rawResponse))
          .toList();

      this._saveAvailableStoriesToDevice(stories);

      return stories;
    } on SocketException {
      log.wtf("Dedicated Server Offline");
      return this._fetchAvailableStoriesFromDevice();
    } on TimeoutException {
      log.wtf("Dedicated Server Offline");
      return this._fetchAvailableStoriesFromDevice();
    } on FA.FirebaseAuthException catch (error) {
      if (error.code == "network-request-failed") {
        return this._fetchAvailableStoriesFromDevice();
      } else {
        throw error;
      }
    }
  }

  Future<List<Story>> fetchArchivedStories() async {
    // Fetch the currently logged in user.
    FA.User? firebaseUser = this._firebaseAuth.currentUser;

    try {
      // Check is the user exists.
      if (firebaseUser == null) {
        throw NotLoggedInException(message: "User not logged in.");
      }

      // Fetching the ID token for authentication.
      String firebaseAuthToken = await firebaseUser.getIdToken();

      // Preparing the URL for the server request.
      Uri url = Uri.parse("$ENDPOINT/story/archive");

      // Preparing the headers for the request.
      Map<String, String> headers = {
        "Authorization": "Bearer $firebaseAuthToken",
      };

      // POSTing to the server with new post details.
      http.Response response = await http
          .get(
            url,
            headers: headers,
          )
          .timeout(new Duration(seconds: 10));

      // Check if the response does not contain any error.
      if (response.statusCode >= 400 && response.statusCode < 500) {
        Map<String, dynamic> body = json.decode(response.body);
        log.e(body["message"]);
        throw ServerException(message: body['message']);
      } else if (response.statusCode >= 500) {
        Map<String, dynamic> body = json.decode(response.body);

        log.e(body["message"]);

        throw ServerException(
          message: 'Something went wrong, please try again later.',
        );
      }

      List<dynamic> responseData = json.decode(response.body);
      List<Story> stories = responseData
          .map((rawResponse) => Story.fromJson(rawResponse))
          .toList();

      this._saveArchivedStoriesToDevice(stories);

      return stories;
    } on SocketException {
      log.wtf("Dedicated Server Offline");
      return this._fetchArchivedStoriesFromDevice();
    } on TimeoutException {
      log.wtf("Dedicated Server Offline");
      return this._fetchArchivedStoriesFromDevice();
    } on FA.FirebaseAuthException catch (error) {
      if (error.code == "network-request-failed") {
        return this._fetchArchivedStoriesFromDevice();
      } else {
        throw error;
      }
    }
  }

  Future<List<Story>> fetchStoriesByUser(String userId) async {
    // Fetch the currently logged in user.
    FA.User? firebaseUser = this._firebaseAuth.currentUser;

    try {
      // Check is the user exists.
      if (firebaseUser == null) {
        throw NotLoggedInException(message: "User not logged in.");
      }

      // Fetching the ID token for authentication.
      String firebaseAuthToken = await firebaseUser.getIdToken();

      // Preparing the URL for the server request.
      Uri url = Uri.http(
        RAW_ENDPOINT,
        "/v1/api/story/user",
        {
          "userId": userId,
        },
      );

      // Preparing the headers for the request.
      Map<String, String> headers = {
        "Authorization": "Bearer $firebaseAuthToken",
      };

      // POSTing to the server with new post details.
      http.Response response = await http
          .get(
            url,
            headers: headers,
          )
          .timeout(new Duration(seconds: 10));

      // Check if the response does not contain any error.
      if (response.statusCode >= 400 && response.statusCode < 500) {
        Map<String, dynamic> body = json.decode(response.body);
        log.e(body["message"]);
        throw ServerException(message: body['message']);
      } else if (response.statusCode >= 500) {
        Map<String, dynamic> body = json.decode(response.body);

        log.e(body["message"]);

        throw ServerException(
          message: 'Something went wrong, please try again later.',
        );
      }

      List<dynamic> responseData = json.decode(response.body);
      List<Story> stories = responseData
          .map((rawResponse) => Story.fromJson(rawResponse))
          .toList();

      if (userId == firebaseUser.uid) {
        this._saveLoggedInUserStoriesToDevice(stories);
      }

      return stories;
    } on SocketException {
      log.wtf("Dedicated Server Offline");
      return firebaseUser!.uid == userId
          ? this._fetchLoggedInUserStoriesFromDevice()
          : [];
    } on TimeoutException {
      log.wtf("Dedicated Server Offline");
      return firebaseUser!.uid == userId
          ? this._fetchLoggedInUserStoriesFromDevice()
          : [];
    } on FA.FirebaseAuthException catch (error) {
      if (error.code == "network-request-failed") {
        return firebaseUser!.uid == userId
            ? this._fetchLoggedInUserStoriesFromDevice()
            : [];
      } else {
        throw error;
      }
    }
  }

  Future<void> createStory(Uint8List storyData) async {
    String storyUrl = await this._uploadStoryAndGenerateUrl(storyData);
    CreateStoryDto createStoryDto = new CreateStoryDto(storyUrl: storyUrl);

    // Fetch the currently logged in user.
    FA.User? firebaseUser = this._firebaseAuth.currentUser;

    // Check is the user exists.
    if (firebaseUser == null) {
      throw NotLoggedInException(message: "User not logged in.");
    }

    // Fetching the ID token for authentication.
    String firebaseAuthToken = await firebaseUser.getIdToken();

    // Preparing the URL for the server request.
    Uri url = Uri.parse("$ENDPOINT/story");

    // Preparing the headers for the request.
    Map<String, String> headers = {
      "Authorization": "Bearer $firebaseAuthToken",
    };

    // POSTing to the server with new post details.
    http.Response response = await http
        .post(
          url,
          headers: headers,
          body: createStoryDto.toJson(),
        )
        .timeout(new Duration(seconds: 10));

    // Check if the response does not contain any error.
    if (response.statusCode >= 400 && response.statusCode < 500) {
      Map<String, dynamic> body = json.decode(response.body);
      log.e(body["message"]);
      throw ServerException(message: body['message']);
    } else if (response.statusCode >= 500) {
      Map<String, dynamic> body = json.decode(response.body);

      log.e(body["message"]);

      throw ServerException(
        message: 'Something went wrong, please try again later.',
      );
    }
  }

  Future<void> deleteStory(DeleteStoryDto deleteStoryDto) async {
    // Fetch the currently logged in user.
    FA.User? firebaseUser = this._firebaseAuth.currentUser;

    // Check is the user exists.
    if (firebaseUser == null) {
      throw NotLoggedInException(message: "User not logged in.");
    }

    // Fetching the ID token for authentication.
    String firebaseAuthToken = await firebaseUser.getIdToken();

    // Preparing the URL for the server request.
    Uri url = Uri.parse("$ENDPOINT/story");

    // Preparing the headers for the request.
    Map<String, String> headers = {
      "Authorization": "Bearer $firebaseAuthToken",
    };

    // POSTing to the server with new post details.
    http.Response response = await http
        .delete(
          url,
          headers: headers,
          body: deleteStoryDto.toJson(),
        )
        .timeout(new Duration(seconds: 10));

    // Check if the response does not contain any error.
    if (response.statusCode >= 400 && response.statusCode < 500) {
      Map<String, dynamic> body = json.decode(response.body);
      log.e(body["message"]);
      throw ServerException(message: body['message']);
    } else if (response.statusCode >= 500) {
      Map<String, dynamic> body = json.decode(response.body);

      log.e(body["message"]);

      throw ServerException(
        message: 'Something went wrong, please try again later.',
      );
    }
  }

  Future<String> _uploadStoryAndGenerateUrl(
    Uint8List storyData,
  ) async {
    String imageUuid = uuid.v4();

    await this
        ._firebaseStorage
        .ref("stories/$imageUuid.jpg")
        .putData(storyData);

    return await this
        ._firebaseStorage
        .ref("stories/$imageUuid.jpg")
        .getDownloadURL();
  }

  void _saveLoggedInUserStoriesToDevice(List<Story> stories) {
    log.i("Saving USER STORIES to Hive DB");
    this._yasmStoriesBox.put(LOGGED_IN_USER_STORIES, stories);
    log.i("Saved USER STORIES to Hive DB");
  }

  List<Story> _fetchLoggedInUserStoriesFromDevice() {
    return this
        ._yasmStoriesBox
        .get(LOGGED_IN_USER_STORIES, defaultValue: [])!.cast<Story>();
  }

  void _saveAvailableStoriesToDevice(List<User> stories) {
    log.i("Saving AVAILABLE STORIES to Hive DB");
    this._yasmStoriesBox.put(AVAILABLE_STORIES, stories);
    log.i("Saved AVAILABLE STORIES to Hive DB");
  }

  List<User> _fetchAvailableStoriesFromDevice() {
    return this
        ._yasmStoriesBox
        .get(AVAILABLE_STORIES, defaultValue: [])!.cast<User>();
  }

  void _saveArchivedStoriesToDevice(List<Story> stories) {
    log.i("Saving ARCHIVED STORIES to Hive DB");
    this._yasmStoriesBox.put(ARCHIVED_STORIES, stories);
    log.i("Saved ARCHIVED STORIES to Hive DB");
  }

  List<Story> _fetchArchivedStoriesFromDevice() {
    return this
        ._yasmStoriesBox
        .get(ARCHIVED_STORIES, defaultValue: [])!.cast<Story>();
  }
}
