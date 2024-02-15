abstract class LocalStorageService {
  Future<void> setString(String key, String value);
  Future<String?> getString(String key);
  Future<void> deleteString(String key);

  Future<void> setBool(String key, bool value);
  Future<bool?> getBool(String key);
  Future<void> deleteBool(String key);
}
