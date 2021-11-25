class NotLoggedInException implements Exception {
  String message;

  NotLoggedInException({required this.message});

  @override
  String toString() {
    return message;
  }
}
