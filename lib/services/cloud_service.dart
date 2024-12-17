import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/gift.dart';

class CloudService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
}