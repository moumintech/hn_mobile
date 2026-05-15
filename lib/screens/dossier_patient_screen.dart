import 'package:flutter/material.dart';
import '../models/patient.dart';
import '../services/patient_service.dart';
import 'edit_profile_screen.dart';

class DossierPatientScreen extends StatefulWidget {
  final int patientId;
  final VoidCallback? onGoHome;

  const DossierPatientScreen({super.key, required this.patientId, this.onGoHome});

  @override
  State<DossierPatientScreen> createState() => _DossierPatientScreenState();
}

class _DossierPatientScreenState extends State<DossierPatientScreen> {
  final PatientService _patientService = PatientService();

  Patient? _patient;
  bool     _isLoading   = true;
  String   _errorMsg    = '';

  @override
  void initState() {
    super.initState();
    loadPatient();
  }

  Future<void> loadPatient() async {
    setState(() { _isLoading = true; _errorMsg = ''; });
    try {
      final p = await _patientService.getPatient();
      if (mounted) setState(() { _patient = p; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _errorMsg = e.toString(); _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primary = Color(0xFF2F80ED);
    const Color bg      = Color(0xFFF5F7FB);

    return Scaffold(
      backgroundColor: bg,
      body: Column(
        children: [
          // ── Header ─────────────────────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              color: primary,
              borderRadius: BorderRadius.only(
                bottomLeft:  Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                child: Column(
                  children: [
                    // Barre titre
                    Row(
                      children: [
                        if (widget.onGoHome != null)
                          IconButton(
                            onPressed: widget.onGoHome,
                            icon: const Icon(Icons.arrow_back_ios_new,
                                color: Colors.white, size: 20),
                            tooltip: 'Accueil',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        if (widget.onGoHome != null) const SizedBox(width: 4),
                        const Icon(Icons.local_hospital_outlined,
                            color: Colors.white, size: 22),
                        const SizedBox(width: 8),
                        const Text(
                          'HealthNorth',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                        ),
                        const Spacer(),
                        if (!_isLoading && _errorMsg.isEmpty)
                          IconButton(
                            onPressed: loadPatient,
                            icon: const Icon(Icons.refresh,
                                color: Colors.white70),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Avatar + nom
                    if (!_isLoading && _patient != null) ...[
                      CircleAvatar(
                        radius: 38,
                        backgroundColor:
                            Colors.white.withValues(alpha: 0.20),
                        backgroundImage:
                            (_patient!.photo != null && _patient!.photo!.isNotEmpty)
                                ? NetworkImage(_patient!.photo!)
                                : null,
                        child: (_patient!.photo == null ||
                                _patient!.photo!.isEmpty)
                            ? Text(
                                (_patient!.prenom.isNotEmpty ? _patient!.prenom : '?')[0].toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${_patient!.prenom} ${_patient!.nom}'.trim(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Profil Patient',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.75),
                          fontSize: 13,
                        ),
                      ),
                    ] else if (_isLoading)
                      const CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.5),
                  ],
                ),
              ),
            ),
          ),

          // ── Contenu ─────────────────────────────────────────────────
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMsg.isNotEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_errorMsg, textAlign: TextAlign.center),
                            const SizedBox(height: 14),
                            TextButton.icon(
                              onPressed: loadPatient,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Réessayer'),
                            ),
                          ],
                        ),
                      )
                    : _patient == null
                        ? const Center(child: Text('Aucune donnée'))
                        : SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                // Infos card
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(18),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black
                                            .withValues(alpha: 0.05),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _infoRow(Icons.person_outline,
                                          'Nom', _patient!.nom),
                                      _infoRow(Icons.person_outline,
                                          'Prénom', _patient!.prenom),
                                      _infoRow(Icons.badge_outlined,
                                          'N° Sécurité sociale',
                                          _patient!.numSecu),
                                      _infoRow(Icons.email_outlined,
                                          'Email', _patient!.email),
                                      _infoRow(Icons.phone_outlined,
                                          'Téléphone', _patient!.telephone),
                                      _infoRow(
                                          Icons.contact_phone_outlined,
                                          'Personne à contacter',
                                          _patient!.personneAContacter),
                                      _infoRow(Icons.medical_services_outlined,
                                          'Médecin traitant',
                                          _patient!.medecinTraitant,
                                          showDivider: false),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 20),

                                // Bouton modifier
                                SizedBox(
                                  width: double.infinity,
                                  height: 52,
                                  child: ElevatedButton.icon(
                                    onPressed: () async {
                                      final updated =
                                          await Navigator.push<bool>(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => EditProfileScreen(
                                              patient: _patient!),
                                        ),
                                      );
                                      if (updated == true) loadPatient();
                                    },
                                    icon: const Icon(Icons.edit_outlined),
                                    label: const Text(
                                      'Modifier les informations',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primary,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(14),
                                      ),
                                      elevation: 0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String? value,
      {bool showDivider = true}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 20, color: const Color(0xFF2F80ED)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.black45,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      (value == null || value.isEmpty) ? '—' : value,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (showDivider) const Divider(height: 1, thickness: 0.5),
      ],
    );
  }
}
