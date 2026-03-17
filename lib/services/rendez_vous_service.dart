import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/rendez_vous.dart';
import 'session_service.dart';

class RendezVousService {
  final SessionService sessionService = SessionService();

  Future<List<RendezVous>> getRendezVous() async {
    final String? token = await sessionService.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Token manquant. Veuillez vous reconnecter.');
    }

    final url = Uri.parse('${ApiConfig.baseUrl}/patient/get_rendez_vous.php');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      final List list = data['rendez_vous'];
      return list.map((item) => RendezVous.fromJson(item)).toList();
    } else {
      throw Exception(
        data['message'] ?? 'Erreur lors du chargement des rendez-vous',
      );
    }
  }
}