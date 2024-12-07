// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<UserModel?> get userStream => _auth.authStateChanges().map((user) {
    if (user == null) return null;
    return UserModel(
      id: user.uid,
      name: user.displayName ?? '',
      email: user.email!,
      phoneNum: user.phoneNumber ?? '',
      //profilePictureUrl: user.photoURL ?? '',
      upcomingEvents: [],
    );
  });

  Future<UserModel?> signIn(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return UserModel(
        id: userCredential.user!.uid,
        name: userCredential.user!.displayName ?? '',
        email: userCredential.user!.email!,
        phoneNum: userCredential.user!.phoneNumber ?? '',
        //profilePictureUrl: userCredential.user!.photoURL ?? '',
        upcomingEvents: [],
      );
    } catch (e) {
      print("Sign-in failed: $e");
      return null;
    }
  }

  Future<UserModel?> signUp(String name, String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await userCredential.user!.updateDisplayName(name);
      return UserModel(
        id: userCredential.user!.uid,
        name: name,
        email: email,
        phoneNum: userCredential.user!.phoneNumber ?? '',
        //profilePictureUrl: userCredential.user!.photoURL ?? '',
        upcomingEvents: [],
      );
    } catch (e) {
      print("Sign-up failed: $e");
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}