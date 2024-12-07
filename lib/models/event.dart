// lib/models/event.dart
class EventModel {
  final String id;
  final String name;
  final DateTime date;
  final String location;
  final String description;
  final String userId;

  EventModel({
    required this.id,
    required this.name,
    required this.date,
    required this.location,
    required this.description,
    required this.userId,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'],
      name: json['name'],
      date: DateTime.parse(json['date']),
      location: json['location'],
      description: json['description'],
      userId: json['userId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'date': date.toIso8601String(),
      'location': location,
      'description': description,
      'userId': userId,
    };
  }
}