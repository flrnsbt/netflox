class TMDBError implements Exception {
  final String message;

  const TMDBError._(this.message);

  factory TMDBError(Object message) {
    final errorMessage = _errorMatcher[message.toString()];
    return TMDBError._(errorMessage ?? "unknown-error");
  }

  static const Map<String, String> _errorMatcher = {
    "query must be provided": "No search terms provided",
    "": "No search terms provided",
  };

  @override
  String toString() {
    return message;
  }
}
