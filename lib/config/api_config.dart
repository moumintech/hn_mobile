class ApiConfig {
  // Emulateur Android  : 10.0.2.2
  // Appareil physique  : IP locale de la machine (ex. 192.168.1.x)
  // iOS simulateur     : localhost
  static const String _host     = '10.0.2.2';
  static const String _base     = 'http://$_host/healthnorth/api';
  static const String _mobile   = '$_base/mobile/patient';

  // --- Endpoints Auth ---
  static const String loginEndpoint = '$_base/auth/patient_login.php';

  // --- Endpoints Patient ---
  static const String getPatientEndpoint    = '$_mobile/get_patient.php';
  static const String updatePatientEndpoint = '$_mobile/update_patient.php';

  // --- Endpoints Rendez-vous ---
  static const String getRendezVousEndpoint   = '$_mobile/get_rendez_vous.php';
  static const String toggleRappelRdvEndpoint = '$_mobile/toggle_rappel_rdv.php';

  // --- Endpoints Prescriptions ---
  static const String getPrescriptionsEndpoint = '$_mobile/get_prescriptions.php';

  // --- Endpoints Rappels médicaments ---
  static const String getRappelsEndpoint    = '$_mobile/get_rappels.php';
  static const String toggleRappelEndpoint  = '$_mobile/toggle_rappel.php';
  static const String addRappelEndpoint     = '$_mobile/add_rappel.php';
  static const String deleteRappelEndpoint  = '$_mobile/delete_rappel.php';

  // --- Endpoints Options ---
  static const String getOptionsEndpoint   = '$_mobile/get_options.php';
  static const String updateOptionEndpoint = '$_mobile/update_option.php';
}
