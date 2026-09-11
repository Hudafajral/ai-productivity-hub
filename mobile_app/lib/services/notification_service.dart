import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:alarm/alarm.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) async {
  final actionId = notificationResponse.actionId;
  final notificationId = notificationResponse.id;

  if (notificationId == null) return;

  await Alarm.init();

  if (actionId == NotificationService.actionStop) {
    await Alarm.stop(notificationId);
    await Alarm.stopAll();
    await NotificationService().cancelAllNotifications();
  } else if (actionId == NotificationService.actionSnooze) {
    final alarms = Alarm.getAlarms();
    AlarmSettings? currentAlarm;

    try {
      currentAlarm = alarms.firstWhere((a) => a.id == notificationId);
    } catch (_) {
      if (alarms.isNotEmpty) currentAlarm = alarms.first;
    }

    await Alarm.stop(notificationId);
    await Alarm.stopAll();
    await NotificationService().cancelAllNotifications();

    if (currentAlarm != null) {
      await Future.delayed(const Duration(milliseconds: 300));
      final snoozeTime = DateTime.now().add(const Duration(minutes: 5));
      await Alarm.set(
        alarmSettings: currentAlarm.copyWith(
          id: (DateTime.now().millisecondsSinceEpoch ~/ 1000) % 2147483647,
          dateTime: snoozeTime,
        ),
      );
    }
  }
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String actionStop = 'ACTION_ALARM_STOP';
  static const String actionSnooze = 'ACTION_ALARM_SNOOZE';

  Future<void> init({
    void Function(NotificationResponse)? onNotificationTap,
  }) async {
    tz.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
    } catch (_) {
      tz.setLocalLocation(tz.local);
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    try {
      await flutterLocalNotificationsPlugin.initialize(
        settings: initializationSettings,
        onDidReceiveNotificationResponse: (details) {
          if (details.actionId == actionStop || details.actionId == actionSnooze) {
            notificationTapBackground(details);
          } else if (onNotificationTap != null) {
            onNotificationTap(details);
          }
        },
        onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
      );

      final androidPlugin = flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        await androidPlugin.requestNotificationsPermission();
        await androidPlugin.requestExactAlarmsPermission();
      }
    } catch (e) {
      debugPrint("Gagal inisialisasi notifikasi: $e");
    }
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    bool isAlarm = false,
    String? soundName,
    String? payload,
  }) async {
    final now = DateTime.now();

    if (scheduledDate.isBefore(now)) {
      debugPrint(">>> GAGAL: Waktu target sudah lewat!");
      return;
    }

    final tz.TZDateTime tzScheduledDate = tz.TZDateTime.from(
      scheduledDate,
      tz.local,
    );

    // Channel senyap agar Android tidak memutar ringtone default sistem
    const String channelId = 'silent_alarm_notification_channel_v1';
    const String channelName = 'Pengingat Jadwal Senyap';

    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: 'Pengingat agenda dengan kontrol audio via aplikasi',
      importance: Importance.max,
      priority: Priority.high,
      playSound: false,
      enableVibration: true,
      sound: null,
      channelAction: AndroidNotificationChannelAction.createIfNotExists,
      fullScreenIntent: false,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tzScheduledDate,
      notificationDetails: NotificationDetails(android: androidDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );
  }

  Future<void> showAlarmNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'active_alarm_channel_pure_silent_v9',
      'Kontrol Alarm Aktif',
      channelDescription: 'Menampilkan kontrol saat alarm sedang berdering',
      importance: Importance.max,
      priority: Priority.high,
      ongoing: true,
      autoCancel: false,
      playSound: false,
      enableVibration: false,
      sound: null,
      fullScreenIntent: false,
      category: AndroidNotificationCategory.status,
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction(
          actionSnooze,
          'Tunda',
          showsUserInterface: true,
          cancelNotification: true,
        ),
        AndroidNotificationAction(
          actionStop,
          'Matikan',
          showsUserInterface: true,
          cancelNotification: true,
        ),
      ],
    );

    await flutterLocalNotificationsPlugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(android: androidDetails),
    );
  }

  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id: id);
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}
