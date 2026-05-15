import 'package:flutter/material.dart';
import '../main.dart';
import '../models/option_model.dart';
import '../services/option_service.dart';

class OptionsScreen extends StatefulWidget {
  final int patientId;

  const OptionsScreen({super.key, required this.patientId});

  @override
  State<OptionsScreen> createState() => _OptionsScreenState();
}

class _OptionsScreenState extends State<OptionsScreen> {
  final OptionService _optionService = OptionService();

  List<OptionModel> options    = [];
  bool              isLoading  = true;
  String            errorMessage = '';
  final Set<int>    _toggling  = {};

  @override
  void initState() {
    super.initState();
    loadOptions();
  }

  Future<void> loadOptions() async {
    setState(() { isLoading = true; errorMessage = ''; });
    try {
      final result = await _optionService.getOptions();
      setState(() { options = result; isLoading = false; });
      // Synchroniser le thème sombre depuis les options serveur
      _syncTheme(result);
    } catch (e) {
      setState(() { errorMessage = e.toString(); isLoading = false; });
    }
  }

  void _syncTheme(List<OptionModel> opts) {
    final themeSombre = opts.firstWhere(
      (o) => o.valeur == 'theme_sombre',
      orElse: () => OptionModel(idOption: -1, libelle: '', valeur: '', active: false),
    );
    appThemeNotifier.value =
        themeSombre.active ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> _toggleOption(int index) async {
    final option   = options[index];
    if (_toggling.contains(option.idOption)) return;
    final newValue = !option.active;

    setState(() {
      _toggling.add(option.idOption);
      options[index] = OptionModel(
        idOption: option.idOption,
        libelle:  option.libelle,
        valeur:   option.valeur,
        active:   newValue,
      );
    });

    // Appliquer le thème immédiatement si c'est l'option sombre
    if (option.valeur == 'theme_sombre') {
      appThemeNotifier.value = newValue ? ThemeMode.dark : ThemeMode.light;
    }

    final result = await _optionService.updateOption(
      idOption: option.idOption,
      active:   newValue,
    );

    if (!mounted) return;

    if (result['success'] != true) {
      // Rollback
      setState(() {
        options[index] = OptionModel(
          idOption: option.idOption,
          libelle:  option.libelle,
          valeur:   option.valeur,
          active:   option.active,
        );
      });
      if (option.valeur == 'theme_sombre') {
        appThemeNotifier.value = option.active ? ThemeMode.dark : ThemeMode.light;
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(result['message'] ?? 'Erreur lors de la mise à jour.'),
        backgroundColor: const Color(0xFFDC2626),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(newValue ? 'Option activée.' : 'Option désactivée.'),
        backgroundColor: const Color(0xFF16A34A),
        duration: const Duration(seconds: 2),
      ));
    }
    setState(() => _toggling.remove(option.idOption));
  }

  IconData _optionIcon(String? valeur) {
    switch (valeur) {
      case 'notif_rdv':     return Icons.calendar_today_outlined;
      case 'notif_rappel':  return Icons.alarm_outlined;
      case 'theme_sombre':  return Icons.dark_mode_outlined;
      default:              return Icons.settings_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primary   = Color(0xFF2F80ED);
    const Color textColor = Color(0xFF1F2937);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Paramètres',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: textColor,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(errorMessage, textAlign: TextAlign.center),
                      const SizedBox(height: 14),
                      TextButton.icon(
                        onPressed: loadOptions,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Réessayer'),
                      ),
                    ],
                  ),
                )
              : options.isEmpty
                  ? const Center(child: Text('Aucune option trouvée'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: options.length,
                      itemBuilder: (context, index) {
                        final option = options[index];
                        final isToggling =
                            _toggling.contains(option.idOption);
                        final icon = _optionIcon(option.valeur);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F7FB),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Row(
                            children: [
                              Container(
                                height: 44,
                                width:  44,
                                decoration: BoxDecoration(
                                  color: primary.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(icon, color: primary),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      option.libelle?.isNotEmpty == true
                                          ? option.libelle!
                                          : 'Option',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: textColor,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      option.active ? 'Activé' : 'Désactivé',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: option.active
                                            ? const Color(0xFF16A34A)
                                            : const Color(0xFF9CA3AF),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              isToggling
                                  ? const SizedBox(
                                      width: 32, height: 32,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2.5))
                                  : Switch(
                                      value: option.active,
                                      onChanged: (_) => _toggleOption(index),
                                      activeThumbColor: primary,
                                    ),
                            ],
                          ),
                        );
                      },
                    ),
    );
  }
}
