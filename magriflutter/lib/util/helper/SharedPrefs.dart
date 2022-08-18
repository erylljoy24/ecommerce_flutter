import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  static SharedPreferences? _prefsInstance;

  static Future<SharedPreferences> get _instance async =>
      _prefsInstance ??= await SharedPreferences.getInstance();

  static Future<SharedPreferences?> init() async {
    _prefsInstance = await SharedPreferences.getInstance();
    return _prefsInstance;
  }

  static String getString(String key, [String? defValue]) {
    return _prefsInstance?.getString(key) ?? "";
  }

  static List<String>? getStringList(String key, [String? defValue]) {
    return _prefsInstance?.getStringList(key) ?? [];
  }

  static Future<bool> setString(String key, String value) {
    return _prefsInstance?.setString(key, value) ?? Future.value(false);
  }

  static Future<bool> setStringList(String key, List<String> value) {
    return _prefsInstance?.setStringList(key, value) ?? Future.value(false);
  }

  static bool? getBool(String key, [bool? defValue]) {
    return _prefsInstance?.getBool(key) ?? defValue;
  }

  static Future<bool> setBool(String key, bool value) {
    return _prefsInstance?.setBool(key, value) ?? Future.value(false);
  }

  static Future<bool>? removeKey(String key) {
    return _prefsInstance?.remove(key);
  }

  static Future<bool> removeString(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.remove(key);
  }

  static void clear() {
    _prefsInstance?.clear();
  }
}
