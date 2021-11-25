class UserNotFoundException implements Exception {
  String message;

  UserNotFoundException({required this.message});

  @override
  String toString() {
    return message;
  }
}
