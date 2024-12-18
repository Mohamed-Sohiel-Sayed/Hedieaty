import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/gift.dart';

class GiftController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addGift(Gift gift) async {
    DocumentReference docRef = _firestore.collection('gifts').doc();
    gift = gift.copyWith(id: docRef.id);
    await docRef.set(gift.toMap());
  }

  Future<void> updateGift(Gift gift) async {
    await _firestore.collection('gifts').doc(gift.id).update(gift.toMap());
  }

  Future<void> deleteGift(String giftId) async {
    await _firestore.collection('gifts').doc(giftId).delete();
  }

  Stream<List<Gift>> getGifts(String eventId) {
    return _firestore.collection('gifts').where('eventId', isEqualTo: eventId).snapshots().map((snapshot) {
      //print('Fetched ${snapshot.docs.length} gifts from Firestore');
      return snapshot.docs.map((doc) {
        //print('Gift data: ${doc.data()}');
        return Gift.fromFirestore(doc);
      }).toList();
    });
  }

  Stream<List<Gift>> getGiftsByUser(String userId) {
    return _firestore.collection('gifts').where('userId', isEqualTo: userId).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Gift.fromFirestore(doc)).toList();
    });
  }

  Stream<List<Gift>> getPledgedGifts(String userId) {
    return _firestore.collection('gifts').where('isPledged', isEqualTo: true).where('userId', isEqualTo: userId).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Gift.fromFirestore(doc)).toList();
    });
  }
}