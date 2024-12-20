import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'cloud_service.dart';
import '../models/user.dart' as app_user;

class AuthService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final CloudService _cloudService = CloudService();

  /// Signs in a user with email and password.
  Future<firebase_auth.User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      firebase_auth.UserCredential result =
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return result.user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  /// Registers a new user with email, password, name, and mobile number.
  Future<firebase_auth.User?> registerWithEmailAndPassword(
      String email, String password, String name, String mobile) async {
    try {
      firebase_auth.UserCredential result =
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      firebase_auth.User? user = result.user;
      if (user != null) {
        app_user.User newUser = app_user.User(
          id: user.uid,
          name: name,
          email: user.email!,
          mobile: mobile,
          profilePictureUrl: '',
          friends: [],
        );
        await _cloudService.createUserDocument(newUser);
      }
      return user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print(e.toString());
    }
  }

  /// Retrieves the current authenticated Firebase user.
  firebase_auth.User? getCurrentUser() {
    return _auth.currentUser;
  }

  /// Stream of authentication state changes.
  Stream<firebase_auth.User?> get user {
    return _auth.authStateChanges();
  }
}