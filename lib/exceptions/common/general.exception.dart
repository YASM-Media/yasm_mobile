class GeneralException implements Exception {
  String message;

  GeneralException({required this.message});

  @override
  String toString() {
    return message;
  }
}
