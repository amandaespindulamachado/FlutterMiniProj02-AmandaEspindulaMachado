import 'package:shared_preferences/shared_preferences.dart';

abstract interface class IPrefsService {
  Future<void> saveUser({
    required String firstName,
    required String lastName,
    required String token,
  });
  Future<bool> isLoggedIn();
  Future<String?> getFirstName();
  Future<String?> getLastName();
  Future<String?> getToken();
  Future<void> clear();
}

class PrefsService implements IPrefsService {
  static const String _keyFirstName = 'user_first_name';
  static const String _keyLastName = 'user_last_name';
  static const String _keyToken = 'user_token';

  @override
  Future<void> saveUser({
    required String firstName,
    required String lastName,
    required String token,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyFirstName, firstName);
    await prefs.setString(_keyLastName, lastName);
    await prefs.setString(_keyToken, token);
  }

  @override
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_keyToken);
    return token != null && token.isNotEmpty;
  }

  @override
  Future<String?> getFirstName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyFirstName);
  }

  @override
  Future<String?> getLastName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLastName);
  }

  @override
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  @override
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
