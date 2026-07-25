import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// One scheduled local notification.
@immutable
class Reminder {
  const Reminder({
    required this.id,
    required this.title,
    required this.body,
    required this.when,
    this.repeatDaily = false,
  });

  /// Stable across reschedules, so updating a reminder replaces it rather than
  /// stacking a second copy on top.
  final int id;
  final String title;
  final String body;
  final DateTime when;

  /// Whether this fires every day at [when]'s time of day.
  final bool repeatDaily;
}

/// Schedules and cancels the app's local reminders.
///
/// Everything is scheduled on the device; nothing is pushed from a server.
/// If the user declines the notification permission the app keeps working —
/// scheduling simply does nothing, which is why every method can fail quietly.
abstract interface class Reminders {
  /// Whether notifications may be shown. Asks the user the first time.
  Future<bool> ensurePermission();

  /// Schedules [reminder], replacing any existing one with the same id.
  /// Reminders in the past are dropped rather than fired immediately.
  Future<void> schedule(Reminder reminder);

  Future<void> cancel(int id);

  Future<void> cancelAll();
}

/// The real implementation, backed by `flutter_local_notifications`.
class LocalReminders implements Reminders {
  LocalReminders([FlutterLocalNotificationsPlugin? plugin])
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _ready = false;
  bool _granted = false;

  static const String _channelId = 'help_me_reminders';

  static const NotificationDetails _details = NotificationDetails(
    android: AndroidNotificationDetails(
      _channelId,
      'Reminders',
      channelDescription: 'Medicine doses, expiry dates and the daily first-aid tip',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    ),
    iOS: DarwinNotificationDetails(),
  );

  Future<void> _init() async {
    if (_ready) return;
    tzdata.initializeTimeZones();
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
    _ready = true;
  }

  @override
  Future<bool> ensurePermission() async {
    await _init();
    if (_granted) return true;
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        final AndroidFlutterLocalNotificationsPlugin? android = _plugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();
        _granted = await android?.requestNotificationsPermission() ?? false;
      } else {
        final IOSFlutterLocalNotificationsPlugin? ios = _plugin
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>();
        _granted = await ios?.requestPermissions(alert: true, badge: true, sound: true) ??
            false;
      }
    } catch (_) {
      _granted = false;
    }
    return _granted;
  }

  @override
  Future<void> schedule(Reminder reminder) async {
    await _init();
    final tz.TZDateTime at = tz.TZDateTime.from(reminder.when, tz.local);
    if (!reminder.repeatDaily && at.isBefore(tz.TZDateTime.now(tz.local))) return;
    try {
      await _plugin.zonedSchedule(
        id: reminder.id,
        title: reminder.title,
        body: reminder.body,
        scheduledDate: at,
        notificationDetails: _details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents:
            reminder.repeatDaily ? DateTimeComponents.time : null,
      );
    } catch (_) {
      // Permission refused, or the platform refused the schedule. The feature
      // this reminder belongs to keeps working without it.
    }
  }

  @override
  Future<void> cancel(int id) async {
    await _init();
    try {
      await _plugin.cancel(id: id);
    } catch (_) {
      // Nothing scheduled under that id.
    }
  }

  @override
  Future<void> cancelAll() async {
    await _init();
    try {
      await _plugin.cancelAll();
    } catch (_) {
      // Nothing scheduled.
    }
  }
}

/// Records what was asked for instead of showing it — used by tests.
class FakeReminders implements Reminders {
  FakeReminders({this.permitted = true});

  final bool permitted;
  final Map<int, Reminder> scheduled = <int, Reminder>{};
  final List<int> cancelled = <int>[];

  @override
  Future<bool> ensurePermission() async => permitted;

  @override
  Future<void> schedule(Reminder reminder) async {
    if (!permitted) return;
    scheduled[reminder.id] = reminder;
  }

  @override
  Future<void> cancel(int id) async {
    cancelled.add(id);
    scheduled.remove(id);
  }

  @override
  Future<void> cancelAll() async {
    cancelled.addAll(scheduled.keys);
    scheduled.clear();
  }
}
