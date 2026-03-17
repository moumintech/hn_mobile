import 'package:flutter/material.dart';
import '../services/session_service.dart';
import 'login_screen.dart';
import 'dossier_patient_screen.dart';
import 'rendez_vous_screen.dart';
import 'prescriptions_screen.dart';
import 'rappels_screen.dart';
import 'options_screen.dart';

class HomeScreen extends StatelessWidget {
  final int patientId;

  const HomeScreen({super.key, required this.patientId});

  void _goTo(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  Future<void> logout(BuildContext context) async {
    final sessionService = SessionService();
    await sessionService.clearSession();

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  Widget buildMenuButton({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Widget screen,
  }) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        elevation: 3,
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: ListTile(
          leading: Icon(icon, color: Colors.blue),
          title: Text(title),
          trailing: const Icon(Icons.arrow_forward_ios, size: 18),
          onTap: () => _goTo(context, screen),
        ),
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
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: textColor,
        title: const Text(
          'Accueil',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => logout(context),
            icon: const Icon(Icons.logout),
            tooltip: 'Déconnexion',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bienvenue dans votre espace patient',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 20),
            buildMenuButton(
              context: context,
              title: 'Mon dossier patient',
              icon: Icons.person_outline,
              screen: DossierPatientScreen(patientId: patientId),
            ),
            buildMenuButton(
              context: context,
              title: 'Mes rendez-vous',
              icon: Icons.calendar_today_outlined,
              screen: RendezVousScreen(patientId: patientId),
            ),
            buildMenuButton(
              context: context,
              title: 'Mes prescriptions',
              icon: Icons.medication_outlined,
              screen: PrescriptionsScreen(patientId: patientId),
            ),
            buildMenuButton(
              context: context,
              title: 'Mes rappels',
              icon: Icons.alarm_outlined,
              screen: RappelsScreen(patientId: patientId),
            ),
            buildMenuButton(
              context: context,
              title: 'Mes options',
              icon: Icons.settings_outlined,
              screen: OptionsScreen(patientId: patientId),
            ),
          ],
        ),
      ),
    );
  }
}