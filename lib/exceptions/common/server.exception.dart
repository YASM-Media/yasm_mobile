class ServerException implements Exception {
  String message;

  ServerException({required this.message});

  @override
  String toString() {
    return message;
  }
}
