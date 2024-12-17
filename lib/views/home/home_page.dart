import 'package:flutter/material.dart';
import '../../controllers/home_controller.dart';
import '../../models/user.dart';
import 'widgets/friend_list_item.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomeController _controller = HomeController();
  late Future<List<User>> _friendsFuture;

  @override
  void initState() {
    super.initState();
    _friendsFuture = _controller.getFriends('currentUserId'); // Replace with actual user ID
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
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