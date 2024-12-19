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
  final String userId;
  final String? pledgedBy;
  final bool isPublic;

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
    required this.userId,
    this.pledgedBy,
    this.isPublic = false,
  });

  factory Gift.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Gift(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: data['imageUrl'] ?? '',
      status: data['status'] ?? '',
      eventId: data['eventId'] ?? '',
      isPledged: _parseBool(data['isPledged']),
      userId: data['userId'] ?? '',
      pledgedBy: data['pledgedBy'],
      isPublic: _parseBool(data['isPublic']),
    );
  }

  factory Gift.fromMap(Map<String, dynamic> data) {
    return Gift(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: data['imageUrl'] ?? '',
      status: data['status'] ?? '',
      eventId: data['eventId'] ?? '',
      isPledged: _parseBool(data['isPledged']),
      userId: data['userId'] ?? '',
      pledgedBy: data['pledgedBy'],
      isPublic: _parseBool(data['isPublic']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'imageUrl': imageUrl,
      'status': status,
      'eventId': eventId,
      'isPledged': isPledged,
      'userId': userId,
      'pledgedBy': pledgedBy,
      'isPublic': isPublic,
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
    String? userId,
    String? pledgedBy,
    bool? isPublic,
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
      userId: userId ?? this.userId,
      pledgedBy: pledgedBy ?? this.pledgedBy,
      isPublic: isPublic ?? this.isPublic,
    );
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) {
      return value;
    } else if (value is int) {
      return value == 1;
    } else if (value is String) {
      return value.toLowerCase() == 'true';
    } else {
      return false;
    }
  }
}

extension GiftDatabaseMapping on Gift {
  Map<String, dynamic> toMapForDatabase() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'imageUrl': imageUrl,
      'status': status,
      'eventId': eventId,
      'isPledged': isPledged ? 1 : 0, // Convert boolean to integer
      'userId': userId,
      'pledgedBy': pledgedBy,
      'isPublic': isPublic ? 1 : 0, // Convert boolean to integer
    };
  }
}