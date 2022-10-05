import 'package:firebase_auth/firebase_auth.dart';
import 'package:universal_io/io.dart';

class NetfloxException implements Exception {
  final String errorCode;

  const NetfloxException({this.errorCode = 'unknown-error'});

  factory NetfloxException.from(Object o) {
    if (o is NetfloxException) {
      return o;
    } else if (o is FirebaseException) {
      return NetfloxException(errorCode: o.code);
    } else if (o is FirebaseAuthException) {
      return NetfloxException(errorCode: o.code);
    } else if (o is SocketException) {
      return const NetfloxException(errorCode: "internet-issue");
    }
    return const NetfloxException();
  }

  @override
  String toString() {
    return errorCode;
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
        return "$code";
    }
  }

  NetfloxHTTPException(int code, String url)
      : super(errorCode: _matchCode(code));
}
