import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/option_model.dart';
import '../services/logger_service.dart';
import 'session_service.dart';

class OptionService {
  static const String _tag = 'OptionService';
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

  // --- Récupération des options ---
  Future<List<OptionModel>> getOptions() async {
    final url = Uri.parse(ApiConfig.getOptionsEndpoint);

    try {
      AppLogger.info('Chargement des options', tag: _tag);
      AppLogger.network(method: 'POST', url: url.toString());

      final response = await http.post(
        url,
        headers: await _authHeaders(),
        body: jsonEncode({}),
      ).timeout(const Duration(seconds: 10));

      AppLogger.network(method: 'POST', url: url.toString(), statusCode: response.statusCode);

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        final list = data['options'] as List;
        AppLogger.info('${list.length} option(s) chargée(s)', tag: _tag);
        return list.map((item) => OptionModel.fromJson(item)).toList();
      }
      throw Exception(data['message'] ?? 'Erreur lors du chargement des options');
    } on TimeoutException {
      AppLogger.error('Timeout getOptions', tag: _tag);
      throw Exception('Le serveur met trop de temps à répondre.');
    } catch (e) {
      AppLogger.error('getOptions échoué', tag: _tag, exception: e);
      rethrow;
    }
  }

  // --- Activer / Désactiver une option ---
  Future<Map<String, dynamic>> updateOption({
    required int idOption,
    required bool active,
  }) async {
    final url = Uri.parse(ApiConfig.updateOptionEndpoint);

    try {
      AppLogger.info('Toggle option #$idOption -> active=$active', tag: _tag);
      AppLogger.network(method: 'POST', url: url.toString());

      final response = await http.post(
        url,
        headers: await _authHeaders(),
        body: jsonEncode({'id_option': idOption, 'active': active ? 1 : 0}),
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
      AppLogger.error('Timeout updateOption', tag: _tag);
      return {'success': false, 'message': 'Délai d\'attente dépassé.'};
    } catch (e) {
      AppLogger.error('updateOption échoué', tag: _tag, exception: e);
      return {'success': false, 'message': 'Impossible de contacter le serveur : $e'};
    }
  }
}
