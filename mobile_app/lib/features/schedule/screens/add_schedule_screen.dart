import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:file_picker/file_picker.dart';
import 'package:alarm/alarm.dart';
import 'package:path_provider/path_provider.dart';
import '../../../models/schedule_model.dart';
import '../../../services/notification_service.dart';
import '../../../services/api_service.dart';

class AddScheduleScreen extends StatefulWidget {
  const AddScheduleScreen({super.key});

  @override
  State<AddScheduleScreen> createState() => _AddScheduleScreenState();
}

class _AddScheduleScreenState extends State<AddScheduleScreen> {
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _noteController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  bool _useAlarm = true;
  bool _isRepeat = false;

  // Pilihan Nada Alarm
  String _selectedTone = 'beep';
  String? _customAudioPath;
  String? _customAudioName;
  bool _isLoading = false;

  final Map<String, String> _presetTones = {
    'beep': 'Digital Alarm Beep',
    'morning': 'Gentle Morning Alarm',
    'custom': 'Pilih Audio dari File HP...',
  };

  final NotificationService _notificationService = NotificationService();

  // Konversi aset Flutter menjadi file lokal nyata agar dibaca bersih oleh native MediaPlayer
  Future<String> _getRealLocalPath(String assetPath) async {
    final byteData = await rootBundle.load(assetPath);
    final tempDir = await getTemporaryDirectory();
    final fileName = assetPath.split('/').last;
    final file = File('${tempDir.path}/$fileName');
    await file.writeAsBytes(byteData.buffer.asUint8List(), flush: true);
    return file.path;
  }

  Future<void> _pickAudioFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _customAudioPath = result.files.single.path;
          _customAudioName = result.files.single.name;
          _selectedTone = 'custom';
        });
      }
    } catch (e) {
      debugPrint("Gagal memilih file audio: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membuka file picker: $e')),
        );
      }
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _saveSchedule() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Judul agenda tidak boleh kosong')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final finalDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final tempId = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    String notificationBody =
        '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')} WIB';
    if (_locationController.text.trim().isNotEmpty) {
      notificationBody += ' • ${_locationController.text.trim()}';
    }

    try {
      // 1. Simpan ke database via ApiService
      try {
        final newSchedule = ScheduleModel(
          userId: 'user_1',
          title: title,
          location: _locationController.text.trim().isNotEmpty
              ? _locationController.text.trim()
              : null,
          description: _noteController.text.trim().isNotEmpty
              ? _noteController.text.trim()
              : null,
          datetime: finalDateTime,
          isRecurring: _isRepeat,
          status: 'pending',
        );
        await ApiService().createSchedule(newSchedule);
      } catch (e) {
        debugPrint("Catatan: Simpan API backend dilewati/gagal ($e)");
      }

      // 2. Tentukan Path Audio (menghasilkan path lokal absolut untuk menghindari fallback Samsung)
      String finalAudioPath = '';
      if (_selectedTone == 'custom' && _customAudioPath != null) {
        finalAudioPath = _customAudioPath!;
      } else {
        String assetSource = 'assets/audio/beep_alarm.mp3';
        if (_selectedTone == 'morning') {
          assetSource = 'assets/audio/morning_alarm.mp3';
        }
        finalAudioPath = await _getRealLocalPath(assetSource);
      }

      // 3. Setel Alarm Jam atau Notifikasi Biasa
      if (_useAlarm) {
        final alarmSettings = AlarmSettings(
          id: tempId % 2147483647,
          dateTime: finalDateTime,
          assetAudioPath: finalAudioPath,
          loopAudio: true,
          vibrate: true,
          volume: 1.0,
          fadeDuration: 0.0,
          notificationTitle: '',
          notificationBody: _isRepeat ? '[REPEAT]' : '',
          enableNotificationOnKill: false,
        );

        await Alarm.set(alarmSettings: alarmSettings);
      } else {
        await _notificationService.scheduleNotification(
          id: tempId,
          title: title,
          body: notificationBody,
          scheduledDate: finalDateTime,
          isAlarm: false,
        );
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan jadwal: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: FilledButton(
              onPressed: _isLoading ? null : _saveSchedule,
              child: _isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Simpan'),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        children: [
          TextField(
            controller: _titleController,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            decoration: const InputDecoration(
              hintText: 'Judul Agenda',
              border: InputBorder.none,
            ),
          ),
          const Divider(height: 32),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.access_time_rounded),
            title: Text(
              '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')} WIB',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              await _pickDate();
              await _pickTime();
            },
          ),
          const Divider(height: 24),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            secondary: const Icon(Icons.alarm_rounded),
            title: const Text('Gunakan Nada Alarm Jam'),
            value: _useAlarm,
            onChanged: (val) => setState(() => _useAlarm = val),
          ),

          // Pilihan Nada dan Custom File
          if (_useAlarm) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pilih Nada Alarm',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedTone,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    items: _presetTones.entries.map((entry) {
                      return DropdownMenuItem<String>(
                        value: entry.key,
                        child: Text(entry.value, style: const TextStyle(fontSize: 14)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedTone = val;
                        });
                        if (val == 'custom') {
                          _pickAudioFile();
                        }
                      }
                    },
                  ),
                  if (_selectedTone == 'custom') ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: _pickAudioFile,
                          icon: const Icon(Icons.folder_open_rounded, size: 18),
                          label: const Text('Ganti File Audio'),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _customAudioName ?? 'Belum ada file dipilih',
                            style: TextStyle(
                              fontSize: 13,
                              color: _customAudioName != null
                                  ? Colors.deepPurple
                                  : Colors.grey.shade600,
                              fontWeight: _customAudioName != null
                                  ? FontWeight.w500
                                  : FontWeight.normal,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),
          TextField(
            controller: _locationController,
            decoration: const InputDecoration(
              icon: Icon(Icons.location_on_outlined),
              hintText: 'Lokasi (opsional)',
              border: InputBorder.none,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _noteController,
            decoration: const InputDecoration(
              icon: Icon(Icons.notes_rounded),
              hintText: 'Catatan tambahan...',
              border: InputBorder.none,
            ),
          ),
          const Divider(height: 24),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            secondary: const Icon(Icons.repeat_rounded),
            title: const Text('Ulangi agenda ini'),
            subtitle: const Text('Alarm akan terus aktif setiap hari di jam yang sama'),
            value: _isRepeat,
            onChanged: (val) => setState(() => _isRepeat = val),
          ),
        ],
      ),
    );
  }
}