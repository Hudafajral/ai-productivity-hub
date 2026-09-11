import 'package:flutter/material.dart';
import 'package:alarm/alarm.dart';
import '../../../services/notification_service.dart';

class AlarmRingScreen extends StatefulWidget {
  final AlarmSettings alarmSettings;

  const AlarmRingScreen({super.key, required this.alarmSettings});

  @override
  State<AlarmRingScreen> createState() => _AlarmRingScreenState();
}

class _AlarmRingScreenState extends State<AlarmRingScreen> {
  bool _isStopping = false;

  Future<void> _stopAlarm() async {
    if (_isStopping) return;
    setState(() => _isStopping = true);

    try {
      // 1. Matikan alarm pada ID spesifik dan bunuh seluruh instance aktif
      await Alarm.stop(widget.alarmSettings.id);
      await Alarm.stopAll();

      // 2. Bersihkan notifikasi sistem
      await NotificationService().cancelNotification(widget.alarmSettings.id);
      await NotificationService().cancelAllNotifications();

      // 3. Penjadwalan ulang jika agenda berulang
      final bodyText = widget.alarmSettings.notificationBody;
      final bool isRepeat = bodyText.contains('[REPEAT]');

      if (isRepeat) {
        final nextAlarmDate = widget.alarmSettings.dateTime.add(const Duration(days: 1));
        await Alarm.set(
          alarmSettings: widget.alarmSettings.copyWith(dateTime: nextAlarmDate),
        );
      }
    } catch (e) {
      debugPrint('Error saat mematikan alarm: $e');
    } finally {
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    }
  }

  Future<void> _snoozeAlarm() async {
    if (_isStopping) return;
    setState(() => _isStopping = true);

    try {
      await Alarm.stop(widget.alarmSettings.id);
      await Alarm.stopAll();
      await NotificationService().cancelNotification(widget.alarmSettings.id);
      await NotificationService().cancelAllNotifications();

      final int newSnoozeId = (DateTime.now().millisecondsSinceEpoch ~/ 1000) % 2147483647;
      final snoozeTime = DateTime.now().add(const Duration(minutes: 5));
      final snoozeSettings = widget.alarmSettings.copyWith(
        id: newSnoozeId,
        dateTime: snoozeTime,
      );
      await Alarm.set(alarmSettings: snoozeSettings);
    } catch (e) {
      debugPrint('Error saat menunda alarm: $e');
    } finally {
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayBody = widget.alarmSettings.notificationBody.replaceAll(' [REPEAT]', '');

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFF1E1B4B),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    const SizedBox(height: 30),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.deepPurple.withAlpha(80),
                      ),
                      child: const Icon(
                        Icons.alarm_on_rounded,
                        size: 84,
                        color: Colors.amberAccent,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      widget.alarmSettings.notificationTitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      displayBody,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white70, width: 1.5),
                        minimumSize: const Size.fromHeight(54),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: _isStopping ? null : _snoozeAlarm,
                      child: const Text('Tunda (5 Menit)', style: TextStyle(fontSize: 16)),
                    ),
                    const SizedBox(height: 14),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(54),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: _isStopping ? null : _stopAlarm,
                      child: const Text(
                        'Matikan Alarm',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}