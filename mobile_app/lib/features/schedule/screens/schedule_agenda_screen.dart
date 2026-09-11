import 'dart:async';
import 'package:flutter/material.dart';
import 'package:alarm/alarm.dart';
import '../../../models/schedule_model.dart';
import '../../../services/api_service.dart';

class ScheduleAgendaScreen extends StatefulWidget {
  final ValueNotifier<int>? refreshTrigger;

  const ScheduleAgendaScreen({super.key, this.refreshTrigger});

  @override
  State<ScheduleAgendaScreen> createState() => _ScheduleAgendaScreenState();
}

class _ScheduleAgendaScreenState extends State<ScheduleAgendaScreen> {
  final ApiService _apiService = ApiService();
  List<ScheduleModel> _schedules = [];
  List<AlarmSettings> _activeAlarms = [];
  bool _isLoading = true;

  Timer? _autoRefreshTimer;

  final List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
  ];
  final List<String> _days = [
    'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'
  ];

  @override
  void initState() {
    super.initState();
    _fetchSchedules();

    widget.refreshTrigger?.addListener(_fetchSchedules);

    // Refresh berkala memeriksa status jam dan tunda alarm tanpa konflik stream
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      _refreshAlarmsOnly();
    });
  }

  void _refreshAlarmsOnly() {
    if (mounted) {
      setState(() {
        _activeAlarms = Alarm.getAlarms();
      });
    }
  }

  @override
  void dispose() {
    widget.refreshTrigger?.removeListener(_fetchSchedules);
    _autoRefreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchSchedules() async {
    setState(() => _isLoading = true);
    try {
      final schedules = await _apiService.getSchedules('user_1');
      final alarms = Alarm.getAlarms();
      if (!mounted) return;
      setState(() {
        _schedules = schedules;
        _activeAlarms = alarms;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  bool _checkIsAlarmActive(ScheduleModel schedule) {
    if (schedule.isRecurring) return true;

    final hasActiveAlarm = _activeAlarms.any(
      (a) => a.notificationTitle == schedule.title && a.dateTime.isAfter(DateTime.now()),
    );

    if (hasActiveAlarm) return true;
    return !schedule.datetime.isBefore(DateTime.now());
  }

  Future<void> _deleteSchedule(int scheduleId) async {
    try {
      await _apiService.deleteSchedule(scheduleId);
      if (!mounted) return;

      Navigator.pop(context);
      await _fetchSchedules();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Jadwal berhasil dihapus'),
          behavior: SnackBarBehavior.floating, // Mencegah Scaffold mendorong tombol Home ke atas
          margin: const EdgeInsets.only(bottom: 90, left: 16, right: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(bottom: 90, left: 16, right: 16),
        ),
      );
    }
  }

  void _showScheduleDetail(ScheduleModel schedule) {
    final dt = schedule.datetime;
    final dayName = _days[dt.weekday - 1];
    final dateFormatted = '$dayName, ${dt.day} ${_months[dt.month - 1]} ${dt.year}';
    final timeFormatted =
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

    final hasLocation = schedule.location != null && schedule.location!.trim().isNotEmpty;
    final hasDescription = schedule.description != null && schedule.description!.trim().isNotEmpty;
    final bool isAlarmActive = _checkIsAlarmActive(schedule);

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          clipBehavior: Clip.antiAlias,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: double.infinity),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.black54),
                        onPressed: () => Navigator.pop(context),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        onPressed: () {
                          if (schedule.id != null) {
                            _deleteSchedule(schedule.id!);
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 14,
                        height: 14,
                        margin: const EdgeInsets.only(top: 6, right: 14),
                        decoration: BoxDecoration(
                          color: isAlarmActive ? Colors.deepPurple : Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              schedule.title,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: isAlarmActive ? Colors.black87 : Colors.grey.shade500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '$dateFormatted\n$timeFormatted WIB',
                              style: TextStyle(fontSize: 14, color: Colors.grey.shade700, height: 1.4),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(height: 1),
                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.location_on_outlined, size: 22, color: Colors.deepPurple.shade300),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          hasLocation ? schedule.location! : 'Tidak ada lokasi',
                          style: TextStyle(
                            fontSize: 15,
                            color: hasLocation ? Colors.black87 : Colors.grey.shade400,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.notes, size: 22, color: Colors.deepPurple.shade300),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Text(
                            hasDescription ? schedule.description! : 'Tidak ada deskripsi kegiatan',
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.4,
                              color: hasDescription ? Colors.black87 : Colors.grey.shade400,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Icon(
                        schedule.isRecurring
                            ? Icons.repeat_rounded
                            : (isAlarmActive ? Icons.alarm_rounded : Icons.alarm_off_rounded),
                        size: 22,
                        color: isAlarmActive ? Colors.deepPurple.shade300 : Colors.grey.shade400,
                      ),
                      const SizedBox(width: 14),
                      Text(
                        schedule.isRecurring
                            ? 'Berulang rutin (Setiap hari)'
                            : (isAlarmActive ? 'Alarm aktif' : 'Alarm sudah lewat (Nonaktif)'),
                        style: TextStyle(
                          fontSize: 14,
                          color: isAlarmActive ? Colors.black87 : Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Icon(Icons.person_outline, size: 22, color: Colors.deepPurple.shade300),
                      const SizedBox(width: 14),
                      Text(
                        '${schedule.userId} (Pribadi)',
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _schedules.isEmpty
              ? Center(
                  child: RefreshIndicator(
                    onRefresh: _fetchSchedules,
                    child: ListView(
                      children: const [
                        SizedBox(height: 200),
                        Center(
                          child: Text(
                            'Belum ada jadwal yang ditambahkan.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchSchedules,
                  child: ListView.separated(
                    padding: const EdgeInsets.only(top: 8, bottom: 90),
                    itemCount: _schedules.length,
                    separatorBuilder: (context, index) => const Divider(height: 1, indent: 64),
                    itemBuilder: (context, index) {
                      final schedule = _schedules[index];
                      final dt = schedule.datetime;
                      final timeFormatted =
                          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
                      final dateFormatted = '${dt.day} ${_months[dt.month - 1]} ${dt.year}';

                      final hasLocation =
                          schedule.location != null && schedule.location!.trim().isNotEmpty;
                      final hasDescription =
                          schedule.description != null && schedule.description!.trim().isNotEmpty;

                      final bool isAlarmActive = _checkIsAlarmActive(schedule);

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                        leading: Container(
                          width: 4,
                          height: 48,
                          decoration: BoxDecoration(
                            color: isAlarmActive ? Colors.deepPurple : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        title: Text(
                          schedule.title,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: isAlarmActive ? Colors.black87 : Colors.grey.shade500,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$dateFormatted • $timeFormatted WIB',
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                              ),
                              if (hasLocation) ...[
                                const SizedBox(height: 3),
                                Row(
                                  children: [
                                    Icon(Icons.location_on_outlined, size: 14, color: Colors.grey.shade500),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        schedule.location!,
                                        style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              if (hasDescription) ...[
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Icon(Icons.notes, size: 14, color: Colors.grey.shade500),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        schedule.description!,
                                        style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (schedule.isRecurring) ...[
                              const Icon(
                                Icons.repeat_rounded,
                                size: 18,
                                color: Colors.deepPurpleAccent,
                              ),
                              const SizedBox(width: 8),
                            ],
                            Icon(
                              isAlarmActive ? Icons.alarm_rounded : Icons.alarm_off_rounded,
                              size: 20,
                              color: isAlarmActive ? Colors.deepPurpleAccent : Colors.grey.shade400,
                            ),
                          ],
                        ),
                        onTap: () => _showScheduleDetail(schedule),
                      );
                    },
                  ),
                ),
    );
  }
}