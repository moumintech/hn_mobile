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
  final PrescriptionService _service = PrescriptionService();

  List<Prescription> _list    = [];
  bool               _loading = true;
  String             _error   = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = ''; });
    try {
      final data = await _service.getPrescriptions();
      if (mounted) setState(() { _list = data; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primary = Color(0xFF2F80ED);
    const Color amber   = Color(0xFFF59E0B);
    const Color green   = Color(0xFF10B981);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text(
          'Mes prescriptions',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1F2937),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _load,
            icon: const Icon(Icons.refresh_outlined),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.wifi_off_outlined, size: 48, color: Colors.black26),
                      const SizedBox(height: 12),
                      Text(_error, textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.black54)),
                      const SizedBox(height: 14),
                      TextButton.icon(
                        onPressed: _load,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Réessayer'),
                      ),
                    ],
                  ),
                )
              : _list.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.description_outlined,
                              size: 56,
                              color: Colors.black.withValues(alpha: 0.2)),
                          const SizedBox(height: 14),
                          const Text('Aucune prescription trouvée',
                              style: TextStyle(color: Colors.black45)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _list.length,
                      itemBuilder: (_, i) {
                        final p = _list[i];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // En-tête ordonnance
                                Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: amber.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(Icons.receipt_long_outlined,
                                          color: amber, size: 22),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Ordonnance #${p.idOrdonnance}',
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF1F2937),
                                            ),
                                          ),
                                          if (p.datePrescription != null &&
                                              p.datePrescription!.isNotEmpty)
                                            Text(
                                              'Date : ${p.datePrescription}',
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.black45),
                                            ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: (p.estValide ? green : Colors.grey)
                                            .withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                      child: Text(
                                        p.estValide ? 'Valide' : 'Expirée',
                                        style: TextStyle(
                                          color: p.estValide ? green : Colors.grey,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                // Instructions
                                if (p.instructionsGenerales != null &&
                                    p.instructionsGenerales!.isNotEmpty) ...[
                                  const SizedBox(height: 10),
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: primary.withValues(alpha: 0.05),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Icon(Icons.info_outline,
                                            size: 15, color: primary),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            p.instructionsGenerales!,
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: Color(0xFF374151)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],

                                // Liste médicaments
                                if (p.medicaments.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  const Divider(height: 1),
                                  const SizedBox(height: 10),
                                  const Text(
                                    'MÉDICAMENTS',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black38,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ...p.medicaments.map(
                                    (m) => Container(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF5F7FB),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            m.medicament ?? '',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 13,
                                              color: Color(0xFF1F2937),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          _medRow(Icons.science_outlined,
                                              m.dosage),
                                          _medRow(Icons.schedule_outlined,
                                              m.frequence),
                                          _medRow(Icons.timelapse_outlined,
                                              m.duree),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }

  Widget _medRow(IconData icon, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 3),
      child: Row(
        children: [
          Icon(icon, size: 13, color: Colors.black38),
          const SizedBox(width: 5),
          Text(value,
              style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
        ],
      ),
    );
  }
}
