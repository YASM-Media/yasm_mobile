import 'package:flutter/foundation.dart';
import 'package:yasm_mobile/models/user/user.model.dart';

class AuthProvider with ChangeNotifier {
  User? _user;

  void saveUser(User user) {
    this._user = user;
    this.notifyListeners();
  }

  User? getUser() => this._user;

  void removeUser() {
    this._user = null;
    this.notifyListeners();
  }
}
