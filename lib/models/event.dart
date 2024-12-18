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
}