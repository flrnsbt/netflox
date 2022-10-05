import 'package:netflox/utils/beautiful_string/public.dart' as p;

extension TMDBEnumStringizer on Enum {
  String get beautifulName => p.beautifulString(name);
}

extension TMDBStringizer on String {
  String get beautifulString => p.beautifulString(this);
}
