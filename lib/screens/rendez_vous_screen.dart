import 'package:flutter/material.dart';
import '../models/rendez_vous.dart';
import '../services/rendez_vous_service.dart';
import '../services/notification_service.dart';

class RendezVousScreen extends StatefulWidget {
  final int patientId;
  final VoidCallback? onGoHome;

  const RendezVousScreen({super.key, required this.patientId, this.onGoHome});

  @override
  State<RendezVousScreen> createState() => _RendezVousScreenState();
}

class _RendezVousScreenState extends State<RendezVousScreen> {
  final RendezVousService _service = RendezVousService();

  List<RendezVous> _list      = [];
  bool             _loading   = true;
  String           _error     = '';
  final Set<int>   _toggling  = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = ''; });
    try {
      final data = await _service.getRendezVous();
      if (mounted) setState(() { _list = data; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _toggleRappel(int index) async {
    final rdv = _list[index];
    if (_toggling.contains(rdv.idRdv)) return;

    final newVal = !rdv.rappelActif;
    setState(() {
      _toggling.add(rdv.idRdv);
      _list[index] = rdv.copyWith(rappelActif: newVal);
    });

    final res = await _service.toggleRappelRdv(
        idRdv: rdv.idRdv, rappelActif: newVal);

    if (!mounted) return;
    if (res['success'] != true) {
      setState(() => _list[index] = rdv.copyWith(rappelActif: rdv.rappelActif));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(res['message'] ?? 'Erreur'),
        backgroundColor: const Color(0xFFDC2626),
      ));
    } else {
      // Planifier ou annuler la notification
      if (newVal) {
        final doc = '${rdv.specialistePrenom ?? ''} ${rdv.specialisteNom ?? ''}'.trim();
        await NotificationService().scheduleRdv(
          idRdv:      rdv.idRdv,
          dateStr:    rdv.dateRdv     ?? '',
          heureStr:   rdv.heureRdv    ?? '',
          doctorName: doc.isEmpty ? 'Médecin' : doc,
          lieu:       rdv.etablissementNom ?? '',
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Rappel activé — vous serez notifié 1h avant'),
            backgroundColor: Color(0xFF16A34A),
            duration: Duration(seconds: 3),
          ));
        }
      } else {
        await NotificationService().cancel(rdv.idRdv);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Rappel désactivé'),
            backgroundColor: Color(0xFF6B7280),
            duration: Duration(seconds: 2),
          ));
        }
      }
    }
    setState(() => _toggling.remove(rdv.idRdv));
  }

  Color _statusColor(String? s) {
    if (s == null) return Colors.grey;
    final v = s.toLowerCase();
    if (v.contains('confirm')) return const Color(0xFF16A34A);
    if (v.contains('attente')) return const Color(0xFFF59E0B);
    if (v.contains('annul'))   return const Color(0xFFDC2626);
    return const Color(0xFF2F80ED);
  }

  @override
  Widget build(BuildContext context) {
    const Color primary = Color(0xFF2F80ED);
    const Color bg      = Color(0xFFF5F7FB);

    return Scaffold(
      backgroundColor: bg,
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

          // Titre de section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
            child: Row(
              children: [
                const Text(
                  'Mes rendez-vous',
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
                      color: primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${_list.length}',
                      style: const TextStyle(
                        color: primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
              ],
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
                        ? const Center(
                            child: Text('Aucun rendez-vous trouvé'))
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                            itemCount: _list.length,
                            itemBuilder: (ctx, i) {
                              final rdv = _list[i];
                              final sc  = _statusColor(rdv.statut);
                              return _rdvCard(rdv, sc, i);
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _rdvCard(RendezVous rdv, Color sc, int index) {
    const Color primary = Color(0xFF2F80ED);
    final doc = '${rdv.specialistePrenom ?? ''} ${rdv.specialisteNom ?? ''}'.trim();

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titre + statut
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.calendar_today_outlined,
                      color: primary, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    doc.isEmpty ? 'Rendez-vous' : 'Rendez-vous avec $doc',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: sc.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    rdv.statut ?? '-',
                    style: TextStyle(
                      color: sc,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Infos
            _row(Icons.event_outlined,
                'Date : ${rdv.dateRdv ?? '-'}'),
            const SizedBox(height: 6),
            _row(Icons.access_time_outlined,
                'Heure : ${_fmt(rdv.heureRdv)}'),
            const SizedBox(height: 6),
            _row(Icons.location_on_outlined,
                'Lieu : ${rdv.etablissementNom ?? '-'}'),
            if (rdv.specialite != null && rdv.specialite!.isNotEmpty) ...[
              const SizedBox(height: 6),
              _row(Icons.medical_information_outlined, rdv.specialite!),
            ],

            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 10),

            // Bas de carte : rappel + voir détails
            Row(
              children: [
                const Icon(Icons.notifications_outlined,
                    size: 17, color: primary),
                const SizedBox(width: 6),
                const Expanded(
                  child: Text(
                    'Rappel',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ),
                _toggling.contains(rdv.idRdv)
                    ? const SizedBox(
                        width: 26,
                        height: 26,
                        child: CircularProgressIndicator(strokeWidth: 2.5))
                    : Switch(
                        value: rdv.rappelActif,
                        onChanged: (_) => _toggleRappel(index),
                        activeThumbColor: primary,
                        materialTapTargetSize:
                            MaterialTapTargetSize.shrinkWrap,
                      ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => _showDetails(rdv),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    backgroundColor: primary.withValues(alpha: 0.08),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text(
                    'Voir détails',
                    style: TextStyle(
                      color: primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDetails(RendezVous rdv) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Détails du rendez-vous',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            _row(Icons.person_outline,
                '${rdv.specialistePrenom ?? ''} ${rdv.specialisteNom ?? ''}'.trim()),
            _row(Icons.event_outlined, rdv.dateRdv ?? '-'),
            _row(Icons.access_time_outlined, _fmt(rdv.heureRdv)),
            _row(Icons.location_on_outlined,
                '${rdv.etablissementNom ?? '-'}\n${rdv.adresse ?? ''}'),
            if (rdv.specialite != null)
              _row(Icons.medical_information_outlined, rdv.specialite!),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _row(IconData icon, String text) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.black45),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    fontSize: 13, color: Color(0xFF374151))),
          ),
        ],
      );

  String _fmt(String? h) {
    if (h == null || h.isEmpty) return '-';
    return h.length >= 5 ? h.substring(0, 5) : h;
  }
}
