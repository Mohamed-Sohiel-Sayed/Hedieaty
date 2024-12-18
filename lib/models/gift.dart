import 'package:cloud_firestore/cloud_firestore.dart';

class Gift {
  final String id;
  final String name;
  final String description;
  final String category;
  final double price;
  final String imageUrl;
  final String status;
  final String eventId;
  final bool isPledged;
  final String userId; // Add this property

  Gift({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.imageUrl,
    required this.status,
    required this.eventId,
    required this.isPledged,
    required this.userId, // Add this property
  });

  // Add this property to the fromFirestore method
  factory Gift.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Gift(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      price: data['price']?.toDouble() ?? 0.0,
      imageUrl: data['imageUrl'] ?? '',
      status: data['status'] ?? '',
      eventId: data['eventId'] ?? '',
      isPledged: data['isPledged'] ?? false,
      userId: data['userId'] ?? '', // Add this property
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'imageUrl': imageUrl,
      'status': status,
      'eventId': eventId,
      'isPledged': isPledged,
      'userId': userId, // Add this property
    };
  }

  Gift copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    double? price,
    String? imageUrl,
    String? status,
    String? eventId,
    bool? isPledged,
    String? userId, // Add this property
  }) {
    return Gift(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      status: status ?? this.status,
      eventId: eventId ?? this.eventId,
      isPledged: isPledged ?? this.isPledged,
      userId: userId ?? this.userId, // Add this property
    );
  }
}