// lib/services/user_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'api_service.dart';
import 'database_service.dart';
import 'cloud_service.dart';
import '../models/user.dart';

class UserService {
  final ApiService _apiService = ApiService();
  //final DatabaseService _databaseService = DatabaseService();
  final CloudService _cloudService = CloudService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<UserModel>> fetchFriends() async {
    final friends = await _apiService.getFriends();
    //await _databaseService.saveFriends(friends);
    return friends;
  }

  Future<void> addFriendByPhoneNumber(String phoneNumber) async {
    await _apiService.addFriend(phoneNumber);
  }

  Future<void> syncGiftLists() async {
    _firestore.collection('giftLists').snapshots().listen((snapshot) {
      // Handle real-time updates
    });
  }

  Future<void> updateGiftStatus(String giftId, String status) async {
    await _firestore.collection('gifts').doc(giftId).update({'status': status});
  }
}