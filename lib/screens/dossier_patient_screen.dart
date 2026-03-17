import 'package:flutter/material.dart';
import '../models/patient.dart';
import '../services/patient_service.dart';

class DossierPatientScreen extends StatefulWidget {
  final int patientId;

  const DossierPatientScreen({super.key, required this.patientId});

  @override
  State<DossierPatientScreen> createState() => _DossierPatientScreenState();
}

class _DossierPatientScreenState extends State<DossierPatientScreen> {
  final PatientService patientService = PatientService();

  Patient? patient;
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    loadPatient();
  }

  Future<void> loadPatient() async {
    try {
      final result = await patientService.getPatient();
      setState(() {
        patient = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Widget buildInfoCard({
    required IconData icon,
    required String label,
    required String? value,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FB),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF2F80ED)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  (value == null || value.isEmpty) ? '-' : value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF2F80ED);
    const Color textColor = Color(0xFF1F2937);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Mon profil'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: textColor,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : patient == null
                  ? const Center(child: Text('Aucune donnée'))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const SizedBox(height: 8),

                          CircleAvatar(
                            radius: 42,
                            backgroundColor: primaryColor.withOpacity(0.12),
                            child: const Icon(
                              Icons.person,
                              size: 46,
                              color: primaryColor,
                            ),
                          ),

                          const SizedBox(height: 14),

                          Text(
                            '${patient!.prenom} ${patient!.nom}',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: textColor,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 6),

                          Text(
                            patient!.email == null || patient!.email!.isEmpty
                                ? 'Patient'
                                : patient!.email!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 28),

                          buildInfoCard(
                            icon: Icons.badge_outlined,
                            label: 'Numéro de sécurité sociale',
                            value: patient!.numSecu,
                          ),
                          buildInfoCard(
                            icon: Icons.cake_outlined,
                            label: 'Date de naissance',
                            value: patient!.dateNaissance,
                          ),
                          buildInfoCard(
                            icon: Icons.phone_outlined,
                            label: 'Téléphone',
                            value: patient!.telephone,
                          ),
                          buildInfoCard(
                            icon: Icons.contact_phone_outlined,
                            label: 'Personne à contacter',
                            value: patient!.personneAContacter,
                          ),
                          buildInfoCard(
                            icon: Icons.local_hospital_outlined,
                            label: 'Médecin traitant',
                            value: patient!.medecinTraitant,
                          ),

                          const SizedBox(height: 20),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Modification à implémenter'),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: const Text('Modifier mes informations'),
                            ),
                          ),
                        ],
                      ),
                    ),
    );
  }
}