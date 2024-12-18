import 'package:cloud_firestore/cloud_firestore.dart';

class Gift {
  final String id;
  final String name;
  final String category;
  final String status;
  final String eventId;
  final bool isPledged;

  Gift({
    required this.id,
    required this.name,
    required this.category,
    required this.status,
    required this.eventId,
    required this.isPledged,
  });

  factory Gift.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Gift(
      id: doc.id,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      status: data['status'] ?? '',
      eventId: data['eventId'] ?? '',
      isPledged: data['isPledged'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'status': status,
      'eventId': eventId,
      'isPledged': isPledged,
    };
  }

  Gift copyWith({
    String? id,
    String? name,
    String? category,
    String? status,
    String? eventId,
    bool? isPledged,
  }) {
    return Gift(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      status: status ?? this.status,
      eventId: eventId ?? this.eventId,
      isPledged: isPledged ?? this.isPledged,
    );
  }
}