import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/schedule_model.dart';
class ApiService {
  // PENTING: 
  // - Jika kamu mengetes (debug) menggunakan Emulator Android di PC, gunakan 'http://10.0.2.2:8000/api/v1'
  // - Jika kamu mengetes langsung dengan men-deploy ke Samsung Tab milikmu, ganti dengan IP lokal PC kamu (misal: 'http://192.168.1.10:8000/api/v1')
  static const String baseUrl = 'http://192.168.1.60:8000/api/v1' ;

  Future<List<ScheduleModel>> getSchedules(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl/schedules/$userId'));
    
    if (response.statusCode == 200) {
      Iterable list = json.decode(response.body);
      return List<ScheduleModel>.from(list.map((model) => ScheduleModel.fromJson(model)));
    } else {
      throw Exception('Gagal memuat jadwal dari server');
    }
  }

  Future<ScheduleModel> createSchedule(ScheduleModel schedule) async {
    final response = await http.post(
      Uri.parse('$baseUrl/schedules/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(schedule.toJson()),
    );
    
    // FastAPI mengembalikan 200 atau 201 Created
    if (response.statusCode == 200 || response.statusCode == 201) {
      return ScheduleModel.fromJson(json.decode(response.body));
    } else {
      // Cetak pesan error dari backend ke debug console
      print('Status Code Error: ${response.statusCode}');
      print('Respon Server: ${response.body}');
      throw Exception('Gagal menyimpan jadwal: ${response.body}');
    }
  }
  Future<void> deleteSchedule(int scheduleId) async {
  final response = await http.delete(
    Uri.parse('$baseUrl/schedules/$scheduleId'),
  );
  if (response.statusCode != 200) {
    throw Exception('Gagal menghapus jadwal');
  }
}
}