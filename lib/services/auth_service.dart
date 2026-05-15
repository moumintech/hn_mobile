import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../services/logger_service.dart';

class AuthService {
  static const String _tag = 'AuthService';

  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse(ApiConfig.loginEndpoint);

    try {
      AppLogger.info('Tentative de connexion : $email', tag: _tag);
      AppLogger.network(method: 'POST', url: url.toString());

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': email, 'password': password}),
      ).timeout(const Duration(seconds: 10));

      AppLogger.network(
        method: 'POST',
        url: url.toString(),
        statusCode: response.statusCode,
        body: response.body,
      );

      if (response.body.isEmpty) {
        AppLogger.warning('Réponse vide du serveur', tag: _tag);
        return {'success': false, 'message': 'Réponse vide du serveur.'};
      }

      return jsonDecode(response.body);
    } on TimeoutException {
      AppLogger.error('Timeout lors de la connexion', tag: _tag);
      return {'success': false, 'message': 'Délai d\'attente dépassé (vérifiez votre serveur).'};
    } catch (e) {
      AppLogger.error('Erreur de connexion', tag: _tag, exception: e);
      return {
        'success': false,
        'message': 'Impossible de joindre le serveur. Vérifiez que XAMPP est lancé.',
      };
    }
  }
}
