import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/patient.dart';
import '../services/session_service.dart';

class PatientService {
  final SessionService sessionService = SessionService();

  Future<Patient> getPatient() async {
    final String? token = await sessionService.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Token manquant. Veuillez vous reconnecter.');
    }

    final url = Uri.parse('${ApiConfig.baseUrl}/patient/get_patient.php');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({}),
    );

    final Map<String, dynamic> data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      return Patient.fromJson(data['patient']);
    } else {
      throw Exception(
        data['message'] ?? 'Erreur lors du chargement du dossier patient',
      );
    }
  }
}