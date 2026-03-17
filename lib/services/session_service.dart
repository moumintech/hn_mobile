import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const String patientIdKey = 'patient_id';

  Future<void> savePatientId(int patientId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(patientIdKey, patientId);
  }

  Future<int?> getPatientId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(patientIdKey);
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(patientIdKey);
  }
  static const String tokenKey = 'api_token';

Future<void> saveToken(String token) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(tokenKey, token);
}

Future<String?> getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(tokenKey);
}
}