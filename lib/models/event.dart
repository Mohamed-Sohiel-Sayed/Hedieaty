import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String id;
  final String name;
  final String date;
  final String location;
  final String description;
  final String userId;

  Event({
    required this.id,
    required this.name,
    required this.date,
    required this.location,
    required this.description,
    required this.userId,
  });

  factory Event.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Event(
      id: doc.id,
      name: data['name'] ?? '',
      date: data['date'] ?? '',
      location: data['location'] ?? '',
      description: data['description'] ?? '',
      userId: data['userId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'date': date,
      'location': location,
      'description': description,
      'userId': userId,
    };
  }

  Event copyWith({
    String? id,
    String? name,
    String? date,
    String? location,
    String? description,
    String? userId,
  }) {
    return Event(
      id: id ?? this.id,
      name: name ?? this.name,
      date: date ?? this.date,
      location: location ?? this.location,
      description: description ?? this.description,
      userId: userId ?? this.userId,
    );
  }

  String getStatus() {
    DateTime eventDate = DateTime.parse(this.date);
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime eventDay = DateTime(eventDate.year, eventDate.month, eventDate.day);

    if (eventDay.isBefore(today)) {
      return 'Past';
    } else if (eventDay.isAfter(today)) {
      return 'Upcoming';
    } else {
      return 'Current';
    }
  }
}