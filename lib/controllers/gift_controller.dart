import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/gift.dart';
import '../services/cloud_service.dart';
import '../services/database_service.dart';

class GiftController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CloudService _cloudService = CloudService();
  final DatabaseService _databaseService = DatabaseService();

  // Add Gift
  Future<void> addGift(Gift gift) async {
    // Store the gift locally
    await _databaseService.insertGift(gift);
  }

  // Update Gift
  Future<void> updateGift(Gift gift) async {
    if (gift.isPublic) {
      await _firestore.collection('gifts').doc(gift.id).update(gift.toMap());
    } else {
      await _databaseService.updateGift(gift);
    }
  }

  // Delete Gift
  Future<void> deleteGift(String giftId, bool isPublic, String userId) async {
    if (isPublic) {
      await _firestore.collection('gifts').doc(giftId).delete();
    } else {
      await _databaseService.deleteGift(giftId, userId);
    }
  }

  // Get All Gifts (for Gift List Page)
  Future<List<Gift>> getAllGifts(String userId, String eventId) async {
    // Fetch public gifts from Firestore for the event
    List<Gift> publicGifts = await _firestore
        .collection('gifts')
        .where('eventId', isEqualTo: eventId)
        .where('isPublic', isEqualTo: true)
        .get()
        .then((snapshot) =>
        snapshot.docs.map((doc) => Gift.fromFirestore(doc)).toList());

    // Fetch private gifts from local database
    List<Gift> privateGifts =
    await _databaseService.getPrivateGiftsByEvent(userId, eventId);

    // Combine the lists
    List<Gift> allGifts = [...publicGifts, ...privateGifts];

    return allGifts;
  }

  // Publish Gift
  Future<void> publishGift(Gift gift) async {
    // Remove from local storage
    await _databaseService.deleteGift(gift.id, gift.userId);
    // Update the gift to be public
    Gift updatedGift = gift.copyWith(isPublic: true);
    // Add to Firestore
    await _cloudService.addGift(updatedGift);
  }

  // Get Public Gifts by User ID (For ProfilePage)
  Stream<List<Gift>> getPublicGifts(String userId) {
    return _firestore
        .collection('gifts')
        .where('isPublic', isEqualTo: true)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => Gift.fromFirestore(doc)).toList());
  }

  // Get Private Gifts by User ID (For PledgedGiftsPage)
  Future<List<Gift>> getPrivateGifts(String userId) async {
    return await _databaseService.getPrivateGifts(userId);
  }

  // Get Pledged Gifts (Gifts pledged by the current user)
  Stream<List<Gift>> getPledgedGifts(String userId) {
    return _firestore
        .collection('gifts')
        .where('isPledged', isEqualTo: true)
        .where('pledgedBy', isEqualTo: userId)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => Gift.fromFirestore(doc)).toList());
  }

  // Get Gifts by User (For ProfilePage)
  Stream<List<Gift>> getGiftsByUser(String userId) {
    return _firestore
        .collection('gifts')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => Gift.fromFirestore(doc)).toList());
  }

  // **NEW METHOD:** Pledge Gift
  Future<void> pledgeGift(String giftId, String currentUserId) async {
    DocumentReference giftRef = _firestore.collection('gifts').doc(giftId);

    await _firestore.runTransaction((transaction) async {
      DocumentSnapshot giftSnapshot = await transaction.get(giftRef);

      if (!giftSnapshot.exists) {
        throw Exception("Gift does not exist!");
      }

      Gift gift = Gift.fromFirestore(giftSnapshot);

      if (gift.isPledged) {
        throw Exception("Gift has already been pledged!");
      }

      if (gift.userId == currentUserId) {
        throw Exception("You cannot pledge your own gift!");
      }

      // Update the gift as pledged
      transaction.update(giftRef, {
        'isPledged': true,
        'pledgedBy': currentUserId,
      });
    });
  }
}