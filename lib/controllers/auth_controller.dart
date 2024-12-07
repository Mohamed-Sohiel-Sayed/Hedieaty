// lib/controllers/auth_controller.dart
import '../services/auth_service.dart';
import '../models/user.dart';

class AuthController {
  final AuthService _authService = AuthService();

  Stream<UserModel?> get userStream => _authService.userStream;

  Future<UserModel?> signIn(String email, String password) {
    return _authService.signIn(email, password);
  }

  Future<UserModel?> signUp(String name, String email, String password, String phoneNum) {
    return _authService.signUp(name, email, password);
  }

  Future<void> signOut() {
    return _authService.signOut();
  }
}