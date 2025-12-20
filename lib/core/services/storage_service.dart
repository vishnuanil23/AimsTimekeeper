import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../utils/constants.dart';

class StorageService {
  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> saveToken(String token) async {
    await _prefs.setString(AppConstants.tokenKey, token);
  }

  Future<String?> getToken() async {
    return _prefs.getString(AppConstants.tokenKey);
  }

  Future<void> saveUser(Map<String, dynamic> user) async {
    await _prefs.setString(AppConstants.userKey, jsonEncode(user));
  }

  Future<Map<String, dynamic>?> getUser() async {
    final userString = _prefs.getString(AppConstants.userKey);
    if (userString != null) {
      return jsonDecode(userString);
    }
    return null;
  }

  Future<void> savePunchStatus(bool isPunchedIn) async {
    await _prefs.setBool(AppConstants.isPunchedInKey, isPunchedIn);
  }

  Future<bool> getPunchStatus() async {
    return _prefs.getBool(AppConstants.isPunchedInKey) ?? false;
  }

  Future<void> clear() async {
    await _prefs.clear();
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }
}
