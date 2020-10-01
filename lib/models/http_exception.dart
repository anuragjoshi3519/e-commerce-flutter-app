class HTTPException implements Exception{
  HTTPException(this.message);
  final String message;

  @override
  String toString() {
    return message;
  }
}