import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/rappel_medicament.dart';
import '../services/logger_service.dart';
import 'session_service.dart';

class RappelService {
  static const String _tag = 'RappelService';
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

  // --- Récupération des rappels médicaments ---
  Future<List<RappelMedicament>> getRappels() async {
    final url = Uri.parse(ApiConfig.getRappelsEndpoint);
    try {
      AppLogger.info('Chargement des rappels médicaments', tag: _tag);
      final response = await http.get(url, headers: await _authHeaders())
          .timeout(const Duration(seconds: 10));
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200 && data['success'] == true) {
        final list = data['rappels'] as List;
        return list.map((item) => RappelMedicament.fromJson(item)).toList();
      }
      throw Exception(data['message'] ?? 'Erreur lors du chargement des rappels');
    } on TimeoutException {
      throw Exception('Le serveur met trop de temps à répondre.');
    } catch (e) {
      AppLogger.error('getRappels échoué', tag: _tag, exception: e);
      rethrow;
    }
  }

  // --- Activer / Désactiver un rappel ---
  Future<Map<String, dynamic>> toggleRappel({
    required int idRappel,
    required bool actif,
  }) async {
    final url = Uri.parse(ApiConfig.toggleRappelEndpoint);
    try {
      final response = await http.post(
        url,
        headers: await _authHeaders(),
        body: jsonEncode({'id_rappel': idRappel, 'actif': actif ? 1 : 0}),
      ).timeout(const Duration(seconds: 10));
      if (response.body.isEmpty) {
        return {'success': false, 'message': 'Réponse vide du serveur.'};
      }
      return jsonDecode(response.body) as Map<String, dynamic>;
    } on TimeoutException {
      return {'success': false, 'message': 'Délai d\'attente dépassé.'};
    } catch (e) {
      return {'success': false, 'message': 'Impossible de contacter le serveur.'};
    }
  }

  // --- Ajouter un rappel ---
  Future<Map<String, dynamic>> addRappel({
    required String medicament,
    required String heure, // "HH:mm"
  }) async {
    final url = Uri.parse(ApiConfig.addRappelEndpoint);
    try {
      AppLogger.info('Ajout rappel: $medicament à $heure', tag: _tag);
      final response = await http.post(
        url,
        headers: await _authHeaders(),
        body: jsonEncode({'medicament': medicament, 'heure': heure}),
      ).timeout(const Duration(seconds: 10));
      if (response.body.isEmpty) {
        return {'success': false, 'message': 'Réponse vide du serveur.'};
      }
      return jsonDecode(response.body) as Map<String, dynamic>;
    } on TimeoutException {
      return {'success': false, 'message': 'Délai d\'attente dépassé.'};
    } catch (e) {
      AppLogger.error('addRappel échoué', tag: _tag, exception: e);
      return {'success': false, 'message': 'Impossible de contacter le serveur.'};
    }
  }

  // --- Supprimer un rappel ---
  Future<Map<String, dynamic>> deleteRappel(int idRappel) async {
    final url = Uri.parse(ApiConfig.deleteRappelEndpoint);
    try {
      AppLogger.info('Suppression rappel #$idRappel', tag: _tag);
      final response = await http.post(
        url,
        headers: await _authHeaders(),
        body: jsonEncode({'id_rappel': idRappel}),
      ).timeout(const Duration(seconds: 10));
      if (response.body.isEmpty) {
        return {'success': false, 'message': 'Réponse vide du serveur.'};
      }
      return jsonDecode(response.body) as Map<String, dynamic>;
    } on TimeoutException {
      return {'success': false, 'message': 'Délai d\'attente dépassé.'};
    } catch (e) {
      AppLogger.error('deleteRappel échoué', tag: _tag, exception: e);
      return {'success': false, 'message': 'Impossible de contacter le serveur.'};
    }
  }
}
