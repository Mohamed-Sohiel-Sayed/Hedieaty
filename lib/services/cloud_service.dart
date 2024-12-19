import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/gift.dart';
import '../models/user.dart';

class CloudService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Gift-related methods
  Future<void> addGift(Gift gift) async {
    await _firestore.collection('gifts').doc(gift.id).set(gift.toMap());
  }

  Future<void> updateGiftStatus(String giftId, String status) async {
    await _firestore.collection('gifts').doc(giftId).update({'status': status});
  }

  Stream<List<Gift>> getGifts(String eventId) {
    return _firestore.collection('gifts').where('eventId', isEqualTo: eventId).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Gift.fromFirestore(doc)).toList();
    });
  }

  Stream<List<Gift>> getPublicGifts() {
    return _firestore.collection('gifts').where('isPublic', isEqualTo: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Gift.fromFirestore(doc)).toList();
    });
  }

  Future<void> deleteGift(String giftId) async {
    await _firestore.collection('gifts').doc(giftId).delete();
  }

  // User-related methods
  Future<void> createUserDocument(User user) async {
    await _firestore.collection('users').doc(user.id).set(user.toMap());
  }

  Future<User?> getUserDocument(String userId) async {
    DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();
    if (userDoc.exists) {
      return User.fromFirestore(userDoc);
    }
    return null;
  }
}