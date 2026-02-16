import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  AppPreferences(this._prefs);

  final SharedPreferences _prefs;

  static Future<AppPreferences> create() async {
    final prefs = await SharedPreferences.getInstance();
    return AppPreferences(prefs);
  }

  String? getString(String key) => _prefs.getString(key);

  int? getInt(String key) => _prefs.getInt(key);
  bool? getBool(String key) => _prefs.getBool(key);

  Future<bool> setString(String key, String value) => _prefs.setString(key, value);

  Future<bool> setInt(String key, int value) => _prefs.setInt(key, value);
  Future<bool> setBool(String key, bool value) => _prefs.setBool(key, value);
}
