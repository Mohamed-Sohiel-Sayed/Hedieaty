// lib/views/home/home_page.dart
import 'package:flutter/material.dart';
import '../../controllers/friend_controller.dart';
import '../../models/friend.dart';
import '../gift_list/gift_list_page.dart' as gift_list;
import '../event_list/event_list_page.dart' as event_list;

class HomePage extends StatelessWidget {
  final FriendController _friendController = FriendController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // Implement search functionality
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Friend>>(
        future: _friendController.getFriends(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No friends found.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final friend = snapshot.data![index];
                return ListTile(
                  leading: CircleAvatar(
                    //backgroundImage: NetworkImage(friend.profilePictureUrl),
                  ),
                  title: Text(friend.name),
                  subtitle: Text(friend.upcomingEvents.isNotEmpty
                      ? 'Upcoming Events: ${friend.upcomingEvents.length}'
                      : 'No Upcoming Events'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => gift_list.GiftListPage(eventId: friend.id),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => event_list.EventListPage(eventId: '',)),
          );
        },
        child: Icon(Icons.add),
        tooltip: 'Create Your Own Event/List',
      ),
    );
  }
}