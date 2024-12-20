import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/user.dart' as app_user;
import 'package:firebase_auth/firebase_auth.dart' as auth;

class HomeController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetches the list of friends for the given user ID.
  Future<List<app_user.User>> getFriends(String userId) async {
    DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();

    if (!userDoc.exists) {
      throw Exception('User document does not exist');
    }

    List<String> friendsIds = List<String>.from(userDoc['friends'] ?? []);

    List<app_user.User> friends = [];
    for (String friendId in friendsIds) {
      DocumentSnapshot friendDoc = await _firestore.collection('users').doc(friendId).get();
      if (friendDoc.exists) {
        friends.add(app_user.User.fromFirestore(friendDoc));
      }
    }
    return friends;
  }

  /// Fetches device contacts after requesting necessary permissions.
  Future<List<Contact>> getDeviceContacts() async {
    PermissionStatus permissionStatus = await _getContactPermission();
    if (permissionStatus.isGranted) {
      return await FlutterContacts.getContacts(withProperties: true);
    } else {
      throw Exception('Contacts permission denied');
    }
  }

  /// Requests and checks contacts permission.
  Future<PermissionStatus> _getContactPermission() async {
    PermissionStatus status = await Permission.contacts.status;
    if (status.isGranted) {
      return status;
    } else {
      status = await Permission.contacts.request();
      return status;
    }
  }

  /// Adds a friend by their mobile number.
  /// If the user does not exist, does NOT create a new user and returns false.
  Future<bool> addFriendByMobile(String currentUserId, String mobile) async {
    try {
      // Sanitize mobile number (e.g., remove spaces, dashes)
      String sanitizedMobile = mobile.replaceAll(RegExp(r'\D'), '');

      // Search user by mobile number
      QuerySnapshot userSnapshot = await _firestore
          .collection('users')
          .where('mobile', isEqualTo: sanitizedMobile)
          .limit(1)
          .get();

      // --- CHANGED LOGIC: Return false if no user found ---
      if (userSnapshot.docs.isEmpty) {
        // User does not exist in the system
        return false;
      } else {
        // A user with that mobile exists
        String friendId = userSnapshot.docs.first.id;

        if (friendId == currentUserId) {
          // Prevent adding oneself as a friend
          return false;
        }

        // Check if already friends
        DocumentSnapshot currentUserDoc =
        await _firestore.collection('users').doc(currentUserId).get();
        List<String> currentFriends = List<String>.from(currentUserDoc['friends'] ?? []);
        if (currentFriends.contains(friendId)) {
          return false; // Already friends
        }

        // Add friend to current user's friends list
        await _firestore.collection('users').doc(currentUserId).update({
          'friends': FieldValue.arrayUnion([friendId]),
        });

        // Optionally, add current user to friend's friends list
        await _firestore.collection('users').doc(friendId).update({
          'friends': FieldValue.arrayUnion([currentUserId]),
        });

        return true;
      }
    } catch (e) {
      throw e;
    }
  }

  /// Searches for friends by their name.
  Future<List<app_user.User>> searchFriendsByName(String query, String currentUserId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: query + '\uf8ff')
          .limit(10)
          .get();

      List<app_user.User> searchResults = [];
      for (var doc in snapshot.docs) {
        if (doc.id != currentUserId) {
          // Exclude self
          searchResults.add(app_user.User.fromFirestore(doc));
        }
      }
      return searchResults;
    } catch (e) {
      throw e;
    }
  }

  /// Retrieves your application's User model for the current authenticated user.
  Future<app_user.User?> getCurrentUser() async {
    auth.User? firebaseUser = auth.FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) {
      return null;
    }

    DocumentSnapshot userDoc = await _firestore.collection('users').doc(firebaseUser.uid).get();

    if (!userDoc.exists) {
      return null;
    }

    return app_user.User.fromFirestore(userDoc);
  }
}