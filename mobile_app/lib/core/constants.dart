class AppConstants {
  // Alamat IP khusus untuk emulator Android membaca localhost komputer host
  static const String baseUrl = 'http://192.168.1.60:8000';
  
  // Endpoint jadwal
  static const String schedulesEndpoint = '$baseUrl/api/v1/schedules';
}