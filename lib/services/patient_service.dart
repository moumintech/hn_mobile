import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/patient.dart';
import '../services/logger_service.dart';
import '../services/session_service.dart';

class PatientService {
  static const String _tag = 'PatientService';
  final SessionService sessionService = SessionService();

  Future<Map<String, String>> _authHeaders() async {
    final token = await sessionService.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Token manquant. Veuillez vous reconnecter.');
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // --- Récupération du profil patient ---
  Future<Patient> getPatient() async {
    final url = Uri.parse(ApiConfig.getPatientEndpoint);
    try {
      AppLogger.info('Chargement du dossier patient', tag: _tag);
      final response = await http.get(url, headers: await _authHeaders())
          .timeout(const Duration(seconds: 10));
      if (response.body.isEmpty) throw Exception('Réponse vide du serveur.');
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200 && data['success'] == true) {
        return Patient.fromJson(data['patient']);
      }
      throw Exception(data['message'] ?? 'Erreur chargement profil');
    } on TimeoutException {
      throw Exception('Le serveur met trop de temps à répondre.');
    } catch (e) {
      AppLogger.error('getPatient échoué', tag: _tag, exception: e);
      rethrow;
    }
  }

  // --- Mise à jour du profil patient ---
  Future<Map<String, dynamic>> updatePatient({
    required String telephone,
    required String personneAContacter,
    String contactUrgenceTel = '',
    String numSecu           = '',
    String adresse           = '',
    String ville             = '',
    String codePostal        = '',
  }) async {
    final url = Uri.parse(ApiConfig.updatePatientEndpoint);
    try {
      AppLogger.info('Mise à jour du profil patient', tag: _tag);
      final response = await http.post(
        url,
        headers: await _authHeaders(),
        body: jsonEncode({
          'telephone':            telephone,
          'personne_a_contacter': personneAContacter,
          'contact_urgence_tel':  contactUrgenceTel,
          'num_secu':             numSecu,
          'adresse':              adresse,
          'ville':                ville,
          'code_postal':          codePostal,
        }),
      ).timeout(const Duration(seconds: 10));
      if (response.body.isEmpty) {
        return {'success': false, 'message': 'Réponse vide du serveur.'};
      }
      return jsonDecode(response.body) as Map<String, dynamic>;
    } on TimeoutException {
      return {'success': false, 'message': 'Délai d\'attente dépassé.'};
    } catch (e) {
      AppLogger.error('updatePatient échoué', tag: _tag, exception: e);
      return {'success': false, 'message': 'Impossible de contacter le serveur.'};
    }
  }
}
