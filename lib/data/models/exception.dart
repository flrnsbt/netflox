class NetfloxException implements Exception {
  final String? message;
  final String code;

  const NetfloxException({this.message, required this.code});

  factory NetfloxException.dyn(Object o) {
    if (o is NetfloxException) {
      return o;
    }
    return const NetfloxException(code: "unknown");
  }
}

class NetfloxHTTPException extends NetfloxException {
  static _matchCode(int code) {
    if (code >= 500) {
      return "server-error";
    }
    switch (code) {
      case 403:
        return "forbidden";
      case 408:
        return "timeout";
      case 429:
        return "too-many-requests";

      default:
        return "unknown";
    }
  }

  NetfloxHTTPException(int code) : super(code: _matchCode(code));
}
