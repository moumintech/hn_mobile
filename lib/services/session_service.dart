import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const String _patientIdKey = 'patient_id';
  static const String _tokenKey = 'api_token';

  // --- Patient ID ---
  Future<void> savePatientId(int patientId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_patientIdKey, patientId);
  }

  Future<int?> getPatientId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_patientIdKey);
  }

  // --- Token JWT ---
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  // --- Déconnexion complète ---
  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_patientIdKey);
    await prefs.remove(_tokenKey);
  }
}
