import 'package:flutter/material.dart';
import '../models/patient.dart';
import '../services/patient_service.dart';
import '../services/session_service.dart';
import 'login_screen.dart';
import 'dossier_patient_screen.dart';
import 'prescriptions_screen.dart';
import 'options_screen.dart';

class HomeScreen extends StatefulWidget {
  final int patientId;
  final void Function(int index)? onTabChange;

  const HomeScreen({super.key, required this.patientId, this.onTabChange});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PatientService  _patientService  = PatientService();
  final SessionService  _sessionService  = SessionService();

  Patient? _patient;
  bool     _loadingProfile = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final p = await _patientService.getPatient();
      if (mounted) setState(() { _patient = p; _loadingProfile = false; });
    } catch (_) {
      if (mounted) setState(() => _loadingProfile = false);
    }
  }

  Future<void> _logout() async {
    await _sessionService.clearSession();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _push(Widget screen) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => screen));

  @override
  Widget build(BuildContext context) {
    const Color primary = Color(0xFF2F80ED);
    const Color bg      = Color(0xFFF5F7FB);

    final String prenom = _patient?.prenom ?? '';
    final String nom    = _patient?.nom    ?? '';
    final String fullName = '${prenom.isNotEmpty ? prenom : ''} ${nom.isNotEmpty ? nom : ''}'.trim();

    return Scaffold(
      backgroundColor: bg,
      body: Column(
        children: [

          // ── Header ──────────────────────────────────────────────────
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
                padding: const EdgeInsets.fromLTRB(20, 16, 12, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Barre logo + déconnexion
                    Row(
                      children: [
                        const Icon(Icons.local_hospital_outlined,
                            color: Colors.white, size: 24),
                        const SizedBox(width: 8),
                        const Text(
                          'HealthNorth',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 20,
                            letterSpacing: 0.4,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: _logout,
                          icon: const Icon(Icons.logout,
                              color: Colors.white70, size: 22),
                          tooltip: 'Déconnexion',
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Profil
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor:
                              Colors.white.withValues(alpha: 0.20),
                          backgroundImage:
                              (_patient?.photo != null && _patient!.photo!.isNotEmpty)
                                  ? NetworkImage(_patient!.photo!)
                                  : null,
                          child: (_patient?.photo == null ||
                                  _patient!.photo!.isEmpty)
                              ? Text(
                                  prenom.isNotEmpty ? prenom[0].toUpperCase() : '?',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 14),
                        _loadingProfile
                            ? const CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2.5)
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    fullName.isEmpty ? 'Patient' : fullName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.20),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: const Text(
                                      'Bienvenue !',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Cartes de raccourcis ─────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'MON ESPACE',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.black45,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),

                  _card(
                    icon: Icons.folder_shared_outlined,
                    color: primary,
                    title: 'Mes informations',
                    subtitle: 'Dossier & profil patient',
                    onTap: () => _push(
                        DossierPatientScreen(patientId: widget.patientId)),
                  ),
                  _card(
                    icon: Icons.calendar_today_outlined,
                    color: const Color(0xFF10B981),
                    title: 'Mes rendez-vous',
                    subtitle: 'Consulter & gérer',
                    onTap: () => widget.onTabChange?.call(1),
                  ),
                  _card(
                    icon: Icons.description_outlined,
                    color: const Color(0xFFF59E0B),
                    title: 'Mes prescriptions',
                    subtitle: 'Ordonnances médicales',
                    onTap: () => _push(
                        PrescriptionsScreen(patientId: widget.patientId)),
                  ),
                  _card(
                    icon: Icons.alarm_outlined,
                    color: const Color(0xFF8B5CF6),
                    title: 'Alarmes médicaments',
                    subtitle: 'Rappels & alertes',
                    onTap: () => widget.onTabChange?.call(2),
                  ),
                  _card(
                    icon: Icons.settings_outlined,
                    color: const Color(0xFF6B7280),
                    title: 'Paramètres',
                    subtitle: 'Préférences & options',
                    onTap: () =>
                        _push(OptionsScreen(patientId: widget.patientId)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 15,
            color: Color(0xFF1F2937),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: Colors.black45),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.black26),
        onTap: onTap,
      ),
    );
  }
}
