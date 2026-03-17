import 'package:flutter/material.dart';
import '../models/rappel_medicament.dart';
import '../services/rappel_service.dart';

class RappelsScreen extends StatefulWidget {
  final int patientId;

  const RappelsScreen({super.key, required this.patientId});

  @override
  State<RappelsScreen> createState() => _RappelsScreenState();
}

class _RappelsScreenState extends State<RappelsScreen> {
  final RappelService rappelService = RappelService();

  List<RappelMedicament> rappels = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    loadRappels();
  }

  Future<void> loadRappels() async {
    try {
      final result = await rappelService.getRappels();
      setState(() {
        rappels = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  String formatActif(bool actif) {
    return actif ? 'Actif' : 'Inactif';
  }

  String formatHeure(String? heure) {
    if (heure == null || heure.isEmpty) return '-';
    return heure.length >= 5 ? heure.substring(0, 5) : heure;
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF2F80ED);
    const Color cardColor = Color(0xFFF5F7FB);
    const Color textColor = Color(0xFF1F2937);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Alarmes médicaments'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: textColor,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Expanded(
                        child: rappels.isEmpty
                            ? const Center(
                                child: Text('Aucun rappel trouvé'),
                              )
                            : ListView.builder(
                                itemCount: rappels.length,
                                itemBuilder: (context, index) {
                                  final rappel = rappels[index];

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 14),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: cardColor,
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          height: 44,
                                          width: 44,
                                          decoration: BoxDecoration(
                                            color: primaryColor.withOpacity(0.12),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: const Icon(
                                            Icons.alarm_outlined,
                                            color: primaryColor,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Rappel médicament',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700,
                                                  color: textColor,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                'Heure : ${formatHeure(rappel.heure)}',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black54,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Statut : ${formatActif(rappel.actif)}',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: rappel.actif
                                                      ? const Color(0xFF16A34A)
                                                      : const Color(0xFFDC2626),
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Switch(
                                          value: rappel.actif,
                                          onChanged: null,
                                          activeColor: primaryColor,
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Ajout de rappel à implémenter'),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add_alarm),
                          label: const Text('Ajouter un rappel'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}