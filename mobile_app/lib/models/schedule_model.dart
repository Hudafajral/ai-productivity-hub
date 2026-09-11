class ScheduleModel {
  final int? id;
  final String userId;
  final String title;
  final String? location;
  final String? description;
  final DateTime datetime;
  final bool isRecurring;
  final String status;

  ScheduleModel({
    this.id,
    required this.userId,
    required this.title,
    this.location,
    this.description,
    required this.datetime,
    required this.isRecurring,
    required this.status,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    return ScheduleModel(
      id: json['id'],
      userId: json['user_id'] ?? json['userId'] ?? '',
      title: json['title'] ?? '',
      // Pastikan membaca key location dan description dari backend
      location: json['location'],
      description: json['description'],
      datetime: DateTime.parse(json['datetime']),
      isRecurring: json['is_recurring'] ?? json['isRecurring'] ?? false,
      status: json['status'] ?? 'active',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'title': title,
      'location': location,
      'description': description,
      'datetime': datetime.toIso8601String(),
      'is_recurring': isRecurring,
      'status': status,
    };
  }
}