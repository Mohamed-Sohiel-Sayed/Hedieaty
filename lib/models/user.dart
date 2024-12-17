import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String name;
  final String email;
  final String profilePictureUrl;
  final List<String> preferences;
  final List<String> friends;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.profilePictureUrl,
    required this.preferences,
    required this.friends,
  });

  factory User.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return User(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      profilePictureUrl: data['profilePictureUrl'] ?? '',
      preferences: List<String>.from(data['preferences'] ?? []),
      friends: List<String>.from(data['friends'] ?? []),
    );
  }
}