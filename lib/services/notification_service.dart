import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    tz.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);

    await _plugin.initialize(settings);

    // Demander la permission sur Android 13+
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    _initialized = true;
  }

  // ── Notification immédiate ────────────────────────────────────────────────
  Future<void> showNow({
    required int id,
    required String title,
    required String body,
  }) async {
    await init();
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'healthnorth_now',
        'Notifications immédiates',
        channelDescription: 'Notifications en temps réel HealthNorth',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
    );
    await _plugin.show(id, title, body, details);
  }

  // ── Notification planifiée RDV ────────────────────────────────────────────
  Future<void> scheduleRdv({
    required int idRdv,
    required String dateStr,  // "yyyy-MM-dd"
    required String heureStr, // "HH:mm:ss" ou "HH:mm"
    required String doctorName,
    required String lieu,
  }) async {
    await init();
    await cancel(idRdv);

    final DateTime? rdvDt = _parseDateTime(dateStr, heureStr);
    if (rdvDt == null) return;

    final DateTime notifDt = rdvDt.subtract(const Duration(hours: 1));
    if (notifDt.isBefore(DateTime.now())) return;

    final tz.TZDateTime scheduledDate = tz.TZDateTime.from(notifDt, tz.local);

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'healthnorth_rdv',
        'Rappels Rendez-vous',
        channelDescription: 'Rappels avant les rendez-vous médicaux',
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        styleInformation: BigTextStyleInformation(''),
      ),
    );

    await _plugin.zonedSchedule(
      idRdv,
      'Rappel rendez-vous',
      'Dans 1 heure : $doctorName — $lieu',
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // ── Notification planifiée médicament ─────────────────────────────────────
  Future<void> scheduleMedicament({
    required int idRappel,
    required String heureStr, // "HH:mm:ss" ou "HH:mm"
    required String medicament,
  }) async {
    await init();
    await cancelMed(idRappel);

    final TimeOfDay? tod = _parseTime(heureStr);
    if (tod == null) return;

    final now = DateTime.now();
    DateTime next =
        DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
    if (next.isBefore(now)) next = next.add(const Duration(days: 1));

    final tz.TZDateTime scheduledDate = tz.TZDateTime.from(next, tz.local);

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'healthnorth_med',
        'Rappels Médicaments',
        channelDescription: 'Rappels pour la prise de médicaments',
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
    );

    // Offset +10000 pour ne pas entrer en conflit avec les IDs RDV
    await _plugin.zonedSchedule(
      idRappel + 10000,
      'Rappel médicament',
      'N\'oubliez pas de prendre : $medicament',
      scheduledDate,
      details,
      matchDateTimeComponents: DateTimeComponents.time, // répétition quotidienne
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancel(int idRdv) async => _plugin.cancel(idRdv);
  Future<void> cancelMed(int idRappel) async => _plugin.cancel(idRappel + 10000);

  // ── Helpers ───────────────────────────────────────────────────────────────
  DateTime? _parseDateTime(String date, String heure) {
    try {
      final parts = date.split('-');
      final tod = _parseTime(heure);
      if (parts.length < 3 || tod == null) return null;
      return DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
        tod.hour,
        tod.minute,
      );
    } catch (_) {
      return null;
    }
  }

  TimeOfDay? _parseTime(String h) {
    try {
      final parts = h.split(':');
      return TimeOfDay(
        hour:   int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    } catch (_) {
      return null;
    }
  }
}
