import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/main_screen.dart';
import 'services/session_service.dart';
import 'services/logger_service.dart';
import 'services/notification_service.dart';

/// Notifier global pour le thème (clair / sombre)
final ValueNotifier<ThemeMode> appThemeNotifier =
    ValueNotifier<ThemeMode>(ThemeMode.light);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialiser les notifications locales
  await NotificationService().init();
  runApp(const HealthNorthApp());
}

class HealthNorthApp extends StatelessWidget {
  const HealthNorthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: appThemeNotifier,
      builder: (_, mode, child) => MaterialApp(
        title: 'HealthNorth Mobile',
        debugShowCheckedModeBanner: false,
        themeMode: mode,
        theme: ThemeData(
          colorSchemeSeed: const Color(0xFF2F80ED),
          useMaterial3: true,
          brightness: Brightness.light,
        ),
        darkTheme: ThemeData(
          colorSchemeSeed: const Color(0xFF2F80ED),
          useMaterial3: true,
          brightness: Brightness.dark,
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  // null = en cours, true = connecté, false = non connecté
  bool? _sessionFound;

  int? _patientId;

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    try {
      // Timeout 3 s : si SharedPreferences ne répond pas, on va au login
      final sessionService = SessionService();
      final savedId = await sessionService
          .getPatientId()
          .timeout(const Duration(seconds: 3));

      AppLogger.info('Session vérifiée : patientId=$savedId', tag: 'AuthWrapper');

      if (!mounted) return;
      setState(() {
        _patientId    = savedId;
        _sessionFound = savedId != null;
      });
    } catch (e) {
      AppLogger.warning('checkSession échoué ($e), redirection login', tag: 'AuthWrapper');
      if (!mounted) return;
      setState(() => _sessionFound = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Session encore en cours de vérification
    if (_sessionFound == null) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.local_hospital_outlined,
                  size: 56, color: Color(0xFF2F80ED)),
              SizedBox(height: 20),
              CircularProgressIndicator(color: Color(0xFF2F80ED)),
            ],
          ),
        ),
      );
    }

    if (_sessionFound == true && _patientId != null) {
      return MainScreen(patientId: _patientId!);
    }

    return const LoginScreen();
  }
}
