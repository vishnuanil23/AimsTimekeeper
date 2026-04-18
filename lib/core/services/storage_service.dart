import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../utils/constants.dart';

class StorageService {
  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> saveUser(Map<String, dynamic> user) async {
    await _prefs.setString(AppConstants.userKey, jsonEncode(user));
  }

  Future<void> saveLoginStatus(bool isLoggedIn) async {
    await _prefs.setBool(AppConstants.isLoggedInKey, isLoggedIn);
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

  Future<void> saveRememberedEmail(String email) async {
    await _prefs.setString("remembered_email", email);
  }

  Future<String?> getRememberedEmail() async {
    return _prefs.getString("remembered_email");
  }

  Future<void> clearRememberedEmail() async {
    await _prefs.remove("remembered_email");
  }

  Future<void> saveCachedLocation(String location) async {
    await _prefs.setString("cached_location", location);
  }

  String? getCachedLocation() {
    return _prefs.getString("cached_location");
  }

  Future<void> clearCachedLocation() async {
    await _prefs.remove("cached_location");
  }

  Future<void> clear() async {
    await _prefs.clear();
  }

  Future<void> clearAll() async {
    await _prefs.clear();
  }

  Future<bool> isLoggedIn() async {
    return _prefs.getBool(AppConstants.isLoggedInKey) ?? false;
  }
}
