import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:yasm_mobile/constants/endpoint.constant.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebaseAuth;
import 'package:yasm_mobile/exceptions/auth/NotLoggedIn.dart';
import 'package:yasm_mobile/models/user/user.model.dart';

class AuthService {
  final firebaseAuth.FirebaseAuth _firebaseAuth =
      firebaseAuth.FirebaseAuth.instance;

  Future<void> getLoggedInUserDetails() async {
    if (_firebaseAuth.currentUser != null) {
      String firebaseAuthToken =
          await this._firebaseAuth.currentUser!.getIdToken();

      Uri url = Uri.parse("$endpoint/v1/api/user/me");

      Map<String, String> headers = {
        "Authorization": "Bearer $firebaseAuthToken",
      };

      http.Response response = await http.get(url, headers: headers);

      if (response.statusCode >= 400) {
        throw NotLoggedInException(
          message: "You are not logged in. Please log in and try again.",
        );
      }

      print(json.decode(response.body));
    }
  }
}
