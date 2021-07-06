import 'package:http/http.dart' as http;
import 'package:yasm_mobile/constants/endpoint.constant.dart';

class AuthService {
  Future<void> getLoggedInUserDetails() async {
    try {
      Uri url = Uri.parse("$endpoint/v1/api/user/me");
      http.Response response = await http.get(url);

      print("Response Code: ${response.statusCode}");
      print("Response Body: ${response.body}");
    } catch (error) {
      print("ERROR");
      print(error);
    }
  }
}
