import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class User {
  final String id;
  final String name;
  final String email;
  final String profilePictureUrl;
  final String mobile;
  final List<String> friends; // List of friend user IDs

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.profilePictureUrl,
    required this.mobile,
    required this.friends,
  });

  /// Creates a [User] instance from a Firestore [DocumentSnapshot].
  factory User.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return User(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      profilePictureUrl: data['profilePictureUrl'] ?? '',
      mobile: data['mobile'] ?? '',
      friends: List<String>.from(data['friends'] ?? []),
    );
  }

  /// Converts the [User] instance to a map suitable for Firestore operations.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profilePictureUrl': profilePictureUrl,
      'mobile': mobile,
      'friends': friends,
    };
  }

  /// Creates a copy of the current [User] with optional new values.
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? profilePictureUrl,
    String? mobile,
    List<String>? friends,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      mobile: mobile ?? this.mobile,
      friends: friends ?? this.friends,
    );
  }

  @override
  String toString() {
    return 'User{id: $id, name: $name, email: $email, mobile: $mobile, friends: $friends}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is User &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              name == other.name &&
              email == other.email &&
              mobile == other.mobile &&
              listEquals(friends, other.friends);

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      email.hashCode ^
      mobile.hashCode ^
      friends.hashCode;
}