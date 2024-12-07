// lib/models/user.dart
class UserModel {
  final String id;
  final String name;
  final String email;
  final String phoneNum;
  //final String profilePictureUrl;
  final List<String> upcomingEvents;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNum,
    //required this.profilePictureUrl,
    required this.upcomingEvents,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phoneNum': phoneNum,
      //'profilePictureUrl': profilePictureUrl,
      'upcomingEvents': upcomingEvents.join(','),
    };
  }
}