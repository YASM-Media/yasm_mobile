import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart' as FA;
import 'package:hive/hive.dart';
import 'package:yasm_mobile/constants/hive_names.constant.dart';
import 'package:yasm_mobile/constants/logger.constant.dart';
import 'package:yasm_mobile/exceptions/auth/not_logged_in.exception.dart';
import 'package:yasm_mobile/exceptions/common/server.exception.dart';
import 'package:yasm_mobile/models/activity/activity.model.dart';
import 'package:http/http.dart' as http;

class ActivityService {
  final FA.FirebaseAuth _firebaseAuth = FA.FirebaseAuth.instance;
  final Box<List<dynamic>> _yasmActivityDb =
      Hive.box<List<dynamic>>(YASM_ACTIVITY_BOX);

  final String apiUrl;
  final String rawApiUrl;

  ActivityService({
    required this.rawApiUrl,
    required this.apiUrl,
  });

  Future<List<Activity>> fetchActivity() async {
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
      Uri url = Uri.parse("$apiUrl/activity");

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

      // Decoding all activities to JSON and converting them to post objects.
      List<dynamic> rawActivities = json.decode(response.body);
      List<Activity> activity =
          rawActivities.map((activity) => Activity.fromJson(activity)).toList();

      // Save activities to local storage.
      this._saveActivitiesToDevice(activity);

      // Returning activities.
      return activity;
    } on SocketException {
      log.wtf("Dedicated Server Offline");
      return this._fetchActivitiesFromDevice();
    } on TimeoutException {
      log.wtf("Dedicated Server Offline");
      return _fetchActivitiesFromDevice();
    } on FA.FirebaseAuthException catch (error) {
      if (error.code == "network-request-failed") {
        return this._fetchActivitiesFromDevice();
      } else {
        throw error;
      }
    }
  }

  void _saveActivitiesToDevice(List<Activity> activity) {
    log.i("Saving ACTIVITY to Hive DB");
    this._yasmActivityDb.put(ACTIVITIES, activity);
    log.i("Saved ACTIVITY to Hive DB");
  }

  List<Activity> _fetchActivitiesFromDevice() {
    log.i("Fetching ACTIVITY from Hive DB");
    return this
        ._yasmActivityDb
        .get(ACTIVITIES, defaultValue: [])!.cast<Activity>();
  }
}
