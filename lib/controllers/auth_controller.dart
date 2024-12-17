import 'package:firebase_auth/firebase_auth.dart';

class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Sign-In Method
  Future<String> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      print('User signed in: $email');
      return 'Success';
    } on FirebaseAuthException catch (e) {
      print('Sign-In Error: ${e.message}');
      return e.message ?? 'Sign-In Failed';
    }
  }

  // Sign-Up Method
  Future<String> signUp(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      print('User signed up: $email');
      return 'Success';
    } on FirebaseAuthException catch (e) {
      print('Sign-Up Error: ${e.message}');
      return e.message ?? 'Sign-Up Failed';
    }
  }

  // Sign-Out Method
  Future<void> signOut() async {
    await _auth.signOut();
    print('User signed out');
  }
}
