import 'package:digitos/services/local_storage_service/local_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService implements LocalStorageService {
  // string values
  @override
  Future<void> setString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  @override
  Future<String?> getString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  @override
  Future<void> deleteString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  // boolean values
  @override
  Future<void> setBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Future<bool?> getBool(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key);
  }

  @override
  Future<void> deleteBool(String key) async {
    // This method can reuse deleteString since SharedPreferences.remove() works for any type
    await deleteString(key);
  }
}
