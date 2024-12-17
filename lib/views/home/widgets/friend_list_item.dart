import 'package:flutter/material.dart';
import '../../../models/user.dart';

class FriendListItem extends StatelessWidget {
  final User friend;

  FriendListItem({required this.friend});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(friend.profilePictureUrl),
      ),
      title: Text(friend.name),
      subtitle: Text('Upcoming Events: ${friend.preferences.length}'), // Replace with actual logic
      trailing: Icon(Icons.arrow_forward),
      onTap: () {
        // Navigate to friend's gift lists
      },
    );
  }
}