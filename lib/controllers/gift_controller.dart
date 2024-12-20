import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import '../models/gift.dart';
import '../models/user.dart'; // Ensure the User model is imported
import '../services/cloud_service.dart';
import '../services/database_service.dart';
import '../services/auth_service.dart';

class GiftController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CloudService _cloudService = CloudService();
  final DatabaseService _databaseService = DatabaseService();
  final AuthService _authService = AuthService();

  // Add Gift
  Future<void> addGift(Gift gift) async {
    // Store the gift locally
    await _databaseService.insertGift(gift);
    // add to Firestore if it's public:
    if (gift.isPublic) {
      await _cloudService.addGift(gift);
    }
  }

  Future<void> updateGift(Gift gift) async {
    if (gift.isPublic) {
      await _firestore.collection('gifts').doc(gift.id).update(gift.toMap());
    } else {
      await _databaseService.updateGift(gift);
    }
  }

  Future<void> deleteGift(String giftId, bool isPublic, String userId) async {
    if (isPublic) {
      await _firestore.collection('gifts').doc(giftId).delete();
    } else {
      await _databaseService.deleteGift(giftId, userId);
    }
  }

  // Get All Gifts (for Gift List Page) as Future
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

  // Get All Gifts as Stream for Real-Time Updates
  Stream<List<Gift>> getAllGiftsStream(String userId, String eventId) {
    // Stream for public gifts
    Stream<List<Gift>> publicGiftsStream = _firestore
        .collection('gifts')
        .where('eventId', isEqualTo: eventId)
        .where('isPublic', isEqualTo: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => Gift.fromFirestore(doc)).toList());

    // Stream for private gifts from local database
    Stream<List<Gift>> privateGiftsStream =
    _databaseService.getPrivateGiftsStream(userId, eventId);

    // Combine both streams
    return CombineLatestStream.combine2<List<Gift>, List<Gift>, List<Gift>>(
      publicGiftsStream,
      privateGiftsStream,
          (publicGifts, privateGifts) => [...publicGifts, ...privateGifts],
    );
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
  Future<List<Gift>> getPrivateGifts(String userId, String eventId) async {
    return await _databaseService.getPrivateGiftsByEvent(userId, eventId);
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

  // Pledge Gift with Friendship Verification
  Future<void> pledgeGift(String giftId) async {
    String? currentUserId = _authService.getCurrentUser()?.uid;
    if (currentUserId == null) {
      throw Exception("User not authenticated!");
    }

    DocumentReference giftRef = _firestore.collection('gifts').doc(giftId);

    // Fetch current user's data
    User? currentUser = await fetchUser(currentUserId);
    if (currentUser == null) {
      throw Exception("User data not found!");
    }

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

      // Check if the gift's owner is a friend
      if (!currentUser.friends.contains(gift.userId)) {
        throw Exception("You can only pledge gifts from your friends!");
      }

      // Update the gift as pledged
      transaction.update(giftRef, {
        'isPledged': true,
        'pledgedBy': currentUserId,
      });
    });
  }

  // Fetches a user by their ID
  Future<User?> fetchUser(String userId) async {
    try {
      DocumentSnapshot userSnapshot =
      await _firestore.collection('users').doc(userId).get();
      if (userSnapshot.exists) {
        return User.fromFirestore(userSnapshot);
      }
      return null;
    } catch (e) {
      print('Error fetching user: $e');
      return null;
    }
  }
}