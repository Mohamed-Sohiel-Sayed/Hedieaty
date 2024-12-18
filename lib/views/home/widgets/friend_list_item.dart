import 'package:flutter/material.dart';
import '../../../models/user.dart';

class FriendListItem extends StatelessWidget {
  final User friend;
  final String subtitle;
  final VoidCallback onTap;
  FriendListItem({required this.friend, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: friend.profilePictureUrl.isNotEmpty
            ? NetworkImage(friend.profilePictureUrl)
            : AssetImage('assets/placeholder.png') as ImageProvider,
      ),
      title: Text(friend.name),
      subtitle: Text(subtitle),
      trailing: Icon(Icons.arrow_forward),
      onTap: onTap,
    );
  }
}