import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceService {
  final SharedPreferences? _sharedPreferences;

  const SharedPreferenceService._(this._sharedPreferences);

  static late final SharedPreferenceService instance;

  static Future<void> init() async {
    final sh = await SharedPreferences.getInstance();
    instance = SharedPreferenceService._(sh);
  }

  T? get<T>(String key) => _sharedPreferences!.get(key) as T?;

  Future<bool> set(String key, Object object) {
    switch (object.runtimeType) {
      case bool:
        return _sharedPreferences!.setBool(key, object as bool);
      case String:
        return _sharedPreferences!.setString(key, object as String);
      case double:
        return _sharedPreferences!.setDouble(key, object as double);
      case int:
        return _sharedPreferences!.setInt(key, object as int);
      case List<String>:
        return _sharedPreferences!.setStringList(key, object as List<String>);
      default:
        return _sharedPreferences!.setString(key, object.toString());
    }
  }

  bool checkExists(String key) {
    return _sharedPreferences!.containsKey(key);
  }

  Future<void> clear() {
    return _sharedPreferences!.clear();
  }
}
