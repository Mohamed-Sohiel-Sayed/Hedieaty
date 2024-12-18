import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../controllers/home_controller.dart';
import '../../models/user.dart';
import '../../routes.dart';
import '../../services/auth_service.dart';
import 'widgets/friend_list_item.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomeController _controller = HomeController();
  final AuthService _authService = AuthService();
  late Future<List<User>> _friendsFuture;

  @override
  void initState() {
    super.initState();
    firebase_auth.User? currentUser = _authService.getCurrentUser();
    if (currentUser != null) {
      _friendsFuture = _controller.getFriends(currentUser.uid);
    } else {
      // Handle the case where the user is not signed in
      _friendsFuture = Future.error('User not signed in');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await _authService.signOut();
              Navigator.of(context).pushReplacementNamed(AppRoutes.signIn);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                // Navigate to create event/list page
              },
              child: Text('Create Your Own Event/List'),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<User>>(
              future: _friendsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No friends found'));
                } else {
                  List<User> friends = snapshot.data!;
                  return ListView.builder(
                    itemCount: friends.length,
                    itemBuilder: (context, index) {
                      return FriendListItem(friend: friends[index]);
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}