import 'package:flutter/material.dart';
import '../models/rappel_medicament.dart';
import '../services/rappel_service.dart';
import '../services/notification_service.dart';

class RappelsScreen extends StatefulWidget {
  final int patientId;
  final VoidCallback? onGoHome;

  const RappelsScreen({super.key, required this.patientId, this.onGoHome});

  @override
  State<RappelsScreen> createState() => _RappelsScreenState();
}

class _RappelsScreenState extends State<RappelsScreen> {
  final RappelService _service = RappelService();

  List<RappelMedicament> _list     = [];
  bool                   _loading  = true;
  String                 _error    = '';
  final Set<int>         _toggling = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = ''; });
    try {
      final data = await _service.getRappels();
      if (mounted) setState(() { _list = data; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _toggle(int index) async {
    final r = _list[index];
    if (_toggling.contains(r.idRappel)) return;

    final newVal = !r.actif;
    setState(() {
      _toggling.add(r.idRappel);
      _list[index] = RappelMedicament(
        idRappel: r.idRappel, heure: r.heure, actif: newVal,
        idLigne: r.idLigne, medicament: r.medicament,
        dosage: r.dosage, frequence: r.frequence, duree: r.duree,
      );
    });

    final res = await _service.toggleRappel(idRappel: r.idRappel, actif: newVal);
    if (!mounted) return;

    if (res['success'] != true) {
      setState(() {
        _list[index] = RappelMedicament(
          idRappel: r.idRappel, heure: r.heure, actif: r.actif,
          idLigne: r.idLigne, medicament: r.medicament,
          dosage: r.dosage, frequence: r.frequence, duree: r.duree,
        );
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(res['message'] ?? 'Erreur'),
        backgroundColor: const Color(0xFFDC2626),
      ));
    } else {
      // Planifier/annuler la notification
      if (newVal) {
        await NotificationService().scheduleMedicament(
          idRappel:   r.idRappel,
          heureStr:   r.heure ?? '',
          medicament: r.medicament ?? 'Médicament',
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Rappel activé pour ${r.medicament ?? 'médicament'}'),
            backgroundColor: const Color(0xFF16A34A),
            duration: const Duration(seconds: 2),
          ));
        }
      } else {
        await NotificationService().cancelMed(r.idRappel);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Rappel désactivé'),
            backgroundColor: Color(0xFF6B7280),
            duration: Duration(seconds: 2),
          ));
        }
      }
    }
    setState(() => _toggling.remove(r.idRappel));
  }

  Future<void> _delete(int index) async {
    final r = _list[index];
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer le rappel'),
        content: Text(
            'Supprimer le rappel pour "${r.medicament ?? 'ce médicament'}" ?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: const Color(0xFFDC2626)),
              child: const Text('Supprimer')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final res = await _service.deleteRappel(r.idRappel);
    if (!mounted) return;
    if (res['success'] == true) {
      await NotificationService().cancelMed(r.idRappel);
      if (!mounted) return;
      setState(() => _list.removeAt(index));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Rappel supprimé'),
        backgroundColor: Color(0xFF6B7280),
        duration: Duration(seconds: 2),
      ));
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(res['message'] ?? 'Erreur'),
        backgroundColor: const Color(0xFFDC2626),
      ));
    }
  }

  void _showAddDialog() {
    final medicCtrl = TextEditingController();
    TimeOfDay selectedTime = TimeOfDay.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setSheet) {
          return Padding(
            padding: EdgeInsets.only(
              left: 24, right: 24, top: 24,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.alarm_add_outlined,
                        color: Color(0xFF8B5CF6), size: 24),
                    const SizedBox(width: 10),
                    const Text(
                      'Nouveau rappel médicament',
                      style: TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w700),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: medicCtrl,
                  decoration: InputDecoration(
                    labelText: 'Nom du médicament',
                    prefixIcon: const Icon(Icons.medication_outlined),
                    filled: true,
                    fillColor: const Color(0xFFF5F7FB),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: ctx,
                      initialTime: selectedTime,
                    );
                    if (picked != null) setSheet(() => selectedTime = picked);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F7FB),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time_outlined,
                            color: Color(0xFF8B5CF6)),
                        const SizedBox(width: 12),
                        Text(
                          'Heure : ${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
                          style: const TextStyle(fontSize: 15),
                        ),
                        const Spacer(),
                        const Icon(Icons.edit_outlined,
                            size: 16, color: Colors.black38),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final med = medicCtrl.text.trim();
                      if (med.isEmpty) return;
                      final heure =
                          '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}';
                      Navigator.pop(ctx);
                      await _addRappel(med, heure);
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Ajouter le rappel',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B5CF6),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  Future<void> _addRappel(String medicament, String heure) async {
    final res = await _service.addRappel(medicament: medicament, heure: heure);
    if (!mounted) return;
    if (res['success'] == true) {
      await _load();
      // Planifier notification
      final idRappel = res['id_rappel'] as int? ?? 0;
      if (idRappel > 0) {
        await NotificationService().scheduleMedicament(
          idRappel:   idRappel,
          heureStr:   heure,
          medicament: medicament,
        );
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Rappel ajouté pour $medicament à $heure'),
          backgroundColor: const Color(0xFF8B5CF6),
          duration: const Duration(seconds: 3),
        ));
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(res['message'] ?? 'Erreur lors de l\'ajout'),
          backgroundColor: const Color(0xFFDC2626),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primary = Color(0xFF2F80ED);
    const Color purple  = Color(0xFF8B5CF6);
    const Color bg      = Color(0xFFF5F7FB);

    return Scaffold(
      backgroundColor: bg,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        backgroundColor: purple,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_alarm_outlined),
        label: const Text('Nouveau rappel',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: Column(
        children: [
          // Header
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
                padding: const EdgeInsets.fromLTRB(20, 16, 12, 24),
                child: Row(
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
                    IconButton(
                      onPressed: _load,
                      icon: const Icon(Icons.refresh, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Titre
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 4),
            child: Row(
              children: [
                const Text(
                  'Rappels médicaments',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const Spacer(),
                if (!_loading)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: purple.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${_list.length}',
                      style: const TextStyle(
                        color: purple,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Text(
              'Glissez vers la gauche pour supprimer un rappel',
              style: TextStyle(fontSize: 11, color: Colors.black.withValues(alpha: 0.4)),
            ),
          ),

          // Liste
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error.isNotEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_error, textAlign: TextAlign.center),
                            const SizedBox(height: 14),
                            TextButton.icon(
                              onPressed: _load,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Réessayer'),
                            ),
                          ],
                        ),
                      )
                    : _list.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.alarm_off_outlined,
                                    size: 56,
                                    color: Colors.black.withValues(alpha: 0.2)),
                                const SizedBox(height: 14),
                                const Text('Aucun rappel configuré',
                                    style: TextStyle(color: Colors.black45)),
                                const SizedBox(height: 8),
                                const Text(
                                  'Appuyez sur "+ Nouveau rappel" pour en créer un',
                                  style: TextStyle(fontSize: 12, color: Colors.black38),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding:
                                const EdgeInsets.fromLTRB(16, 0, 16, 80),
                            itemCount: _list.length,
                            itemBuilder: (_, i) => Dismissible(
                              key: ValueKey(_list[i].idRappel),
                              direction: DismissDirection.endToStart,
                              confirmDismiss: (_) async {
                                await _delete(i);
                                return false; // On gère manuellement
                              },
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDC2626),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: const Icon(Icons.delete_outline,
                                    color: Colors.white, size: 26),
                              ),
                              child: _alarmCard(_list[i], i),
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _alarmCard(RappelMedicament r, int index) {
    const Color purple     = Color(0xFF8B5CF6);
    final bool isToggling  = _toggling.contains(r.idRappel);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Icône alarme
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: (r.actif ? purple : Colors.grey)
                    .withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.alarm_outlined,
                color: r.actif ? purple : Colors.grey,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),

            // Infos
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    r.medicament?.isNotEmpty == true
                        ? r.medicament!
                        : 'Médicament',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.access_time_outlined,
                          size: 13, color: Colors.black38),
                      const SizedBox(width: 4),
                      Text(
                        _fmt(r.heure),
                        style: const TextStyle(
                            fontSize: 13, color: Colors.black54),
                      ),
                    ],
                  ),
                  if (r.dosage != null && r.dosage!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      r.dosage!,
                      style: const TextStyle(
                          fontSize: 12, color: Colors.black45),
                    ),
                  ],
                ],
              ),
            ),

            // Toggle
            isToggling
                ? const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(strokeWidth: 2.5))
                : Switch(
                    value: r.actif,
                    onChanged: (_) => _toggle(index),
                    activeThumbColor: purple,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
          ],
        ),
      ),
    );
  }

  String _fmt(String? h) {
    if (h == null || h.isEmpty) return '-';
    return h.length >= 5 ? h.substring(0, 5) : h;
  }
}
