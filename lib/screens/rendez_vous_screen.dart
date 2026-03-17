import 'package:flutter/material.dart';
import '../models/rendez_vous.dart';
import '../services/rendez_vous_service.dart';

class RendezVousScreen extends StatefulWidget {
  final int patientId;

  const RendezVousScreen({super.key, required this.patientId});

  @override
  State<RendezVousScreen> createState() => _RendezVousScreenState();
}

class _RendezVousScreenState extends State<RendezVousScreen> {
  final RendezVousService rendezVousService = RendezVousService();

  List<RendezVous> rendezVousList = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    loadRendezVous();
  }

  Future<void> loadRendezVous() async {
    try {
      final result = await rendezVousService.getRendezVous();
      setState(() {
        rendezVousList = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Color getStatusColor(String? statut) {
    if (statut == null) return Colors.grey;
    final s = statut.toLowerCase();

    if (s.contains('confirm')) return const Color(0xFF16A34A);
    if (s.contains('attente')) return const Color(0xFFF59E0B);
    if (s.contains('annul')) return const Color(0xFFDC2626);

    return const Color(0xFF2F80ED);
  }

  String formatDate(String? date) {
    if (date == null || date.isEmpty) return '-';
    return date;
  }

  String formatHeure(String? heure) {
    if (heure == null || heure.isEmpty) return '-';
    return heure.length >= 5 ? heure.substring(0, 5) : heure;
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF2F80ED);
    const Color textColor = Color(0xFF1F2937);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Mes rendez-vous'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: textColor,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : rendezVousList.isEmpty
                  ? const Center(child: Text('Aucun rendez-vous trouvé'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: rendezVousList.length,
                      itemBuilder: (context, index) {
                        final rdv = rendezVousList[index];
                        final statusColor = getStatusColor(rdv.statut);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F7FB),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    height: 44,
                                    width: 44,
                                    decoration: BoxDecoration(
                                      color: primaryColor.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.calendar_today_outlined,
                                      color: primaryColor,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      '${rdv.specialistePrenom ?? ''} ${rdv.specialisteNom ?? ''}'.trim().isEmpty
                                          ? 'Spécialiste'
                                          : '${rdv.specialistePrenom ?? ''} ${rdv.specialisteNom ?? ''}'.trim(),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: textColor,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: statusColor.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      rdv.statut ?? '-',
                                      style: TextStyle(
                                        color: statusColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 14),

                              Text(
                                rdv.specialite == null || rdv.specialite!.isEmpty
                                    ? '-'
                                    : rdv.specialite!,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),

                              const SizedBox(height: 16),

                              Row(
                                children: [
                                  const Icon(Icons.event_outlined,
                                      size: 18, color: Colors.black54),
                                  const SizedBox(width: 8),
                                  Text(
                                    formatDate(rdv.dateRdv),
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  const Icon(Icons.access_time_outlined,
                                      size: 18, color: Colors.black54),
                                  const SizedBox(width: 8),
                                  Text(
                                    formatHeure(rdv.heureRdv),
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.location_on_outlined,
                                      size: 18, color: Colors.black54),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '${rdv.etablissementNom ?? '-'}\n${rdv.adresse ?? '-'}',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
    );
  }
}