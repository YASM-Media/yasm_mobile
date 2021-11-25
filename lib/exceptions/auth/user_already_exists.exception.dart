class UserAlreadyExistsException implements Exception {
  String message;

  UserAlreadyExistsException({required this.message});

  @override
  String toString() {
    return message;
  }
}
