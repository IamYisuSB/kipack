import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import '../models/trip.dart';

/// Schedules local "your trip is coming up" reminders (3 days and 1 day
/// before departure) and cancels them once they're no longer useful — the
/// trip got deleted, or the packing list is already fully checked off.
///
/// Uses inexact alarms (`inexactAllowWhileIdle`) on purpose: a reminder that
/// fires a few minutes off doesn't matter here, and it avoids needing the
/// Android 12+ "schedule exact alarms" permission entirely.
class RemindersService {
  RemindersService._();
  static final RemindersService instance = RemindersService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    tzdata.initializeTimeZones();
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    await _plugin.initialize(settings: settings);
    _initialized = true;
  }

  /// Requests the Android 13+ notification permission. Returns true if
  /// reminders can actually be shown (already granted, or just granted).
  Future<bool> requestPermission() async {
    await _ensureInitialized();
    final granted = await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
    return granted ?? true;
  }

  /// Stable per-trip notification ids (derived from the trip's uuid) so the
  /// same two reminders can always be found again to cancel them, without
  /// having to persist the ids anywhere ourselves.
  ///
  /// Notification ids must fit in a 32-bit signed int, and we multiply this
  /// by 10 below (to leave room for the two reminder slots), so the mask
  /// has to leave enough headroom — 0x3fffffff was too wide and could
  /// overflow, which made `zonedSchedule` throw for a lot of trip ids.
  int _baseId(String tripId) => tripId.hashCode & 0x07ffffff;

  Future<void> scheduleTripReminders(Trip trip) async {
    await _ensureInitialized();
    final base = _baseId(trip.id);
    final departureDay = DateTime(
      trip.startDate.year,
      trip.startDate.month,
      trip.startDate.day,
      9,
    );

    await _scheduleOne(
      id: base * 10 + 1,
      title: '🎒 Se acerca tu viaje a ${trip.destination}',
      body: 'Faltan 3 días — revisa que tengas la maleta lista.',
      fireAt: departureDay.subtract(const Duration(days: 3)),
    );
    await _scheduleOne(
      id: base * 10 + 2,
      title: '🎒 Mañana sales hacia ${trip.destination}',
      body: 'Es tu último día para terminar la maleta.',
      fireAt: departureDay.subtract(const Duration(days: 1)),
    );
  }

  Future<void> _scheduleOne({
    required int id,
    required String title,
    required String body,
    required DateTime fireAt,
  }) async {
    // A reminder whose moment has already passed (e.g. the trip starts in
    // under 3 days) would otherwise throw — just skip it.
    if (fireAt.isBefore(DateTime.now())) return;
    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(fireAt, tz.local),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'trip_reminders',
          'Recordatorios de viaje',
          channelDescription: 'Avisos antes de que empiece un viaje',
        ),
      ),
    );
  }

  /// Fires immediately (not scheduled) — lets a user confirm permissions,
  /// the notification channel, and the plugin itself all actually work on
  /// their specific device, independent of whether a *scheduled* reminder
  /// days out ever fires (which Android's battery/Doze optimizations can
  /// silently delay for hours, unrelated to whether the app is broken).
  Future<void> showTestNotification() async {
    await _ensureInitialized();
    await _plugin.show(
      id: 999999,
      title: '🎒 Notificación de prueba',
      body:
          'Si ves esto, las notificaciones de Kipack funcionan en este dispositivo.',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'trip_reminders',
          'Recordatorios de viaje',
          channelDescription: 'Avisos antes de que empiece un viaje',
        ),
      ),
    );
  }

  /// Fires when a new trip-collaborator invite is found addressed to the
  /// signed-in user (see `PendingInvitesNotifier`) — a separate channel
  /// from `trip_reminders` since it's a different kind of alert (something
  /// to act on, not just an FYI).
  Future<void> showInviteNotification({required String destination}) async {
    await _ensureInitialized();
    await _plugin.show(
      id: destination.hashCode & 0x07ffffff,
      title: '✈️ Nueva invitación de viaje',
      body: 'Te han invitado a un viaje a $destination. Ábrelo para aceptar.',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'trip_invites',
          'Invitaciones de viaje',
          channelDescription: 'Avisos cuando alguien te invita a un viaje',
        ),
      ),
    );
  }

  Future<void> cancelTripReminders(String tripId) async {
    await _ensureInitialized();
    final base = _baseId(tripId);
    await _plugin.cancel(id: base * 10 + 1);
    await _plugin.cancel(id: base * 10 + 2);
  }
}
