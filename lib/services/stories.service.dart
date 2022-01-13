import 'dart:convert';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart' as FA;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:yasm_mobile/constants/endpoint.constant.dart';
import 'package:yasm_mobile/constants/logger.constant.dart';
import 'package:yasm_mobile/dto/story/create_story/create_story.dto.dart';
import 'package:yasm_mobile/dto/story/delete_story/delete_story.dto.dart';
import 'package:yasm_mobile/exceptions/auth/not_logged_in.exception.dart';
import 'package:http/http.dart' as http;
import 'package:yasm_mobile/exceptions/common/server.exception.dart';

class StoriesService {
  final FA.FirebaseAuth _firebaseAuth = FA.FirebaseAuth.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  final Uuid uuid = new Uuid();

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
}
