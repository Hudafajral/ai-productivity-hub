import 'dart:async';
import 'package:flutter/material.dart';
import 'package:alarm/alarm.dart';
import 'features/schedule/screens/alarm_ring_screen.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';
import 'features/auth/screens/auth_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AuthService().init();
  await NotificationService().init();
  await NotificationService().cancelAllNotifications(); // Bersihkan sisa notifikasi yang nyangkut
  await Alarm.init();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static StreamSubscription<AlarmSettings>? _alarmSubscription;
  static bool _isRingScreenActive = false;

  @override
  void initState() {
    super.initState();

    _alarmSubscription ??= Alarm.ringStream.stream.listen((alarmSettings) async {
      if (_isRingScreenActive) return;
      _isRingScreenActive = true;

      // Buka langsung antarmuka layar alarm saat jam berdering.
      // Notifikasi berbunyi dari notification_service dinonaktifkan di sini
      // agar OS Android tidak membajak audio stream bawaan.
      if (navigatorKey.currentState != null) {
        await navigatorKey.currentState!.push(
          PageRouteBuilder(
            opaque: true,
            pageBuilder: (_, __, ___) => AlarmRingScreen(alarmSettings: alarmSettings),
          ),
        );
      }
      _isRingScreenActive = false;
    });
  }

  @override
  void dispose() {
    _alarmSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'AI Productivity Hub',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const AuthScreen(),
    );
  }
}