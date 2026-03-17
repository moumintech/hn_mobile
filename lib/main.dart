import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'services/session_service.dart';

void main() {
  runApp(const HealthNorthApp());
}

class HealthNorthApp extends StatelessWidget {
  const HealthNorthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HealthNorth Mobile',
      debugShowCheckedModeBanner: false,
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final SessionService sessionService = SessionService();
  int? patientId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    checkSession();
  }

  Future<void> checkSession() async {
    final savedPatientId = await sessionService.getPatientId();

    setState(() {
      patientId = savedPatientId;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (patientId != null) {
      return HomeScreen(patientId: patientId!);
    }

    return const LoginScreen();
  }
}