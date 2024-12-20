import 'package:flutter/material.dart';
import '../../../models/user.dart';
import '../../../shared/widgets/custom_widgets.dart';

class FriendListItem extends StatelessWidget {
  final User friend;
  final String subtitle;
  final VoidCallback onTap;

  FriendListItem({
    required this.friend,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasProfilePicture = friend.profilePictureUrl.isNotEmpty;

    return ListTile(
      leading: CircleAvatar(
        radius: 25,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        backgroundImage: hasProfilePicture
            ? NetworkImage(friend.profilePictureUrl)
            : AssetImage('assets/default_avatar.png') as ImageProvider,
        child: !hasProfilePicture
            ? Icon(
          Icons.person,
          size: 25,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        )
            : null,
      ),
      title: CustomText(
        text: friend.name,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
      subtitle: CustomText(
        text: subtitle,
        fontSize: 14,
        color: Colors.grey[600],
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: Theme.of(context).colorScheme.primary,
        size: 16,
      ),
      onTap: onTap,
    );
  }
}