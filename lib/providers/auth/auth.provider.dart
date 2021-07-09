import 'package:flutter/foundation.dart';
import 'package:yasm_mobile/models/user/user.model.dart';

/*
 * Provider implementation for authentication.
 */
class AuthProvider with ChangeNotifier {
  User? _user;

  /*
   * Save user details in memory.
   */
  void saveUser(User user) {
    this._user = user;
    this.notifyListeners();
  }

  /*
   * Get user details from memory.
   */
  User? getUser() => this._user;

  /*
   * Remove user details from memory.
   */
  void removeUser() {
    this._user = null;
    this.notifyListeners();
  }
}
