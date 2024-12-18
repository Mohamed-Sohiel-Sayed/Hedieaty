import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

class ProfileController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> updateUser(User user) async {
    await _firestore.collection('users').doc(user.id).update(user.toMap());
  }

  Future<User?> getUser(String userId) async {
    DocumentSnapshot doc = await _firestore.collection('users').doc(userId).get();
    if (doc.exists) {
      return User.fromFirestore(doc);
    } else {
      return null;
    }
  }
}