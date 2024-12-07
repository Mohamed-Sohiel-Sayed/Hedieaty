// lib/controllers/home_controller.dart
import '../models/user.dart';
import '../services/user_service.dart';

class HomeController {
  final UserService _userService = UserService();

  Future<List<UserModel>> getFriends() {
    return _userService.fetchFriends();
  }

  Future<void> addFriend(String phoneNumber) {
    return _userService.addFriendByPhoneNumber(phoneNumber);
  }
}