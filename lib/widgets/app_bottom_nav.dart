import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/rendez_vous_screen.dart';
import '../screens/prescriptions_screen.dart';
import '../screens/dossier_patient_screen.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final int patientId;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.patientId,
  });

  void _onTap(BuildContext context, int index) {
    if (index == currentIndex) return;

    Widget screen;

    switch (index) {
      case 0:
        screen = HomeScreen(patientId: patientId);
        break;
      case 1:
        screen = RendezVousScreen(patientId: patientId);
        break;
      case 2:
        screen = PrescriptionsScreen(patientId: patientId);
        break;
      case 3:
        screen = DossierPatientScreen(patientId: patientId);
        break;
      default:
        screen = HomeScreen(patientId: patientId);
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF2F80ED);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => _onTap(context, index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.black45,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            label: 'Rendez-vous',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medication_outlined),
            label: 'Médicaments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}