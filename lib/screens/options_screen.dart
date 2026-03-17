import 'package:flutter/material.dart';
import '../models/option_model.dart';
import '../services/option_service.dart';

class OptionsScreen extends StatefulWidget {
  final int patientId;

  const OptionsScreen({super.key, required this.patientId});

  @override
  State<OptionsScreen> createState() => _OptionsScreenState();
}

class _OptionsScreenState extends State<OptionsScreen> {
  final OptionService optionService = OptionService();

  List<OptionModel> options = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    loadOptions();
  }

  Future<void> loadOptions() async {
    try {
      final result = await optionService.getOptions();
      setState(() {
        options = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  String formatActif(bool actif) {
    return actif ? 'Actif' : 'Inactif';
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF2F80ED);
    const Color cardColor = Color(0xFFF5F7FB);
    const Color textColor = Color(0xFF1F2937);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Paramètres'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: textColor,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : options.isEmpty
                  ? const Center(child: Text('Aucune option trouvée'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: options.length,
                      itemBuilder: (context, index) {
                        final option = options[index];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Row(
                            children: [
                              Container(
                                height: 44,
                                width: 44,
                                decoration: BoxDecoration(
                                  color: primaryColor.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.settings_outlined,
                                  color: primaryColor,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      option.libelle == null || option.libelle!.isEmpty
                                          ? 'Option'
                                          : option.libelle!,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: textColor,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Valeur : ${option.valeur == null || option.valeur!.isEmpty ? '-' : option.valeur!}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black54,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Statut : ${formatActif(option.active)}',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: option.active
                                            ? const Color(0xFF16A34A)
                                            : const Color(0xFFDC2626),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: option.active,
                                onChanged: null,
                                activeColor: primaryColor,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
    );
  }
}