import 'package:flutter/material.dart';
import '../models/prescription.dart';
import '../services/prescription_service.dart';

class PrescriptionsScreen extends StatefulWidget {
  final int patientId;

  const PrescriptionsScreen({super.key, required this.patientId});

  @override
  State<PrescriptionsScreen> createState() => _PrescriptionsScreenState();
}

class _PrescriptionsScreenState extends State<PrescriptionsScreen> {
  final PrescriptionService prescriptionService = PrescriptionService();

  List<Prescription> prescriptions = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    loadPrescriptions();
  }

 Future<void> loadPrescriptions() async {
  try {
    final result = await prescriptionService.getPrescriptions();
    setState(() {
      prescriptions = result;
      isLoading = false;
    });
  } catch (e) {
    setState(() {
      errorMessage = e.toString();
      isLoading = false;
    });
  }
}

  Widget buildInfoRow(IconData icon, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.black54),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$label : ${(value == null || value.isEmpty) ? '-' : value}',
              style: const TextStyle(fontSize: 14, color: Color(0xFF1F2937)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF2F80ED);
    const Color cardColor = Color(0xFFF5F7FB);
    const Color textColor = Color(0xFF1F2937);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Mes prescriptions'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: textColor,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : prescriptions.isEmpty
                  ? const Center(child: Text('Aucune prescription trouvée'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: prescriptions.length,
                      itemBuilder: (context, index) {
                        final p = prescriptions[index];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cardColor,
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
                                      Icons.medication_outlined,
                                      color: primaryColor,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      p.medicament == null || p.medicament!.isEmpty
                                          ? 'Prescription'
                                          : p.medicament!,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: textColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 14),

                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: primaryColor.withOpacity(0.10),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  'Ordonnance #${p.idOrdonnance}',
                                  style: const TextStyle(
                                    color: primaryColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 16),

                              buildInfoRow(
                                Icons.event_outlined,
                                'Date',
                                p.dateOrdonnance,
                              ),
                              buildInfoRow(
                                Icons.description_outlined,
                                'Description',
                                p.description,
                              ),
                              buildInfoRow(
                                Icons.science_outlined,
                                'Dosage',
                                p.dosage,
                              ),
                              buildInfoRow(
                                Icons.schedule_outlined,
                                'Fréquence',
                                p.frequence,
                              ),
                              buildInfoRow(
                                Icons.timelapse_outlined,
                                'Durée',
                                p.duree,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
    );
  }
}