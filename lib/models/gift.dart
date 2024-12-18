import 'package:cloud_firestore/cloud_firestore.dart';

class Gift {
  final String id;
  final String name;
  final String description;
  final String category;
  final String status;
  final String eventId;
  final bool isPledged;
  final double price;
  final String imageUrl;

  Gift({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.status,
    required this.eventId,
    required this.isPledged,
    required this.price,
    required this.imageUrl,
  });

  factory Gift.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Gift(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      status: data['status'] ?? '',
      eventId: data['eventId'] ?? '',
      isPledged: data['isPledged'] ?? false,
      price: data['price'] ?? 0.0,
      imageUrl: data['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'status': status,
      'eventId': eventId,
      'isPledged': isPledged,
      'price': price,
      'imageUrl': imageUrl,
    };
  }

  Gift copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    String? status,
    String? eventId,
    bool? isPledged,
    double? price,
    String? imageUrl,
  }) {
    return Gift(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      status: status ?? this.status,
      eventId: eventId ?? this.eventId,
      isPledged: isPledged ?? this.isPledged,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}