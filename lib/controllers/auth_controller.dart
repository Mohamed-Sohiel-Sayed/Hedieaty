import '../services/auth_service.dart';

class AuthController {
  final AuthService _authService = AuthService();

  Future<void> signIn(String email, String password) async {
    await _authService.signInWithEmailAndPassword(email, password);
  }

  Future<void> register(String email, String password) async {
    await _authService.registerWithEmailAndPassword(email, password);
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }
}