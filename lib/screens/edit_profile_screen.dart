import 'package:flutter/material.dart';
import '../models/patient.dart';
import '../services/patient_service.dart';

class EditProfileScreen extends StatefulWidget {
  final Patient patient;

  const EditProfileScreen({super.key, required this.patient});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final PatientService _patientService = PatientService();

  late final TextEditingController _telephoneCtrl;
  late final TextEditingController _contactNomCtrl;
  late final TextEditingController _contactTelCtrl;
  late final TextEditingController _numSecuCtrl;
  late final TextEditingController _adresseCtrl;
  late final TextEditingController _villeCtrl;
  late final TextEditingController _codePostalCtrl;

  bool   _isSaving     = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _telephoneCtrl  = TextEditingController(text: widget.patient.telephone ?? '');
    _contactNomCtrl = TextEditingController(text: widget.patient.personneAContacter ?? '');
    _contactTelCtrl = TextEditingController(text: widget.patient.contactUrgenceTel ?? '');
    _numSecuCtrl    = TextEditingController(text: widget.patient.numSecu ?? '');
    _adresseCtrl    = TextEditingController(text: widget.patient.adresse  ?? '');
    _villeCtrl      = TextEditingController(text: widget.patient.ville    ?? '');
    _codePostalCtrl = TextEditingController(text: widget.patient.codePostal ?? '');
  }

  @override
  void dispose() {
    _telephoneCtrl.dispose();
    _contactNomCtrl.dispose();
    _contactTelCtrl.dispose();
    _numSecuCtrl.dispose();
    _adresseCtrl.dispose();
    _villeCtrl.dispose();
    _codePostalCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() { _isSaving = true; _errorMessage = ''; });

    final result = await _patientService.updatePatient(
      telephone:           _telephoneCtrl.text.trim(),
      personneAContacter:  _contactNomCtrl.text.trim(),
      contactUrgenceTel:   _contactTelCtrl.text.trim(),
      numSecu:             _numSecuCtrl.text.trim(),
      adresse:             _adresseCtrl.text.trim(),
      ville:               _villeCtrl.text.trim(),
      codePostal:          _codePostalCtrl.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Profil mis à jour avec succès.'),
        backgroundColor: Color(0xFF16A34A),
      ));
      Navigator.pop(context, true);
    } else {
      setState(() => _errorMessage = result['message'] ?? 'Une erreur est survenue.');
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primary   = Color(0xFF2F80ED);
    const Color textColor = Color(0xFF1F2937);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text('Modifier mon profil'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: textColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: primary.withValues(alpha: 0.15),
                    child: const Icon(Icons.person, size: 32, color: primary),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${widget.patient.prenom} ${widget.patient.nom}',
                          style: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w700, color: textColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(widget.patient.email ?? '',
                            style: const TextStyle(fontSize: 13, color: Colors.black54)),
                        if (widget.patient.medecinTraitant != null &&
                            widget.patient.medecinTraitant!.trim().isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Row(children: [
                            const Icon(Icons.medical_services_outlined,
                                size: 13, color: Colors.black45),
                            const SizedBox(width: 4),
                            Text('Dr ${widget.patient.medecinTraitant!.trim()}',
                                style: const TextStyle(fontSize: 12, color: Colors.black45)),
                          ]),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            _sectionLabel('Coordonnées'),
            _field(_telephoneCtrl,  'Téléphone',           Icons.phone_outlined,
                keyboardType: TextInputType.phone),
            _field(_adresseCtrl,    'Adresse',             Icons.home_outlined),
            _field(_villeCtrl,      'Ville',               Icons.location_city_outlined),
            _field(_codePostalCtrl, 'Code postal',         Icons.markunread_mailbox_outlined,
                keyboardType: TextInputType.number),

            const SizedBox(height: 8),
            _sectionLabel('Numéro de sécurité sociale'),
            _field(_numSecuCtrl, 'N° Sécurité Sociale', Icons.badge_outlined,
                keyboardType: TextInputType.number),

            const SizedBox(height: 8),
            _sectionLabel('Contact d\'urgence'),
            _field(_contactNomCtrl, 'Nom du contact',       Icons.contact_phone_outlined),
            _field(_contactTelCtrl, 'Téléphone du contact', Icons.phone_callback_outlined,
                keyboardType: TextInputType.phone),

            // Médecin traitant — lecture seule
            if (widget.patient.medecinTraitant != null &&
                widget.patient.medecinTraitant!.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              _sectionLabel('Médecin traitant'),
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.medical_services_outlined,
                        color: primary, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      'Dr ${widget.patient.medecinTraitant!.trim()}',
                      style: const TextStyle(fontSize: 15, color: textColor),
                    ),
                    const Spacer(),
                    const Text('(non modifiable)',
                        style: TextStyle(fontSize: 11, color: Colors.black38)),
                  ],
                ),
              ),
            ],

            if (_errorMessage.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(_errorMessage,
                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
            ],

            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 22, height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.4, color: Colors.white))
                    : const Text('Enregistrer',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(
          text.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Colors.black45,
            letterSpacing: 1.2,
          ),
        ),
      );

  Widget _field(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
  }) =>
      Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon, color: const Color(0xFF2F80ED)),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  const BorderSide(color: Color(0xFF2F80ED), width: 1.5),
            ),
          ),
        ),
      );
}
