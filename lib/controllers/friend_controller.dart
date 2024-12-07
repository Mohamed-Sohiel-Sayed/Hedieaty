// lib/controllers/friend_controller.dart
import '../models/friend.dart';
import '../models/user.dart';
import '../services/user_service.dart';

class FriendController {
  final UserService _userService = UserService();

  Future<List<Friend>> getFriends() async {
    List<UserModel> users = await _userService.fetchFriends();
    return users.map((user) => Friend(
      id: user.id,
      name: user.name,
      //profilePictureUrl: user.profilePictureUrl,
      upcomingEvents: [], // Assuming no events for now
    )).toList();
  }

  Future<void> addFriend(String phoneNumber) {
    return _userService.addFriendByPhoneNumber(phoneNumber);
  }
}