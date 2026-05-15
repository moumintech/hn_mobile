import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/rendez_vous.dart';
import '../services/logger_service.dart';
import 'session_service.dart';

class RendezVousService {
  static const String _tag = 'RendezVousService';
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

  // --- Récupération des rendez-vous ---
  Future<List<RendezVous>> getRendezVous() async {
    final url = Uri.parse(ApiConfig.getRendezVousEndpoint);

    try {
      AppLogger.info('Chargement des rendez-vous', tag: _tag);
      AppLogger.network(method: 'POST', url: url.toString());

      final response = await http.post(
        url,
        headers: await _authHeaders(),
        body: jsonEncode({}),
      ).timeout(const Duration(seconds: 10));

      AppLogger.network(method: 'POST', url: url.toString(), statusCode: response.statusCode);

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        final list = data['rendez_vous'] as List;
        AppLogger.info('${list.length} rendez-vous chargé(s)', tag: _tag);
        return list.map((item) => RendezVous.fromJson(item)).toList();
      }
      throw Exception(data['message'] ?? 'Erreur lors du chargement des rendez-vous');
    } on TimeoutException {
      AppLogger.error('Timeout getRendezVous', tag: _tag);
      throw Exception('Le serveur met trop de temps à répondre.');
    } catch (e) {
      AppLogger.error('getRendezVous échoué', tag: _tag, exception: e);
      rethrow;
    }
  }

  // --- Activer / Désactiver le rappel d'un rendez-vous ---
  Future<Map<String, dynamic>> toggleRappelRdv({
    required int idRdv,
    required bool rappelActif,
  }) async {
    final url = Uri.parse(ApiConfig.toggleRappelRdvEndpoint);

    try {
      AppLogger.info('Toggle rappel RDV #$idRdv -> rappelActif=$rappelActif', tag: _tag);
      AppLogger.network(method: 'POST', url: url.toString());

      final response = await http.post(
        url,
        headers: await _authHeaders(),
        body: jsonEncode({'id_rdv': idRdv, 'rappel_actif': rappelActif ? 1 : 0}),
      ).timeout(const Duration(seconds: 10));

      AppLogger.network(
        method: 'POST',
        url: url.toString(),
        statusCode: response.statusCode,
        body: response.body,
      );

      if (response.body.isEmpty) {
        return {'success': false, 'message': 'Réponse vide du serveur.'};
      }

      return jsonDecode(response.body) as Map<String, dynamic>;
    } on TimeoutException {
      AppLogger.error('Timeout toggleRappelRdv', tag: _tag);
      return {'success': false, 'message': 'Délai d\'attente dépassé.'};
    } catch (e) {
      AppLogger.error('toggleRappelRdv échoué', tag: _tag, exception: e);
      return {'success': false, 'message': 'Impossible de contacter le serveur : $e'};
    }
  }
}
