import 'package:flutter/services.dart';

extension GenericTypeCheckerExtension on Object? {
  bool isList() => toString().startsWith("List");
  bool isSet() => toString().startsWith("Set");
  bool isNativeIterable() => toString().startsWith("Iterable");
  bool isIterable() => isNativeIterable() || isSet() || isList();
  String get genericTypeName {
    if (isList()) {
      return _listSubTypeName();
    }
    return toString();
  }

  String _listSubTypeName() {
    if (isList()) {
      final str = toString();
      return str.substring(str.indexOf("<") + 1, str.lastIndexOf(">"));
    }
    throw PlatformException(code: 'Generic Type not a list');
  }
}
