class WeakPasswordException implements Exception {
  String message;

  WeakPasswordException({required this.message});

  @override
  String toString() {
    return message;
  }
}
