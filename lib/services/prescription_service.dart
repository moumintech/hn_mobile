import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/prescription.dart';
import '../services/logger_service.dart';
import 'session_service.dart';

class PrescriptionService {
  static const String _tag = 'PrescriptionService';
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

  Future<List<Prescription>> getPrescriptions() async {
    final url = Uri.parse(ApiConfig.getPrescriptionsEndpoint);

    try {
      AppLogger.info('Chargement des prescriptions', tag: _tag);
      AppLogger.network(method: 'GET', url: url.toString());

      final response = await http.get(
        url,
        headers: await _authHeaders(),
      ).timeout(const Duration(seconds: 10));

      AppLogger.network(method: 'GET', url: url.toString(), statusCode: response.statusCode);

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        final list = data['prescriptions'] as List;
        AppLogger.info('${list.length} ordonnance(s) chargée(s)', tag: _tag);
        return list
            .map((item) => Prescription.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      throw Exception(data['message'] ?? 'Erreur lors du chargement des prescriptions');
    } on TimeoutException {
      AppLogger.error('Timeout getPrescriptions', tag: _tag);
      throw Exception('Le serveur met trop de temps à répondre.');
    } catch (e) {
      AppLogger.error('getPrescriptions échoué', tag: _tag, exception: e);
      rethrow;
    }
  }
}
