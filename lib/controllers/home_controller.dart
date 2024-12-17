import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

class HomeController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<User>> getFriends(String userId) async {
    DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();

    if (!userDoc.exists) {
      throw Exception('User document does not exist');
    }

    List<dynamic> friendsIds = userDoc['friends'] ?? [];

    List<User> friends = [];
    for (String friendId in friendsIds) {
      DocumentSnapshot friendDoc = await _firestore.collection('users').doc(friendId).get();
      if (friendDoc.exists) {
        friends.add(User.fromFirestore(friendDoc));
      }
    }
    return friends;
  }
}